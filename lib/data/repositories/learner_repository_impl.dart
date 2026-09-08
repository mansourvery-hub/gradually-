/// Drift implementation of [LearnerRepository] (ARCHITECTURE.md §2, §4).
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../core/progress.dart';
import '../../core/vocab.dart';
import '../../learner/known.dart';
import '../../learner/learner_repository.dart';
import '../../learner/learner_state.dart';
import '../database.dart';

/// Concrete implementation of [LearnerRepository] using Drift SQLite.
final class DriftLearnerRepository implements LearnerRepository {
  DriftLearnerRepository(this._db);

  final AppDatabase _db;

  @override
  Future<LearnerState> getLearnerState() async {
    final exposureRows = await _db.select(_db.exposures).get();
    final progressRows = await _db.select(_db.contentProgresses).get();
    final evidenceRows = await _db.select(_db.masteryEvidences).get();

    return _buildLearnerState(
      exposureRows: exposureRows,
      progressRows: progressRows,
      evidenceRows: evidenceRows,
    );
  }

  @override
  Stream<LearnerState> watchLearnerState() {
    // Combine table change streams into a single LearnerState stream.
    final exposuresStream = _db.select(_db.exposures).watch();
    final progressStream = _db.select(_db.contentProgresses).watch();
    final evidenceStream = _db.select(_db.masteryEvidences).watch();

    return Stream.multi((controller) {
      List<ExposureRow>? latestExposures;
      List<ContentProgressRow>? latestProgress;
      List<MasteryEvidenceRow>? latestEvidence;

      void emitIfReady() {
        if (latestExposures != null &&
            latestProgress != null &&
            latestEvidence != null) {
          controller.add(
            _buildLearnerState(
              exposureRows: latestExposures!,
              progressRows: latestProgress!,
              evidenceRows: latestEvidence!,
            ),
          );
        }
      }

      final sub1 = exposuresStream.listen((data) {
        latestExposures = data;
        emitIfReady();
      });

      final sub2 = progressStream.listen((data) {
        latestProgress = data;
        emitIfReady();
      });

      final sub3 = evidenceStream.listen((data) {
        latestEvidence = data;
        emitIfReady();
      });

      controller.onCancel = () {
        sub1.cancel();
        sub2.cancel();
        sub3.cancel();
      };
    });
  }

  @override
  Future<void> recordExposure(
    VocabId vocabId,
    ContentId contentId, {
    DateTime? at,
  }) async {
    final now = at ?? DateTime.now();

    await _db.transaction(() async {
      final existing = await (_db.select(
        _db.exposures,
      )..where((t) => t.vocabId.equals(vocabId))).getSingleOrNull();

      if (existing == null) {
        await _db
            .into(_db.exposures)
            .insert(
              ExposuresCompanion.insert(
                vocabId: vocabId,
                encounterCount: const Value(1),
                contentItemIdsJson: jsonEncode([contentId]),
                firstSeen: now,
                lastSeen: now,
              ),
            );
      } else {
        final List<dynamic> rawList =
            jsonDecode(existing.contentItemIdsJson) as List<dynamic>;
        final Set<String> contentSet = rawList.cast<String>().toSet()
          ..add(contentId);

        await (_db.update(
          _db.exposures,
        )..where((t) => t.vocabId.equals(vocabId))).write(
          ExposuresCompanion(
            encounterCount: Value(existing.encounterCount + 1),
            contentItemIdsJson: Value(jsonEncode(contentSet.toList())),
            lastSeen: Value(now),
          ),
        );
      }
    });
  }

  @override
  Future<void> recordBatchExposure(
    List<VocabId> vocabIds,
    ContentId contentId, {
    DateTime? at,
  }) async {
    final now = at ?? DateTime.now();
    await _db.transaction(() async {
      for (final vocabId in vocabIds) {
        final existing = await (_db.select(
          _db.exposures,
        )..where((t) => t.vocabId.equals(vocabId))).getSingleOrNull();

        if (existing == null) {
          await _db
              .into(_db.exposures)
              .insert(
                ExposuresCompanion.insert(
                  vocabId: vocabId,
                  encounterCount: const Value(1),
                  contentItemIdsJson: jsonEncode([contentId]),
                  firstSeen: now,
                  lastSeen: now,
                ),
              );
        } else {
          final List<dynamic> rawList =
              jsonDecode(existing.contentItemIdsJson) as List<dynamic>;
          final Set<String> contentSet = rawList.cast<String>().toSet()
            ..add(contentId);

          await (_db.update(
            _db.exposures,
          )..where((t) => t.vocabId.equals(vocabId))).write(
            ExposuresCompanion(
              encounterCount: Value(existing.encounterCount + 1),
              contentItemIdsJson: Value(jsonEncode(contentSet.toList())),
              lastSeen: Value(now),
            ),
          );
        }
      }
    });
  }

