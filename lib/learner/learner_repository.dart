/// Persistence interface for learner state, exposure, mastery evidence, and
/// content progress (ARCHITECTURE.md §2, §4).
library;

import '../core/ids.dart';
import '../core/progress.dart';
import 'known.dart';
import 'learner_state.dart';

/// Repository interface for reading and writing learner model data.
///
/// Implementations live in `lib/data/` (e.g. Drift SQLite implementation).
abstract interface class LearnerRepository {
  /// Fetches the current consolidated [LearnerState].
  Future<LearnerState> getLearnerState();

  /// Emits updated [LearnerState] whenever learner state changes.
  Stream<LearnerState> watchLearnerState();

  /// Records an encounter for a single word in a content item.
  Future<void> recordExposure(
    VocabId vocabId,
    ContentId contentId, {
    DateTime? at,
  });

  /// Records encounters for a list of words in a content item (batch).
  Future<void> recordBatchExposure(
    List<VocabId> vocabIds,
    ContentId contentId, {
    DateTime? at,
  });

  /// Records explicit mastery evidence (recognition or review outcome).
  Future<void> recordMasteryEvidence(MasteryEvidence evidence);

  /// Saves or updates reading progress for a content item.
  Future<void> updateContentProgress(ContentProgress progress);

  /// Gets reading progress for a specific content item, or null if unread.
  Future<ContentProgress?> getContentProgress(ContentId contentId);
}
