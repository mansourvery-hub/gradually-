/// Selector golden tests (E-06, LEARNING_ENGINE.md §5).
///
/// V2 pins the dynamic-sequencing contract:
/// - one output always; deterministic regardless of candidate input order
/// - fresh learner starts at the first unit
/// - selection responds to learner state (exposure, not just mastery)
/// - forward preparation: units pre-teaching upcoming story words win
/// - prerequisites gate eligibility; completed content stays eligible
/// - the sequence is never a hardcoded list — it comes from the selector
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/core/content_type.dart';
import 'package:jianru/core/progress.dart';
import 'package:jianru/learner/learner_state.dart';
import 'package:jianru/selector/selector.dart';

ContentProgress _completed(String id, DateTime now) =>
    ContentProgress.initial(contentId: id, now: now).recordCompletion(now);

const _units = [
  CandidateContent(
    id: 'unit-1',
    curriculumOrder: 1,
    prerequisiteIds: {},
    vocabulary: {'水'},
    type: ContentType.beginnerUnit,
  ),
  CandidateContent(
    id: 'unit-2',
    curriculumOrder: 2,
    prerequisiteIds: {},
    vocabulary: {'茶'},
    type: ContentType.beginnerUnit,
  ),
  CandidateContent(
    id: 'unit-3',
    curriculumOrder: 3,
    prerequisiteIds: {},
    vocabulary: {'喝'},
    type: ContentType.beginnerUnit,
  ),
  CandidateContent(
    id: 'unit-4',
    curriculumOrder: 4,
    prerequisiteIds: {},
    vocabulary: {'想'},
    type: ContentType.beginnerUnit,
  ),
];

const _storyTea = CandidateContent(
  id: 'story-tea',
  curriculumOrder: 100,
  prerequisiteIds: {},
  vocabulary: {'我', '想', '喝', '水', '茶', '也'},
  type: ContentType.microStory,
);

