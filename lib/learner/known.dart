/// The single "known" rule (LEARNING_ENGINE.md §2).
///
/// [PROPOSED] V1: a small function over review/recognition outcomes; keep
/// the rule in the learner model only. Never surfaced as colors or counts.
library;

import '../core/hanzi.dart';
import '../core/ids.dart';
import '../core/vocab.dart';

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

/// Computes whether a vocabulary item is "known" in V1 (LEARNING_ENGINE.md §2).
///
/// Deterministic rule: a word is known if its most recent mastery evidence
/// is [RecallGrade.remembered] or [RecallGrade.partiallyRemembered], OR if it has at
/// least two positive outcomes without a subsequent forgotten outcome.
bool computeIsVocabularyKnown(List<MasteryEvidence> history) {
  if (history.isEmpty) return false;

  // Sort chronologically by timestamp (newest last)
  final sorted = List<MasteryEvidence>.from(history)
    ..sort((a, b) => a.at.compareTo(b.at));

  final latest = sorted.last;
  if (latest.grade == RecallGrade.forgotten) {
    return false;
  }

  // Count positive outcomes
  final positiveCount = sorted
      .where((e) => e.grade != RecallGrade.forgotten)
      .length;
  return positiveCount >= 1;
}

/// Derives known [Hanzi] set from known vocabulary items and explicit Hanzi evidence.
Set<Hanzi> deriveKnownHanzi({
  required Set<VocabularyItem> knownVocabulary,
  required List<MasteryEvidence> hanziEvidence,
}) {
  final result = <Hanzi>{};

  // 1. All Hanzi characters in known vocabulary items are known
  for (final vocab in knownVocabulary) {
    for (final char in vocab.surface.runes) {
      final str = String.fromCharCode(char);
      // Only include Hanzi (CJK Unified Ideographs range 0x4E00..0x9FFF)
      if (char >= 0x4E00 && char <= 0x9FFF) {
        result.add(Hanzi(character: str));
      }
    }
  }

  // 2. Add Hanzi directly recognized in Hanzi-kind evidence
  final explicitHanzi = hanziEvidence.where(
    (e) =>
        e.kind == MasteryEvidenceKind.hanzi && e.grade != RecallGrade.forgotten,
  );
  for (final evidence in explicitHanzi) {
    for (final char in evidence.vocabId.runes) {
      if (char >= 0x4E00 && char <= 0x9FFF) {
        result.add(Hanzi(character: String.fromCharCode(char)));
      }
    }
  }

  return result;
}
