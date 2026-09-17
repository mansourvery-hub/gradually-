import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/learner/v3_learner_state.dart';
import '../tool/pipeline/extraction/canonical/canonical_model.dart';
import '../tool/pipeline/planner/narrative_planner.dart';

void main() {
  group('Contract 6: Narrative Planner', () {
    const planner = ProgressiveNarrativePlanner();

    // Create a controlled fixture graph: A -> B -> C
    const eventA = CanonicalEvent(
      id: 'ev_A',
      chapterIndex: 1,
      temporalOrder: 1,
      title: 'Event A: Origin',
      summary: 'Stone is left at Green Ridge Peak',
      participants: ['char_stone'],
      locations: ['loc_peak'],
      kind: FactKind.sourceFact,
      evidence: [
        SourceEvidence(
          segmentId: 'seg_1',
          chapterIndex: 1,
          rawStartOffset: 0,
          rawEndOffset: 10,
          snippet: 'origin',
        ),
      ],
      confidence: 1.0,
      causalPredecessors: [],
    );

    const eventB = CanonicalEvent(
      id: 'ev_B',
      chapterIndex: 1,
      temporalOrder: 2,
      title: 'Event B: Monk and Priest appear',
      summary: 'Monk and Priest engrave the stone',
      participants: ['char_stone', 'char_monk'],
      locations: ['loc_peak'],
      kind: FactKind.sourceFact,
      evidence: [
        SourceEvidence(
          segmentId: 'seg_2',
          chapterIndex: 1,
          rawStartOffset: 15,
          rawEndOffset: 25,
          snippet: 'monk appears',
        ),
      ],
      confidence: 1.0,
      causalPredecessors: ['ev_A'],
    );

    const eventC = CanonicalEvent(
      id: 'ev_C',
      chapterIndex: 2,
      temporalOrder: 3,
      title: 'Event C: Mortal Realm Descent',
      summary: 'Stone descends to human world',
      participants: ['char_stone', 'char_lin'],
      locations: ['loc_capital'],
      kind: FactKind.sourceFact,
      evidence: [
        SourceEvidence(
          segmentId: 'seg_3',
          chapterIndex: 2,
          rawStartOffset: 30,
          rawEndOffset: 40,
          snippet: 'descent',
        ),
      ],
      confidence: 1.0,
      causalPredecessors: ['ev_B'],
    );

    const fixtureModel = CanonicalStoryModel(
      sourceId: 'fixture_novel',
      sourceHash: 'hash_123',
      entities: [
        CanonicalEntity(
          id: 'char_stone',
          name: '石头',
          type: EntityType.character,
          kind: FactKind.sourceFact,
          evidence: [
            SourceEvidence(
              segmentId: 'seg_1',
              chapterIndex: 1,
              rawStartOffset: 0,
              rawEndOffset: 2,
              snippet: '石头',
            ),
          ],
          confidence: 1.0,
          firstChapter: 1,
        ),
      ],
      relationships: [],
      events: [eventA, eventB, eventC],
    );

    test('prerequisite handling: does not select C or B before A', () {
      const emptyLearner = V3LearnerState(
        learnerId: 'test_learner',
        linguistic: LinguisticLearnerState(),
        narrative: NarrativeLearnerState(),
      );

      final target1 = planner.selectNextTarget(
        storyModel: fixtureModel,
        learnerState: emptyLearner,
      );

      expect(target1, isNotNull);
      expect(target1!.targetEventId, 'ev_A');
      expect(target1.hasValidProvenance, isTrue);
      expect(target1.prerequisites, isEmpty);
    });

    test('progressively advances A -> B -> C', () {
      // Step 1: Learner completes Event A
      final learnerAfterA =
          const V3LearnerState(
            learnerId: 'test_learner',
            linguistic: LinguisticLearnerState(),
            narrative: NarrativeLearnerState(),
          ).copyWith(
            narrative: const NarrativeLearnerState().recordEventExposed(
              eventId: 'ev_A',
              chapterIndex: 1,
              characterIds: ['char_stone'],
              locationIds: ['loc_peak'],
            ),
          );

      // Next target must be B (because B requires A, and A is satisfied)
      final target2 = planner.selectNextTarget(
        storyModel: fixtureModel,
        learnerState: learnerAfterA,
      );
      expect(target2, isNotNull);
      expect(target2!.targetEventId, 'ev_B');
      expect(target2.prerequisites, contains('ev_A'));

      // Step 2: Learner completes Event B
      final learnerAfterB = learnerAfterA.copyWith(
        narrative: learnerAfterA.narrative.recordEventExposed(
          eventId: 'ev_B',
          chapterIndex: 1,
          characterIds: ['char_monk'],
        ),
      );

      // Next target must be C
      final target3 = planner.selectNextTarget(
        storyModel: fixtureModel,
        learnerState: learnerAfterB,
      );
      expect(target3, isNotNull);
      expect(target3!.targetEventId, 'ev_C');

      // Step 3: Learner completes Event C
      final learnerAfterC = learnerAfterB.copyWith(
        narrative: learnerAfterB.narrative.recordEventExposed(
          eventId: 'ev_C',
          chapterIndex: 2,
        ),
      );

      // All events exposed -> returns null
      final target4 = planner.selectNextTarget(
        storyModel: fixtureModel,
        learnerState: learnerAfterC,
      );
      expect(target4, isNull);
    });

    test(
      'returns null if prerequisites cannot be satisfied (isolated branch)',
      () {
        const isolatedModel = CanonicalStoryModel(
          sourceId: 'fixture_novel',
          sourceHash: 'hash_123',
          entities: [],
          relationships: [],
          events: [
            CanonicalEvent(
              id: 'ev_orphan',
              chapterIndex: 5,
              temporalOrder: 1,
              title: 'Orphan Event',
              summary: 'Unreachable',
              participants: [],
              locations: [],
              kind: FactKind.sourceFact,
              evidence: [
                SourceEvidence(
                  segmentId: 'seg_orphan',
                  chapterIndex: 5,
                  rawStartOffset: 0,
                  rawEndOffset: 5,
                  snippet: 'orphan',
                ),
              ],
              confidence: 1.0,
              causalPredecessors: ['ev_unreachable_root'],
            ),
          ],
        );

        const learner = V3LearnerState(
          learnerId: 'test_learner',
          linguistic: LinguisticLearnerState(),
          narrative: NarrativeLearnerState(),
        );

        final target = planner.selectNextTarget(
          storyModel: isolatedModel,
          learnerState: learner,
        );
        expect(target, isNull);
      },
    );
  });
}
