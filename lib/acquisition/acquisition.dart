/// Acquisition pipeline boundary (E-05, LEARNING_ENGINE.md §3).
///
/// Distinct states: unknown encounter → acquisition candidate → promoted
/// to SRS → established knowledge. Never `unknown == flashcard`. Candidate
/// records are separate from cards and from learner state.
library;

import 'dart:convert';

import 'package:fsrs/fsrs.dart' as fsrs;

import '../core/ids.dart';
import '../core/token.dart';
import '../learner/learner_state.dart';
import '../review/review.dart';
import '../review/review_repository.dart';

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
abstract interface class AcquisitionPipeline {
  /// Evaluates an encountered vocabulary item for SRS card promotion.
  Future<ReviewCardRecord?> evaluateAndPromote({
    required LearnerState learner,
    required VocabId vocabId,
    required ContentId contentId,
    required String sourceSentenceText,
    required Token token,
    bool isCurriculumCritical = false,
    String? visualAsset,
    String? audioAsset,
    DateTime? now,
  });
}

/// V1 implementation of the acquisition pipeline (E-05, LEARNING_ENGINE.md §3).
final class V1AcquisitionPipeline implements AcquisitionPipeline {
  const V1AcquisitionPipeline({
    required ReviewRepository reviewRepository,
    V1PromotionRule promotionRule = const V1PromotionRule(),
  })  : _reviewRepository = reviewRepository,
        _promotionRule = promotionRule;

  final ReviewRepository _reviewRepository;
  final V1PromotionRule _promotionRule;

  @override
  Future<ReviewCardRecord?> evaluateAndPromote({
    required LearnerState learner,
    required VocabId vocabId,
    required ContentId contentId,
    required String sourceSentenceText,
    required Token token,
    bool isCurriculumCritical = false,
    String? visualAsset,
    String? audioAsset,
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();

    // 1. If already known by the learner model, do not create duplicate cards
    if (learner.isVocabKnown(vocabId)) {
      return null;
    }

    // 2. If a review card already exists in the SRS, do not duplicate
    final existingCard = await _reviewRepository.getCardByVocabId(vocabId);
    if (existingCard != null) {
      return null;
    }

    // 3. Construct acquisition candidate from current exposure aggregate
    final agg = learner.exposure[vocabId];
    final encounterCount = (agg?.encounterCount ?? 0) + 1;
    final distinctContentItems = {
      ...?agg?.contentItemIds,
      contentId,
    }.length;

    final candidate = AcquisitionCandidate(
      vocabId: vocabId,
      encounterCount: encounterCount,
      distinctContentItems: distinctContentItems,
      curriculumCritical: isCurriculumCritical,
    );

    // 4. Test promotion rule (never unknown == flashcard)
    if (!_promotionRule.shouldPromote(candidate)) {
      return null;
    }

    // 5. Promote: build initial SRS review card preserving richest context
    final cardId = 'card-$vocabId';
    final initialFsrsCard = fsrs.Card(cardId: cardId.hashCode);

    final cardRecord = ReviewCardRecord(
      card: ReviewCard(
        id: cardId,
        vocabId: vocabId,
        sourceSentence: sourceSentenceText,
        targetEmphasis: (start: token.start, end: token.end),
        visualAsset: visualAsset,
        wordAudio: audioAsset,
      ),
      fsrsCardStateJson: jsonEncode(initialFsrsCard.toMap()),
      due: currentTime,
    );

    await _reviewRepository.saveCard(cardRecord);
    return cardRecord;
  }
}
