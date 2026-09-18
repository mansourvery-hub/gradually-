import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/core/hanzi.dart';
import 'package:jianru/core/progress.dart';
import 'package:jianru/data/database.dart';
import 'package:jianru/data/repositories/learner_repository_impl.dart';
import 'package:jianru/data/repositories/review_repository_impl.dart';
import 'package:jianru/learner/known.dart';
import 'package:jianru/review/review.dart';

void main() {
  late AppDatabase db;
  late DriftLearnerRepository learnerRepo;
  late DriftReviewRepository reviewRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    learnerRepo = DriftLearnerRepository(db);
    reviewRepo = DriftReviewRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftLearnerRepository', () {
    test(
      'recordExposure upserts bounded exposure aggregates correctly',
      () async {
        final t0 = DateTime(2026, 9, 8, 10, 0);
        final t1 = DateTime(2026, 9, 8, 11, 0);

        // 1st encounter in story-1
        await learnerRepo.recordExposure('你好', 'story-1', at: t0);

        var state = await learnerRepo.getLearnerState();
        expect(state.exposure['你好']?.encounterCount, 1);
        expect(state.exposure['你好']?.contentItemIds, {'story-1'});

        // 2nd encounter in story-1 (reread)
        await learnerRepo.recordExposure('你好', 'story-1', at: t1);

        state = await learnerRepo.getLearnerState();
        expect(state.exposure['你好']?.encounterCount, 2);
        expect(state.exposure['你好']?.contentItemIds, {
          'story-1',
        }, reason: 'reread adds no new content IDs');

        // 3rd encounter in story-2
        await learnerRepo.recordExposure('你好', 'story-2', at: t1);

        state = await learnerRepo.getLearnerState();
        expect(state.exposure['你好']?.encounterCount, 3);
        expect(state.exposure['你好']?.contentItemIds, {'story-1', 'story-2'});
      },
    );

    test(
      'updateContentProgress and getContentProgress round-trip correctly',
      () async {
        final now = DateTime(2026, 9, 8);
        final progress = ContentProgress.initial(
          contentId: 'story-1',
          now: now,
        ).updatePosition(15, now).recordCompletion(now);

        await learnerRepo.updateContentProgress(progress);

        final loaded = await learnerRepo.getContentProgress('story-1');
        expect(loaded, isNotNull);
        expect(loaded?.lastPosition, 15);
        expect(loaded?.completionCount, 1);
        expect(loaded?.isCompleted, isTrue);
      },
    );

    test(
      'recordMasteryEvidence updates known vocabulary and known Hanzi in LearnerState',
      () async {
        final now = DateTime(2026, 9, 8);
        final evidence = MasteryEvidence(
          vocabId: '你好',
          kind: MasteryEvidenceKind.meaning,
          grade: RecallGrade.remembered,
          at: now,
        );

        await learnerRepo.recordMasteryEvidence(evidence);

        final state = await learnerRepo.getLearnerState();
        expect(state.isVocabKnown('你好'), isTrue);
        expect(state.isHanziKnown(const Hanzi(character: '你')), isTrue);
        expect(state.isHanziKnown(const Hanzi(character: '好')), isTrue);
      },
    );
  });

  group('DriftReviewRepository', () {
    test('saveCard and getDueCards filter by due date correctly', () async {
      final now = DateTime(2026, 9, 8, 12, 0);

      final card1 = ReviewCardRecord(
        card: const ReviewCard(
          id: 'card-1',
          vocabId: '水',
          sourceSentence: '我想喝水。',
          targetEmphasis: (start: 3, end: 4),
        ),
        fsrsCardStateJson: '{"state": 1}',
        due: DateTime(2026, 9, 8, 11, 0),
      );

      final card2 = ReviewCardRecord(
        card: const ReviewCard(
          id: 'card-2',
          vocabId: '茶',
          sourceSentence: '我想喝茶。',
          targetEmphasis: (start: 3, end: 4),
        ),
        fsrsCardStateJson: '{"state": 1}',
        due: now.add(const Duration(days: 1)),
      );

      await reviewRepo.saveCard(card1);
      await reviewRepo.saveCard(card2);

      final dueCards = await reviewRepo.getDueCards(now: now);
      expect(dueCards.length, 1);
      expect(dueCards.first.card.id, 'card-1');
    });

    test(
      'recordReviewOutcome updates card and emits mastery evidence',
      () async {
        final now = DateTime(2026, 9, 8);
        final card = ReviewCardRecord(
          card: const ReviewCard(
            id: 'card-1',
            vocabId: '水',
            sourceSentence: '我想喝水。',
            targetEmphasis: (start: 3, end: 4),
          ),
          fsrsCardStateJson: '{"state": 1}',
          due: DateTime(2026, 9, 8, 10, 0),
        );

        await reviewRepo.saveCard(card);

        final outcome = ReviewOutcome(
          cardId: 'card-1',
          vocabId: '水',
          grade: RecallGrade.remembered,
          at: now,
        );

        final updatedRecord = ReviewCardRecord(
          card: card.card,
          fsrsCardStateJson: '{"state": 2}',
          due: now.add(const Duration(days: 3)),
        );

        await reviewRepo.recordReviewOutcome(
          outcome: outcome,
          updatedCardRecord: updatedRecord,
          evidence: outcome.toEvidence(),
        );

        // Verify card was updated
        final loadedCard = await reviewRepo.getCardByVocabId('水');
        expect(loadedCard?.fsrsCardStateJson, '{"state": 2}');

        // Verify mastery evidence was received by learner repo
        final learnerState = await learnerRepo.getLearnerState();
        expect(learnerState.isVocabKnown('水'), isTrue);
      },
    );
  });

  group('Privacy Invariant Check', () {
    test('database schema contains NO forbidden behavioral fields', () {
      final schemaTableNames = db.allTables
          .map((t) => t.actualTableName)
          .toList();
      expect(
        schemaTableNames,
        containsAll([
          'exposures',
          'content_progresses',
          'mastery_evidences',
          'review_cards',
        ]),
      );

      for (final table in db.allTables) {
        for (final col in table.$columns) {
          final name = col.$name.toLowerCase();
          expect(name, isNot(contains('hesitation')));
          expect(name, isNot(contains('speed')));
          expect(name, isNot(contains('scroll')));
          expect(name, isNot(contains('cursor')));
          expect(name, isNot(contains('engagement')));
          expect(name, isNot(contains('dwell')));
          expect(name, isNot(contains('profile')));
        }
      }
    });
  });
}
