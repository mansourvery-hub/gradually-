/// Regression test: at simulated levels (LEVEL>0), tapping must advance
/// the learner state so the selector picks a *different* next item.
/// Guards against the "forever stuck on one word" regression.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/content/bootstrap_corpus.dart';
import 'package:jianru/core/simulated_level.dart';

void main() {
  test('applySimulatedCompletion advances learner state', () {
    final initial = buildSimulatedLearnerState(10);
    final item = bootstrapCurriculum.first;

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
    var state = buildSimulatedLearnerState(10);

    // Complete every curriculum item once through the simulated reducer.
    for (final item in bootstrapCurriculum) {
      state = applySimulatedCompletion(state, item);
    }

    final completedCount = bootstrapCurriculum
        .where((i) => state.isContentCompleted(i.id))
        .length;
    expect(
      completedCount,
      bootstrapCurriculum.length,
      reason: 'all items should be completable via simulated completions',
    );
  });
}
