/// Bounded aggregate tracking reading progress and completion for a content item
/// (CONTENT.md §3, §7, ARCHITECTURE.md §4).
library;

import 'ids.dart';

/// Tracks saved reading position and completion/reread counts for a content item.
///
/// Follows the bounded aggregate model: one row per content item ever started.
final class ContentProgress {
  const ContentProgress({
    required this.contentId,
    required this.lastPosition,
    required this.completionCount,
    required this.rereadCount,
    required this.firstRead,
    required this.lastRead,
  });

  /// Creates initial reading progress for a newly opened content item.
  ContentProgress.initial({
    required this.contentId,
    required DateTime now,
    this.lastPosition = 0,
  }) : completionCount = 0,
       rereadCount = 0,
       firstRead = now,
       lastRead = now;

  final ContentId contentId;

  /// Saved reading position offset (e.g. character index or sentence index).
  final int lastPosition;

  /// Total completed reads (first complete read makes this 1).
  final int completionCount;

  /// Total rereads (0 for first read, 1+ for subsequent completed rereads).
  final int rereadCount;

  final DateTime firstRead;
  final DateTime lastRead;

  /// Whether this content item has been completed at least once.
  bool get isCompleted => completionCount > 0;

  /// Returns updated progress with new reading position.
  ContentProgress updatePosition(int newPosition, DateTime now) {
    return ContentProgress(
      contentId: contentId,
      lastPosition: newPosition,
      completionCount: completionCount,
      rereadCount: rereadCount,
      firstRead: firstRead,
      lastRead: now,
    );
  }

  /// Returns updated progress after completing a read or reread.
  ContentProgress recordCompletion(DateTime now) {
    final isFirstCompletion = completionCount == 0;
    return ContentProgress(
      contentId: contentId,
      lastPosition: lastPosition,
      completionCount: completionCount + 1,
      rereadCount: isFirstCompletion ? rereadCount : rereadCount + 1,
      firstRead: firstRead,
      lastRead: now,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentProgress &&
          runtimeType == other.runtimeType &&
          contentId == other.contentId &&
          lastPosition == other.lastPosition &&
          completionCount == other.completionCount &&
          rereadCount == other.rereadCount &&
          firstRead == other.firstRead &&
          lastRead == other.lastRead;

  @override
  int get hashCode =>
      contentId.hashCode ^
      lastPosition.hashCode ^
      completionCount.hashCode ^
      rereadCount.hashCode ^
      firstRead.hashCode ^
      lastRead.hashCode;
}
