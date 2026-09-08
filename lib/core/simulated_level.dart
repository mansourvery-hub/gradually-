/// Simulated level testing hook (CHOICES.md §4, tasks.json T10).
///
/// Seeds synthetic learner state from compile-time environment flags
/// `--dart-define=LEVEL=0..100` for rapid testing of any progression stage.
library;

import '../content/bootstrap_corpus.dart';
import '../learner/learner_state.dart';
import 'ids.dart';
import 'progress.dart';

/// Reads the simulated level from environment (`--dart-define=LEVEL=0..100`).
const int kSimulatedLevel = int.fromEnvironment('LEVEL', defaultValue: 0);

/// Minimum exposures required before pure exposure phase transitions to review ($CHOICES §1).
const int kPureExposureThreshold = 500;

/// Returns a synthetic [LearnerState] corresponding to [level] (0..100).
LearnerState buildSimulatedLearnerState(int level) {
  if (level <= 0) {
    return const LearnerState();
  }

  final now = DateTime(2026, 9, 8);
  final allVocab = <VocabId>{};
  final allItemIds = <ContentId>[];

  for (final item in bootstrapCurriculum) {
    allItemIds.add(item.id);
    allVocab.addAll(item.metadata.vocabulary);
  }

  final vocabList = allVocab.toList();
  final exposureMap = <VocabId, ExposureAggregate>{};
  final knownVocab = <VocabId>{};
  final progressMap = <ContentId, ContentProgress>{};

  // Fraction of curriculum completed based on level (0..100)
  final double fraction = (level.clamp(0, 100)) / 100.0;
  final int completedItemsCount = (allItemIds.length * fraction).round();
  final int knownVocabCount = (vocabList.length * fraction).round();

  // 1. Seed progress
  for (int i = 0; i < completedItemsCount; i++) {
    final id = allItemIds[i];
    progressMap[id] = ContentProgress.initial(
      contentId: id,
      now: now,
    ).recordCompletion(now);
  }

  // 2. Seed exposures and known vocabulary
  for (int i = 0; i < vocabList.length; i++) {
    final vocab = vocabList[i];
    final isLearned = i < knownVocabCount;
    final encounterCount = isLearned
        ? (4 + (fraction * 10).round())
        : (fraction > 0.2 ? 1 : 0);

    if (encounterCount > 0) {
      exposureMap[vocab] = ExposureAggregate(
        vocabId: vocab,
        encounterCount: encounterCount,
        contentItemIds: {'simulated-unit'},
        firstSeen: now,
        lastSeen: now,
      );
    }

    if (isLearned) {
      knownVocab.add(vocab);
    }
  }

  return LearnerState(
    knownVocabulary: knownVocab,
    exposure: exposureMap,
    progress: progressMap,
  );
}
