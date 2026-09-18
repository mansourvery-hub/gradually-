/// The content corpus: DATA, not code (CONTENT IS DATA).
///
/// One loader for the whole curriculum:
/// - beginner exposure units are GENERATED from the target-led lexicon
///   (`assets/content/curriculum/bootstrap_target_lexicon.json`) —
///   changing the first 100 words means editing data, not code;
/// - stories / dialogues / sentences / articles are loaded from the
///   corpus manifest (`assets/content/manifest.json`) referencing
///   pre-tokenized JSON files.
///
/// The application never compiles curriculum content into Dart. Adding a
/// story = adding a JSON file + a manifest line; the repository and the
/// selector pick it up without any code change.
///
/// Unit identifiers embed the lexicon word (`unit-NNN-词`) so ids stay
/// stable across corpus growth (existing learner progress keys on them).
library;

import 'dart:convert';

import '../core/token.dart';
import 'content.dart';

/// A target vocabulary item as loaded from the lexicon data file.
final class LexiconItem {
  const LexiconItem({
    required this.id,
    required this.surface,
    required this.pinyin,
    required this.concept,
    required this.asset,
  });

  factory LexiconItem.fromJson(Map<String, dynamic> json) {
    return LexiconItem(
      id: json['id'] as String,
      surface: json['surface'] as String,
      pinyin: json['pinyin'] as String,
      concept: json['concept'] as String? ?? '',
      asset: json['asset'] as String?,
    );
  }

  final String id;
  final String surface;
  final String pinyin;
  final String concept;

  /// Optional concept-visual asset path (ASCII-safe, R-05).
  final String? asset;
}

/// Stable beginner-unit id for lexicon position [index] (0-based) and
/// word [word]. Kept identical to the ids the previous compiled corpus
/// used, so persisted learner progress continues to resolve.
String beginnerUnitId(int index, String word) =>
    'unit-${(index + 1).toString().padLeft(3, '0')}-$word';

/// Builds the beginner exposure unit for a lexicon item.
///
/// Units carry NO prerequisite chain: eligibility is selector policy
/// (SEQUENCING IS LOGIC), not baked into the dataset. Media are optional
/// data — absent audio/visuals are valid (E-08).
ContentItem buildBeginnerUnit(int index, LexiconItem item) {
  final id = beginnerUnitId(index, item.id);
  return ContentItem(
    metadata: ContentMetadata(
      id: id,
      title: item.surface,
      type: ContentType.beginnerUnit,
      curriculumOrder: index + 1,
      prerequisiteIds: const {},
      difficultyEstimate: 1,
      vocabulary: {item.id},
      curriculumCriticalVocabulary: {item.id},
      tags: {'bootstrap'},
    ),
    sections: [
      ContentSection(
        id: 'sec-1',
        text: item.surface,
        visualAsset: item.asset,
        audioAsset: 'assets/audio/words/${item.id}.mp3',
        sentences: [
          ContentSentence(
            id: 's-$id',
            text: item.surface,
            tokens: [
              // Single-char/word surfaces: offset 0..length (D-05 exact).
              Token(
                vocabId: item.id,
                surface: item.surface,
                start: 0,
                end: item.surface.length,
              ),
            ],
            criticalVocabIds: {item.id},
          ),
        ],
      ),
    ],
  );
}

/// Builds all beginner units from lexicon data.
List<ContentItem> buildBeginnerUnits(List<LexiconItem> lexicon) {
  return [
    for (int i = 0; i < lexicon.length; i++) buildBeginnerUnit(i, lexicon[i]),
  ];
}

/// Parses a lexicon JSON payload (`{ "items": [...] }`).
List<LexiconItem> parseLexiconJson(String jsonString) {
  final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
  final items = decoded['items'] as List<dynamic>? ?? const [];
  return items
      .map((i) => LexiconItem.fromJson(i as Map<String, dynamic>))
      .toList();
}

/// Corpus order for a story item (units occupy 1..N; stories continue
/// after the lexicon). Stories declare their own `curriculumOrder` in
/// JSON — this constant is only the documented convention floor.
const int kStoryOrderFloor = 100;
