/// Shared token type — the single vocabulary representation consumed by
/// reader, dictionary, SRS, selector, and importer (E-07, ARCHITECTURE.md §5).
library;

import 'ids.dart';

/// One segmented unit of Chinese text produced by the tokenizer.
///
/// A token references a vocabulary item by its stable id; the surface form
/// is carried alongside for display and offset mapping.
final class Token {
  const Token({
    required this.vocabId,
    required this.surface,
    required this.start,
    required this.end,
  });

  /// The stable vocabulary id this token maps to.
  final VocabId vocabId;

  /// The exact surface text as it appeared in the source.
  final String surface;

  /// Character offset of the first character in the source text.
  final int start;

  /// Character offset one past the last character.
  final int end;
}
