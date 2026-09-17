import 'package:jianru/learner/v3_learner_state.dart';
import 'package:jianru/tokenizer/jieba_tokenizer.dart';
import '../generation/generated_passage.dart';
import '../planner/narrative_target.dart';

/// Structured validation report produced by the Independent Validation Stack (Contract 8).
class GenerationValidationReport {
  const GenerationValidationReport({
    required this.passed,
    required this.passageId,
    required this.checks,
    required this.failures,
    required this.warnings,
  });

  final bool passed;
  final String passageId;
  final Map<String, dynamic> checks;
  final List<String> failures;
  final List<String> warnings;

  Map<String, dynamic> toJson() => {
    'passed': passed,
    'passageId': passageId,
    'checks': checks,
    'failures': failures,
    'warnings': warnings,
  };

  factory GenerationValidationReport.fromJson(Map<String, dynamic> json) =>
      GenerationValidationReport(
        passed: json['passed'] as bool,
        passageId: json['passageId'] as String,
        checks: json['checks'] as Map<String, dynamic>,
        failures: (json['failures'] as List<dynamic>).cast<String>(),
        warnings: (json['warnings'] as List<dynamic>).cast<String>(),
      );
}

/// Independent Multi-Layer Validation Stack for generated Chinese passages.
class IndependentValidationStack {
  IndependentValidationStack({JiebaTokenizer? tokenizer})
    : _tokenizer = tokenizer ?? JiebaTokenizer();

  final JiebaTokenizer _tokenizer;

  static final RegExp _chineseCharPattern = RegExp(r'[\u4e00-\u9fa5]');
  static final RegExp _englishPattern = RegExp(r'[a-zA-Z]');
  static final RegExp _promptLeakPattern = RegExp(
    r'(?:system|prompt|assistant|human|json|markdown|instruction|```)',
    caseSensitive: false,
  );

  GenerationValidationReport validate({
    required GeneratedPassage passage,
    required NarrativeTarget target,
    required V3LearnerState learnerState,
    List<GeneratedPassage> history = const [],
  }) {
    final failures = <String>[];
    final warnings = <String>[];
    final text = passage.generatedText;

    // ==========================================
    // Layer A: Deterministic Checks
    // ==========================================
    final checkA = <String, dynamic>{};

    if (text.trim().isEmpty) {
      failures.add('Deterministic: generated text is empty');
      checkA['nonEmpty'] = false;
    } else {
      checkA['nonEmpty'] = true;
    }

    if (_englishPattern.hasMatch(text)) {
      failures.add(
        'Deterministic: contains forbidden English characters (Monolingual invariant P-01)',
      );
      checkA['monolingual'] = false;
    } else {
      checkA['monolingual'] = true;
    }

    if (_promptLeakPattern.hasMatch(text)) {
      failures.add('Deterministic: detected prompt/system leakage in text');
      checkA['leakFree'] = false;
    } else {
      checkA['leakFree'] = true;
    }

    if (passage.sourceRefs.isEmpty) {
      failures.add(
        'Deterministic: passage missing source references (Provenance invariant V3-03)',
      );
      checkA['provenance'] = false;
    } else {
      checkA['provenance'] = true;
    }

    // ==========================================
    // Layer B: Linguistic Checks
    // ==========================================
    final checkB = <String, dynamic>{};

    if (!_chineseCharPattern.hasMatch(text)) {
      failures.add('Linguistic: contains no Chinese characters');
      checkB['hasChinese'] = false;
    } else {
      checkB['hasChinese'] = true;
    }

    // Sentence punctuation check
    if (!text.endsWith('。') && !text.endsWith('！') && !text.endsWith('？')) {
      warnings.add(
        'Linguistic: sentence does not terminate with Chinese terminal punctuation',
      );
      checkB['punctuated'] = false;
    } else {
      checkB['punctuated'] = true;
    }

    final tokens = _tokenizer.segmentSync(text);
    checkB['tokenCount'] = tokens.length;

    // Vocabulary difficulty threshold check
    final maxNewWords =
        (target.linguisticConstraints['maxNewWords'] as num?)?.toInt() ?? 8;
    if (passage.newWords.length > maxNewWords) {
      failures.add(
        'Linguistic: newly introduced words (${passage.newWords.length}) exceeds budget ($maxNewWords)',
      );
      checkB['vocabularyBudget'] = false;
    } else {
      checkB['vocabularyBudget'] = true;
    }

    // ==========================================
    // Layer C: Source Grounding Checks
    // ==========================================
    final checkC = <String, dynamic>{};

    // Passage must be semantically linked to target evidence or title
    final hasTargetAnchor =
        passage.sourceRefs.any(
          (ref) => text.contains(ref.snippet) || text.contains(target.title),
        ) ||
        text.contains(target.title);

    if (!hasTargetAnchor) {
      failures.add(
        'Grounding: text contains no references to target title or source evidence',
      );
      checkC['groundedInSource'] = false;
    } else {
      checkC['groundedInSource'] = true;
    }

    // ==========================================
    // Layer D: Narrative Coherence Checks
    // ==========================================
    final checkD = <String, dynamic>{};

    if (passage.targetEventId != target.targetEventId) {
      failures.add(
        'Narrative: target event mismatch (passage: ${passage.targetEventId} vs target: ${target.targetEventId})',
      );
      checkD['targetMatch'] = false;
    } else {
      checkD['targetMatch'] = true;
    }

    // Novelty check: avoid duplicate repeating text
    final isDuplicate = history.any((h) => h.generatedText == text);
    if (isDuplicate) {
      failures.add(
        'Narrative: passage text is an unprompted identical duplicate of previous passage',
      );
      checkD['novelty'] = false;
    } else {
      checkD['novelty'] = true;
    }

    // ==========================================
    // Layer E: Independent Judge Checks
    // ==========================================
    final checkE = <String, dynamic>{};

    // Verify entity alignment
    var charactersMatched = true;
    for (final charId in target.introducedCharacters) {
      final name = charId.replaceFirst('char_', '');
      if (name.isNotEmpty && !text.contains(name)) {
        charactersMatched = false;
      }
    }
    checkE['introducedCharactersChecked'] = charactersMatched;

    final allChecks = {
      'deterministic': checkA,
      'linguistic': checkB,
      'grounding': checkC,
      'narrative': checkD,
      'judge': checkE,
    };

    return GenerationValidationReport(
      passed: failures.isEmpty,
      passageId: passage.passageId,
      checks: allChecks,
      failures: failures,
      warnings: warnings,
    );
  }
}
