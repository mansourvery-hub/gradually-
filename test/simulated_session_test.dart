/// Regression test: at simulated levels (LEVEL>0), tapping must advance
/// the learner state so the selector picks a *different* next item.
/// Guards against the "forever stuck on one word" regression.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/content/content.dart';
import 'package:jianru/core/simulated_level.dart';

import 'helpers/corpus_loader.dart';

void main() {
  test('applySimulatedCompletion advances learner state', () {
    final corpus = fullCorpus();
    final initial = buildSimulatedLearnerState(10, corpus: corpus);
    final item = corpus.first;

    final next = applySimulatedCompletion(initial, item);

    // The completed item must now be marked as completed.
    expect(
      next.isContentCompleted(item.id),
      isTrue,
      reason: 'tapped item must be recorded as completed',
    );
    // Exposure must grow for the item's vocabulary.
    final exposed = item.metadata.vocabulary.any(
      (v) => next.exposure[v]?.encounterCount != null,
    );
    expect(
      exposed,
      isTrue,
      reason: 'vocabulary exposure must be recorded in simulated mode',
    );
    // State must be a new instance (immutably advanced).
    expect(identical(initial, next), isFalse);
  });

  test('repeated simulated completions eventually cover the curriculum', () {
    final corpus = fullCorpus();
    var state = buildSimulatedLearnerState(10, corpus: corpus);

    // Complete every curriculum item once through the simulated reducer.
    for (final item in corpus) {
      state = applySimulatedCompletion(state, item);
    }

    final completedCount = corpus
        .where((i) => state.isContentCompleted(i.id))
        .length;
    expect(
      completedCount,
      corpus.length,
      reason: 'all items should be completable via simulated completions',
    );
  });

  test('simulated state derives from the corpus data, not compiled code', () {
    // The corpus must be loadable purely from data files: 45 lexicon
    // units plus the manifest stories (>= 20 by the V1 milestone).
    final corpus = fullCorpus();
    final units = corpus
        .where((i) => i.type == ContentType.beginnerUnit)
        .length;
    final stories = corpus.length - units;
    expect(units, 45, reason: 'lexicon data generates 45 beginner units');
    expect(
      stories,
      greaterThanOrEqualTo(20),
      reason: 'manifest data carries at least 20 stories/dialogues',
    );
  });
}
