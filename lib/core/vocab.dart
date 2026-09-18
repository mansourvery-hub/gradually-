/// Shared value objects: vocabulary item (E-07, ARCHITECTURE.md §2).
library;

import 'ids.dart';

/// A vocabulary item — the stable unit of learner knowledge.
///
/// LEARNING_ENGINE.md §2: stable id · surface form · internal pinyin+tone.
/// The special-item flag is reserved for later idiom/proper-noun handling.
final class VocabularyItem {
  const VocabularyItem({
    required this.id,
    required this.surface,
    required this.pinyin,
    required this.isSpecialItem,
  });

  final VocabId id;

  /// The simplified-Chinese surface form (D-06: simplified only).
  final String surface;

  /// Internal pinyin including tone marks. Never displayed directly;
  /// display is stage-driven (CONTENT.md §6).
  final String pinyin;

  /// Reserved for later idiom / proper-noun treatment (not MVP).
  final bool isSpecialItem;
}
