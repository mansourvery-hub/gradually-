/// Integration tests for V3 Mother-Story Portfolio rendering in HomeScreen.
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/app/providers.dart';
import 'package:jianru/content/content.dart';
import 'package:jianru/data/database.dart';
import 'package:jianru/data/repositories/content_repository_impl.dart';
import 'package:jianru/pipeline/generation/generated_passage.dart';
import 'package:jianru/pipeline/ladder/ladder_model.dart';
import 'package:jianru/pipeline/portfolio/portfolio_manager.dart';
import 'package:jianru/reader/home.dart';

void main() {
  const passage1 = GeneratedPassage(
    passageId: 'pass_1',
    targetEventId: 'ev_1',
    chapterIndex: 1,
    generatedText: '贾宝玉在红楼梦中。',
    sourceRefs: [],
    newWords: ['贾宝玉'],
    newCharacters: ['贾', '宝', '玉'],
    difficultyEstimate: 1.0,
    generationMetadata: {},
  );

  const samplePortfolio = StoryPortfolio(
    portfolioId: 'portfolio_红楼梦',
    sourceId: '红楼梦',
    sourceContentHash: 'hash_123',
    pipelineVersion: 'V3.0',
    createdAt: '2026-09-18T00:00:00.000Z',
    ladder: ProgressiveLadder(
      sourceId: '红楼梦',
      sourceHash: 'hash_123',
      levels: [
        LadderLevel(
          levelNumber: 0,
          title: 'Level 0',
          difficultyFloor: 1.0,
          difficultyCeiling: 1.5,
          passages: [passage1],
          cumulativeKnownWords: {'贾宝玉'},
          cumulativeKnownCharacters: {'贾', '宝', '玉'},
          introducedEvents: ['ev_1'],
        ),
      ],
    ),
  );

  testWidgets(
    'HomeScreen renders V3PortfolioReader when v3PortfolioProvider provides a portfolio',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final contentRepo = AssetContentRepository(
        db: db,
        initialItems: const [
          ContentItem(
            metadata: ContentMetadata(
              id: 'u1',
              title: '水',
              type: ContentType.beginnerUnit,
              curriculumOrder: 1,
              vocabulary: {'水'},
              curriculumCriticalVocabulary: {'水'},
            ),
            sections: [ContentSection(id: 's1', text: '水', sentences: [])],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            contentRepositoryProvider.overrideWith((ref) => contentRepo),
            v3PortfolioProvider.overrideWith((ref) async => samplePortfolio),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // V3 portfolio passage is displayed instead of fallback V2 unit '水'
      expect(find.text('贾宝玉在红楼梦中。'), findsOneWidget);
      expect(find.text('水'), findsNothing);

      // Advance by tapping
      await tester.tap(find.text('贾宝玉在红楼梦中。'));
      await tester.pumpAndSettle();

      // Portfolio completed indicator '完'
      expect(find.text('完'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    },
  );
}
