/// Review subsystem boundary (E-03, LEARNING_ENGINE.md §4).
///
/// Review owns cards and scheduling. The learner model consumes mastery
/// evidence; scheduler internals never leak into learner state. Card data
/// is separated from the scheduler implementation (D-04) so the algorithm
/// can change without touching cards.
library;

import '../core/ids.dart';
import '../learner/known.dart'
    show MasteryEvidence, MasteryEvidenceKind, RecallGrade;

/// A review card. Media fields are optional (E-08); provenance and the
/// strongest available context are preserved.
final class ReviewCard {
  const ReviewCard({
    required this.id,
    required this.vocabId,
    required this.sourceSentence,
    required this.targetEmphasis,
    this.visualAsset,
    this.wordAudio,
  });

  final CardId id;
  final VocabId vocabId;

  /// Full source sentence (sentence-based cards, later phase).
  final String sourceSentence;

  /// Which span of the sentence is the target word.
  final ({int start, int end}) targetEmphasis;

  /// Story visual when available (optional, E-08).
  final String? visualAsset;

  /// Native word audio when available (optional, E-08).
  final String? wordAudio;
}

/// A complete record storing a [ReviewCard] and its scheduler state
/// (separated per D-04, E-03).
final class ReviewCardRecord {
  const ReviewCardRecord({
    required this.card,
    required this.fsrsCardStateJson,
    required this.due,
  });

  final ReviewCard card;

  /// Opaque JSON representation of FSRS Card state (D-04).
  /// Internals never leak into learner state or UI.
  final String fsrsCardStateJson;

  /// When this card is due for review.
  final DateTime due;
}

/// Review outcome → mastery evidence emitted to the learner model.
final class ReviewOutcome {
  const ReviewOutcome({
    required this.cardId,
    required this.vocabId,
    required this.grade,
    required this.at,
  });

  final CardId cardId;
  final VocabId vocabId;
  final RecallGrade grade;
  final DateTime at;

  MasteryEvidence toEvidence() => MasteryEvidence(
    vocabId: vocabId,
    kind: MasteryEvidenceKindMeaningPlaceholder.kind,
    grade: grade,
    at: at,
  );
}

/// Temporary alias keeping review outcome → evidence mapping in one place
/// until the beginner phase defines per-aspect outcomes.
final class MasteryEvidenceKindMeaningPlaceholder {
  const MasteryEvidenceKindMeaningPlaceholder._();

  static const kind = MasteryEvidenceKind.meaning;
}

/// Owns cards and scheduling; answers "what's due?" — never "what's next?"
abstract interface class ReviewSystem {
  /// Cards currently due, in review order.
  List<ReviewCard> dueCards({required DateTime now});

  /// Applies an outcome and returns updated mastery evidence.
  MasteryEvidence submitOutcome(ReviewOutcome outcome);
}
