import 'package:jianru/learner/v3_learner_state.dart';
import 'package:jianru/tokenizer/jieba_tokenizer.dart';
import '../extraction/canonical/canonical_model.dart';
import '../generation/controlled_generator.dart';
import '../generation/generated_passage.dart';
import '../planner/narrative_planner.dart';
import '../validation/independent_validation_stack.dart';
import 'ladder_model.dart';

/// Configuration options for progressive ladder generation.
class LadderConfig {
  const LadderConfig({
    this.totalLevels = 3,
    this.passagesPerLevel = 2,
    this.baseDifficulty = 1.0,
    this.difficultyStep = 0.8,
  });

  final int totalLevels;
  final int passagesPerLevel;
  final double baseDifficulty;
  final double difficultyStep;
}

/// Generates a structured multi-tiered [ProgressiveLadder] from a canonical story model (Contract 10).
class ProgressiveLadderGenerator {
  ProgressiveLadderGenerator({
    ProgressiveNarrativePlanner? planner,
    ControlledGenerator? generator,
    IndependentValidationStack? validator,
    JiebaTokenizer? tokenizer,
  }) : _planner = planner ?? const ProgressiveNarrativePlanner(),
       _generator =
           generator ??
           ControlledGenerator(tokenizer: tokenizer ?? JiebaTokenizer()),
       _validator =
           validator ??
           IndependentValidationStack(tokenizer: tokenizer ?? JiebaTokenizer());

  final ProgressiveNarrativePlanner _planner;
  final ControlledGenerator _generator;
  final IndependentValidationStack _validator;

  /// Generates the complete progressive reading ladder.
  ProgressiveLadder generate({
    required CanonicalStoryModel storyModel,
    LadderConfig config = const LadderConfig(),
    V3LearnerState? initialLearnerState,
  }) {
    final levels = <LadderLevel>[];
    final allGeneratedPassages = <GeneratedPassage>[];

    var currentLearner =
        initialLearnerState ??
        const V3LearnerState(
          learnerId: 'ladder_learner',
          linguistic: LinguisticLearnerState(
            knownCharacters: {},
            knownWords: {},
            estimatedDifficulty: 1.0,
          ),
          narrative: NarrativeLearnerState(),
        );

    final cumulativeWords = <String>{...currentLearner.linguistic.knownWords};
    final cumulativeChars = <String>{
      ...currentLearner.linguistic.knownCharacters,
    };

    for (int lvlIdx = 0; lvlIdx < config.totalLevels; lvlIdx++) {
      final floor = config.baseDifficulty + (lvlIdx * config.difficultyStep);
      final ceiling = floor + config.difficultyStep;
      final levelPassages = <GeneratedPassage>[];
      final introducedEvents = <String>[];

      // Update learner difficulty floor for this level
      currentLearner = currentLearner.copyWith(
        linguistic: LinguisticLearnerState(
          knownCharacters: Set.unmodifiable(cumulativeChars),
          knownWords: Set.unmodifiable(cumulativeWords),
          estimatedDifficulty: floor,
        ),
      );

      for (int pIdx = 0; pIdx < config.passagesPerLevel; pIdx++) {
        final target = _planner.selectNextTarget(
          storyModel: storyModel,
          learnerState: currentLearner,
        );

        if (target == null) {
          // No more available candidates in graph
          break;
        }

        final passage = _generator.generate(
          target: target,
          learnerState: currentLearner,
        );

        final report = _validator.validate(
          passage: passage,
          target: target,
          learnerState: currentLearner,
          history: allGeneratedPassages,
        );

        if (!report.passed) {
          throw StateError(
            'Validation failed during ladder generation at Level $lvlIdx, Passage $pIdx: ${report.failures}',
          );
        }

        levelPassages.add(passage);
        allGeneratedPassages.add(passage);
        introducedEvents.add(target.targetEventId);

        cumulativeWords.addAll(passage.newWords);
        cumulativeChars.addAll(passage.newCharacters);

        // Advance learner state
        final updatedLinguistic = currentLearner.linguistic.recordLearnedWords(
          passage.newWords.toSet(),
          newDifficulty: passage.difficultyEstimate,
        );

        final updatedNarrative = currentLearner.narrative.recordEventExposed(
          eventId: target.targetEventId,
          chapterIndex: target.chapterIndex,
          characterIds: target.introducedCharacters,
          locationIds: target.introducedLocations,
        );

        currentLearner = currentLearner.copyWith(
          linguistic: updatedLinguistic,
          narrative: updatedNarrative,
        );
      }

      levels.add(
        LadderLevel(
          levelNumber: lvlIdx,
          title:
              'Level $lvlIdx: Tier ${(floor).toStringAsFixed(1)} - ${(ceiling).toStringAsFixed(1)}',
          difficultyFloor: floor,
          difficultyCeiling: ceiling,
          passages: levelPassages,
          cumulativeKnownWords: Set.unmodifiable(cumulativeWords),
          cumulativeKnownCharacters: Set.unmodifiable(cumulativeChars),
          introducedEvents: introducedEvents,
        ),
      );
    }

    return ProgressiveLadder(
      sourceId: storyModel.sourceId,
      sourceHash: storyModel.sourceHash,
      levels: levels,
      metadata: {
        'totalLevels': levels.length,
        'totalPassages': allGeneratedPassages.length,
        'cumulativeVocabularySize': cumulativeWords.length,
        'cumulativeCharacterCount': cumulativeChars.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
