import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/learner/v3_learner_state.dart';
import '../tool/pipeline/extraction/canonical/canonical_model.dart';
import '../tool/pipeline/generation/controlled_generator.dart';
import '../tool/pipeline/generation/generated_passage.dart';
import '../tool/pipeline/planner/narrative_target.dart';
import '../tool/pipeline/validation/independent_validation_stack.dart';

void main() {
  group('Contracts 7 & 8: Controlled Generation & Independent Validation Stack', () {
    final generator = ControlledGenerator();
    final validator = IndependentValidationStack();

    const sampleEvidence = SourceEvidence(
      segmentId: 'seg_ch1_0',
      chapterIndex: 1,
      rawStartOffset: 0,
      rawEndOffset: 10,
      snippet: '甄士隐梦幻识通灵',
      isDirectQuote: true,
    );

    const sampleTarget = NarrativeTarget(
      targetEventId: 'ev_ch1_1',
      title: '甄士隐梦幻识通灵',
      summary: 'Chapter 1: Zhen Shiyin dreams of the spiritual stone',
      chapterIndex: 1,
      sourceEvidence: [sampleEvidence],
      prerequisites: [],
      reasonForSelection: 'Opening narrative event',
      narrativeDifficulty: 1.0,
      introducedCharacters: ['char_甄士隐'],
      introducedLocations: [],
      linguisticConstraints: {
        'maxNewWords': 6,
        'maxSentenceDifficulty': 1.5,
        'targetVocabularyRatio': 0.8,
      },
    );

    const beginnerLearner = V3LearnerState(
      learnerId: 'test_learner',
      linguistic: LinguisticLearnerState(
        knownCharacters: {
          '这',
          '是',
          '关',
          '于',
          '的',
          '故',
          '事',
          '我',
          '们',
          '看',
          '到',
        },
        knownWords: {'这是', '关于', '的故事', '我们', '看到'},
        estimatedDifficulty: 1.0,
      ),
      narrative: NarrativeLearnerState(),
    );

    test(
      'Contract 7: generates structured passage with full metadata & provenance',
      () {
        final passage = generator.generate(
          target: sampleTarget,
          learnerState: beginnerLearner,
        );

        expect(passage.targetEventId, sampleTarget.targetEventId);
        expect(passage.generatedText, contains('甄士隐梦幻识通灵'));
        expect(passage.sourceRefs, isNotEmpty);
        expect(passage.newWords, contains('甄士隐'));
        expect(passage.difficultyEstimate, greaterThan(1.0));
        expect(
          passage.generationMetadata['generator'],
          contains('ControlledGenerator'),
        );

        // Validate passage with independent validator
        final report = validator.validate(
          passage: passage,
          target: sampleTarget,
          learnerState: beginnerLearner,
        );

        expect(report.passed, isTrue, reason: 'Failures: ${report.failures}');
        expect(report.failures, isEmpty);
        final deterministic =
            report.checks['deterministic'] as Map<String, dynamic>;
        final grounding = report.checks['grounding'] as Map<String, dynamic>;
        expect(deterministic['monolingual'], isTrue);
        expect(grounding['groundedInSource'], isTrue);
      },
    );

    test(
      'Contract 8: validator rejects English contamination (Monolingual P-01)',
      () {
        final badPassage = GeneratedPassage(
          passageId: 'passage_bad_1',
          targetEventId: sampleTarget.targetEventId,
          chapterIndex: 1,
          generatedText: '这是关于甄士隐梦幻识通灵的 story。', // Forbidden English word
          sourceRefs: sampleTarget.sourceEvidence,
          newWords: const ['甄士隐'],
          newCharacters: const ['甄'],
          difficultyEstimate: 1.0,
          generationMetadata: const {},
        );

        final report = validator.validate(
          passage: badPassage,
          target: sampleTarget,
          learnerState: beginnerLearner,
        );

        expect(report.passed, isFalse);
        expect(report.failures, anyElement(contains('forbidden English')));
      },
    );

    test(
      'Contract 8: validator rejects prompt leakage / instruction injection',
      () {
        final badPassage = GeneratedPassage(
          passageId: 'passage_bad_2',
          targetEventId: sampleTarget.targetEventId,
          chapterIndex: 1,
          generatedText: '这是关于甄士隐梦幻识通灵的故事。```json {"role": "assistant"}```',
          sourceRefs: sampleTarget.sourceEvidence,
          newWords: const ['甄士隐'],
          newCharacters: const ['甄'],
          difficultyEstimate: 1.0,
          generationMetadata: const {},
        );

        final report = validator.validate(
          passage: badPassage,
          target: sampleTarget,
          learnerState: beginnerLearner,
        );

        expect(report.passed, isFalse);
        expect(report.failures, anyElement(contains('prompt/system leakage')));
      },
    );

    test(
      'Contract 8: validator rejects ungrounded generation (hallucination / wrong topic)',
      () {
        final badPassage = GeneratedPassage(
          passageId: 'passage_bad_3',
          targetEventId: sampleTarget.targetEventId,
          chapterIndex: 1,
          generatedText: '今天天气很好，小狗在草地上快乐地奔跑。', // Unrelated hallucination
          sourceRefs: sampleTarget.sourceEvidence,
          newWords: const ['小狗'],
          newCharacters: const ['狗'],
          difficultyEstimate: 1.0,
          generationMetadata: const {},
        );

        final report = validator.validate(
          passage: badPassage,
          target: sampleTarget,
          learnerState: beginnerLearner,
        );

        expect(report.passed, isFalse);
        expect(
          report.failures,
          anyElement(
            contains('no references to target title or source evidence'),
          ),
        );
      },
    );

    test('Contract 8: validator rejects missing provenance (V3-03)', () {
      final badPassage = GeneratedPassage(
        passageId: 'passage_bad_4',
        targetEventId: sampleTarget.targetEventId,
        chapterIndex: 1,
        generatedText: '这是关于甄士隐梦幻识通灵的故事。',
        sourceRefs: const [], // NO PROVENANCE
        newWords: const ['甄士隐'],
        newCharacters: const ['甄'],
        difficultyEstimate: 1.0,
        generationMetadata: const {},
      );

      final report = validator.validate(
        passage: badPassage,
        target: sampleTarget,
        learnerState: beginnerLearner,
      );

      expect(report.passed, isFalse);
      expect(
        report.failures,
        anyElement(contains('missing source references')),
      );
    });

    test('Contract 8: validator rejects target event mismatch', () {
      final badPassage = GeneratedPassage(
        passageId: 'passage_bad_5',
        targetEventId: 'ev_ch99_wrong', // Wrong event
        chapterIndex: 1,
        generatedText: '这是关于甄士隐梦幻识通灵的故事。',
        sourceRefs: sampleTarget.sourceEvidence,
        newWords: const ['甄士隐'],
        newCharacters: const ['甄'],
        difficultyEstimate: 1.0,
        generationMetadata: const {},
      );

      final report = validator.validate(
        passage: badPassage,
        target: sampleTarget,
        learnerState: beginnerLearner,
      );

      expect(report.passed, isFalse);
      expect(report.failures, anyElement(contains('target event mismatch')));
    });

    test(
      'Contract 8: validator rejects duplicate passages without novelty',
      () {
        final passage = generator.generate(
          target: sampleTarget,
          learnerState: beginnerLearner,
        );

        // Validate with identical passage already in history
        final report = validator.validate(
          passage: passage,
          target: sampleTarget,
          learnerState: beginnerLearner,
          history: [passage],
        );

        expect(report.passed, isFalse);
        expect(report.failures, anyElement(contains('identical duplicate')));
      },
    );
  });
}
