/// Learner Model (E-04): known Hanzi + known vocabulary + bounded exposure
/// aggregates. First-order approximation of reading ability.
///
/// Invariants (LEARNING_ENGINE.md §2): no SRS internals here — no intervals,
/// ease, or memory-state fields. The learner model receives mastery evidence
/// and maintains learner-level knowledge only.
library;

import '../core/hanzi.dart';
import '../core/ids.dart';
import '../core/progress.dart';

/// Bounded per-word exposure aggregate (LEARNING_ENGINE.md §2).
///
/// Updated **in place** on every encounter — never appended to. Rereading a
/// story increments counters; it adds no rows. Records *what was
/// encountered*, never behavior.
final class ExposureAggregate {
  const ExposureAggregate({
    required this.vocabId,
    required this.encounterCount,
    required this.contentItemIds,
    required this.firstSeen,
    required this.lastSeen,
  });

  ExposureAggregate.firstEncounter({
    required this.vocabId,
    required ContentId contentId,
    required DateTime now,
  }) : encounterCount = 1,
       contentItemIds = {contentId},
       firstSeen = now,
       lastSeen = now;

  final VocabId vocabId;

  /// Total encounters across all reading, including rereads.
  final int encounterCount;

  /// Distinct content items the word appeared in while the learner read
  /// them. Bounded by corpus size.
  final Set<ContentId> contentItemIds;

  final DateTime firstSeen;
  final DateTime lastSeen;

  /// Returns the aggregate after one more encounter in [contentId].
  ExposureAggregate recordEncounter(ContentId contentId, DateTime now) {
    return ExposureAggregate(
      vocabId: vocabId,
      encounterCount: encounterCount + 1,
      contentItemIds: {...contentItemIds, contentId},
      firstSeen: firstSeen,
      lastSeen: now,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExposureAggregate &&
          runtimeType == other.runtimeType &&
          vocabId == other.vocabId &&
          encounterCount == other.encounterCount &&
          firstSeen == other.firstSeen &&
          lastSeen == other.lastSeen;

  @override
  int get hashCode =>
      vocabId.hashCode ^
      encounterCount.hashCode ^
      firstSeen.hashCode ^
      lastSeen.hashCode;
}

/// Learner-level knowledge state. Computed from mastery evidence; the "known"
/// rule lives here and nowhere else (LEARNING_ENGINE.md §2).
final class LearnerState {
  const LearnerState({
    this.knownVocabulary = const {},
    this.knownHanzi = const {},
    this.exposure = const {},
    this.progress = const {},
  });

  /// All words ever encountered, as bounded aggregates.
  final Map<VocabId, ExposureAggregate> exposure;

  /// Vocabulary ids the learner knows, derived from mastery evidence.
  final Set<VocabId> knownVocabulary;

  /// Hanzi the learner knows (V1: derived from known vocabulary
  /// plus beginner recognition outcomes).
  final Set<Hanzi> knownHanzi;

  /// Content reading progress and completion history across all content items.
  final Map<ContentId, ContentProgress> progress;

  /// Whether a vocabulary item is known by this learner.
  bool isVocabKnown(VocabId vocabId) => knownVocabulary.contains(vocabId);

  /// Whether a Hanzi character is known by this learner.
  bool isHanziKnown(Hanzi hanzi) => knownHanzi.contains(hanzi);

  /// Whether a content item has been completed by this learner.
  bool isContentCompleted(ContentId contentId) =>
      progress[contentId]?.isCompleted ?? false;

  /// Vocabulary the learner has explicitly encountered (bounded exposure
  /// aggregates). This is the *seen* signal — it exists before any review
  /// or mastery evidence, so selection can be exposure-driven during the
  /// pure-exposure phase (LEARNING_ENGINE.md §2 allowed inputs).
  Set<VocabId> get seenVocabulary => exposure.keys.toSet();

  /// Returns a copy with the given fields replaced.
  LearnerState copyWith({
    Set<VocabId>? knownVocabulary,
    Set<Hanzi>? knownHanzi,
    Map<VocabId, ExposureAggregate>? exposure,
    Map<ContentId, ContentProgress>? progress,
  }) {
    return LearnerState(
      knownVocabulary: knownVocabulary ?? this.knownVocabulary,
      knownHanzi: knownHanzi ?? this.knownHanzi,
      exposure: exposure ?? this.exposure,
      progress: progress ?? this.progress,
    );
  }
}
