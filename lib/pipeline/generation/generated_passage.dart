import '../extraction/canonical/canonical_model.dart';

/// Structured output from controlled generation (Contract 7).
class GeneratedPassage {
  const GeneratedPassage({
    required this.passageId,
    required this.targetEventId,
    required this.chapterIndex,
    required this.generatedText,
    required this.sourceRefs,
    required this.newWords,
    required this.newCharacters,
    required this.difficultyEstimate,
    required this.generationMetadata,
  });

  final String passageId;
  final String targetEventId;
  final int chapterIndex;
  final String generatedText;
  final List<SourceEvidence> sourceRefs;
  final List<String> newWords;
  final List<String> newCharacters;
  final double difficultyEstimate;
  final Map<String, dynamic> generationMetadata;

  Map<String, dynamic> toJson() => {
    'passageId': passageId,
    'targetEventId': targetEventId,
    'chapterIndex': chapterIndex,
    'generatedText': generatedText,
    'sourceRefs': sourceRefs.map((r) => r.toJson()).toList(),
    'newWords': newWords,
    'newCharacters': newCharacters,
    'difficultyEstimate': difficultyEstimate,
    'generationMetadata': generationMetadata,
  };

  factory GeneratedPassage.fromJson(Map<String, dynamic> json) =>
      GeneratedPassage(
        passageId: json['passageId'] as String,
        targetEventId: json['targetEventId'] as String,
        chapterIndex: json['chapterIndex'] as int,
        generatedText: json['generatedText'] as String,
        sourceRefs: (json['sourceRefs'] as List<dynamic>)
            .map((r) => SourceEvidence.fromJson(r as Map<String, dynamic>))
            .toList(),
        newWords: (json['newWords'] as List<dynamic>).cast<String>(),
        newCharacters: (json['newCharacters'] as List<dynamic>).cast<String>(),
        difficultyEstimate: (json['difficultyEstimate'] as num).toDouble(),
        generationMetadata:
            json['generationMetadata'] as Map<String, dynamic>? ?? const {},
      );
}
