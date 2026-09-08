/// Content domain model and JSON schema (CONTENT.md §3, DECISIONS.md D-05).
///
/// Pre-tokenized at authoring time; supports optional visuals and audio
/// across beginner units, micro-stories, and longer text without forcing
/// universal media requirements (E-08).
library;

import '../core/ids.dart';
import '../core/token.dart';
import '../selector/selector.dart';

/// The pedagogical classification of a content item (CONTENT.md §2).
enum ContentType {
  /// Atomic beginner unit (concept/visual + native sound + Hanzi + tone).
  beginnerUnit,

  /// Visual-heavy narrated micro-story.
  microStory,

  /// Graded children's or cultural story.
  story,

  /// Plain native text / article.
  article,
}

/// A sentence within a content section with pre-tokenized tokens and learning metadata.
final class ContentSentence {
  const ContentSentence({
    required this.id,
    required this.text,
    required this.tokens,
    this.criticalVocabIds = const {},
    this.audioAsset,
  });

  factory ContentSentence.fromJson(Map<String, dynamic> json) {
    final rawTokens = json['tokens'] as List<dynamic>? ?? const [];
    final rawCritical = json['criticalVocabIds'] as List<dynamic>? ?? const [];

    return ContentSentence(
      id: json['id'] as SentenceId,
      text: json['text'] as String,
      tokens: rawTokens
          .map((t) => Token.fromJson(t as Map<String, dynamic>))
          .toList(),
      criticalVocabIds: rawCritical.cast<String>().toSet(),
      audioAsset: json['audioAsset'] as String?,
    );
  }

  final SentenceId id;

  /// Full unspaced Chinese text for this sentence.
  final String text;

  /// Pre-tokenized tokens mapping to vocabulary items (E-07).
  final List<Token> tokens;

  /// Vocabulary marked as curriculum-critical in this sentence (CONTENT.md §5).
  final Set<VocabId> criticalVocabIds;

  /// Optional audio asset path for this sentence (E-08).
  final String? audioAsset;

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'tokens': tokens.map((t) => t.toJson()).toList(),
    if (criticalVocabIds.isNotEmpty)
      'criticalVocabIds': criticalVocabIds.toList(),
    if (audioAsset != null) 'audioAsset': audioAsset,
  };
}

/// A scene or section within a content item.
final class ContentSection {
  const ContentSection({
    required this.id,
    required this.text,
    required this.sentences,
    this.title,
    this.visualAsset,
    this.audioAsset,
  });

  factory ContentSection.fromJson(Map<String, dynamic> json) {
    final rawSentences = json['sentences'] as List<dynamic>? ?? const [];

    return ContentSection(
      id: json['id'] as String,
      text: json['text'] as String,
      title: json['title'] as String?,
      visualAsset: json['visualAsset'] as String?,
      audioAsset: json['audioAsset'] as String?,
      sentences: rawSentences
          .map((s) => ContentSentence.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String? title;

  /// Full unspaced Chinese text of this section.
  final String text;

  /// Optional scene illustration or visual placeholder (E-08).
  final String? visualAsset;

  /// Optional section/scene narration audio (E-08).
  final String? audioAsset;

  /// Segmented sentences in this section.
  final List<ContentSentence> sentences;

  Map<String, dynamic> toJson() => {
    'id': id,
    if (title != null) 'title': title,
    'text': text,
    if (visualAsset != null) 'visualAsset': visualAsset,
    if (audioAsset != null) 'audioAsset': audioAsset,
    'sentences': sentences.map((s) => s.toJson()).toList(),
  };
}

/// Lexical and curriculum metadata for a content item (CONTENT.md §3).
final class ContentMetadata {
  const ContentMetadata({
    required this.id,
    required this.title,
    required this.type,
    required this.curriculumOrder,
    this.prerequisiteIds = const {},
    this.difficultyEstimate = 1,
    this.vocabulary = const {},
    this.curriculumCriticalVocabulary = const {},
  });

  factory ContentMetadata.fromJson(Map<String, dynamic> json) {
    final rawPrereqs = json['prerequisiteIds'] as List<dynamic>? ?? const [];
    final rawVocab = json['vocabulary'] as List<dynamic>? ?? const [];
    final rawCritical =
        json['curriculumCriticalVocabulary'] as List<dynamic>? ?? const [];

    final typeStr = json['type'] as String;
    final type = ContentType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => ContentType.story,
    );

    return ContentMetadata(
      id: json['id'] as ContentId,
      title: json['title'] as String,
      type: type,
      curriculumOrder: json['curriculumOrder'] as int? ?? 0,
      prerequisiteIds: rawPrereqs.cast<String>().toSet(),
      difficultyEstimate: json['difficultyEstimate'] as int? ?? 1,
      vocabulary: rawVocab.cast<String>().toSet(),
      curriculumCriticalVocabulary: rawCritical.cast<String>().toSet(),
    );
  }

  final ContentId id;
  final String title;
  final ContentType type;

  /// Sequence position in the curriculum.
  final int curriculumOrder;

  /// Prerequisites that must be completed before this content is reachable.
  final Set<ContentId> prerequisiteIds;

  /// Estimated internal difficulty level (internals stay internal).
  final int difficultyEstimate;

  /// Distinct vocabulary IDs present in this content item.
  final Set<VocabId> vocabulary;

  /// Curriculum-critical vocabulary IDs to prioritize for acquisition.
  final Set<VocabId> curriculumCriticalVocabulary;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.name,
    'curriculumOrder': curriculumOrder,
    if (prerequisiteIds.isNotEmpty) 'prerequisiteIds': prerequisiteIds.toList(),
    'difficultyEstimate': difficultyEstimate,
    if (vocabulary.isNotEmpty) 'vocabulary': vocabulary.toList(),
    if (curriculumCriticalVocabulary.isNotEmpty)
      'curriculumCriticalVocabulary': curriculumCriticalVocabulary.toList(),
  };
}

/// A complete curated content item (unit, story, or article).
final class ContentItem {
  const ContentItem({required this.metadata, required this.sections});

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    final metadataJson = json['metadata'] as Map<String, dynamic>;
    final sectionsJson = json['sections'] as List<dynamic>? ?? const [];

    return ContentItem(
      metadata: ContentMetadata.fromJson(metadataJson),
      sections: sectionsJson
          .map((s) => ContentSection.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  final ContentMetadata metadata;
  final List<ContentSection> sections;

  ContentId get id => metadata.id;
  String get title => metadata.title;
  ContentType get type => metadata.type;

  /// Derives candidate metadata for the ContentSelector without loading full text/media.
  CandidateContent toCandidateContent() {
    // If metadata vocabulary is empty, derive from all sentence tokens
    final vocab = metadata.vocabulary.isNotEmpty
        ? metadata.vocabulary
        : {
            for (final section in sections)
              for (final sentence in section.sentences)
                for (final token in sentence.tokens) token.vocabId,
          };

    return CandidateContent(
      id: metadata.id,
      curriculumOrder: metadata.curriculumOrder,
      prerequisiteIds: metadata.prerequisiteIds,
      vocabulary: vocab,
    );
  }

  Map<String, dynamic> toJson() => {
    'metadata': metadata.toJson(),
    'sections': sections.map((s) => s.toJson()).toList(),
  };
}
