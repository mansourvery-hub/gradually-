/// Riverpod dependency injection and provider wiring (ARCHITECTURE.md §2, D-03).
///
/// Contains NO learning logic; composes domain services, repositories,
/// and streams for widgets to consume.
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../acquisition/acquisition.dart';
import '../content/content.dart';
import '../content/content_repository.dart';
import '../content/media_capabilities.dart';
import '../core/ids.dart';
import '../core/progress.dart';
import '../core/simulated_level.dart'
    show applySimulatedCompletion, buildSimulatedLearnerState, kSimulatedLevel;
import '../data/database.dart';
import '../data/repositories/content_repository_impl.dart';
import '../data/repositories/learner_repository_impl.dart';
import '../data/repositories/review_repository_impl.dart';
import '../dictionary/lookup.dart';
import '../learner/exposure_gate.dart';
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

/// Reactive learner state. Synchronously yields state on Frame 1 (zero-delay
/// startup). At simulated levels this Notifier advances in memory as the
/// learner completes items; at LEVEL=0 it mirrors the persisted SQLite stream.
class SimulatedLearnerNotifier extends Notifier<LearnerState> {
  @override
  LearnerState build() {
    if (kSimulatedLevel > 0) {
      // Corpus-independent seeding: when the repository has not resolved
      // yet, start empty and re-seed once it loads.
      final corpus =
          ref.watch(_simulatedCorpusProvider).value ?? const <ContentItem>[];
      return buildSimulatedLearnerState(kSimulatedLevel, corpus: corpus);
    }
    // LEVEL=0: mirror the persisted DB stream.
    return ref.watch(learnerStateStreamProvider).value ?? const LearnerState();
  }

  /// Records in-session completion of [item] at simulated levels.
  /// No-op at LEVEL=0 where the SQLite stream owns the state.
  void completeItem(ContentItem item) {
    if (kSimulatedLevel == 0) return;
    state = applySimulatedCompletion(state, item);
  }

  /// Updates the simulated reading position for [contentId] (T_UI_030).
  /// No-op at LEVEL=0 where the SQLite stream owns the state.
  void updatePosition(ContentId contentId, int position, DateTime now) {
    if (kSimulatedLevel == 0) return;
    final progress = Map<ContentId, ContentProgress>.from(state.progress);
    final existing = progress[contentId];
    progress[contentId] =
        (existing ?? ContentProgress.initial(contentId: contentId, now: now))
            .updatePosition(position, now);
    state = state.copyWith(progress: progress);
  }
}

/// At simulated levels: the corpus snapshot used for seeding, empty until
/// the repository resolves (rebuilds the simulated state on arrival).
Future<List<ContentItem>> _simulatedCorpus(Ref ref) async {
  if (kSimulatedLevel == 0) return const [];
  try {
    final repo = await ref.watch(contentRepositoryProvider.future);
    return await repo.getAllContentItems();
  } catch (_) {
    return const [];
  }
}

final _simulatedCorpusProvider = FutureProvider(_simulatedCorpus);

/// Provides the active learner state — simulated in-memory at LEVEL>0,
/// streamed from SQLite at LEVEL=0.
final activeLearnerStateProvider =
    NotifierProvider<SimulatedLearnerNotifier, LearnerState>(
      SimulatedLearnerNotifier.new,
    );

