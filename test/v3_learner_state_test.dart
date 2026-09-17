import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/learner/v3_learner_state.dart';

void main() {
  group('Contract 5: Learner State + Narrative State', () {
    // 1. Fixture: Beginner Learner (knows basic words, 0 narrative knowledge)
    const beginnerLearner = V3LearnerState(
      learnerId: 'learner_beginner',
      linguistic: LinguisticLearnerState(
        knownCharacters: {'我', '你', '他', '水', '茶'},
        knownWords: {'我', '你', '他', '水', '茶'},
        estimatedDifficulty: 1.0,
      ),
      narrative: NarrativeLearnerState(),
    );

    // 2. Fixture: Intermediate Learner (literary reader, moderate vocabulary)
    const intermediateLearner = V3LearnerState(
      learnerId: 'learner_intermediate',
      linguistic: LinguisticLearnerState(
        knownCharacters: {'贾', '林', '宝', '玉', '黛', '府', '母', '老'},
        knownWords: {'贾府', '宝玉', '黛玉', '贾母'},
        estimatedDifficulty: 2.5,
      ),
      narrative: NarrativeLearnerState(
        encounteredCharacters: {'char_贾宝玉', 'char_林黛玉'},
        encounteredLocations: {'loc_贾府'},
        encounteredEvents: {'ev_ch1_1'},
        representedSourceRegions: {1},
      ),
    );

    // 3. Fixture: Advanced Learner (fluent Chinese reader exploring Red Chamber)
    const advancedLearner = V3LearnerState(
      learnerId: 'learner_advanced',
      linguistic: LinguisticLearnerState(
        knownCharacters: {'甄', '士', '隐', '梦', '幻', '识', '通', '灵', '雪', '芹'},
        knownWords: {'甄士隐', '梦幻', '通灵', '神游', '太虚'},
        estimatedDifficulty: 5.0,
      ),
      narrative: NarrativeLearnerState(
        encounteredCharacters: {'char_贾宝玉', 'char_林黛玉', 'char_甄士隐', 'char_贾雨村'},
        encounteredLocations: {'loc_大荒山', 'loc_青埂峰', 'loc_荣国府'},
        encounteredEvents: {'ev_ch1_1', 'ev_ch1_2', 'ev_ch2_1'},
        representedSourceRegions: {1, 2},
      ),
    );

    test('narrative state evolves independently of linguistic state', () {
      // Advance narrative state of beginner
      final updatedNarrative = beginnerLearner.narrative.recordEventExposed(
        eventId: 'ev_ch3_1',
        chapterIndex: 3,
        characterIds: ['char_林黛玉', 'char_贾母'],
        locationIds: ['loc_荣国府'],
        openedThread: 'thread_lin_enters_jia',
      );

      final updatedLearner = beginnerLearner.copyWith(
        narrative: updatedNarrative,
      );

      // Narrative state changed
      expect(updatedLearner.narrative.encounteredEvents, contains('ev_ch3_1'));
      expect(
        updatedLearner.narrative.encounteredCharacters,
        contains('char_林黛玉'),
      );
      expect(
        updatedLearner.narrative.openedThreads,
        contains('thread_lin_enters_jia'),
      );

      // Linguistic state remained unchanged (still knows only 5 basic words)
      expect(updatedLearner.linguistic.knownWords.length, 5);
      expect(updatedLearner.linguistic.knownWords, contains('水'));
      expect(updatedLearner.linguistic.knownCharacters, isNot(contains('黛')));
    });

    test('linguistic state evolves independently of narrative state', () {
      // Teach new vocabulary to intermediate learner
      final updatedLinguistic = intermediateLearner.linguistic
          .recordLearnedWords({'苹果', '红茶', '喝水'}, newDifficulty: 2.8);

      final updatedLearner = intermediateLearner.copyWith(
        linguistic: updatedLinguistic,
      );

      // Linguistic state updated
      expect(updatedLearner.linguistic.knownWords, contains('苹果'));
      expect(updatedLearner.linguistic.knownCharacters, contains('苹'));
      expect(updatedLearner.linguistic.estimatedDifficulty, 2.8);

      // Narrative state remained unchanged
      expect(
        updatedLearner.narrative.encounteredEvents,
        intermediateLearner.narrative.encounteredEvents,
      );
      expect(
        updatedLearner.narrative.encounteredCharacters,
        intermediateLearner.narrative.encounteredCharacters,
      );
    });

    test('serialization roundtrip preserves dual states exactly', () {
      final json = advancedLearner.toJson();
      final restored = V3LearnerState.fromJson(json);

      expect(restored.learnerId, advancedLearner.learnerId);
      expect(
        restored.linguistic.knownCharacters,
        advancedLearner.linguistic.knownCharacters,
      );
      expect(
        restored.linguistic.knownWords,
        advancedLearner.linguistic.knownWords,
      );
      expect(
        restored.narrative.encounteredCharacters,
        advancedLearner.narrative.encounteredCharacters,
      );
      expect(
        restored.narrative.encounteredEvents,
        advancedLearner.narrative.encounteredEvents,
      );
      expect(
        restored.narrative.representedSourceRegions,
        advancedLearner.narrative.representedSourceRegions,
      );
    });

    test(
      'planner can evaluate narrative readiness and linguistic accessibility separately',
      () {
        const targetNarrativePrerequisites = {'ev_ch1_1'};
        final targetVocabulary = {'贾府', '宝玉', '黛玉'};

        // Beginner: not ready narratively (missing ev_ch1_1), cannot express linguistically
        expect(
          targetNarrativePrerequisites.every(
            (e) => beginnerLearner.narrative.encounteredEvents.contains(e),
          ),
          isFalse,
        );
        expect(
          beginnerLearner.linguistic.computeKnownRatio(targetVocabulary),
          0.0,
        );

        // Intermediate: ready narratively (knows ev_ch1_1) AND knows 100% of target vocabulary
        expect(
          targetNarrativePrerequisites.every(
            (e) => intermediateLearner.narrative.encounteredEvents.contains(e),
          ),
          isTrue,
        );
        expect(
          intermediateLearner.linguistic.computeKnownRatio(targetVocabulary),
          1.0,
        );
      },
    );
  });
}
