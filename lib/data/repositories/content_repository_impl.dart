/// Asset-based and database-backed implementation of [ContentRepository]
/// (DECISIONS.md D-05, ARCHITECTURE.md §3).
///
/// CONTENT IS DATA: the corpus is assembled from
/// - beginner units generated from the target lexicon data, and
/// - story/dialogue JSON files listed in the corpus manifest.
/// Nothing curriculum-shaped is compiled into Dart.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../content/content.dart';
import '../../content/content_repository.dart';
import '../../content/corpus.dart';
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

  /// Loads and registers multiple content items from a JSON manifest /
  /// list payload (`[item, item, ...]` or `{"items": [paths]}` is NOT
  /// supported here — paths are resolved by the caller; this accepts a
  /// plain JSON array of item objects).
  void registerManifestJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    for (final raw in decoded) {
      final item = ContentItem.fromJson(raw as Map<String, dynamic>);
      _items[item.id] = item;
    }
  }

  /// Builds the full corpus from data sources: beginner units generated
  /// from [lexiconJson] (target-led lexicon data) plus the story items
  /// in [storyPayloads] (each an already-loaded JSON string from the
  /// corpus manifest).
  ///
  /// Availability filter: only [ContentStatus.available] items are
  /// registered — draft/retired items live in the dataset but never
  /// reach the selector.
  static AssetContentRepository fromData({
    required AppDatabase db,
    required String lexiconJson,
    required Iterable<String> storyPayloads,
  }) {
    final units = buildBeginnerUnits(parseLexiconJson(lexiconJson));
    final items = <ContentItem>[...units];
    for (final payload in storyPayloads) {
      final item = ContentItem.fromJson(
        jsonDecode(payload) as Map<String, dynamic>,
      );
      if (item.metadata.status == ContentStatus.available) {
        items.add(item);
      }
    }
    return AssetContentRepository(db: db, initialItems: items);
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

  @override
  void register(ContentItem item) {
    if (item.metadata.status != ContentStatus.available) return;
    _items[item.id] = item;
  }

  @override
  Future<ContentId?> firstItemId() async {
    if (_items.isEmpty) return null;
    final sorted = _items.values.toList()
      ..sort(
        (a, b) =>
            a.metadata.curriculumOrder.compareTo(b.metadata.curriculumOrder),
      );
    return sorted.first.id;
  }
}