  @override
  Future<void> recordMasteryEvidence(MasteryEvidence evidence) async {
    await _db
        .into(_db.masteryEvidences)
        .insert(
          MasteryEvidencesCompanion.insert(
            vocabId: evidence.vocabId,
            kind: evidence.kind.name,
            grade: evidence.grade.name,
            at: evidence.at,
          ),
        );
  }

  @override
  Future<void> updateContentProgress(ContentProgress progress) async {
    await _db
        .into(_db.contentProgresses)
        .insertOnConflictUpdate(
          ContentProgressesCompanion.insert(
            contentId: progress.contentId,
            lastPosition: Value(progress.lastPosition),
            completionCount: Value(progress.completionCount),
            rereadCount: Value(progress.rereadCount),
            firstRead: progress.firstRead,
            lastRead: progress.lastRead,
          ),
        );
  }

  @override
  Future<ContentProgress?> getContentProgress(ContentId contentId) async {
    final row = await (_db.select(
      _db.contentProgresses,
    )..where((t) => t.contentId.equals(contentId))).getSingleOrNull();

    if (row == null) return null;

    return ContentProgress(
      contentId: row.contentId,
      lastPosition: row.lastPosition,
      completionCount: row.completionCount,
      rereadCount: row.rereadCount,
      firstRead: row.firstRead,
      lastRead: row.lastRead,
    );
  }

  LearnerState _buildLearnerState({
    required List<ExposureRow> exposureRows,
    required List<ContentProgressRow> progressRows,
    required List<MasteryEvidenceRow> evidenceRows,
  }) {
    // 1. Build ExposureAggregate map
    final exposureMap = <VocabId, ExposureAggregate>{};
    for (final row in exposureRows) {
      final List<dynamic> rawList =
          jsonDecode(row.contentItemIdsJson) as List<dynamic>;
      final contentSet = rawList.cast<ContentId>().toSet();

      exposureMap[row.vocabId] = ExposureAggregate(
        vocabId: row.vocabId,
        encounterCount: row.encounterCount,
        contentItemIds: contentSet,
        firstSeen: row.firstSeen,
        lastSeen: row.lastSeen,
      );
    }

    // 2. Build ContentProgress map
    final progressMap = <ContentId, ContentProgress>{};
    for (final row in progressRows) {
      progressMap[row.contentId] = ContentProgress(
        contentId: row.contentId,
        lastPosition: row.lastPosition,
        completionCount: row.completionCount,
        rereadCount: row.rereadCount,
        firstRead: row.firstRead,
        lastRead: row.lastRead,
      );
    }

    // 3. Group mastery evidence by vocabId
    final evidenceByVocab = <VocabId, List<MasteryEvidence>>{};
    final allEvidence = <MasteryEvidence>[];

    for (final row in evidenceRows) {
      final kind = MasteryEvidenceKind.values.firstWhere(
        (e) => e.name == row.kind,
        orElse: () => MasteryEvidenceKind.meaning,
      );
      final grade = RecallGrade.values.firstWhere(
        (e) => e.name == row.grade,
        orElse: () => RecallGrade.forgotten,
      );

      final evidence = MasteryEvidence(
        vocabId: row.vocabId,
        kind: kind,
        grade: grade,
        at: row.at,
      );

      evidenceByVocab.putIfAbsent(row.vocabId, () => []).add(evidence);
      allEvidence.add(evidence);
    }

    // 4. Compute known vocabulary using the single "known" rule in known.dart
    final knownVocabulary = <VocabId>{};
    final knownVocabItems = <VocabularyItem>{};

    for (final entry in evidenceByVocab.entries) {
      if (computeIsVocabularyKnown(entry.value)) {
        knownVocabulary.add(entry.key);
        knownVocabItems.add(
          VocabularyItem(
            id: entry.key,
            surface: entry.key, // Fallback surface form is vocabId
            pinyin: '',
            isSpecialItem: false,
          ),
        );
      }
    }

    // 5. Derive known Hanzi
    final knownHanzi = deriveKnownHanzi(
      knownVocabulary: knownVocabItems,
      hanziEvidence: allEvidence,
    );

    return LearnerState(
      knownVocabulary: knownVocabulary,
      knownHanzi: knownHanzi,
      exposure: exposureMap,
      progress: progressMap,
    );
  }
}
