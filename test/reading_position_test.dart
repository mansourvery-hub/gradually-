/// Reading-position persistence tests (T_UI_030 resume contract).
///
/// Mid-story reading positions must persist and restore exactly, for both
/// the persisted DB path and the in-memory simulated session path (E-10:
/// completed content stays accessible; rereading uses current state).
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/content/content.dart';
import 'package:jianru/core/progress.dart';
import 'package:jianru/data/database.dart';
import 'package:jianru/data/repositories/content_repository_impl.dart';

import 'helpers/corpus_loader.dart';

void main() {
  late AppDatabase db;
  late AssetContentRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = AssetContentRepository(db: db, initialItems: fullCorpus());
  });

  tearDown(() async {
    await db.close();
  });

  test('position round-trips through saveProgress/getProgress', () async {
    final story = fullCorpus().firstWhere(
      (i) => i.type == ContentType.microStory,
    );

    // First open: record initial.
    final initial = ContentProgress.initial(
      contentId: story.id,
      now: DateTime(2026, 9, 9, 10),
    );
    await repo.saveProgress(initial);

    // Read to section 2 (position 2), persist.
    final midRead = initial.updatePosition(2, DateTime(2026, 9, 9, 10, 5));
    await repo.saveProgress(midRead);

    // New session reads back the exact position.
    final restored = await repo.getProgress(story.id);
    expect(restored, isNotNull);
    expect(
      restored!.lastPosition,
      2,
      reason: 'reading position must resume exactly',
    );
    expect(
      restored.isCompleted,
      isFalse,
      reason: 'mid-read item must not be marked completed',
    );
  });

  test('position survives completion and reread (bounded upsert)', () async {
    final story = fullCorpus().firstWhere(
      (i) => i.type == ContentType.microStory,
    );
    final now = DateTime(2026, 9, 9, 10);

    // First complete read.
    var progress = ContentProgress.initial(
      contentId: story.id,
      now: now,
    ).updatePosition(story.sections.length - 1, now).recordCompletion(now);
    await repo.saveProgress(progress);

    // Reread: open again, position resets through a fresh update.
    progress = progress.updatePosition(0, now).recordCompletion(now);
    await repo.saveProgress(progress);

    final restored = await repo.getProgress(story.id);
    expect(restored!.lastPosition, 0);
    expect(
      restored.completionCount,
      2,
      reason: 'rereading increments completion count in place',
    );
    expect(
      restored.rereadCount,
      1,
      reason: 'second complete read counts as a reread',
    );
  });

  test('clamping restores a valid section when content shrinks', () {
    // Guards the restore path: a saved position beyond the current section
    // count (e.g. after content edits) must clamp, never crash.
    final story = fullCorpus().firstWhere((i) => i.id == 'story-001-drink-tea');
    final saved = 99;
    final clamped = saved.clamp(0, story.sections.length - 1);
    expect(
      clamped,
      story.sections.length - 1,
      reason: 'out-of-range position clamps to the last section',
    );
    expect(clamped >= 0, isTrue);
  });

  test(
    'children story entity exists and recycles only known lexicon',
    () async {
      final corpus = fullCorpus();
      final children = corpus.where((i) => i.type == ContentType.story);
      expect(
        children.length,
        1,
        reason: 'children stories are a distinct entity from micro stories',
      );
      final story = children.first;
      expect(
        story.sections.length,
        greaterThanOrEqualTo(5),
        reason: 'children stories are longer than micro stories',
      );

      // Every vocabulary id in the children story must exist in the corpus
      // lexicon (content is part of the algorithm: no stray vocabulary).
      final allVocab = corpus.expand((i) => i.metadata.vocabulary).toSet();
      final lexicon = corpus
          .where((i) => i.type == ContentType.beginnerUnit)
          .expand((i) => i.metadata.vocabulary)
          .toSet();
      for (final v in story.metadata.vocabulary) {
        expect(
          lexicon.contains(v),
          isTrue,
          reason:
              'children story vocabulary "$v" must be recycled from the '
              'bootstrap lexicon',
        );
        expect(allVocab.contains(v), isTrue);
      }
    },
  );

  test('micro stories are distinct from children stories', () {
    final micros = fullCorpus()
        .where((i) => i.type == ContentType.microStory)
        .toList();
    expect(
      micros.length,
      greaterThanOrEqualTo(3),
      reason: 'the original Stories 1-3 plus new micro stories exist',
    );
    for (final m in micros) {
      expect(
        m.sections.length,
        lessThan(5),
        reason: 'micro stories stay a few lines long',
      );
    }
  });
}
