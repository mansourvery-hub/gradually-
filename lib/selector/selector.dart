/// Content Selector boundary (E-06, LEARNING_ENGINE.md §5).
///
/// LearnerState + CandidateContent[] → ContentSelector → ONE experience.
/// No scoring in widgets, repositories, or reader; runnable on synthetic
/// inputs without a database.
library;

import '../core/ids.dart';
import '../learner/learner_state.dart';

/// A candidate content item with the lexical/progression metadata the
/// selector needs. Full content lives in the content package.
final class CandidateContent {
  const CandidateContent({
    required this.id,
    required this.curriculumOrder,
    required this.prerequisiteIds,
    required this.vocabulary,
  });

  final ContentId id;

  /// Position in the curriculum sequence; tie-breaker for equal scores.
  final int curriculumOrder;

  /// Content that must be completed before this item is reachable.
  final Set<ContentId> prerequisiteIds;

  /// Distinct vocabulary ids present in this item.
  final Set<VocabId> vocabulary;
}

/// The selector's output: one experience. Never a list, score, or ranking
/// (E-06: internals stay internal).
final class SelectedExperience {
  const SelectedExperience({required this.contentId});

  final ContentId contentId;
}

/// Answers: given everything the learner knows, which piece of Chinese
/// should come next?
abstract interface class ContentSelector {
  /// Returns exactly one experience, or null when no content is available.
  SelectedExperience? select(
    LearnerState learner,
    List<CandidateContent> candidates,
  );
}

/// Default V1 Content Selector algorithm (LEARNING_ENGINE.md §5).
///
/// Pure Dart, deterministic, replaceable.
final class V1ContentSelector implements ContentSelector {
  const V1ContentSelector();

  @override
  SelectedExperience? select(
    LearnerState learner,
    List<CandidateContent> candidates,
  ) {
    if (candidates.isEmpty) return null;

    // 1. Filter: prerequisite fulfillment
    final reachable = candidates.where((c) {
      return c.prerequisiteIds.every(learner.isContentCompleted);
    }).toList();

    if (reachable.isEmpty) {
      // Fallback to lowest curriculum order
      final sorted = List<CandidateContent>.from(candidates)
        ..sort((a, b) => a.curriculumOrder.compareTo(b.curriculumOrder));
      return SelectedExperience(contentId: sorted.first.id);
    }

    // 2. Separate uncompleted vs completed reachable items
    final uncompleted = reachable
        .where((c) => !learner.isContentCompleted(c.id))
        .toList();

    final pool = uncompleted.isNotEmpty ? uncompleted : reachable;

    // 3. Score candidates
    CandidateContent? bestCandidate;
    double highestScore = -double.infinity;

    for (final candidate in pool) {
      final score = _scoreCandidate(learner, candidate);
      if (score > highestScore) {
        highestScore = score;
        bestCandidate = candidate;
      } else if ((score - highestScore).abs() < 0.0001 &&
          bestCandidate != null) {
        if (candidate.curriculumOrder < bestCandidate.curriculumOrder) {
          bestCandidate = candidate;
        }
      }
    }

    return bestCandidate != null
        ? SelectedExperience(contentId: bestCandidate.id)
        : null;
  }

  double _scoreCandidate(LearnerState learner, CandidateContent candidate) {
    final vocab = candidate.vocabulary;
    final unknownCount = vocab.difference(learner.knownVocabulary).length;
    final knownCount = vocab.intersection(learner.knownVocabulary).length;

    // Base score prioritizes curriculum progression
    double score = 1000.0 - (candidate.curriculumOrder * 10.0);

    // If learner is an absolute beginner, advance strictly along curriculum order
    if (learner.knownVocabulary.isEmpty) {
      return score - (unknownCount * 2.0);
    }

    // Optimal i+1 zone: 1 to 3 new words
    if (unknownCount >= 1 && unknownCount <= 3) {
      score += 50.0;
      score += knownCount * 3.0; // Reward reusing already known words
    } else if (unknownCount == 0) {
      score += 15.0; // Consolidation value
    } else {
      score -= (unknownCount - 3) * 20.0; // Penalty for vocab overload
    }

    return score;
  }
}
