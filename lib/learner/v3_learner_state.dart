/// V3 Decoupled Learner State (Contract 5).
///
/// Strictly separates:
/// 1. [LinguisticLearnerState] — what Chinese language (Hanzi, words, grammar) the learner knows.
/// 2. [NarrativeLearnerState] — what story information (characters, events, locations, threads) the learner has encountered.
///
/// These two states evolve independently and are never conflated.
library;

/// Represents the learner's linguistic proficiency.
final class LinguisticLearnerState {
  const LinguisticLearnerState({
    this.knownCharacters = const {},
    this.knownWords = const {},
    this.knownGrammarPatterns = const {},
    this.estimatedDifficulty = 1.0,
    this.recentlyIntroducedWords = const [],
    this.wordMastery = const {},
  });

  final Set<String> knownCharacters;
  final Set<String> knownWords;
  final Set<String> knownGrammarPatterns;
  final double estimatedDifficulty;
  final List<String> recentlyIntroducedWords;
  final Map<String, double> wordMastery;

  /// Returns a new state after learning the specified words and their characters.
  LinguisticLearnerState recordLearnedWords(
    Set<String> words, {
    double? newDifficulty,
  }) {
    final updatedWords = {...knownWords, ...words};
    final updatedChars = {...knownCharacters};
    final updatedMastery = {...wordMastery};

    for (final w in words) {
      for (int i = 0; i < w.length; i++) {
        updatedChars.add(w[i]);
      }
      updatedMastery[w] = 1.0;
    }

    final recent = [...words, ...recentlyIntroducedWords].take(30).toList();

    return LinguisticLearnerState(
      knownCharacters: Set.unmodifiable(updatedChars),
      knownWords: Set.unmodifiable(updatedWords),
      knownGrammarPatterns: knownGrammarPatterns,
      estimatedDifficulty: newDifficulty ?? estimatedDifficulty,
      recentlyIntroducedWords: List.unmodifiable(recent),
      wordMastery: Map.unmodifiable(updatedMastery),
    );
  }

  /// Calculates the fraction of a given text's words that are known.
  double computeKnownRatio(Iterable<String> words) {
    final list = words.toList();
    if (list.isEmpty) return 1.0;
    int knownCount = 0;
    for (final w in list) {
      if (knownWords.contains(w)) {
        knownCount++;
      }
    }
    return knownCount / list.length;
  }

  Map<String, dynamic> toJson() => {
    'knownCharacters': knownCharacters.toList(),
    'knownWords': knownWords.toList(),
    'knownGrammarPatterns': knownGrammarPatterns.toList(),
    'estimatedDifficulty': estimatedDifficulty,
    'recentlyIntroducedWords': recentlyIntroducedWords,
    'wordMastery': wordMastery,
  };

  factory LinguisticLearnerState.fromJson(
    Map<String, dynamic> json,
  ) => LinguisticLearnerState(
    knownCharacters: (json['knownCharacters'] as List<dynamic>)
        .cast<String>()
        .toSet(),
    knownWords: (json['knownWords'] as List<dynamic>).cast<String>().toSet(),
    knownGrammarPatterns:
        (json['knownGrammarPatterns'] as List<dynamic>?)
            ?.cast<String>()
            .toSet() ??
        const {},
    estimatedDifficulty: (json['estimatedDifficulty'] as num).toDouble(),
    recentlyIntroducedWords:
        (json['recentlyIntroducedWords'] as List<dynamic>?)?.cast<String>() ??
        const [],
    wordMastery:
        (json['wordMastery'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ) ??
        const {},
  );
}

/// Represents the learner's narrative comprehension of the Mother Story.
final class NarrativeLearnerState {
  const NarrativeLearnerState({
    this.encounteredCharacters = const {},
    this.understoodRelationships = const {},
    this.encounteredEvents = const {},
    this.openedThreads = const {},
    this.resolvedThreads = const {},
    this.encounteredLocations = const {},
    this.introducedConcepts = const {},
    this.representedSourceRegions = const {},
  });

  final Set<String> encounteredCharacters;
  final Set<String> understoodRelationships;
  final Set<String> encounteredEvents;
  final Set<String> openedThreads;
  final Set<String> resolvedThreads;
  final Set<String> encounteredLocations;
  final Set<String> introducedConcepts;
  final Set<int> representedSourceRegions;

