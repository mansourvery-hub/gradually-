import 'package:jianru/learner/v3_learner_state.dart';
import 'package:jianru/tokenizer/jieba_tokenizer.dart';
import '../planner/narrative_target.dart';
import 'generated_passage.dart';

/// Controlled generator producing level-appropriate Chinese strictly for a selected [NarrativeTarget].
class ControlledGenerator {
  ControlledGenerator({JiebaTokenizer? tokenizer})
    : _tokenizer = tokenizer ?? JiebaTokenizer();

  final JiebaTokenizer _tokenizer;

  /// Generates a structured [GeneratedPassage] expressing [target] for the given [learnerState].
  GeneratedPassage generate({
    required NarrativeTarget target,
    required V3LearnerState learnerState,
  }) {
    // 1. Synthesize core narrative sentence constrained by target summary and title
    final snippet = target.sourceEvidence.isNotEmpty
        ? target.sourceEvidence.first.snippet
        : target.title;

    final generatedChinese = _synthesizeAccessibleText(
      title: target.title,
      snippet: snippet,
      difficulty: learnerState.linguistic.estimatedDifficulty,
    );

    // 2. Tokenize and extract lexical deltas against learner linguistic state
    final tokens = _tokenizer.segmentSync(generatedChinese);
    final newWords = <String>{};
    final newChars = <String>{};

    for (final token in tokens) {
      final word = token.surface;
      if (!learnerState.linguistic.knownWords.contains(word)) {
        newWords.add(word);
      }
      for (int i = 0; i < word.length; i++) {
        final ch = word[i];
        if (!learnerState.linguistic.knownCharacters.contains(ch)) {
          newChars.add(ch);
        }
      }
    }

    // 3. Compute deterministic difficulty estimate
    // base difficulty + (new words ratio)
    final newRatio = tokens.isEmpty ? 0.0 : newWords.length / tokens.length;
    final difficultyEstimate =
        learnerState.linguistic.estimatedDifficulty + (newRatio * 0.8);

    return GeneratedPassage(
      passageId: 'passage_${target.targetEventId}',
      targetEventId: target.targetEventId,
      chapterIndex: target.chapterIndex,
      generatedText: generatedChinese,
      sourceRefs: target.sourceEvidence,
      newWords: newWords.toList(),
      newCharacters: newChars.toList(),
      difficultyEstimate: difficultyEstimate,
      generationMetadata: {
        'generator': 'ControlledGenerator_v3',
        'targetTitle': target.title,
        'tokenCount': tokens.length,
        'newRatio': newRatio,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  String _synthesizeAccessibleText({
    required String title,
    required String snippet,
    required double difficulty,
  }) {
    // Format into accessible, grammatically standard Chinese narrative sentences
    if (difficulty < 2.0) {
      // Level 1: Simple subject-action declarative sentence
      return '这是关于$snippet的故事。我们看到$title。';
    } else if (difficulty < 3.5) {
      // Level 2-3: Narrative sentence with setting and characters
      return '在第章的故事中，$snippet。这一刻发生了$title。';
    } else {
      // Level 4+: Literary narrative progression
      return '书中所记：$snippet。此正是$title的因由。';
    }
  }
}
