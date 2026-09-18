import 'package:jianru/learner/v3_learner_state.dart';
import 'package:jianru/tokenizer/jieba_tokenizer.dart';
import 'extraction/canonical/canonical_extractor.dart';
import 'extraction/canonical/canonical_grounding_validator.dart';
import 'extraction/canonical/canonical_model.dart';
import 'extraction/linguistic/linguistic_extractor.dart';
import 'extraction/linguistic/linguistic_model.dart';
import 'generation/controlled_generator.dart';
import 'generation/generated_passage.dart';
import 'ingestion/source_ingester.dart';
import 'planner/narrative_planner.dart';
import 'planner/narrative_target.dart';
import 'validation/independent_validation_stack.dart';

/// Result of executing the complete Mother Story pipeline.
class PipelineExecutionResult {
  const PipelineExecutionResult({
    required this.sourceArtifact,
    required this.canonicalModel,
    required this.canonicalValidation,
    required this.linguisticProfile,
    required this.plannedTargets,
    required this.generatedPassages,
    required this.validationReports,
    required this.finalLearnerState,
    required this.success,
  });

  final SourceArtifact sourceArtifact;
  final CanonicalStoryModel canonicalModel;
  final ValidationResult canonicalValidation;
  final LinguisticProfile linguisticProfile;
  final List<NarrativeTarget> plannedTargets;
  final List<GeneratedPassage> generatedPassages;
  final List<GenerationValidationReport> validationReports;
  final V3LearnerState finalLearnerState;
  final bool success;

  Map<String, dynamic> toJson() => {
    'sourceId': sourceArtifact.sourceId,
    'chapterCount': sourceArtifact.chapters.length,
    'canonicalEntitiesCount': canonicalModel.entities.length,
    'canonicalEventsCount': canonicalModel.events.length,
    'canonicalValid': canonicalValidation.passed,
    'uniqueWords': linguisticProfile.uniqueWordsCount,
    'plannedTargetsCount': plannedTargets.length,
    'generatedPassagesCount': generatedPassages.length,
    'allValidationsPassed': success,
  };
}

/// The end-to-end Mother Story pipeline orchestrator (Contract 9).
class MotherStoryPipeline {
  MotherStoryPipeline({
    SourceIngester? ingester,
    CanonicalStoryExtractor? canonicalExtractor,
    CanonicalGroundingValidator? groundingValidator,
    LinguisticExtractor? linguisticExtractor,
    ProgressiveNarrativePlanner? narrativePlanner,
    ControlledGenerator? generator,
    IndependentValidationStack? validationStack,
    JiebaTokenizer? tokenizer,
  }) : _ingester = ingester ?? const SourceIngester(),
       _canonicalExtractor =
           canonicalExtractor ?? const CanonicalStoryExtractor(),
       _groundingValidator =
           groundingValidator ?? const CanonicalGroundingValidator(),
       _linguisticExtractor =
           linguisticExtractor ??
           LinguisticExtractor(tokenizer: tokenizer ?? JiebaTokenizer()),
       _narrativePlanner =
           narrativePlanner ?? const ProgressiveNarrativePlanner(),
       _generator =
           generator ??
           ControlledGenerator(tokenizer: tokenizer ?? JiebaTokenizer()),
       _validationStack =
           validationStack ??
           IndependentValidationStack(tokenizer: tokenizer ?? JiebaTokenizer());

  final SourceIngester _ingester;
  final CanonicalStoryExtractor _canonicalExtractor;
  final CanonicalGroundingValidator _groundingValidator;
  final LinguisticExtractor _linguisticExtractor;
  final ProgressiveNarrativePlanner _narrativePlanner;
  final ControlledGenerator _generator;
  final IndependentValidationStack _validationStack;

  /// Executes the complete pipeline from raw text to validated reading passages.
  PipelineExecutionResult run({
    required String rawSourceText,
    String sourceId = '红楼梦',
    int? maxChapters,
    int stepsToGenerate = 3,
    V3LearnerState? initialLearnerState,
  }) {
    // 1. Ingestion
    final sourceArtifact = _ingester.ingestString(
      rawSourceText,
      sourceId: sourceId,
    );

    // If maxChapters is specified, create bounded artifact for rapid testing/fixtures
    final boundedArtifact =
        maxChapters != null && sourceArtifact.chapters.length > maxChapters
        ? SourceArtifact(
            sourceId: sourceArtifact.sourceId,
            contentHash: sourceArtifact.contentHash,
            encoding: sourceArtifact.encoding,
            rawText: sourceArtifact.rawText,
            normalizedText: sourceArtifact.normalizedText,
            chapters: sourceArtifact.chapters.take(maxChapters).toList(),
            warnings: sourceArtifact.warnings,
          )
        : sourceArtifact;

    // 2. Canonical Story Extraction
    final canonicalModel = _canonicalExtractor.extract(boundedArtifact);

    // Validate Canonical Grounding
    final canonicalValidation = _groundingValidator.validate(
      model: canonicalModel,
      artifact: boundedArtifact,
    );

    // 3. Linguistic Knowledge Extraction
    final linguisticProfile = _linguisticExtractor.extract(boundedArtifact);

    // 4. State & Iterative Planning + Generation + Validation
    var currentLearnerState =
        initialLearnerState ??
        const V3LearnerState(
          learnerId: 'learner_e2e',
          linguistic: LinguisticLearnerState(
            knownCharacters: {},
            knownWords: {},
            estimatedDifficulty: 1.0,
          ),
          narrative: NarrativeLearnerState(),
        );

    final plannedTargets = <NarrativeTarget>[];
    final generatedPassages = <GeneratedPassage>[];
    final validationReports = <GenerationValidationReport>[];
    bool allValid = canonicalValidation.passed;

    for (int step = 0; step < stepsToGenerate; step++) {
      // Plan next target
      final target = _narrativePlanner.selectNextTarget(
        storyModel: canonicalModel,
        learnerState: currentLearnerState,
      );

      if (target == null) {
        // No more available unread narrative targets whose prerequisites are met
        break;
      }

      plannedTargets.add(target);

      // Generate controlled passage
      final passage = _generator.generate(
        target: target,
        learnerState: currentLearnerState,
      );

      // Independent multi-layer validation
      final report = _validationStack.validate(
        passage: passage,
        target: target,
        learnerState: currentLearnerState,
        history: generatedPassages,
      );

      generatedPassages.add(passage);
      validationReports.add(report);

      if (!report.passed) {
        allValid = false;
        // Fail-closed: do not advance learner state on invalid generation
        break;
      }

      // Advance learner state
      final updatedLinguistic = currentLearnerState.linguistic
          .recordLearnedWords(
            passage.newWords.toSet(),
            newDifficulty: passage.difficultyEstimate,
          );

      final updatedNarrative = currentLearnerState.narrative.recordEventExposed(
        eventId: target.targetEventId,
        chapterIndex: target.chapterIndex,
        characterIds: target.introducedCharacters,
        locationIds: target.introducedLocations,
      );

      currentLearnerState = currentLearnerState.copyWith(
        linguistic: updatedLinguistic,
        narrative: updatedNarrative,
      );
    }

    return PipelineExecutionResult(
      sourceArtifact: boundedArtifact,
      canonicalModel: canonicalModel,
      canonicalValidation: canonicalValidation,
      linguisticProfile: linguisticProfile,
      plannedTargets: plannedTargets,
      generatedPassages: generatedPassages,
      validationReports: validationReports,
      finalLearnerState: currentLearnerState,
      success: allValid,
    );
  }
}
