/// Learner Model (E-04): known Hanzi + known vocabulary + bounded exposure
/// aggregates. First-order approximation of reading ability.
///
/// Invariants (LEARNING_ENGINE.md §2): no SRS internals here — no intervals,
/// ease, or memory-state fields. The learner model receives mastery evidence
/// and maintains learner-level knowledge only.
library;

import '../core/hanzi.dart';
import '../core/ids.dart';

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
}

/// Learner-level knowledge state. Computed from mastery evidence; the "known"
/// rule lives here and nowhere else (LEARNING_ENGINE.md §2).
final class LearnerState {
  const LearnerState({
    this.knownVocabulary = const {},
    this.knownHanzi = const {},
    this.exposure = const {},
  });

  /// All words ever encountered, as bounded aggregates.
  final Map<VocabId, ExposureAggregate> exposure;

  /// Vocabulary ids the learner knows, derived from mastery evidence.
  final Set<VocabId> knownVocabulary;

  /// Hanzi the learner knows (V1 [PROPOSED]: derived from known vocabulary
  /// plus beginner recognition outcomes).
  final Set<Hanzi> knownHanzi;

  /// Words never encountered by this learner.
  ///
  /// Derived on demand from corpus vocabulary — the corpus is not stored
  /// here, so this accessor is intentionally absent; selectors compute
  /// unknowns against candidate content directly.
}
