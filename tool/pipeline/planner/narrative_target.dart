import '../extraction/canonical/canonical_model.dart';

/// A concrete, source-grounded narrative target selected by the Progressive Narrative Planner.
///
/// Decides "WHAT meaningful piece of the Mother Story should become visible next",
/// completely separate from "HOW to express it linguistically".
class NarrativeTarget {
  const NarrativeTarget({
    required this.targetEventId,
    required this.title,
    required this.summary,
    required this.chapterIndex,
    required this.sourceEvidence,
    required this.prerequisites,
    required this.reasonForSelection,
    required this.narrativeDifficulty,
    required this.introducedCharacters,
    required this.introducedLocations,
    required this.linguisticConstraints,
  });

  final String targetEventId;
  final String title;
  final String summary;
  final int chapterIndex;
  final List<SourceEvidence> sourceEvidence;
  final List<String> prerequisites;
  final String reasonForSelection;
  final double narrativeDifficulty;
  final List<String> introducedCharacters;
  final List<String> introducedLocations;
  final Map<String, dynamic> linguisticConstraints;

  bool get hasValidProvenance => sourceEvidence.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'targetEventId': targetEventId,
    'title': title,
    'summary': summary,
    'chapterIndex': chapterIndex,
    'sourceEvidence': sourceEvidence.map((e) => e.toJson()).toList(),
    'prerequisites': prerequisites,
    'reasonForSelection': reasonForSelection,
    'narrativeDifficulty': narrativeDifficulty,
    'introducedCharacters': introducedCharacters,
    'introducedLocations': introducedLocations,
    'linguisticConstraints': linguisticConstraints,
  };

  factory NarrativeTarget.fromJson(Map<String, dynamic> json) =>
      NarrativeTarget(
        targetEventId: json['targetEventId'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        chapterIndex: json['chapterIndex'] as int,
        sourceEvidence: (json['sourceEvidence'] as List<dynamic>)
            .map((e) => SourceEvidence.fromJson(e as Map<String, dynamic>))
            .toList(),
        prerequisites: (json['prerequisites'] as List<dynamic>).cast<String>(),
        reasonForSelection: json['reasonForSelection'] as String,
        narrativeDifficulty: (json['narrativeDifficulty'] as num).toDouble(),
        introducedCharacters: (json['introducedCharacters'] as List<dynamic>)
            .cast<String>(),
        introducedLocations: (json['introducedLocations'] as List<dynamic>)
            .cast<String>(),
        linguisticConstraints:
            json['linguisticConstraints'] as Map<String, dynamic>? ?? const {},
      );
}
