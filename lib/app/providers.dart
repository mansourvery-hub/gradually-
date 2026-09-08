/// Riverpod dependency injection and provider wiring (ARCHITECTURE.md §2, D-03).
///
/// Contains NO learning logic; composes domain services, repositories,
/// and streams for widgets to consume.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/bootstrap_corpus.dart';
import '../content/content.dart';
import '../content/content_repository.dart';
import '../data/database.dart';
import '../data/repositories/content_repository_impl.dart';
import '../data/repositories/learner_repository_impl.dart';
import '../learner/learner_repository.dart';
import '../learner/learner_state.dart';
import '../selector/selector.dart';

/// Constructs a multiplatform Drift database executor.
QueryExecutor _constructDatabase() {
  return driftDatabase(
    name: 'jianru_db',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}

/// Provides the local Drift SQLite database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(_constructDatabase());
  ref.onDispose(db.close);
  return db;
});

/// Provides the [LearnerRepository] implementation.
final learnerRepositoryProvider = Provider<LearnerRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftLearnerRepository(db);
});

/// Reactive stream of the consolidated [LearnerState].
final learnerStateStreamProvider = StreamProvider<LearnerState>((ref) {
  final repo = ref.watch(learnerRepositoryProvider);
  return repo.watchLearnerState();
});

/// Provides the [ContentSelector] algorithm instance.
final contentSelectorProvider = Provider<ContentSelector>((ref) {
  return const V1ContentSelector();
});

/// Provides the [ContentRepository] loaded with the curated bootstrap corpus.
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AssetContentRepository(
    db: db,
    initialItems: bootstrapCurriculum,
  );
});

/// The single selected [ContentItem] for the learner to experience next (E-02, E-06).
final nextExperienceProvider = FutureProvider<ContentItem?>((ref) async {
  try {
    final contentRepo = ref.watch(contentRepositoryProvider);
    final learnerStateAsync = ref.watch(learnerStateStreamProvider);
    final learnerState = learnerStateAsync.value ?? const LearnerState();
    final selector = ref.watch(contentSelectorProvider);

    final candidates = await contentRepo.getCandidateContents();
    final selection = selector.select(learnerState, candidates);

    if (selection == null) return null;
    return await contentRepo.getContentItem(selection.contentId);
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('nextExperienceProvider error: $e\n$stack');
    }
    rethrow;
  }
});
