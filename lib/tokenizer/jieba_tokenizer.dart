/// Concrete implementation of [Tokenizer] using `dart_jieba` (D-02, E-07).
///
/// Single deterministic Chinese segmentation service across the app.
library;

import 'package:dart_jieba/dart_jieba.dart';

import '../core/token.dart';
import 'tokenizer.dart';

/// Authoritative jieba-based tokenizer.
final class JiebaTokenizer implements Tokenizer {
  JiebaTokenizer({JiebaSegmenter? segmenter})
    : _segmenter = segmenter ?? JiebaSegmenter() {
    _ensureInitialized();
  }

  final JiebaSegmenter _segmenter;
  bool _initialized = false;

  void _ensureInitialized() {
    if (!_initialized) {
      _segmenter.initializeSync();
      _initialized = true;
    }
  }

  @override
  Future<List<Token>> segment(String text) async {
    return segmentSync(text);
  }

  /// Synchronous segmentation with character offset calculation.
  List<Token> segmentSync(String text) {
    _ensureInitialized();
    final words = _segmenter.cut(text);
    final tokens = <Token>[];

    int currentIndex = 0;
    for (final word in words) {
      // Find start offset of word in remaining text
      final start = text.indexOf(word, currentIndex);
      if (start == -1) {
        continue;
      }
      final end = start + word.length;
      currentIndex = end;

      // Filter out punctuation and whitespace
      final trimmed = word.trim();
      if (trimmed.isEmpty || _isPunctuation(trimmed)) {
        continue;
      }

      tokens.add(
        Token(
          vocabId: trimmed,
          surface: trimmed,
          start: start,
          end: end,
        ),
      );
    }

    return tokens;
  }

  static bool _isPunctuation(String text) {
    final punctuationSet = {
      '。',
      '，',
      '、',
      '；',
      '：',
      '？',
      '！',
      '“',
      '”',
      '‘',
      '’',
      '（',
      '）',
      '《',
      '》',
      '【',
      '】',
      '—',
      '…',
      '.',
      ',',
      '!',
      '?',
      ':',
      ';',
      '"',
      '\'',
      '(',
      ')',
      '[',
      ']',
      '-',
    };
    return text.runes.every(
      (r) => punctuationSet.contains(String.fromCharCode(r)),
    );
  }
}
