/// Content Selector boundary (E-06, LEARNING_ENGINE.md §5).
///
/// LearnerState + CandidateContent[] → ContentSelector → ONE experience.
/// SEQUENCING IS LOGIC — this package is the only place that decides what
/// the learner encounters next. No scoring in widgets, repositories, or
/// reader; runnable on synthetic inputs without a database.
library;

import '../core/content_type.dart';
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
    this.type = ContentType.beginnerUnit,
    this.difficulty = 1,
    this.criticalVocabulary = const {},
  });

  final ContentId id;

  /// The pedagogical content type (drives phase-appropriate selection).
  final ContentType type;

  /// Position in the curriculum sequence; tie-breaker for equal scores.
  final int curriculumOrder;

  /// Content that must be completed before this item is reachable.
  final Set<ContentId> prerequisiteIds;

  /// Estimated internal difficulty (1 easiest; internals stay internal).
  final int difficulty;

  /// Distinct vocabulary ids present in this item.
  final Set<VocabId> vocabulary;

  /// Vocabulary the curriculum marks as important to acquire here.
  final Set<VocabId> criticalVocabulary;

  /// Distinct vocabulary not yet known to [learner].
  Set<VocabId> unknownVocabularyFor(LearnerState learner) =>
      vocabulary.difference(learner.knownVocabulary);

  /// Distinct vocabulary the learner has not yet *encountered* (no
  /// exposure record). Drives phase/readiness decisions during the
  /// pure-exposure period, before any mastery evidence exists.
  Set<VocabId> unseenVocabularyFor(LearnerState learner) =>
      vocabulary.difference(learner.seenVocabulary);

  /// Fraction of this item's vocabulary the learner already knows.
  double knownRatioFor(LearnerState learner) {
    if (vocabulary.isEmpty) return 1;
    return vocabulary.intersection(learner.knownVocabulary).length /
        vocabulary.length;
  }

  /// Fraction of this item's vocabulary the learner has encountered.
  double seenRatioFor(LearnerState learner) {
    if (vocabulary.isEmpty) return 1;
    return vocabulary.intersection(learner.seenVocabulary).length /
        vocabulary.length;
  }
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

