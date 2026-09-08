/// Riverpod dependency injection and provider wiring (ARCHITECTURE.md §2, D-03).
///
/// Contains NO learning logic; composes domain services, repositories,
/// and streams for widgets to consume.
library;

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/content.dart';
import '../content/content_repository.dart';
import '../data/database.dart';
import '../data/repositories/content_repository_impl.dart';
import '../data/repositories/learner_repository_impl.dart';
import '../learner/learner_repository.dart';
import '../learner/learner_state.dart';
import '../selector/selector.dart';

/// Provides the local Drift SQLite database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'jianru_db'));
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

/// Provides the [ContentRepository] loaded with the curated assets corpus.
final contentRepositoryProvider = FutureProvider<AssetContentRepository>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final repo = AssetContentRepository(db: db);

  // Curated bootstrap unit paths
  const curatedPaths = [
    'assets/content/unit_001_water.json',
    'assets/content/unit_002_tea.json',
    'assets/content/unit_003_drink.json',
    'assets/content/unit_004_eat.json',
    'assets/content/story_001_tea_and_rice.json',
  ];

  for (final path in curatedPaths) {
    try {
      final jsonStr = await rootBundle.loadString(path);
      repo.registerJson(jsonStr);
    } catch (_) {
      // Graceful fallback for non-bundled environments
    }
  }

  return repo;
});

/// The single selected [ContentItem] for the learner to experience next (E-02, E-06).
final nextExperienceProvider = FutureProvider<ContentItem?>((ref) async {
  final contentRepo = await ref.watch(contentRepositoryProvider.future);
  final learnerState =
      ref.watch(learnerStateStreamProvider).value ?? const LearnerState();
  final selector = ref.watch(contentSelectorProvider);

  final candidates = await contentRepo.getCandidateContents();
  final selection = selector.select(learnerState, candidates);

  if (selection == null) return null;
  return contentRepo.getContentItem(selection.contentId);
});