/// Reactive stream of the consolidated [LearnerState].
///
/// Never blocks initial render: synchronously yields immediate state on Frame 1.
final learnerStateStreamProvider = StreamProvider<LearnerState>((ref) async* {
  // 1. Yield initial state synchronously on Frame 1 (Zero-delay startup)
  yield const LearnerState();

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

/// Provides cards currently due for review (only active after the
/// pure-exposure gate unlocks, CHOICES §1, T_ENG_020).
final dueReviewCardsProvider = FutureProvider<List<ReviewCardRecord>>((
  ref,
) async {
  final learnerState = ref.watch(activeLearnerStateProvider);

  // Evaluate the pure-exposure gate: recognition stays locked until the
  // exposure phase completes with broad per-word coverage (CHOICES §1).
  final gate = evaluateExposureGate(learnerState);
  if (!gate.isUnlocked) {
    return const [];
  }

  try {
    final reviewSystem = ref.watch(reviewSystemProvider);
    final allDue = await reviewSystem.fetchDueCards(now: DateTime.now());

    // Pacing: only words that individually passed the per-word exposure
    // floor are eligible; rereads keep growing exposure post-unlock.
    final readySet = gate.reviewReadyVocab.toSet();
    final readyDue = allDue
        .where((record) => readySet.contains(record.card.vocabId))
        .toList();

    // First-session ramp: after unlock, begin with a small cohort instead
    // of flooding the learner with the entire backlog at once.
    if (learnerState.progress.values.every(
      (p) => p.completionCount == 0 || p.rereadCount == 0,
    )) {
      // No rereads recorded anywhere yet → earliest sessions: ramp in.
      final cohort = firstUnlockCohort(gate).toSet();
      return readyDue
          .where((record) => cohort.contains(record.card.vocabId))
          .toList();
    }
    return readyDue;
  } catch (_) {
    return const [];
  }
});

/// Provides the [ContentSelector] algorithm instance.
///
/// V2: deterministic, learner-aware sequencing with forward preparation.
/// Swapping the algorithm is a one-line change here — the app talks to
/// the [ContentSelector] interface, never a specific curriculum.
final contentSelectorProvider = Provider<ContentSelector>((ref) {
  return const V2ContentSelector();
});

/// Provides the [ContentRepository] loaded from the content corpus DATA:
/// beginner units generated from the target lexicon + story/dialogue
/// JSON files referenced by the corpus manifest. Nothing curriculum-
/// shaped is compiled into Dart (CONTENT IS DATA).
final contentRepositoryProvider = FutureProvider<ContentRepository>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  try {
    // 1. Lexicon data → beginner exposure units.
    final lexiconJson = await rootBundle.loadString(
      'assets/content/curriculum/bootstrap_target_lexicon.json',
    );

    // 2. Corpus manifest → story payloads.
    final manifestJson = await rootBundle.loadString(
      'assets/content/manifest.json',
    );
    final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;
    final paths = (manifest['items'] as List<dynamic>).cast<String>();
    final storyPayloads = await Future.wait(
      paths.map((p) => rootBundle.loadString(p)),
    );

    return AssetContentRepository.fromData(
      db: db,
      lexiconJson: lexiconJson,
      storyPayloads: storyPayloads,
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('contentRepositoryProvider: falling back to empty ($e)');
    }
    // Serene degradation: empty corpus rather than a crash (R-01).
    return AssetContentRepository(db: db);
  }
});

/// Provides the [AudioPlaybackController] initialized with corpus media
/// capabilities. Gracefully no-ops when no audio assets exist (E-08).
final audioPlaybackControllerProvider = Provider<AudioPlaybackController>((
  ref,
) {
  final controller = AudioPlaybackController();
  ref.listen<AsyncValue<ContentRepository>>(contentRepositoryProvider, (
    _,
    next,
  ) {
    final repo = next.value;
    if (repo == null) return;
    // Media capabilities are derived from the corpus the repository
    // actually loaded — never from a compiled list.
    repo.getAllContentItems().then((items) {
      controller.initialize(buildMediaCapabilities(items));
    });
  }, fireImmediately: true);
  return controller;
});

/// The single selected [ContentItem] for the learner to experience next
/// (E-02, E-06). SEQUENCING IS LOGIC: this provider asks the selector;
/// it never knows a curriculum.
final nextExperienceProvider = FutureProvider<ContentItem?>((ref) async {
  try {
    final contentRepo = await ref.watch(contentRepositoryProvider.future);
    final learnerState = ref.watch(activeLearnerStateProvider);
    final selector = ref.watch(contentSelectorProvider);

    final candidates = await contentRepo.getCandidateContents();
    final selection = selector.select(learnerState, candidates);

    if (selection == null) {
      return await _firstItem(contentRepo);
    }
    return await contentRepo.getContentItem(selection.contentId) ??
        await _firstItem(contentRepo);
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('nextExperienceProvider error: $e\n$stack');
    }
    return null;
  }
});

Future<ContentItem?> _firstItem(ContentRepository repo) async {
  final id = await repo.firstItemId();
  return id == null ? null : repo.getContentItem(id);
}

/// Provides the local monolingual dictionary (T_UI_040).
///
/// Loads the curated dictionary asset once. When the asset is missing or
/// unparseable, degrades to an empty dictionary: every lookup is absent,
/// never an error (E-08 spirit). Swap `assets/dictionary/mock_dictionary.json`
/// for the real dictionary later without code changes.
final dictionaryProvider = FutureProvider<MonolingualDictionary>((ref) async {
  try {
    const assetPath = 'assets/dictionary/mock_dictionary.json';
    final jsonString = await rootBundle.loadString(assetPath);
    return MonolingualDictionary.fromJson(jsonString);
  } catch (e) {
    if (kDebugMode) {
      debugPrint('dictionaryProvider: using empty dictionary ($e)');
    }
    return MonolingualDictionary.empty();
  }
});
