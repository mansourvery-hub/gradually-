/// Asset-based and database-backed implementation of [ContentRepository]
/// (DECISIONS.md D-05, ARCHITECTURE.md §3).
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../content/content.dart';
import '../../content/content_repository.dart';
import '../../core/ids.dart';
import '../../core/progress.dart';
import '../../selector/selector.dart';
import '../database.dart';

/// Loads curated JSON content items from assets / raw JSON strings and tracks
/// reading progress in the Drift SQLite database.
final class AssetContentRepository implements ContentRepository {
  AssetContentRepository({
    required AppDatabase db,
    List<ContentItem> initialItems = const [],
  }) : _db = db,
       _items = {for (final item in initialItems) item.id: item};

  final AppDatabase _db;
  final Map<ContentId, ContentItem> _items;

  /// Loads and registers a content item from a JSON string.
  void registerJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final item = ContentItem.fromJson(decoded);
    _items[item.id] = item;
  }

  /// Loads and registers multiple content items from a JSON manifest / list string.
  void registerManifestJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    for (final raw in decoded) {
      final item = ContentItem.fromJson(raw as Map<String, dynamic>);
      _items[item.id] = item;
    }
  }

  @override
  Future<List<CandidateContent>> getCandidateContents() async {
    final sorted = _items.values.toList()
      ..sort(
        (a, b) =>
            a.metadata.curriculumOrder.compareTo(b.metadata.curriculumOrder),
      );

    return sorted.map((item) => item.toCandidateContent()).toList();
  }

  @override
  Future<ContentItem?> getContentItem(ContentId id) async {
    return _items[id];
  }

  @override
  Future<List<ContentItem>> getAllContentItems() async {
    final sorted = _items.values.toList()
      ..sort(
        (a, b) =>
            a.metadata.curriculumOrder.compareTo(b.metadata.curriculumOrder),
      );
    return sorted;
  }

  @override
  Future<ContentProgress?> getProgress(ContentId contentId) async {
    final row = await (_db.select(
      _db.contentProgresses,
    )..where((t) => t.contentId.equals(contentId))).getSingleOrNull();

    if (row == null) return null;

    return ContentProgress(
      contentId: row.contentId,
      lastPosition: row.lastPosition,
      completionCount: row.completionCount,
      rereadCount: row.rereadCount,
      firstRead: row.firstRead,
      lastRead: row.lastRead,
    );
  }

  @override
  Future<void> saveProgress(ContentProgress progress) async {
    await _db
        .into(_db.contentProgresses)
        .insertOnConflictUpdate(
          ContentProgressesCompanion.insert(
            contentId: progress.contentId,
            lastPosition: Value(progress.lastPosition),
            completionCount: Value(progress.completionCount),
            rereadCount: Value(progress.rereadCount),
            firstRead: progress.firstRead,
            lastRead: progress.lastRead,
          ),
        );
  }
}
