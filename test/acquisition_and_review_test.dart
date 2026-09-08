import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/acquisition/acquisition.dart';
import 'package:jianru/core/token.dart';
import 'package:jianru/data/database.dart';
import 'package:jianru/data/repositories/learner_repository_impl.dart';
import 'package:jianru/data/repositories/review_repository_impl.dart';
import 'package:jianru/learner/known.dart';
import 'package:jianru/learner/learner_state.dart';
import 'package:jianru/review/fsrs_review_system.dart';
import 'package:jianru/review/review.dart';

void main() {
  late AppDatabase db;
  late DriftLearnerRepository learnerRepo;
  late DriftReviewRepository reviewRepo;
  late FsrsReviewSystem reviewSystem;
  late V1AcquisitionPipeline pipeline;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    learnerRepo = DriftLearnerRepository(db);
    reviewRepo = DriftReviewRepository(db);
    reviewSystem = FsrsReviewSystem(repository: reviewRepo);
    pipeline = V1AcquisitionPipeline(reviewRepository: reviewRepo);
  });

  tearDown(() async {
    await db.close();
  });

  group('V1AcquisitionPipeline', () {
    test('promotes curriculum-critical vocabulary on first encounter', () async {
      final now = DateTime(2026, 9, 8);
      const learner = LearnerState();

      final promotedCard = await pipeline.evaluateAndPromote(
        learner: learner,
        vocabId: '水',
        contentId: 'unit-1',
        sourceSentenceText: '我想喝水。',
        token: const Token(vocabId: '水', surface: '水', start: 3, end: 4),
        isCurriculumCritical: true,
        now: now,
      );

      expect(promotedCard, isNotNull);
      expect(promotedCard?.card.vocabId, '水');
      expect(promotedCard?.card.sourceSentence, '我想喝水。');

      // Verify card was persisted in review repository
      final savedCard = await reviewRepo.getCardByVocabId('水');
      expect(savedCard, isNotNull);
      expect(savedCard?.card.vocabId, '水');
    });

    test('does NOT promote known words or duplicate existing cards', () async {
      final now = DateTime(2026, 9, 8);
      const learner = LearnerState(knownVocabulary: {'水'});

      final promotedCard = await pipeline.evaluateAndPromote(
        learner: learner,
        vocabId: '水',
        contentId: 'unit-1',
        sourceSentenceText: '我想喝水。',
        token: const Token(vocabId: '水', surface: '水', start: 3, end: 4),
        isCurriculumCritical: true,
        now: now,
      );

      expect(promotedCard, isNull, reason: 'Already known words should not be promoted');
    });
  });

  group('FsrsReviewSystem', () {
    test('processOutcome schedules card in future on remembered grade', () async {
      final now = DateTime(2026, 9, 8, 12, 0);

      final initialCard = ReviewCardRecord(
        card: const ReviewCard(
          id: 'card-1',
          vocabId: '水',
          sourceSentence: '我想喝水。',
          targetEmphasis: (start: 3, end: 4),
        ),
        fsrsCardStateJson: '{"state": 1}',
        due: DateTime(2026, 9, 8, 11, 0),
      );

      await reviewRepo.saveCard(initialCard);

      final evidence = await reviewSystem.processOutcome(
        cardRecord: initialCard,
        grade: RecallGrade.remembered,
        now: now,
      );

      expect(evidence.vocabId, '水');
      expect(evidence.grade, RecallGrade.remembered);

      // Verify card's due date was moved to the future by FSRS
      final updatedCard = await reviewRepo.getCardByVocabId('水');
      expect(updatedCard, isNotNull);
      expect(updatedCard!.due.isAfter(now), isTrue);

      // Verify mastery evidence makes vocab known in LearnerState
      final learnerState = await learnerRepo.getLearnerState();
      expect(learnerState.isVocabKnown('水'), isTrue);
    });

    test('gradeToRating maps 3-grade recall to FSRS ratings correctly', () {
      expect(
        FsrsReviewSystem.gradeToRating(RecallGrade.remembered).name,
        'good',
      );
      expect(
        FsrsReviewSystem.gradeToRating(RecallGrade.partiallyRemembered).name,
        'hard',
      );
      expect(
        FsrsReviewSystem.gradeToRating(RecallGrade.forgotten).name,
        'again',
      );
    });
  });
}
