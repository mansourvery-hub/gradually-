import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/pipeline/dashboard/quality_dashboard.dart';
import 'package:jianru/pipeline/extraction/canonical/canonical_extractor.dart';
import 'package:jianru/pipeline/ingestion/source_ingester.dart';
import 'package:jianru/pipeline/ladder/ladder_generator.dart';
import 'package:jianru/pipeline/portfolio/portfolio_manager.dart';
import 'package:jianru/reader/v3_portfolio_reader.dart';

void main() {
  group('Contract 16: Final Product Gate - End-to-End TXT to Interactive Reader', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('v3_final_gate_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    testWidgets(
      'Full Gate: Ingests TXT -> Extracts Canonical Model -> Generates Progressive Ladder -> Saves Fingerprinted Portfolio -> Generates Quality Dashboard -> Consumes via Flutter Runtime Reader',
      (tester) async {
        // 1. Ingest TXT Source
        final sourceFile = File('assets/source/红楼梦.txt');
        expect(sourceFile.existsSync(), isTrue);
        final rawText = sourceFile.readAsStringSync();

        const ingester = SourceIngester();
        // Ingest bounded chapters directly for fast deterministic gate test (< 500ms)
        final artifact = ingester.ingestString(
          rawText,
          sourceId: '红楼梦',
          maxChapters: 3,
        );

        expect(artifact.chapters.length, equals(3));
        expect(artifact.totalSegments, greaterThan(0));

        // 2. Canonical Extraction
        const extractor = CanonicalStoryExtractor();
        final canonicalModel = extractor.extract(artifact);

        expect(canonicalModel.entities, isNotEmpty);
        expect(canonicalModel.events, isNotEmpty);
        expect(canonicalModel.relationships, isNotEmpty);

        // 3. Progressive Ladder Generation
        final ladderGen = ProgressiveLadderGenerator();
        final ladder = ladderGen.generate(
          storyModel: canonicalModel,
          config: const LadderConfig(totalLevels: 3, passagesPerLevel: 2),
        );

        expect(ladder.levels.length, equals(3));
        expect(ladder.totalPassages, equals(6));
        expect(ladder.isMonotonicallyIncreasing, isTrue);
        expect(ladder.hasNarrativeContinuity, isTrue);

        // 4. Portfolio Caching & Persistence
        final portfolio = StoryPortfolio(
          portfolioId: 'portfolio_hongloumeng_gate',
          sourceId: '红楼梦',
          sourceContentHash: artifact.contentHash,
          pipelineVersion: '3.0.0',
          createdAt: DateTime.now().toIso8601String(),
          ladder: ladder,
        );

        final cacheManager = PortfolioCacheManager(storageDirectory: tempDir);
        StoryPortfolio? loadedPortfolio;
        await tester.runAsync(() async {
          await cacheManager.save(portfolio);
          loadedPortfolio = await cacheManager.load(
            sourceId: '红楼梦',
            expectedSourceContentHash: artifact.contentHash,
          );
        });

        expect(loadedPortfolio, isNotNull);
        expect(loadedPortfolio!.portfolioId, equals(portfolio.portfolioId));
        expect(loadedPortfolio!.ladder.totalPassages, equals(6));

        // 5. Automated Quality Dashboard & Invariant Verification
        const dashboard = QualityDashboardBuilder();
        final report = dashboard.buildFromPortfolio(loadedPortfolio!);

        expect(report.status, isNot(PipelineHealthStatus.red));
        expect(
          report
              .invariantAudit['V3-06: Monotonically increasing progressive ladder'],
          isTrue,
        );
        expect(
          report
              .invariantAudit['V3-03: Strict bidirectional provenance mapping'],
          isTrue,
        );
        expect(
          report
              .invariantAudit['V3-01: Zero Chinese knowledge operator assurance'],
          isTrue,
        );

        final markdownSummary = report.toMarkdown();
        expect(
          markdownSummary,
          contains('# JianRu V3 Automated Quality & Pipeline Health Report'),
        );
        expect(markdownSummary, contains('**Status:** `GREEN`'));

        // 6. Interactive Reader Runtime Consumption
        await tester.pumpWidget(
          MaterialApp(home: V3PortfolioReader(portfolio: loadedPortfolio!)),
        );
        await tester.pumpAndSettle();

        // Level 0 first passage text should be displayed
        final firstPassageText =
            loadedPortfolio!.ladder.levels[0].passages[0].generatedText;
        expect(find.text(firstPassageText), findsOneWidget);

        // Advance to next passage via tap
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        final secondPassageText =
            loadedPortfolio!.ladder.levels[0].passages[1].generatedText;
        expect(find.text(secondPassageText), findsOneWidget);
      },
    );
  });
}
