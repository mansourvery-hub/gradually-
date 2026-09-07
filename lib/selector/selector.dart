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
