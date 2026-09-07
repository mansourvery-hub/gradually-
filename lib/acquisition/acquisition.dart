/// Acquisition pipeline boundary (E-05, LEARNING_ENGINE.md §3).
///
/// Distinct states: unknown encounter → acquisition candidate → promoted
/// to SRS → established knowledge. Never `unknown == flashcard`. Candidate
/// records are separate from cards and from learner state.
library;

import '../core/ids.dart';
import '../learner/learner_state.dart';

/// A word under consideration for promotion to SRS.
final class AcquisitionCandidate {
  const AcquisitionCandidate({
    required this.vocabId,
    required this.encounterCount,
    required this.distinctContentItems,
    required this.curriculumCritical,
  });

  final VocabId vocabId;

  /// Recurrence across reading (from the bounded exposure aggregate).
  final int encounterCount;

  /// Distinct stories/units the word has appeared in.
  final int distinctContentItems;

  /// Flag from content metadata; informs promotion (CONTENT.md §5).
  final bool curriculumCritical;
}

/// [PROPOSED] V1 promotion rule: a single, named, unit-tested rule combining
/// recurrence count across content with a curriculum-importance flag. Keep
/// in `acquisition/`, replaceable (LEARNING_ENGINE.md §3).
final class V1PromotionRule {
  const V1PromotionRule({
    this.minEncounters = 3,
    this.minDistinctContentItems = 2,
  });

  static const criticalMinEncounters = 1;

  final int minEncounters;
  final int minDistinctContentItems;

  /// Decides whether an encountered word becomes an SRS card. Curriculum-
  /// critical words promote on first encounter; ordinary words need
  /// recurrence across more than one content item.
  bool shouldPromote(AcquisitionCandidate candidate) {
    if (candidate.curriculumCritical) {
      return candidate.encounterCount >= criticalMinEncounters;
    }
    return candidate.encounterCount >= minEncounters &&
        candidate.distinctContentItems >= minDistinctContentItems;
  }
}

/// Consumes encounters from reading; creates candidates; promotes to SRS.
/// [PROPOSED] V1 pipeline service skeleton.
abstract interface class AcquisitionPipeline {
  /// Called when the learner reads a word that is not yet known.
  void onUnknownEncounter(
    LearnerState learner,
    VocabId vocabId,
    ContentId contentId,
  );
}
