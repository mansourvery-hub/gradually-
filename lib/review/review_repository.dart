/// Persistence interface for review cards and scheduler state (ARCHITECTURE.md §2, §4).
library;

import '../core/ids.dart';
import '../learner/known.dart';
import 'review.dart';

/// Repository interface for storing and retrieving review cards.
abstract interface class ReviewRepository {
  /// Fetches cards that are due on or before [now].
  Future<List<ReviewCardRecord>> getDueCards({required DateTime now});

  /// Fetches all cards in the review system.
  Future<List<ReviewCardRecord>> getAllCards();

  /// Gets a card record by its vocabulary ID, if it exists.
  Future<ReviewCardRecord?> getCardByVocabId(VocabId vocabId);

  /// Saves or updates a review card and its scheduler state.
  Future<void> saveCard(ReviewCardRecord cardRecord);

  /// Records review outcome and emits [MasteryEvidence] to learner model.
  Future<void> recordReviewOutcome({
    required ReviewOutcome outcome,
    required ReviewCardRecord updatedCardRecord,
    required MasteryEvidence evidence,
  });
}
