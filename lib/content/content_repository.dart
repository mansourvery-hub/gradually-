/// Content Repository interface (ARCHITECTURE.md §2, §3).
library;

import '../core/ids.dart';
import '../core/progress.dart';
import '../selector/selector.dart';

/// Repository interface for accessing content metadata and reading progress.
abstract interface class ContentRepository {
  /// Fetches candidate content items for the selector.
  Future<List<CandidateContent>> getCandidateContents();

  /// Reads progress for a content item.
  Future<ContentProgress?> getProgress(ContentId contentId);

  /// Saves progress for a content item.
  Future<void> saveProgress(ContentProgress progress);
}