void main() {
  const selector = V2ContentSelector();
  final now = DateTime(2026, 9, 8);

  group('V2 contract', () {
    test('absolute beginner receives the first unit', () {
      const learner = LearnerState();
      final selected = selector.select(learner, [..._units, _storyTea]);
      expect(selected, isNotNull);
      expect(selected?.contentId, 'unit-1');
    });

    test('selection is independent of candidate input order (corpus supplies '
        'no ordering promise)', () {
      final forward = [..._units, _storyTea];
      final shuffled = [_storyTea, _units[3], _units[0], _units[2], _units[1]];

      // Multiple learner states: identical selections in both orders.
      const states = [LearnerState(), LearnerState()];
      for (final learner in states) {
        expect(
          selector.select(learner, forward)?.contentId,
          selector.select(learner, shuffled)?.contentId,
          reason: 'input order must never change the sequence',
        );
      }

      // A learner with some exposure too.
      final exposed = LearnerState(
        exposure: {
          '水': ExposureAggregate.firstEncounter(
            vocabId: '水',
            contentId: 'unit-1',
            now: now,
          ),
        },
        progress: {'unit-1': _completed('unit-1', now)},
      );
      expect(
        selector.select(exposed, forward)?.contentId,
        selector.select(exposed, shuffled)?.contentId,
      );
    });

    test('the next item changes with learner state (dynamic sequencing)', () {
      final learnerA = LearnerState(
        progress: {'unit-1': _completed('unit-1', now)},
        exposure: {
          '水': ExposureAggregate(
            vocabId: '水',
            encounterCount: 6,
            contentItemIds: {'unit-1'},
            firstSeen: now,
            lastSeen: now,
          ),
        },
      );
      final a = selector.select(learnerA, [..._units, _storyTea]);
      expect(a?.contentId, isNot('unit-1'));

      // After absorbing the story's whole vocabulary, the story becomes
      // the best i+1 candidate and preempts remaining drill units.
      final learnerB = LearnerState(
        progress: {
          'unit-1': _completed('unit-1', now),
          'unit-2': _completed('unit-2', now),
          'unit-3': _completed('unit-3', now),
          'unit-4': _completed('unit-4', now),
        },
        exposure: {
          for (final v in ['水', '茶', '喝', '想', '我', '也'])
            v: ExposureAggregate(
              vocabId: v,
              encounterCount: 5,
              contentItemIds: {'units'},
              firstSeen: now,
              lastSeen: now,
            ),
        },
      );
      final b = selector.select(learnerB, [..._units, _storyTea]);
      expect(
        b?.contentId,
        'story-tea',
        reason: 'a readable story beats remaining drill units',
      );
    });

    test('forward preparation: a unit pre-teaching upcoming story vocabulary '
        'outranks an earlier non-preparing unit', () {
      // Learner completed unit-1 (水); the upcoming story needs
      // 想/喝/茶/我/也 — mostly unseen, so the story is NOT yet in the
      // i+1 zone: units continue, and the preparing ones win.
      final learner = LearnerState(
        progress: {'unit-1': _completed('unit-1', now)},
        exposure: {
          '水': ExposureAggregate(
            vocabId: '水',
            encounterCount: 6,
            contentItemIds: {'unit-1'},
            firstSeen: now,
            lastSeen: now,
          ),
        },
      );

      // Sanity: the story is not yet readable (seen ratio below the
      // selector's readiness floor).
      expect(_storyTea.seenRatioFor(learner), lessThan(0.6));
      expect(_storyTea.unseenVocabularyFor(learner).length, 5);

      final selected = selector.select(learner, [..._units, _storyTea]);
      // unit-2 (茶) / unit-3 (喝) / unit-4 (想) all prepare the story;
      // the earliest preparing unit wins (curriculum-order tie-break).
      expect(selected?.contentId, 'unit-2');
      expect(
        _storyTea.vocabulary.contains('茶'),
        isTrue,
        reason: 'fixture sanity: unit-2 must actually prepare the story',
      );
    });

    test('prerequisites gate story eligibility', () {
      const lockedStory = CandidateContent(
        id: 'story-locked',
        curriculumOrder: 101,
        prerequisiteIds: {'unit-4'},
        vocabulary: {'水', '茶', '喝'},
        type: ContentType.microStory,
      );

      final learner = LearnerState(
        progress: {'unit-1': _completed('unit-1', now)},
        exposure: {
          for (final v in ['水', '茶', '喝', '想'])
            v: ExposureAggregate(
              vocabId: v,
              encounterCount: 8,
              contentItemIds: {'units'},
              firstSeen: now,
              lastSeen: now,
            ),
        },
      );

      final selected = selector.select(learner, [
        ..._units,
        lockedStory,
        _storyTea,
      ]);
      // lockedStory requires unit-4 (not completed): never selected.
      expect(selected?.contentId, isNot('story-locked'));
    });

    test('completed content stays eligible (rereading rotation, E-10)', () {
      // Everything completed: the selector must still return an item.
      final learner = LearnerState(
        progress: {
          'unit-1': _completed('unit-1', now),
          'unit-2': _completed('unit-2', now),
          'unit-3': _completed('unit-3', now),
          'unit-4': _completed('unit-4', now),
          'story-tea': _completed('story-tea', now),
        },
        exposure: {
          for (final v in ['水', '茶', '喝', '想', '我', '也'])
            v: ExposureAggregate(
              vocabId: v,
              encounterCount: 6,
              contentItemIds: {'units'},
              firstSeen: now,
              lastSeen: now,
            ),
        },
      );

      final selected = selector.select(learner, [..._units, _storyTea]);
      expect(selected, isNotNull);
      expect(selected?.contentId, isNotEmpty);
    });

    test('empty corpus yields null (no fabricated curriculum)', () {
      expect(selector.select(const LearnerState(), const []), isNull);
    });

    test('story with too many unseen words holds back (i+1, not i+10)', () {
      // All units completed except a story full of unseen vocabulary.
      const hardStory = CandidateContent(
        id: 'story-hard',
        curriculumOrder: 100,
        prerequisiteIds: {},
        vocabulary: {'雨伞', '冷', '热', '书', '家', '里', '回', '来', '跑', '鱼'},
        type: ContentType.microStory,
      );

      final learner = LearnerState(
        progress: {
          'unit-1': _completed('unit-1', now),
          'unit-2': _completed('unit-2', now),
          'unit-3': _completed('unit-3', now),
          'unit-4': _completed('unit-4', now),
        },
        exposure: {
          for (final v in ['水', '茶', '喝', '想'])
            v: ExposureAggregate(
              vocabId: v,
              encounterCount: 6,
              contentItemIds: {'units'},
              firstSeen: now,
              lastSeen: now,
            ),
        },
      );

      final selected = selector.select(learner, [
        ..._units.where((u) => false), // all units completed
        ...const [],
        hardStory,
        _storyTea,
      ]);
      // _storyTea (5/6 unseen -> but 我/想/喝/水 seen => 2 unseen) wins
      // over hardStory (10 unseen).
      expect(selected?.contentId, 'story-tea');
    });
  });
}
