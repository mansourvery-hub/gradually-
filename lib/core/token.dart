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

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      vocabId: json['vocabId'] as String,
      surface: json['surface'] as String,
      start: json['start'] as int,
      end: json['end'] as int,
    );
  }

  /// The stable vocabulary id this token maps to.
  final VocabId vocabId;

  /// The exact surface text as it appeared in the source.
  final String surface;

  /// Character offset of the first character in the source text.
  final int start;

  /// Character offset one past the last character.
  final int end;

  Map<String, dynamic> toJson() => {
    'vocabId': vocabId,
    'surface': surface,
    'start': start,
    'end': end,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token &&
          runtimeType == other.runtimeType &&
          vocabId == other.vocabId &&
          surface == other.surface &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode =>
      vocabId.hashCode ^ surface.hashCode ^ start.hashCode ^ end.hashCode;
}
