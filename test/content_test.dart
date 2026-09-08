import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/content/content.dart';
import 'package:jianru/core/ids.dart';
import 'package:jianru/core/progress.dart';
import 'package:jianru/core/token.dart';
import 'package:jianru/data/database.dart';
import 'package:jianru/data/repositories/content_repository_impl.dart';

void main() {
  group('Content Models JSON Serialization', () {
    test('ContentSentence serializes and deserializes cleanly', () {
      const sentence = ContentSentence(
        id: 's-1',
        text: '我想喝水。',
        tokens: [
          Token(vocabId: '我', surface: '我', start: 0, end: 1),
          Token(vocabId: '想', surface: '想', start: 1, end: 2),
          Token(vocabId: '喝', surface: '喝', start: 2, end: 3),
          Token(vocabId: '水', surface: '水', start: 3, end: 4),
        ],
        criticalVocabIds: {'我', '想'},
        audioAsset: 'audio/s1.mp3',
      );

      final json = sentence.toJson();
      final roundtripped = ContentSentence.fromJson(json);

      expect(roundtripped.id, 's-1');
      expect(roundtripped.text, '我想喝水。');
      expect(roundtripped.tokens.length, 4);
      expect(roundtripped.tokens[0].vocabId, '我');
      expect(roundtripped.tokens[3].surface, '水');
      expect(roundtripped.criticalVocabIds, {'我', '想'});
      expect(roundtripped.audioAsset, 'audio/s1.mp3');
    });

    test('ContentMetadata serializes and deserializes cleanly', () {
      const metadata = ContentMetadata(
        id: 'story-1',
        title: '测试故事',
        type: ContentType.story,
        curriculumOrder: 10,
        prerequisiteIds: {'unit-1', 'unit-2'},
        difficultyEstimate: 3,
        vocabulary: {'我', '想', '喝', '水'},
        curriculumCriticalVocabulary: {'想'},
      );

      final json = metadata.toJson();
      final roundtripped = ContentMetadata.fromJson(json);

      expect(roundtripped.id, 'story-1');
      expect(roundtripped.title, '测试故事');
      expect(roundtripped.type, ContentType.story);
      expect(roundtripped.curriculumOrder, 10);
      expect(roundtripped.prerequisiteIds, {'unit-1', 'unit-2'});
      expect(roundtripped.difficultyEstimate, 3);
      expect(roundtripped.vocabulary, {'我', '想', '喝', '水'});
      expect(roundtripped.curriculumCriticalVocabulary, {'想'});
    });

    test('toCandidateContent derives lexical metadata for the selector', () {
      const item = ContentItem(
        metadata: ContentMetadata(
          id: 'unit-1',
          title: '水',
          type: ContentType.beginnerUnit,
          curriculumOrder: 1,
          prerequisiteIds: {},
          vocabulary: {'水'},
        ),
        sections: [
          ContentSection(
            id: 'sec-1',
            text: '水',
            sentences: [
              ContentSentence(
                id: 's-1',
                text: '水',
                tokens: [Token(vocabId: '水', surface: '水', start: 0, end: 1)],
              ),
            ],
          ),
        ],
      );

      final candidate = item.toCandidateContent();
      expect(candidate.id, 'unit-1');
      expect(candidate.curriculumOrder, 1);
      expect(candidate.prerequisiteIds, isEmpty);
      expect(candidate.vocabulary, {'水'});
    });
  });

  group('Curated Content Corpus Regression & Validation (E-13)', () {
    final contentDir = Directory('assets/content');
    final jsonFiles = contentDir
        .listSync()
        .whereType<File>()
        .where(
          (f) => f.path.endsWith('.json') && !f.path.endsWith('manifest.json'),
        )
        .toList();

    test('curated content directory contains content files', () {
      expect(
        jsonFiles.isNotEmpty,
        isTrue,
        reason: 'assets/content must contain curated JSON items',
      );
    });

    final allItemIds = <ContentId>{};
    final items = <ContentItem>[];

    for (final file in jsonFiles) {
      final fileName = file.uri.pathSegments.last;
      test('validates schema and token offsets for $fileName', () {
        final contentString = file.readAsStringSync();
        final json = jsonDecode(contentString) as Map<String, dynamic>;
        final item = ContentItem.fromJson(json);

        items.add(item);
        allItemIds.add(item.id);

        expect(item.id.isNotEmpty, isTrue);
        expect(item.title.isNotEmpty, isTrue);
        expect(item.metadata.curriculumOrder, greaterThan(0));

        // Validate every sentence and its token offsets
        for (final section in item.sections) {
          expect(section.id.isNotEmpty, isTrue);
          expect(section.text.isNotEmpty, isTrue);

          for (final sentence in section.sentences) {
            expect(sentence.id.isNotEmpty, isTrue);
            expect(sentence.text.isNotEmpty, isTrue);
            expect(
              sentence.tokens.isNotEmpty,
              isTrue,
              reason: 'Each sentence must have pre-tokenized tokens (D-05)',
            );

            int lastOffset = 0;
            for (final token in sentence.tokens) {
              expect(
                token.start,
                greaterThanOrEqualTo(lastOffset),
                reason: 'Token start offset must be monotonically increasing',
              );
              expect(
                token.end,
                greaterThan(token.start),
                reason: 'Token end must be after token start',
              );
              expect(
                token.end,
                lessThanOrEqualTo(sentence.text.length),
                reason: 'Token end must be within sentence bounds',
              );

              // Exact substring match
              final actualSubstring = sentence.text.substring(
                token.start,
                token.end,
              );
              expect(
                actualSubstring,
                equals(token.surface),
                reason: 'Token surface form must match exact text slice',
              );

              lastOffset = token.end;
            }
          }
        }
      });
    }

    test('all prerequisite IDs point to existing content items in corpus', () {
      for (final item in items) {
        for (final prereq in item.metadata.prerequisiteIds) {
          expect(
            allItemIds,
            contains(prereq),
            reason:
                'Prerequisite $prereq in ${item.id} must exist in the corpus',
          );
        }
      }
    });

    test('curriculumOrder is strictly distinct for all items', () {
      final orders = items.map((i) => i.metadata.curriculumOrder).toList();
      final distinctOrders = orders.toSet();
      expect(
        distinctOrders.length,
        equals(orders.length),
        reason: 'Every content item must have a unique curriculumOrder',
      );
    });
  });

  group('AssetContentRepository', () {
    late AppDatabase db;
    late AssetContentRepository repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = AssetContentRepository(db: db);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'registers and retrieves candidate contents in curriculum order',
      () async {
        const item1 = ContentItem(
          metadata: ContentMetadata(
            id: 'unit-2',
            title: '茶',
            type: ContentType.beginnerUnit,
            curriculumOrder: 2,
          ),
          sections: [],
        );

        const item2 = ContentItem(
          metadata: ContentMetadata(
            id: 'unit-1',
            title: '水',
            type: ContentType.beginnerUnit,
            curriculumOrder: 1,
          ),
          sections: [],
        );

        repository.registerJson(jsonEncode(item1.toJson()));
        repository.registerJson(jsonEncode(item2.toJson()));

        final candidates = await repository.getCandidateContents();
        expect(candidates.length, 2);
        expect(candidates[0].id, 'unit-1');
        expect(candidates[1].id, 'unit-2');

        final loadedItem = await repository.getContentItem('unit-1');
        expect(loadedItem?.title, '水');
      },
    );

    test('tracks and saves content progress', () async {
      final now = DateTime(2026, 9, 8);
      final progress = ContentProgress.initial(
        contentId: 'unit-1',
        now: now,
      ).updatePosition(2, now).recordCompletion(now);

      await repository.saveProgress(progress);

      final loadedProgress = await repository.getProgress('unit-1');
      expect(loadedProgress, isNotNull);
      expect(loadedProgress?.contentId, 'unit-1');
      expect(loadedProgress?.lastPosition, 2);
      expect(loadedProgress?.completionCount, 1);
      expect(loadedProgress?.isCompleted, isTrue);
    });
  });
}
