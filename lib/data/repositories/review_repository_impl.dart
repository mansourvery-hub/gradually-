/// Drift implementation of [ReviewRepository] (ARCHITECTURE.md §2, §4).
library;

import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../learner/known.dart';
import '../../review/review.dart';
import '../../review/review_repository.dart';
import '../database.dart';

/// Concrete implementation of [ReviewRepository] using Drift SQLite.
final class DriftReviewRepository implements ReviewRepository {
  DriftReviewRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<ReviewCardRecord>> getDueCards({required DateTime now}) async {
    final query = _db.select(_db.reviewCards)
      ..where((t) => t.due.isSmallerOrEqualValue(now));

    final rows = await query.get();

    return rows.map(_mapToRecord).toList();
  }

  @override
  Future<List<ReviewCardRecord>> getAllCards() async {
    final rows = await _db.select(_db.reviewCards).get();

    return rows.map(_mapToRecord).toList();
  }

  @override
  Future<ReviewCardRecord?> getCardByVocabId(VocabId vocabId) async {
    final row = await (_db.select(
      _db.reviewCards,
    )..where((t) => t.vocabId.equals(vocabId))).getSingleOrNull();

    if (row == null) return null;
    return _mapToRecord(row);
  }

  @override
  Future<void> saveCard(ReviewCardRecord cardRecord) async {
    await _db
        .into(_db.reviewCards)
        .insertOnConflictUpdate(
          ReviewCardsCompanion.insert(
            cardId: cardRecord.card.id,
            vocabId: cardRecord.card.vocabId,
            sourceSentence: cardRecord.card.sourceSentence,
            targetStart: cardRecord.card.targetEmphasis.start,
            targetEnd: cardRecord.card.targetEmphasis.end,
            visualAsset: Value(cardRecord.card.visualAsset),
            wordAudio: Value(cardRecord.card.wordAudio),
            fsrsCardStateJson: cardRecord.fsrsCardStateJson,
            due: cardRecord.due,
          ),
        );
  }

  @override
  Future<void> recordReviewOutcome({
    required ReviewOutcome outcome,
    required ReviewCardRecord updatedCardRecord,
    required MasteryEvidence evidence,
  }) async {
    await _db.transaction(() async {
      // 1. Update review card state
      await saveCard(updatedCardRecord);

      // 2. Record explicit mastery evidence for learner state
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
    });
  }

  ReviewCardRecord _mapToRecord(ReviewCardRow row) {
    return ReviewCardRecord(
      card: ReviewCard(
        id: row.cardId,
        vocabId: row.vocabId,
        sourceSentence: row.sourceSentence,
        targetEmphasis: (start: row.targetStart, end: row.targetEnd),
        visualAsset: row.visualAsset,
        wordAudio: row.wordAudio,
      ),
      fsrsCardStateJson: row.fsrsCardStateJson,
      due: row.due,
    );
  }
}
