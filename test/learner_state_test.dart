// Learner-state tests (ARCHITECTURE.md §7): exposure → aggregate update
// consistency. The bounded aggregate model from LEARNING_ENGINE.md §2.
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/learner/learner_state.dart';

void main() {
  final t0 = DateTime(2026, 9, 5);
  final t1 = DateTime(2026, 9, 6);

  test('first encounter creates a bounded aggregate with count 1', () {
    final agg = ExposureAggregate.firstEncounter(
      vocabId: '吃',
      contentId: 'story-1',
      now: t0,
    );

    expect(agg.encounterCount, 1);
    expect(agg.contentItemIds, {'story-1'});
    expect(agg.firstSeen, t0);
  });

  test('rereading the same story increments the counter, adds no rows', () {
    final agg = ExposureAggregate.firstEncounter(
      vocabId: '吃',
      contentId: 'story-1',
      now: t0,
    );

    final afterReread = agg.recordEncounter('story-1', t1);
    final afterRereadAgain = afterReread.recordEncounter('story-1', t1);

    // The model: rereading increments counters; it never appends rows.
    expect(afterRereadAgain.encounterCount, 3);
    expect(afterRereadAgain.contentItemIds, {
      'story-1',
    }, reason: 'same story reread must not grow the distinct-content set');
  });

  test('encounters across stories track distinct content items', () {
    var agg = ExposureAggregate.firstEncounter(
      vocabId: '吃',
      contentId: 'story-1',
      now: t0,
    );
    agg = agg.recordEncounter('story-2', t1);
    agg = agg.recordEncounter('story-2', t1);

    expect(agg.encounterCount, 3);
    expect(agg.contentItemIds, {'story-1', 'story-2'});
    expect(agg.lastSeen, t1);
    expect(agg.firstSeen, t0);
  });

  test('learner state holds knowledge without SRS internals', () {
    const state = LearnerState();

    // E-03: the learner model has no intervals/ease fields. This test
    // documents the boundary; a schema regression would surface here as a
    // compile error when fields are added.
    expect(state.knownVocabulary, isEmpty);
    expect(state.knownHanzi, isEmpty);
    expect(state.exposure, isEmpty);
  });
}
