/// Content architecture boundary tests (handoff milestone).
///
/// Proves the DEFINITION OF DONE:
/// - adding stories to the corpus DATA changes what the repository
///   offers — without touching story UI, navigation, or sequencing code
/// - story/reader UI components contain no curriculum knowledge
///   (no content ids, no order assumptions)
/// - the corpus is assembled from data files, never from Dart lists
/// - unavailable content is filtered; optional media never gates content
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/content/content.dart';
import 'package:jianru/data/database.dart';
import 'package:jianru/data/repositories/content_repository_impl.dart';
import 'package:jianru/learner/learner_state.dart';
import 'package:jianru/selector/selector.dart';

import 'helpers/corpus_loader.dart';

void main() {
  group('CONTENT IS DATA — corpus grows without code changes', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    AssetContentRepository repoWithExtraStories(List<ContentItem> extra) {
      return AssetContentRepository.fromData(
        db: db,
        lexiconJson: lexiconJson(),
        storyPayloads: [
          ...manifestStories().map((i) => jsonEncode(i.toJson())),
          ...extra.map((i) => jsonEncode(i.toJson())),
        ],
      );
    }

    test('adding 20 stories to the corpus changes repository output '
        '(no code changes anywhere)', () async {
      final baseline = AssetContentRepository.fromData(
        db: db,
        lexiconJson: lexiconJson(),
        storyPayloads: [
          ...manifestStories().map((i) => jsonEncode(i.toJson())),
        ],
      );
      final before = await baseline.getCandidateContents();

      // Author 20 brand-new story items — pure data objects with
      // lexicon vocabulary; the app has never seen their ids.
      ContentItem story(int i) => ContentItem(
        metadata: ContentMetadata(
          id: 'added-story-$i',
          title: '新增故事$i',
          type: ContentType.microStory,
          curriculumOrder: 300 + i,
          vocabulary: {'水', '茶', '猫'},
          status: ContentStatus.available,
        ),
        sections: [
          const ContentSection(id: 'sec-1', text: '我想喝茶。', sentences: []),
        ],
      );
      final newStories = [for (var i = 0; i < 20; i++) story(i)];

      final grown = repoWithExtraStories(newStories);
      final after = await grown.getCandidateContents();

      expect(after.length, before.length + 20);
      for (final s in newStories) {
        expect(
          after.any((c) => c.id == s.id),
          isTrue,
          reason: 'added story ${s.id} must be selectable via data alone',
        );
      }

      // Content retrieval by stable id works for the new stories too.
      final item = await grown.getContentItem('added-story-7');
      expect(item, isNotNull);
      expect(item?.title, '新增故事7');
    });

    test('content ids remain stable across corpus growth (learner progress '
        'keys on them)', () async {
      final corpus = fullCorpus();
      // The original four stories keep their exact ids.
      expect(corpus.any((i) => i.id == 'story-001-drink-tea'), isTrue);
      expect(corpus.any((i) => i.id == 'story-002-cats'), isTrue);
      expect(corpus.any((i) => i.id == 'story-003-rainy-day'), isTrue);
      expect(corpus.any((i) => i.id == 'story-children-001-cat-day'), isTrue);
      // Beginner units keep the unit-NNN-word convention.
      expect(corpus.any((i) => i.id == 'unit-001-水'), isTrue);
      expect(corpus.any((i) => i.id == 'unit-045-冷'), isTrue);
    });

    test('unavailable content is filtered from candidates', () async {
      final repo = AssetContentRepository.fromData(
        db: db,
        lexiconJson: lexiconJson(),
        storyPayloads: [
          jsonEncode(
            const ContentItem(
              metadata: ContentMetadata(
                id: 'available-story',
                title: '可用',
                type: ContentType.microStory,
                curriculumOrder: 200,
              ),
              sections: [],
            ).toJson(),
          ),
          jsonEncode(
            const ContentItem(
              metadata: ContentMetadata(
                id: 'draft-story',
                title: '草稿',
                type: ContentType.microStory,
                curriculumOrder: 201,
                status: ContentStatus.draft,
              ),
              sections: [],
            ).toJson(),
          ),
          jsonEncode(
            const ContentItem(
              metadata: ContentMetadata(
                id: 'retired-story',
                title: '退役',
                type: ContentType.microStory,
                curriculumOrder: 202,
                status: ContentStatus.retired,
              ),
              sections: [],
            ).toJson(),
          ),
        ],
      );

      final candidates = await repo.getCandidateContents();
      expect(candidates.any((c) => c.id == 'available-story'), isTrue);
      expect(candidates.any((c) => c.id == 'draft-story'), isFalse);
      expect(candidates.any((c) => c.id == 'retired-story'), isFalse);
    });

    test('optional media never gates content existence', () {
      // The 16 new stories carry NO visual/audio/animation references.
      // They must load, select, and serialize exactly like media-bearing
      // items (E-08: absence is valid).
      final medialess = manifestStories().where(
        (i) => i.sections.every(
          (s) => s.visualAsset == null && s.audioAsset == null,
        ),
      );
      expect(medialess.length, greaterThanOrEqualTo(16));

      for (final item in medialess) {
        expect(item.id.isNotEmpty, isTrue);
        // Round-trip serialization preserves the media-optional structure.
        final roundtripped = ContentItem.fromJson(item.toJson());
        expect(
          roundtripped.sections.every((s) => s.visualAsset == null),
          isTrue,
        );
      }
    });
  });

  group('SEQUENCING IS LOGIC — no curriculum knowledge in UI', () {
    test('reader/ widgets never reference content ids or story names', () {
      final readerDir = Directory('lib/reader');
      final readerFiles = readerDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      // Any curriculum-shaped string literal in reader code is a
      // boundary violation (curriculum order belongs to data + selector).
      final curriculumIdPattern = RegExp(
        "['\"](story-[a-z0-9-]+|unit-[0-9]{3}|micro-[a-z0-9-]+|dialogue-[a-z0-9-]+)['\"]",
      );
      for (final f in readerFiles) {
        final src = f.readAsStringSync();
        expect(
          curriculumIdPattern.hasMatch(src),
          isFalse,
          reason:
              '${f.path} embeds a content id — the reader must consume the '
              'selector/repository, never a curriculum',
        );
      }
    });

    test('reader/ widgets never import the corpus data layer', () {
      final readerFiles = Directory('lib/reader')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final f in readerFiles) {
        final src = f.readAsStringSync();
        expect(
          src.contains('package:jianru/content/corpus.dart'),
          isFalse,
          reason: '${f.path} must not import corpus generation directly',
        );
        expect(
          src.contains('package:jianru/data/'),
          isFalse,
          reason:
              '${f.path} must not import persistence (widgets → providers '
              '→ domain, ARCHITECTURE.md §3)',
        );
      }
    });

    test('selector drives the sequence: candidate input order never changes '
        'selection (no UI involvement)', () {
      const selector = V2ContentSelector();
      const learner = LearnerState();

      const a = [
        CandidateContent(
          id: 'u1',
          curriculumOrder: 1,
          prerequisiteIds: {},
          vocabulary: {'水'},
        ),
        CandidateContent(
          id: 'u2',
          curriculumOrder: 2,
          prerequisiteIds: {},
          vocabulary: {'茶'},
        ),
      ];

      // Same items, different data order: identical selection.
      expect(
        selector.select(learner, a)?.contentId,
        selector.select(learner, a.reversed.toList())?.contentId,
      );
    });
  });

  group('AUTHORING — data files are the source of truth', () {
    test('every manifest entry exists on disk and parses', () {
      for (final item in manifestStories()) {
        expect(item.id, isNotEmpty);
        expect(item.sections, isNotEmpty);
        expect(item.metadata.vocabulary, isNotEmpty);
      }
    });

    test('corpus size matches the V1 milestone (~20 stories)', () {
      expect(
        manifestStories().length,
        greaterThanOrEqualTo(20),
        reason: 'handoff §11: at least 20 usable stories in the corpus data',
      );
    });
  });
}
