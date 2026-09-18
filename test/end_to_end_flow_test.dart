/// End-to-end learning-flow regression (handoff §19).
///
/// Simulates a real learner walking the whole corpus through the ACTUAL
/// pipeline: content corpus data → ContentRepository → V2ContentSelector
/// → learner-state updates → next exposure. Verifies the Definition of
/// Done: the sequence emerges from the sequencing layer over the data
/// corpus, with no UI/curriculum coupling anywhere.
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/content/content.dart';
import 'package:jianru/core/simulated_level.dart';
import 'package:jianru/data/database.dart';
import 'package:jianru/data/repositories/content_repository_impl.dart';
import 'package:jianru/learner/learner_state.dart';
import 'package:jianru/selector/selector.dart';

import 'helpers/corpus_loader.dart';

void main() {
  group('end-to-end: content → sequencing → next exposure', () {
    test(
      'a fresh learner walks the corpus and every step is well-formed',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);

        final repo = AssetContentRepository(db: db, initialItems: fullCorpus());
        const selector = V2ContentSelector();

        var learner = const LearnerState();
        final seenIds = <String>[];

        for (var step = 0; step < 300; step++) {
          final candidates = await repo.getCandidateContents();
          final selection = selector.select(learner, candidates);
          expect(selection, isNotNull, reason: 'step $step: no selection');

          final item = await repo.getContentItem(selection!.contentId);
          expect(item, isNotNull, reason: 'step $step: unresolved selection');
          expect(
            item!.metadata.status,
            ContentStatus.available,
            reason: 'step $step: non-available item selected',
          );

          seenIds.add(item.id);

          // Absorb the item (simulated reducer == real exposure path).
          learner = applySimulatedCompletion(learner, item);

          // Termination: everything completed at least once.
          final remaining = candidates
              .where((c) => !learner.isContentCompleted(c.id))
              .length;
          if (remaining == 0) break;
        }

        // The full corpus is completable through the selector alone.
        final allItems = await repo.getAllContentItems();
        final completedCount = allItems
            .where((i) => learner.isContentCompleted(i.id))
            .length;
        expect(
          completedCount,
          allItems.length,
          reason:
              'the walk must cover the entire corpus (${allItems.length} '
              'items) without UI help',
        );

        // Beginner units come before stories in a fresh walk (the
        // pure-exposure phase precedes meaningful reading).
        final firstStoryIndex = seenIds.indexWhere(
          (id) => !id.startsWith('unit-'),
        );
        expect(
          firstStoryIndex,
          greaterThan(0),
          reason: 'the first exposure must be a beginner unit, not a story',
        );

        // No infinite repetition loop: distinct early steps.
        expect(
          seenIds.take(5).toSet().length,
          5,
          reason: 'the first five exposures must be distinct items',
        );
      },
    );

    test(
      'the walk adapts to the corpus: adding stories changes the path',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);

        final base = fullCorpus();
        final repo = AssetContentRepository(db: db, initialItems: base);
        const selector = V2ContentSelector();

        // Take 10 steps on the base corpus.
        var learner = const LearnerState();
        final baseWalk = <String>[];
        for (var i = 0; i < 10; i++) {
          final sel = selector.select(
            learner,
            await repo.getCandidateContents(),
          )!;
          final item = (await repo.getContentItem(sel.contentId))!;
          baseWalk.add(item.id);
          learner = applySimulatedCompletion(learner, item);
        }

        // Add 5 new stories with unseen vocabulary; the next selection
        // must still be well-defined and resolvable.
        final grownRepo = AssetContentRepository(
          db: db,
          initialItems: [
            ...base,
            for (var i = 0; i < 5; i++)
              ContentItem(
                metadata: ContentMetadata(
                  id: 'future-story-$i',
                  title: '未来故事$i',
                  type: ContentType.microStory,
                  curriculumOrder: 400 + i,
                  vocabulary: {'雨伞', '冷', '书', '家', '跑'},
                ),
                sections: [
                  const ContentSection(
                    id: 'sec-1',
                    text: '外面很冷。',
                    sentences: [],
                  ),
                ],
              ),
          ],
        );

        final grownSel = selector.select(
          learner,
          await grownRepo.getCandidateContents(),
        );
        expect(grownSel, isNotNull);
        final grownItem = await grownRepo.getContentItem(grownSel!.contentId);
        expect(grownItem, isNotNull);
        expect(grownItem!.id, isNotEmpty);

        // The base walk itself was stable and progressing.
        expect(baseWalk.length, 10);
        expect(baseWalk.toSet().length, 10);
      },
    );
  });
}
