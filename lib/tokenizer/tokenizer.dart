/// Tokenizer boundary (E-07, D-02, ARCHITECTURE.md §5).
///
/// One interface, one implementation today (dart_jieba behind
/// `JiebaTokenizer`), one shared token type. Content is pre-tokenized at
/// authoring time; runtime tokenization serves lookup and later import.
library;

import 'dart:async';

import '../core/token.dart';

/// Single authoritative segmentation service used by every consumer.
abstract interface class Tokenizer {
  /// Segments [text] into tokens with character offsets.
  ///
  /// Deterministic: the same input must always produce the same output
  /// across every consumer (golden tests pin this).
  Future<List<Token>> segment(String text);
}
