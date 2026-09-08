/// Dynamic data-driven exposure unit generator (CHOICES.md §1, dev_graph.json T_CONT_006).
///
/// Dynamically constructs multi-sensory beginner exposure units from curriculum
/// JSON data files without hardcoding vocabulary into code.
library;

import 'dart:convert';

import '../core/token.dart';
import 'content.dart';

/// Target vocabulary item definition loaded from curriculum data JSON.
final class BootstrapLexiconItem {
  const BootstrapLexiconItem({
    required this.id,
    required this.surface,
    required this.pinyin,
    required this.concept,
  });

  factory BootstrapLexiconItem.fromJson(Map<String, dynamic> json) {
    return BootstrapLexiconItem(
      id: json['id'] as String,
      surface: json['surface'] as String,
      pinyin: json['pinyin'] as String,
      concept: json['concept'] as String? ?? '',
    );
  }

  final String id;
  final String surface;
  final String pinyin;
  final String concept;
}

/// Dynamically builds exposure units from curriculum JSON data.
final class DynamicExposureGenerator {
  const DynamicExposureGenerator();

  /// Parses curriculum lexicon JSON string and returns structured items.
  List<BootstrapLexiconItem> parseLexiconJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final itemsList = decoded['items'] as List<dynamic>? ?? const [];
    return itemsList
        .map((i) => BootstrapLexiconItem.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  /// Generates a sequenced series of [ContentItem] exposure units from [items].
  ///
  /// Each unit introduces the word with its visual asset, audio reference,
  /// Hanzi, and internal pinyin.
  List<ContentItem> generateExposureUnits(List<BootstrapLexiconItem> items) {
    final units = <ContentItem>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final order = i + 1;
      final unitId = 'exp-unit-${i + 1}-${item.id}';
      final prevUnitId = i > 0 ? 'exp-unit-$i-${items[i - 1].id}' : null;

      final unit = ContentItem(
        metadata: ContentMetadata(
          id: unitId,
          title: item.surface,
          type: ContentType.beginnerUnit,
          curriculumOrder: order,
          prerequisiteIds: prevUnitId != null ? {prevUnitId} : const {},
          difficultyEstimate: 1,
          vocabulary: {item.id},
          curriculumCriticalVocabulary: {item.id},
        ),
        sections: [
          ContentSection(
            id: 'sec-1',
            text: item.surface,
            visualAsset: 'assets/images/concepts/${item.id}.png',
            audioAsset: 'assets/audio/words/${item.id}.mp3',
            sentences: [
              ContentSentence(
                id: 's-$unitId',
                text: item.surface,
                tokens: [
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

      units.add(unit);
    }

    return units;
  }
}
