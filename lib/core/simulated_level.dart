/// Simulated level testing hook (CHOICES.md §4, tasks.json T10).
///
/// Seeds synthetic learner state from compile-time environment flags
/// `--dart-define=LEVEL=0..100` for rapid testing of any progression stage.
///
/// LEVEL semantics (CHOICES.md §4):
/// - 0..50 maps linearly onto the pure-exposure phase (0 → ~600 total
///   exposures distributed across the lexicon in absorption order).
/// - 50..100 continues exposure growth with post-exposure reinforcement.
/// - Words become "known" once absorbed through repetition (≥6 encounters).
///
/// Corpus-independent: the simulated state derives from whatever corpus
/// the caller supplies (the running app passes the loaded repository
/// corpus). Nothing here knows a curriculum.
library;

import '../content/content.dart';
import '../learner/learner_state.dart';
import 'ids.dart';
import 'progress.dart';

/// Reads the simulated level from environment (`--dart-define=LEVEL=0..100`).
const int kSimulatedLevel = int.fromEnvironment('LEVEL', defaultValue: 0);

/// Returns a synthetic [LearnerState] corresponding to [level] (0..100)
/// for the given [corpus] (CONTENT IS DATA: any corpus works).
LearnerState buildSimulatedLearnerState(
  int level, {
  List<ContentItem> corpus = const [],
}) {
  if (level <= 0 || corpus.isEmpty) {
    return const LearnerState();
  }

  final now = DateTime(2026, 9, 8);

  // Stable absorption order: curriculum order, then id.
  final ordered = [...corpus]
    ..sort((a, b) {
      final cmp = a.metadata.curriculumOrder.compareTo(
        b.metadata.curriculumOrder,
      );
      if (cmp != 0) return cmp;
      return a.id.compareTo(b.id);
    });

  final allVocab = <VocabId>[];
  final allItemIds = <ContentId>[];

  for (final item in ordered) {
    allItemIds.add(item.id);
    for (final v in item.metadata.vocabulary) {
      if (!allVocab.contains(v)) allVocab.add(v);
    }
  }

  // Total exposure budget: linear 0..600 across the exposure phase (0..50),
  // then continued growth post-gate (600..1000 at mastery).
  final int exposureBudget = level <= 50
      ? level * 12
      : 600 + ((level - 50) * 8);

  final int completedItemsCount =
      (allItemIds.length * (level.clamp(0, 100)) / 100.0).floor();

  final progressMap = <ContentId, ContentProgress>{};
  for (int i = 0; i < completedItemsCount; i++) {
    progressMap[allItemIds[i]] = ContentProgress.initial(
      contentId: allItemIds[i],
      now: now,
    ).recordCompletion(now);
  }

  // Distribute the exposure budget evenly across the lexicon in absorption
  // order: every word receives floor(budget/words); the remainder goes to
  // the earliest-absorbed words. Deterministic, stable across runs.
  final wordCount = allVocab.length;
  final exposureMap = <VocabId, ExposureAggregate>{};
  final knownVocab = <VocabId>{};

  if (wordCount > 0 && exposureBudget > 0) {
    final perWord = exposureBudget ~/ wordCount;
    final remainder = exposureBudget - perWord * wordCount;

    // Known-vocabulary boundary: the leading fraction of the lexicon
    // absorbed at this level (matches curriculum-position intuition).
    final knownBoundary = (wordCount * level.clamp(0, 100)) / 100.0;

    for (int i = 0; i < wordCount; i++) {
      final encounters = perWord + (i < remainder ? 1 : 0);
      if (encounters <= 0) continue;

      exposureMap[allVocab[i]] = ExposureAggregate(
        vocabId: allVocab[i],
        encounterCount: encounters,
        contentItemIds: {'simulated-unit'},
        firstSeen: now,
        lastSeen: now,
      );

      // Absorbed: leading position in the curriculum AND enough encounters.
      if (i < knownBoundary && encounters >= 6) {
        knownVocab.add(allVocab[i]);
      }
    }
  }

  return LearnerState(
    knownVocabulary: knownVocab,
    exposure: exposureMap,
    progress: progressMap,
  );
}

/// Applies a simulated in-session completion of [item] to [state].
///
/// Pure function: returns the next simulated learner state after the learner
/// experiences [item] at simulated level, so the simulated session advances
/// instead of re-presenting the same item forever.
LearnerState applySimulatedCompletion(LearnerState state, ContentItem item) {
  final now = DateTime.now();

  // 1. Mark the item as completed.
  final progress = Map<ContentId, ContentProgress>.from(state.progress);
  final existing = progress[item.id];
  progress[item.id] =
      (existing ?? ContentProgress.initial(contentId: item.id, now: now))
          .recordCompletion(now);

  // 2. Record exposure for the item's vocabulary.
  final exposure = Map<VocabId, ExposureAggregate>.from(state.exposure);
  final vocabToRecord = <VocabId>{
    ...item.metadata.vocabulary,
    ...item.metadata.curriculumCriticalVocabulary,
  };
  for (final vocabId in vocabToRecord) {
    final agg = exposure[vocabId];
    exposure[vocabId] = (agg == null)
        ? ExposureAggregate.firstEncounter(
            vocabId: vocabId,
            contentId: item.id,
            now: now,
          )
        : agg.recordEncounter(item.id, now);
  }

  // 3. Promote words with enough simulated encounters to known.
  //    4+ exposures in-session means the learner "knows" it for testing.
  final known = Set<VocabId>.from(state.knownVocabulary);
  for (final entry in exposure.entries) {
    if (entry.value.encounterCount >= 4 && !known.contains(entry.key)) {
      known.add(entry.key);
    }
  }

  return LearnerState(
    knownVocabulary: known,
    exposure: exposure,
    progress: progress,
  );
}
