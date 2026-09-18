/// Pure-exposure gate and recognition unlock pacing (CHOICES.md §1,
/// LEARNING_ENGINE.md §4, dev_graph.json T_ENG_020).
///
/// The learner model owns this rule and it lives nowhere else. Inputs are
/// explicit learning records only (exposure aggregates); no behavioral
/// signals can open the gate. Pure Dart: runnable on synthetic states
/// without a database, unit-testable at exact boundaries.
library;

import '../core/ids.dart';
import 'learner_state.dart';

/// Total explicit encounters required before any recall testing may begin
/// (CHOICES.md §1: ~500–600 exposures across the bootstrap lexicon).
const int kExposurePhaseTotal = 500;

/// Minimum encounters per word before that word may be tested at all.
/// Bottom of the 4–6 exposure band (CHOICES.md §1): a word seen once or
/// twice is still being absorbed, not ready for recall.
const int kPerWordExposureFloor = 4;

/// Minimum number of review-ready words required before the first unlock.
/// Prevents a learner with a handful of over-exposed words from entering
/// review while the rest of the lexicon is still being absorbed.
const int kUnlockCohortMinimum = 10;

/// Maximum cards presented in the first review session after unlock, so
/// recognition eases in instead of flooding (pacing; not a deck limit —
/// purely an unlock-ramp, invisible to the learner).
const int kFirstSessionCohortSize = 5;

/// Immutable gate evaluation result. Internals stay internal (AGENTS.md
/// §3.11): nothing here is ever surfaced to the learner.
final class ExposureGateStatus {
  const ExposureGateStatus({
    required this.totalExposures,
    required this.reviewReadyVocab,
    required this.isUnlocked,
  });

  /// Total explicit encounters accumulated during the exposure phase.
  final int totalExposures;

  /// Vocabulary ids that individually satisfy the per-word exposure floor,
  /// in stable absorption order (oldest firstSeen first).
  final List<VocabId> reviewReadyVocab;

  /// Whether recognition/review is unlocked for this learner state.
  final bool isUnlocked;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExposureGateStatus &&
          totalExposures == other.totalExposures &&
          isUnlocked == other.isUnlocked &&
          reviewReadyVocab.length == other.reviewReadyVocab.length;

  @override
  int get hashCode =>
      totalExposures.hashCode ^ isUnlocked.hashCode ^ reviewReadyVocab.length;
}

/// Evaluates the pure-exposure gate for a learner state.
///
/// Unlock conditions (all required, CHOICES.md §1):
/// 1. Total explicit exposures ≥ [kExposurePhaseTotal].
/// 2. At least [kUnlockCohortMinimum] words individually meet the
///    per-word exposure floor.
///
/// The per-word floor is what paces the unlock: exposure mass concentrated
/// in few words does not open the gate; broad lexical coverage does.
ExposureGateStatus evaluateExposureGate(LearnerState learner) {
  var total = 0;
  final ready = <(VocabId, DateTime)>[];

  for (final aggregate in learner.exposure.values) {
    total += aggregate.encounterCount;
    if (aggregate.encounterCount >= kPerWordExposureFloor) {
      ready.add((aggregate.vocabId, aggregate.firstSeen));
    }
  }

  // Stable order: oldest first-seen first, then by id for determinism.
  ready.sort((a, b) {
    final cmp = a.$2.compareTo(b.$2);
    if (cmp != 0) return cmp;
    return a.$1.compareTo(b.$1);
  });

  final unlocked =
      total >= kExposurePhaseTotal && ready.length >= kUnlockCohortMinimum;

  return ExposureGateStatus(
    totalExposures: total,
    reviewReadyVocab: ready.map((e) => e.$1).toList(),
    isUnlocked: unlocked,
  );
}

/// Returns the card order for a first review session after unlock:
/// the earliest-absorbed ready words first, capped to ramp pacing.
///
/// Empty when the gate is still closed. The cap is an unlock ramp, not a
/// daily limit — subsequent sessions present the remaining ready cohort.
List<VocabId> firstUnlockCohort(ExposureGateStatus status) {
  if (!status.isUnlocked) return const [];
  return status.reviewReadyVocab.take(kFirstSessionCohortSize).toList();
}
