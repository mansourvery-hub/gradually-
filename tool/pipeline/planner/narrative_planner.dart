import 'package:jianru/learner/v3_learner_state.dart';
import '../extraction/canonical/canonical_model.dart';
import 'narrative_target.dart';

/// Progressive Narrative Planner: decides what part of the Mother Story should become visible next.
class ProgressiveNarrativePlanner {
  const ProgressiveNarrativePlanner();

  /// Plans the next narrative target based on current learner state and canonical story model.
  NarrativeTarget? selectNextTarget({
    required CanonicalStoryModel storyModel,
    required V3LearnerState learnerState,
    bool allowPrerequisiteBypass = false,
  }) {
    final encounteredEvents = learnerState.narrative.encounteredEvents;
    final encounteredChars = learnerState.narrative.encounteredCharacters;
    final encounteredLocs = learnerState.narrative.encounteredLocations;

    // 1. Filter out already exposed events
    final unexposedEvents = storyModel.events
        .where((ev) => !encounteredEvents.contains(ev.id))
        .toList();

    if (unexposedEvents.isEmpty) {
      return null;
    }

    // 2. Filter by narrative prerequisites
    final eligibleCandidates = <CanonicalEvent>[];
    for (final ev in unexposedEvents) {
      final prereqsSatisfied =
          allowPrerequisiteBypass ||
          ev.causalPredecessors.every(
            (pred) => encounteredEvents.contains(pred),
          );

      if (prereqsSatisfied) {
        eligibleCandidates.add(ev);
      }
    }

    if (eligibleCandidates.isEmpty) {
      return null;
    }

    // 3. Rank eligible candidates based on continuity, entity load, and progression
    CanonicalEvent? bestCandidate;
    double bestScore = -1.0;
    String bestReason = '';

    for (final ev in eligibleCandidates) {
      // Metric A: Continuity with currently represented chapters
      final lastRegion = learnerState.narrative.representedSourceRegions.isEmpty
          ? 1
          : learnerState.narrative.representedSourceRegions.reduce(
              (a, b) => a > b ? a : b,
            );

      final chapterDiff = (ev.chapterIndex - lastRegion).abs();
      final continuityScore = 1.0 / (1.0 + chapterDiff);

      // Metric B: Controlled entity load (prefer introducing 1-2 new entities, not overwhelm)
      final newChars = ev.participants
          .where((c) => !encounteredChars.contains(c))
          .length;
      final newLocs = ev.locations
          .where((l) => !encounteredLocs.contains(l))
          .length;
      final entityLoad = newChars + newLocs;
      final loadScore = entityLoad <= 2 ? 1.0 : (1.0 / (entityLoad - 1));

      // Metric C: Temporal sequence alignment
      final seqScore = 1.0 / (1.0 + ev.temporalOrder);

      final totalScore =
          continuityScore * 0.5 + loadScore * 0.3 + seqScore * 0.2;

      if (totalScore > bestScore) {
        bestScore = totalScore;
        bestCandidate = ev;
        bestReason =
            'Optimal narrative continuation (Chapter ${ev.chapterIndex}, $entityLoad new entities)';
      }
    }

    if (bestCandidate == null) {
      return null;
    }

    final newCharacters = bestCandidate.participants
        .where((c) => !encounteredChars.contains(c))
        .toList();
    final newLocations = bestCandidate.locations
        .where((l) => !encounteredLocs.contains(l))
        .toList();

    // Determine level-appropriate linguistic constraints based on linguistic learner state
    final maxNewWords = learnerState.linguistic.knownWords.length < 10
        ? 8
        : (learnerState.linguistic.estimatedDifficulty < 2.0 ? 6 : 8);
    final maxSentenceDifficulty =
        learnerState.linguistic.estimatedDifficulty + 0.5;

    return NarrativeTarget(
      targetEventId: bestCandidate.id,
      title: bestCandidate.title,
      summary: bestCandidate.summary,
      chapterIndex: bestCandidate.chapterIndex,
      sourceEvidence: bestCandidate.evidence,
      prerequisites: bestCandidate.causalPredecessors,
      reasonForSelection: bestReason,
      narrativeDifficulty: 1.0 + (bestCandidate.chapterIndex * 0.05),
      introducedCharacters: newCharacters,
      introducedLocations: newLocations,
      linguisticConstraints: {
        'maxNewWords': maxNewWords,
        'maxSentenceDifficulty': maxSentenceDifficulty,
        'targetVocabularyRatio': 0.8,
      },
    );
  }
}
