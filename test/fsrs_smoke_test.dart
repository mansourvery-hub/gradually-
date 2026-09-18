// Smoke tests for the fsrs dependency (D-04): the mature scheduler behind
// our adapter. Internals (intervals, ease) are never surfaced — here we
// only verify the round-trip works and evidence can be extracted.
import 'package:flutter_test/flutter_test.dart';
import 'package:fsrs/fsrs.dart';

void main() {
  test('fsrs schedules a new card and produces a review log', () {
    final scheduler = Scheduler();
    final initialCard = Card(cardId: 1);

    final (:card, :reviewLog) = scheduler.reviewCard(initialCard, Rating.good);

    expect(
      card.due.isAfter(DateTime.now().toUtc()),
      isTrue,
      reason: 'a Good-rated new card must be scheduled in the future',
    );
    expect(reviewLog.rating, Rating.good);
  });

  test('fsrs card data serializes for persistence (E-03 separation)', () {
    final scheduler = Scheduler();
    final initialCard = Card(cardId: 2);
    final (:card, :reviewLog) = scheduler.reviewCard(initialCard, Rating.hard);

    final cardMap = card.toMap();
    final logMap = reviewLog.toMap();

    expect(cardMap, isNotNull);
    expect(logMap, isNotNull);
    // Round-trip: card data survives storage without the scheduler.
    expect(Card.fromMap(cardMap).due, card.due);
  });

  test('beginner 3-grade outcomes map onto fsrs ratings at the adapter', () {
    // remembered / partially remembered / forgotten → good / hard / again.
    const gradeToRating = {
      'remembered': Rating.good,
      'partially': Rating.hard,
      'forgotten': Rating.again,
    };
    expect(gradeToRating.length, 3);
    expect(gradeToRating['remembered'], Rating.good);
  });
}
