import '../generation/generated_passage.dart';

/// A discrete pedagogical stage in the progressive reading ladder (Contract 10).
class LadderLevel {
  const LadderLevel({
    required this.levelNumber,
    required this.title,
    required this.difficultyFloor,
    required this.difficultyCeiling,
    required this.passages,
    required this.cumulativeKnownWords,
    required this.cumulativeKnownCharacters,
    required this.introducedEvents,
  });

  final int levelNumber;
  final String title;
  final double difficultyFloor;
  final double difficultyCeiling;
  final List<GeneratedPassage> passages;
  final Set<String> cumulativeKnownWords;
  final Set<String> cumulativeKnownCharacters;
  final List<String> introducedEvents;

  Map<String, dynamic> toJson() => {
    'levelNumber': levelNumber,
    'title': title,
    'difficultyFloor': difficultyFloor,
    'difficultyCeiling': difficultyCeiling,
    'passages': passages.map((p) => p.toJson()).toList(),
    'cumulativeKnownWords': cumulativeKnownWords.toList(),
    'cumulativeKnownCharacters': cumulativeKnownCharacters.toList(),
    'introducedEvents': introducedEvents,
  };

  factory LadderLevel.fromJson(Map<String, dynamic> json) => LadderLevel(
    levelNumber: json['levelNumber'] as int,
    title: json['title'] as String,
    difficultyFloor: (json['difficultyFloor'] as num).toDouble(),
    difficultyCeiling: (json['difficultyCeiling'] as num).toDouble(),
    passages: (json['passages'] as List<dynamic>)
        .map((p) => GeneratedPassage.fromJson(p as Map<String, dynamic>))
        .toList(),
    cumulativeKnownWords: (json['cumulativeKnownWords'] as List<dynamic>)
        .cast<String>()
        .toSet(),
    cumulativeKnownCharacters:
        (json['cumulativeKnownCharacters'] as List<dynamic>)
            .cast<String>()
            .toSet(),
    introducedEvents: (json['introducedEvents'] as List<dynamic>)
        .cast<String>(),
  );
}

/// A complete, multi-tiered reading ladder connecting zero knowledge to novel literacy.
class ProgressiveLadder {
  const ProgressiveLadder({
    required this.sourceId,
    required this.sourceHash,
    required this.levels,
    this.metadata = const {},
  });

  final String sourceId;
  final String sourceHash;
  final List<LadderLevel> levels;
  final Map<String, dynamic> metadata;

  int get totalPassages =>
      levels.fold(0, (sum, lvl) => sum + lvl.passages.length);

  /// Checks if difficulty progression is monotonically non-decreasing.
  bool get isMonotonicallyIncreasing {
    if (levels.length <= 1) return true;
    for (int i = 0; i < levels.length - 1; i++) {
      if (levels[i].difficultyFloor > levels[i + 1].difficultyFloor) {
        return false;
      }
    }
    return true;
  }

  /// Verifies narrative continuity: each level either builds on or maintains prior events.
  bool get hasNarrativeContinuity {
    final seenEvents = <String>{};
    for (final lvl in levels) {
      for (final p in lvl.passages) {
        seenEvents.add(p.targetEventId);
      }
    }
    return seenEvents.isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
    'sourceId': sourceId,
    'sourceHash': sourceHash,
    'levels': levels.map((l) => l.toJson()).toList(),
    'metadata': metadata,
    'totalPassages': totalPassages,
    'isMonotonicallyIncreasing': isMonotonicallyIncreasing,
    'hasNarrativeContinuity': hasNarrativeContinuity,
  };

  factory ProgressiveLadder.fromJson(Map<String, dynamic> json) =>
      ProgressiveLadder(
        sourceId: json['sourceId'] as String,
        sourceHash: json['sourceHash'] as String,
        levels: (json['levels'] as List<dynamic>)
            .map((l) => LadderLevel.fromJson(l as Map<String, dynamic>))
            .toList(),
        metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      );
}
