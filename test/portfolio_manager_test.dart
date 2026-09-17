import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../tool/pipeline/ladder/ladder_model.dart';
import '../tool/pipeline/portfolio/portfolio_manager.dart';

void main() {
  group('Contract 11: Portfolio / Caching Model', () {
    late Directory tempDir;
    late PortfolioCacheManager manager;

    const sampleLadder = ProgressiveLadder(
      sourceId: '红楼梦',
      sourceHash: 'sample_hash_12345',
      levels: [
        LadderLevel(
          levelNumber: 0,
          title: 'Level 0: Tier 1.0 - 1.8',
          difficultyFloor: 1.0,
          difficultyCeiling: 1.8,
          passages: [],
          cumulativeKnownWords: {'水', '茶'},
          cumulativeKnownCharacters: {'水', '茶'},
          introducedEvents: ['ev_ch1_1'],
        ),
      ],
    );

    final samplePortfolio = StoryPortfolio(
      portfolioId: 'portfolio_hongloumeng_v3',
      sourceId: '红楼梦',
      sourceContentHash: 'sample_hash_12345',
      pipelineVersion: '3.0.0',
      createdAt: DateTime.now().toIso8601String(),
      ladder: sampleLadder,
    );

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('jianru_portfolio_test_');
      manager = PortfolioCacheManager(storageDirectory: tempDir);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('saves and successfully loads valid portfolio', () async {
      await manager.save(samplePortfolio);

      final loaded = await manager.load(
        sourceId: '红楼梦',
        expectedSourceContentHash: 'sample_hash_12345',
      );

      expect(loaded, isNotNull);
      expect(loaded!.portfolioId, samplePortfolio.portfolioId);
      expect(loaded.sourceContentHash, 'sample_hash_12345');
      expect(loaded.ladder.levels.length, 1);
      expect(loaded.ladder.levels.first.cumulativeKnownWords, contains('水'));
    });

    test('invalidates cache when source content hash changes', () async {
      await manager.save(samplePortfolio);

      // Attempt to load with a different content hash (e.g. source file was modified)
      final loaded = await manager.load(
        sourceId: '红楼梦',
        expectedSourceContentHash: 'different_source_hash_99999',
      );

      expect(
        loaded,
        isNull,
        reason: 'Cache must invalidate on source content modification',
      );
    });

    test('invalidates cache if pipeline version is outdated', () async {
      final oldPortfolio = StoryPortfolio(
        portfolioId: 'portfolio_hongloumeng_v2',
        sourceId: '红楼梦',
        sourceContentHash: 'sample_hash_12345',
        pipelineVersion: '2.0.0', // Outdated pipeline version
        createdAt: DateTime.now().toIso8601String(),
        ladder: sampleLadder,
      );

      await manager.save(oldPortfolio);

      final loaded = await manager.load(
        sourceId: '红楼梦',
        expectedSourceContentHash: 'sample_hash_12345',
      );

      expect(
        loaded,
        isNull,
        reason: 'Cache must invalidate on pipeline version mismatch',
      );
    });

    test('evicts cache explicitly', () async {
      await manager.save(samplePortfolio);
      final evicted = await manager.evict('红楼梦');
      expect(evicted, isTrue);

      final loaded = await manager.load(
        sourceId: '红楼梦',
        expectedSourceContentHash: 'sample_hash_12345',
      );
      expect(loaded, isNull);
    });
  });
}