/// V1 Content Selector algorithm (LEARNING_ENGINE.md §5).
///
/// Pure Dart, deterministic, replaceable. Phase- and prerequisite-aware;
/// scores uncompleted reachable items with a simple i+1 heuristic
/// (modest new-word bonus, reuse reward, overload penalty) and honors
/// curriculum order as the tie-breaker; rotates through completed items
/// least-recently-read when everything is done (E-10).
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
      final sorted = List<CandidateContent>.from(candidates)
        ..sort((a, b) => a.curriculumOrder.compareTo(b.curriculumOrder));
      return SelectedExperience(contentId: sorted.first.id);
    }

    // 2. Separate uncompleted vs completed reachable items
    final uncompleted = reachable
        .where((c) => !learner.isContentCompleted(c.id))
        .toList();

    // If there are uncompleted items, prioritize advancing through them
    if (uncompleted.isNotEmpty) {
      CandidateContent? bestCandidate;
      double highestScore = -double.infinity;

      for (final candidate in uncompleted) {
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

      if (bestCandidate != null) {
        return SelectedExperience(contentId: bestCandidate.id);
      }
    }

    // 3. Rereading Rotation: When all reachable items are completed,
    // pick the least-recently-read item (E-10, E-13)
    final sortedByLeastRecent = List<CandidateContent>.from(reachable)
      ..sort((a, b) {
        final progressA = learner.progress[a.id];
        final progressB = learner.progress[b.id];
        final timeA =
            progressA?.lastRead ?? DateTime.fromMillisecondsSinceEpoch(0);
        final timeB =
            progressB?.lastRead ?? DateTime.fromMillisecondsSinceEpoch(0);
        final cmp = timeA.compareTo(timeB);
        if (cmp != 0) return cmp;
        return a.curriculumOrder.compareTo(b.curriculumOrder);
      });

    return SelectedExperience(contentId: sortedByLeastRecent.first.id);
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

/// V2 Content Selector (dynamic sequencing foundation, handoff §6–§9).
///
/// Deterministic, no ML, no randomness: same inputs → same output,
/// independent of the input order of [candidates] (the corpus supplies
/// no ordering promise — input order is never the learning order).
///
/// Pipeline:
/// 1. eligibility — prerequisites met
/// 2. phase — beginner units build the lexicon; story-like content
///    (sentences/dialogues/stories) is offered once it is actually
///    readable in the i+1 zone, measured against vocabulary the learner
///    has *encountered* (exposure), not merely mastered
/// 3. forward preparation — unread units that pre-teach words needed by
///    uncompleted stories outrank their peers
/// 4. story readiness — prefer the item adding the fewest unencountered
///    words while recycling the most encountered ones (i+1, not i+10)
/// 5. reread rotation — completed content stays eligible (E-10)
final class V2ContentSelector implements ContentSelector {
  const V2ContentSelector({this.maxNewWords = 6, this.minSeenRatio = 0.6});

  /// Upper bound on unencountered vocabulary a single story exposure may
  /// introduce before the selector holds it back for gentler material.
  final int maxNewWords;

  /// Minimum fraction of a story's vocabulary the learner must have
  /// already encountered before the story is offered. Guards against
  /// "6 unseen words in a 20-word story" reading experiences.
  final double minSeenRatio;

  @override
  SelectedExperience? select(
    LearnerState learner,
    List<CandidateContent> candidates,
  ) {
    if (candidates.isEmpty) return null;

    // Order-independent worklist.
    final ordered = List<CandidateContent>.from(candidates)
      ..sort(_byCurriculumThenId);

    // Absolute-beginner anchor: a learner with no encounters at all
    // starts at the first unit of the curriculum (MVP acceptance).
    if (learner.exposure.isEmpty && learner.progress.isEmpty) {
      return SelectedExperience(contentId: ordered.first.id);
    }

    // 1. Prerequisite eligibility.
    final eligible = ordered
        .where((c) => c.prerequisiteIds.every(learner.isContentCompleted))
        .toList();
    if (eligible.isEmpty) {
      // Nothing reachable yet (partial history): present the earliest
      // item; never strand the learner (§3.11).
      return SelectedExperience(contentId: ordered.first.id);
    }

    final uncompleted = eligible
        .where((c) => !learner.isContentCompleted(c.id))
        .toList();

    if (uncompleted.isEmpty) {
      // 5. Everything reachable is completed: least-recently-read wins
      // (rereading is progression, E-10 / E-13).
      final byLeastRecent = List<CandidateContent>.from(eligible)
        ..sort((a, b) {
          final timeA =
              learner.progress[a.id]?.lastRead ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final timeB =
              learner.progress[b.id]?.lastRead ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final cmp = timeA.compareTo(timeB);
          if (cmp != 0) return cmp;
          return _byCurriculumThenId(a, b);
        });
      return SelectedExperience(contentId: byLeastRecent.first.id);
    }

    // 2. Phase split.
    final units = uncompleted
        .where((c) => c.type == ContentType.beginnerUnit)
        .toList();
    final stories = uncompleted
        .where((c) => c.type != ContentType.beginnerUnit)
        .toList();

    if (stories.isEmpty) {
      return SelectedExperience(
        contentId: _selectUnit(learner, units, stories).id,
      );
    }

    final bestStory = _bestStory(learner, stories);
    final storyNewWords = bestStory?.unseenVocabularyFor(learner).length;
    final storySeenRatio = bestStory?.seenRatioFor(learner);
    final storyReady =
        storyNewWords != null &&
        storySeenRatio != null &&
        storyNewWords <= maxNewWords &&
        storySeenRatio >= minSeenRatio;

    if (storyReady && bestStory != null) {
      // A story in the i+1 zone beats remaining drill units — meaningful
      // content is the point of the preparation (stage 4).
      return SelectedExperience(contentId: bestStory.id);
    }

    // The nearest meaningful content is not readable yet: continue
    // units, biased toward forward preparation (stage 3). When no units
    // exist at all, the best story is still the only meaningful choice —
    // the learner is never stranded (§3.11).
    if (units.isEmpty) {
      return SelectedExperience(contentId: bestStory!.id);
    }
    return SelectedExperience(
      contentId: _selectUnit(learner, units, stories).id,
    );
  }

  /// Total-order comparator: curriculum order, then id (both stable).
  static int _byCurriculumThenId(CandidateContent a, CandidateContent b) {
    final cmp = a.curriculumOrder.compareTo(b.curriculumOrder);
    if (cmp != 0) return cmp;
    return a.id.compareTo(b.id);
  }

  /// Chooses the next beginner unit — the forward-preparation step:
  /// among unread units, prefer one whose word is needed by uncompleted
  /// story-like items (weighted toward the most readable upcoming
  /// story), so early exposure deliberately prepares the learner for
  /// upcoming meaningful content (handoff §9).
  ///
  /// Rank ladder (lower wins): preparing > fresh > consolidation.
  /// Curriculum order breaks ties via the ordered iteration.
  CandidateContent _selectUnit(
    LearnerState learner,
    List<CandidateContent> units,
    List<CandidateContent> stories,
  ) {
    assert(units.isNotEmpty, 'caller guarantees units non-empty');

    // Vocabulary needed by uncompleted, prerequisite-satisfied story
    // items — the words upcoming exposure should prepare for.
    final upcomingVocab = <VocabId>{
      for (final story in stories)
        if (!learner.isContentCompleted(story.id) &&
            story.prerequisiteIds.every(learner.isContentCompleted))
          ...story.vocabulary,
    };

    CandidateContent? best;
    int bestRank = _rankBeyondLadder;

    for (final unit in units) {
      final newWords = unit.unseenVocabularyFor(learner);
      final isFresh = newWords.isNotEmpty;
      final prepares = isFresh && newWords.any(upcomingVocab.contains);

      final rank = prepares
          ? _rankPrepares
          : (isFresh ? _rankFresh : _rankConsolidate);

      if (rank < bestRank) {
        bestRank = rank;
        best = unit;
      }
    }

    return best ?? units.first;
  }

  static const int _rankPrepares = 0;
  static const int _rankFresh = 1;
  static const int _rankConsolidate = 2;
  static const int _rankBeyondLadder = 3;

  /// Story selection: i+1 — the candidate adding the fewest unencountered
  /// words; encountered-ratio breaks ties (recycling rewards), curriculum
  /// order wins remaining ties through the ordered iteration.
  CandidateContent? _bestStory(
    LearnerState learner,
    List<CandidateContent> stories,
  ) {
    CandidateContent? best;
    int bestNew = 1 << 30;
    double bestSeen = -1;

    for (final story in stories) {
      final newWords = story.unseenVocabularyFor(learner).length;
      final seen = story.seenRatioFor(learner);
      final improves =
          newWords < bestNew || (newWords == bestNew && seen > bestSeen);
      if (improves) {
        bestNew = newWords;
        bestSeen = seen;
        best = story;
      }
    }
    return best;
  }
}
