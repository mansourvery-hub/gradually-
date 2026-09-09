/// Riverpod dependency injection and provider wiring (ARCHITECTURE.md §2, D-03).
///
/// Contains NO learning logic; composes domain services, repositories,
/// and streams for widgets to consume.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../acquisition/acquisition.dart';
import '../content/bootstrap_corpus.dart';
import '../content/content.dart';
import '../content/content_repository.dart';
import '../content/media_capabilities.dart';
import '../core/simulated_level.dart';
import '../data/database.dart';
import '../data/repositories/content_repository_impl.dart';
import '../data/repositories/learner_repository_impl.dart';
import '../data/repositories/review_repository_impl.dart';
import '../learner/learner_repository.dart';
import '../learner/learner_state.dart';
import '../reader/audio_controller.dart';
import '../review/fsrs_review_system.dart';
import '../review/review.dart';
import '../review/review_repository.dart';
import '../selector/selector.dart';

/// Constructs a fast, lightweight Drift database executor.
QueryExecutor _constructDatabase() {
  if (kIsWeb) {
    // Fast Web database initialization without blocking worker timeout
    return driftDatabase(
      name: 'jianru_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
  return driftDatabase(name: 'jianru_db');
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

/// Provides the [ReviewRepository] implementation.
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftReviewRepository(db);
});

/// Provides the FSRS spaced repetition system adapter.
final reviewSystemProvider = Provider<FsrsReviewSystem>((ref) {
  final repo = ref.watch(reviewRepositoryProvider);
  return FsrsReviewSystem(repository: repo);
});

/// Provides the word acquisition pipeline.
final acquisitionPipelineProvider = Provider<AcquisitionPipeline>((ref) {
  final reviewRepo = ref.watch(reviewRepositoryProvider);
  return V1AcquisitionPipeline(reviewRepository: reviewRepo);
});

/// Reactive stream of the consolidated [LearnerState].
///
/// Never blocks initial render: synchronously yields immediate state on Frame 1.
final learnerStateStreamProvider = StreamProvider<LearnerState>((ref) async* {
  // 1. Yield initial state synchronously on Frame 1 (Zero-delay startup)
  final initial = kSimulatedLevel > 0
      ? buildSimulatedLearnerState(kSimulatedLevel)
      : const LearnerState();
  yield initial;

  // 2. Stream subsequent updates reactively from SQLite
  if (kSimulatedLevel == 0) {
    try {
      final repo = ref.watch(learnerRepositoryProvider);
      yield* repo.watchLearnerState();
    } catch (_) {
      // Graceful fallback for non-persistent environments
    }
  }
});

/// Provides cards currently due for review (only active after pure exposure threshold, CHOICES §1).
final dueReviewCardsProvider = FutureProvider<List<ReviewCardRecord>>((
  ref,
) async {
  final learnerStateAsync = ref.watch(learnerStateStreamProvider);
  final learnerState =
      learnerStateAsync.value ??
      (kSimulatedLevel > 0
          ? buildSimulatedLearnerState(kSimulatedLevel)
          : const LearnerState());

  // Pure exposure phase check: count total exposures
  final totalExposures = learnerState.exposure.values.fold<int>(
    0,
    (sum, agg) => sum + agg.encounterCount,
  );

  // During pure exposure phase (0..threshold), no SRS reviews occur (CHOICES §1)
  if (totalExposures < kPureExposureThreshold) {
    return const [];
  }

  try {
    final reviewSystem = ref.watch(reviewSystemProvider);
    return await reviewSystem.fetchDueCards(now: DateTime.now());
  } catch (_) {
    return const [];
  }
});

/// Provides the [ContentSelector] algorithm instance.
final contentSelectorProvider = Provider<ContentSelector>((ref) {
  return const V1ContentSelector();
});

/// Provides the [ContentRepository] loaded with the curated bootstrap corpus.
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AssetContentRepository(db: db, initialItems: bootstrapCurriculum);
});

/// Provides the [AudioPlaybackController] initialized with bootstrap curriculum
/// media capabilities. Gracefully no-ops when no audio assets exist (E-08).
final audioPlaybackControllerProvider = Provider<AudioPlaybackController>((ref) {
  final controller = AudioPlaybackController();
  controller.initialize(buildMediaCapabilities(bootstrapCurriculum));
  return controller;
});

/// The single selected [ContentItem] for the learner to experience next (E-02, E-06).
///
/// Evaluates synchronously on Frame 1 with zero loading latency.
final nextExperienceProvider = FutureProvider<ContentItem?>((ref) async {
  try {
    final contentRepo = ref.watch(contentRepositoryProvider);
    final learnerStateAsync = ref.watch(learnerStateStreamProvider);
    final learnerState =
        learnerStateAsync.value ??
        (kSimulatedLevel > 0
            ? buildSimulatedLearnerState(kSimulatedLevel)
            : const LearnerState());
    final selector = ref.watch(contentSelectorProvider);

    final candidates = await contentRepo.getCandidateContents();
    final selection = selector.select(learnerState, candidates);

    if (selection == null) {
      // Direct fallback to first curriculum item if selector returned null
      return bootstrapCurriculum.firstOrNull;
    }
    return await contentRepo.getContentItem(selection.contentId) ??
        bootstrapCurriculum.firstOrNull;
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('nextExperienceProvider error: $e\n$stack');
    }
    return bootstrapCurriculum.firstOrNull;
  }
});
