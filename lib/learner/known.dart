/// The single "known" rule (LEARNING_ENGINE.md §2).
///
/// [PROPOSED] V1: a small function over review/recognition outcomes; keep
/// the rule in the learner model only. Never surfaced as colors or counts.
library;

import '../core/ids.dart';

/// A recognition or review outcome for one vocabulary item.
///
/// Meaning, Hanzi, sound, and tone can dissociate early, so the outcome
/// records which aspect was tested. Allowed inputs only (LEARNING_ENGINE
/// §2 / AGENTS.md §6): explicit learning events, never behavioral signals.
enum MasteryEvidenceKind { meaning, hanzi, sound, tone }

/// At-least-three-grade outcome of a recognition/review event
/// (LEARNING_ENGINE.md §4 beginner phase).
enum RecallGrade { forgotten, partiallyRemembered, remembered }

/// One explicit learning outcome; the learner model consumes these.
final class MasteryEvidence {
  const MasteryEvidence({
    required this.vocabId,
    required this.kind,
    required this.grade,
    required this.at,
  });

  final VocabId vocabId;
  final MasteryEvidenceKind kind;
  final RecallGrade grade;
  final DateTime at;
}
