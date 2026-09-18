/// Shared value object representing a single Hanzi (Chinese character).
library;

/// A single Hanzi (Chinese character) knowledge unit.
///
/// Hanzi knowledge is tracked alongside vocabulary (LEARNING_ENGINE.md §2).
final class Hanzi {
  const Hanzi({required this.character});

  /// The character itself, e.g. 吃.
  final String character;

  @override
  bool operator ==(Object other) =>
      other is Hanzi && other.character == character;

  @override
  int get hashCode => character.hashCode;
}
