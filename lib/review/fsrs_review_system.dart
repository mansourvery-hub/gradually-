/// FSRS-based implementation of [ReviewSystem] (D-04, E-03, LEARNING_ENGINE.md §4).
///
/// Pure Dart adapter; separates scheduling algorithm from card data and
/// emits explicit mastery evidence to the learner model.
library;

import 'dart:convert';

import 'package:fsrs/fsrs.dart' as fsrs;

import '../learner/known.dart';
import 'review.dart';
import 'review_repository.dart';

/// Spaced repetition system adapter powered by FSRS.
final class FsrsReviewSystem implements ReviewSystem {
  FsrsReviewSystem({
    required ReviewRepository repository,
    fsrs.Scheduler? scheduler,
  }) : _repository = repository,
       _scheduler = scheduler ?? fsrs.Scheduler();

  final ReviewRepository _repository;
  final fsrs.Scheduler _scheduler;

  /// Maps beginner 3-grade recall outcomes to FSRS ratings (D-04).
  static fsrs.Rating gradeToRating(RecallGrade grade) {
    switch (grade) {
      case RecallGrade.remembered:
        return fsrs.Rating.good;
      case RecallGrade.partiallyRemembered:
        return fsrs.Rating.hard;
      case RecallGrade.forgotten:
        return fsrs.Rating.again;
    }
  }

  @override
  List<ReviewCard> dueCards({required DateTime now}) {
    // Synchronous interface method; async queries go through repository
    throw UnimplementedError('Use fetchDueCards() for async loading');
  }

  /// Fetches cards currently due from repository.
  Future<List<ReviewCardRecord>> fetchDueCards({required DateTime now}) {
    return _repository.getDueCards(now: now);
  }

  /// Processes a review outcome, updates the FSRS card scheduling, saves to
  /// repository, and returns the emitted [MasteryEvidence] for the learner model.
  Future<MasteryEvidence> processOutcome({
    required ReviewCardRecord cardRecord,
    required RecallGrade grade,
    required DateTime now,
  }) async {
    // 1. Reconstitute FSRS Card from opaque JSON
    fsrs.Card fsrsCard;
    try {
      final map =
          jsonDecode(cardRecord.fsrsCardStateJson) as Map<String, dynamic>;
      fsrsCard = fsrs.Card.fromMap(map);
    } catch (_) {
      fsrsCard = fsrs.Card(cardId: cardRecord.card.id.hashCode);
    }

    // 2. Compute next schedule with FSRS
    final rating = gradeToRating(grade);
    final (:card, :reviewLog) = _scheduler.reviewCard(fsrsCard, rating);

    // 3. Serialize updated card state
    final updatedRecord = ReviewCardRecord(
      card: cardRecord.card,
      fsrsCardStateJson: jsonEncode(card.toMap()),
      due: card.due.toLocal(),
    );

    // 4. Create explicit mastery evidence for learner state
    final outcome = ReviewOutcome(
      cardId: cardRecord.card.id,
      vocabId: cardRecord.card.vocabId,
      grade: grade,
      at: now,
    );
    final evidence = outcome.toEvidence();

    // 5. Save in repository (updates review card + writes mastery evidence)
    await _repository.recordReviewOutcome(
      outcome: outcome,
      updatedCardRecord: updatedRecord,
      evidence: evidence,
    );

    return evidence;
  }

  @override
  MasteryEvidence submitOutcome(ReviewOutcome outcome) {
    return outcome.toEvidence();
  }
}
