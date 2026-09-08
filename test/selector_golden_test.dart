import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/core/progress.dart';
import 'package:jianru/learner/learner_state.dart';
import 'package:jianru/selector/selector.dart';

void main() {
  const selector = V1ContentSelector();

  final candidates = [
    const CandidateContent(
      id: 'unit-1',
      curriculumOrder: 1,
      prerequisiteIds: {},
      vocabulary: {'水'},
    ),
    const CandidateContent(
      id: 'unit-2',
      curriculumOrder: 2,
      prerequisiteIds: {'unit-1'},
      vocabulary: {'茶'},
    ),
    const CandidateContent(
      id: 'unit-3',
      curriculumOrder: 3,
      prerequisiteIds: {'unit-2'},
      vocabulary: {'喝', '水', '茶'},
    ),
    const CandidateContent(
      id: 'story-1',
      curriculumOrder: 5,
      prerequisiteIds: {'unit-3'},
      vocabulary: {'我', '想', '喝', '水', '茶'},
    ),
  ];

  test('absolute beginner receives first unit', () {
    const learner = LearnerState();
    final selected = selector.select(learner, candidates);

    expect(selected, isNotNull);
    expect(selected?.contentId, 'unit-1');
  });

  test('completing unit-1 unlocks unit-2', () {
    final now = DateTime(2026, 9, 8);
    final learner = LearnerState(
      knownVocabulary: {'水'},
      progress: {
        'unit-1': ContentProgress.initial(
          contentId: 'unit-1',
          now: now,
        ).recordCompletion(now),
      },
    );

    final selected = selector.select(learner, candidates);
    expect(selected?.contentId, 'unit-2');
  });

  test(
    'prerequisites prevent jumping ahead to story before units are complete',
    () {
      final now = DateTime(2026, 9, 8);
      final learner = LearnerState(
        knownVocabulary: {'水', '茶'},
        progress: {
          'unit-1': ContentProgress.initial(
            contentId: 'unit-1',
            now: now,
          ).recordCompletion(now),
          'unit-2': ContentProgress.initial(
            contentId: 'unit-2',
            now: now,
          ).recordCompletion(now),
        },
      );

      final selected = selector.select(learner, candidates);
      expect(selected?.contentId, 'unit-3');
    },
  );

  test(
    'completed content remains eligible for rereading when everything is completed (E-10)',
    () {
      final now = DateTime(2026, 9, 8);
      final learner = LearnerState(
        knownVocabulary: {'水', '茶', '喝', '我', '想'},
        progress: {
          'unit-1': ContentProgress.initial(
            contentId: 'unit-1',
            now: now,
          ).recordCompletion(now),
          'unit-2': ContentProgress.initial(
            contentId: 'unit-2',
            now: now,
          ).recordCompletion(now),
          'unit-3': ContentProgress.initial(
            contentId: 'unit-3',
            now: now,
          ).recordCompletion(now),
          'story-1': ContentProgress.initial(
            contentId: 'story-1',
            now: now,
          ).recordCompletion(now),
        },
      );

      final selected = selector.select(learner, candidates);
      expect(selected, isNotNull);
      expect(selected?.contentId, isNotEmpty);
    },
  );
}