  /// Returns a new state after exposing an event.
  NarrativeLearnerState recordEventExposed({
    required String eventId,
    required int chapterIndex,
    Iterable<String> characterIds = const [],
    Iterable<String> locationIds = const [],
    String? openedThread,
    String? resolvedThread,
  }) {
    final updatedEvents = {...encounteredEvents, eventId};
    final updatedChars = {...encounteredCharacters, ...characterIds};
    final updatedLocs = {...encounteredLocations, ...locationIds};
    final updatedRegions = {...representedSourceRegions, chapterIndex};

    final updatedOpened = {...openedThreads};
    if (openedThread != null) updatedOpened.add(openedThread);

    final updatedResolved = {...resolvedThreads};
    if (resolvedThread != null) updatedResolved.add(resolvedThread);

    return NarrativeLearnerState(
      encounteredCharacters: Set.unmodifiable(updatedChars),
      understoodRelationships: understoodRelationships,
      encounteredEvents: Set.unmodifiable(updatedEvents),
      openedThreads: Set.unmodifiable(updatedOpened),
      resolvedThreads: Set.unmodifiable(updatedResolved),
      encounteredLocations: Set.unmodifiable(updatedLocs),
      introducedConcepts: introducedConcepts,
      representedSourceRegions: Set.unmodifiable(updatedRegions),
    );
  }

  /// Returns a new state after understanding a character relationship.
  NarrativeLearnerState recordRelationshipUnderstood(String relationshipId) {
    final updatedRels = {...understoodRelationships, relationshipId};
    return NarrativeLearnerState(
      encounteredCharacters: encounteredCharacters,
      understoodRelationships: Set.unmodifiable(updatedRels),
      encounteredEvents: encounteredEvents,
      openedThreads: openedThreads,
      resolvedThreads: resolvedThreads,
      encounteredLocations: encounteredLocations,
      introducedConcepts: introducedConcepts,
      representedSourceRegions: representedSourceRegions,
    );
  }

  Map<String, dynamic> toJson() => {
    'encounteredCharacters': encounteredCharacters.toList(),
    'understoodRelationships': understoodRelationships.toList(),
    'encounteredEvents': encounteredEvents.toList(),
    'openedThreads': openedThreads.toList(),
    'resolvedThreads': resolvedThreads.toList(),
    'encounteredLocations': encounteredLocations.toList(),
    'introducedConcepts': introducedConcepts.toList(),
    'representedSourceRegions': representedSourceRegions.toList(),
  };

  factory NarrativeLearnerState.fromJson(
    Map<String, dynamic> json,
  ) => NarrativeLearnerState(
    encounteredCharacters: (json['encounteredCharacters'] as List<dynamic>)
        .cast<String>()
        .toSet(),
    understoodRelationships: (json['understoodRelationships'] as List<dynamic>)
        .cast<String>()
        .toSet(),
    encounteredEvents: (json['encounteredEvents'] as List<dynamic>)
        .cast<String>()
        .toSet(),
    openedThreads:
        (json['openedThreads'] as List<dynamic>?)?.cast<String>().toSet() ??
        const {},
    resolvedThreads:
        (json['resolvedThreads'] as List<dynamic>?)?.cast<String>().toSet() ??
        const {},
    encounteredLocations:
        (json['encounteredLocations'] as List<dynamic>?)
            ?.cast<String>()
            .toSet() ??
        const {},
    introducedConcepts:
        (json['introducedConcepts'] as List<dynamic>?)
            ?.cast<String>()
            .toSet() ??
        const {},
    representedSourceRegions:
        (json['representedSourceRegions'] as List<dynamic>?)
            ?.cast<int>()
            .toSet() ??
        const {},
  );
}

/// Complete V3 Decoupled Learner State.
final class V3LearnerState {
  const V3LearnerState({
    required this.learnerId,
    required this.linguistic,
    required this.narrative,
  });

  final String learnerId;
  final LinguisticLearnerState linguistic;
  final NarrativeLearnerState narrative;

  V3LearnerState copyWith({
    LinguisticLearnerState? linguistic,
    NarrativeLearnerState? narrative,
  }) {
    return V3LearnerState(
      learnerId: learnerId,
      linguistic: linguistic ?? this.linguistic,
      narrative: narrative ?? this.narrative,
    );
  }

  Map<String, dynamic> toJson() => {
    'learnerId': learnerId,
    'linguistic': linguistic.toJson(),
    'narrative': narrative.toJson(),
  };

  factory V3LearnerState.fromJson(Map<String, dynamic> json) => V3LearnerState(
    learnerId: json['learnerId'] as String,
    linguistic: LinguisticLearnerState.fromJson(
      json['linguistic'] as Map<String, dynamic>,
    ),
    narrative: NarrativeLearnerState.fromJson(
      json['narrative'] as Map<String, dynamic>,
    ),
  );
}
