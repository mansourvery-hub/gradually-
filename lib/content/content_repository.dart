/// Content Repository interface (ARCHITECTURE.md §2, §3).
library;

import '../core/ids.dart';
import '../core/progress.dart';
import '../selector/selector.dart';
import 'content.dart';

/// Repository interface for accessing curated content and reading progress.
abstract interface class ContentRepository {
  /// Fetches candidate content items for the selector.
  Future<List<CandidateContent>> getCandidateContents();

  /// Fetches a specific content item by its ID.
  Future<ContentItem?> getContentItem(ContentId id);

  /// Fetches all loaded content items in curriculum order.
  Future<List<ContentItem>> getAllContentItems();

  /// Reads progress for a content item.
  Future<ContentProgress?> getProgress(ContentId contentId);

  /// Saves progress for a content item.
  Future<void> saveProgress(ContentProgress progress);

  /// Registers a content item at runtime (dictionary entries, later
  /// imported content). Availability filtering happens at registration.
  void register(ContentItem item);

  /// The stable identifier of the first item in the corpus (startup
  /// fallback for empty selections; never a curriculum assumption in
  /// the caller — the repository owns ordering).
  Future<ContentId?> firstItemId();
}
