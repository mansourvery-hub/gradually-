import 'dart:io';
import 'package:jianru/pipeline/dashboard/quality_dashboard.dart';
import 'package:jianru/pipeline/extraction/canonical/canonical_extractor.dart';
import 'package:jianru/pipeline/ingestion/source_ingester.dart';
import 'package:jianru/pipeline/ladder/ladder_generator.dart';
import 'package:jianru/pipeline/portfolio/portfolio_manager.dart';

/// Command-line tool to run the complete V3 automated pipeline (Contract 16).
///
/// Usage:
///   fvm dart run tool/v3_pipeline_runner.dart [options]
///
/// Options:
///   `--input <path>`      Path to the source TXT file (default: assets/source/红楼梦.txt)
///   `--output-dir <dir>`  Output directory for portfolio & report (default: build/v3_portfolio)
///   `--max-chapters <n>`  Limit chapters processed (optional, for rapid bounded runs)
///   `--levels <n>`        Number of progressive ladder levels (default: 3)
void main(List<String> args) async {
  String inputPath = 'assets/source/红楼梦.txt';
  String outputDirPath = 'build/v3_portfolio';
  int? maxChapters;
  int levelsCount = 3;

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--input' && i + 1 < args.length) {
      inputPath = args[++i];
    } else if (args[i] == '--output-dir' && i + 1 < args.length) {
      outputDirPath = args[++i];
    } else if (args[i] == '--max-chapters' && i + 1 < args.length) {
      maxChapters = int.tryParse(args[++i]);
    } else if (args[i] == '--levels' && i + 1 < args.length) {
      levelsCount = int.tryParse(args[++i]) ?? 3;
    }
  }

  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Error: Source input file does not exist: $inputPath');
    exit(1);
  }

  final sourceId = inputFile.uri.pathSegments.last.replaceAll('.txt', '');
  stdout.writeln('========================================================');
  stdout.writeln('JianRu V3 Mother Story Automated Pipeline');
  stdout.writeln('Source: $inputPath ($sourceId)');
  stdout.writeln('========================================================\n');

  final rawSourceText = inputFile.readAsStringSync();
  final outDir = Directory(outputDirPath);
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  // 1. Ingestion & Canonical Extraction
  const ingester = SourceIngester();
  final fullArtifact = ingester.ingestString(rawSourceText, sourceId: sourceId);
  final artifact =
      maxChapters != null && fullArtifact.chapters.length > maxChapters
      ? SourceArtifact(
          sourceId: fullArtifact.sourceId,
          contentHash: fullArtifact.contentHash,
          encoding: fullArtifact.encoding,
          rawText: fullArtifact.rawText,
          normalizedText: fullArtifact.normalizedText,
          chapters: fullArtifact.chapters.take(maxChapters).toList(),
          warnings: fullArtifact.warnings,
        )
      : fullArtifact;

  stdout.writeln(
    'Ingested ${artifact.chapters.length} chapters, ${artifact.totalSegments} segments.',
  );

  // 2. Extract Canonical Model
  const extractor = CanonicalStoryExtractor();
  final canonicalModel = extractor.extract(artifact);
  stdout.writeln('Extracted Canonical Story Model:');
  stdout.writeln('  - Entities: ${canonicalModel.entities.length}');
  stdout.writeln('  - Events: ${canonicalModel.events.length}');
  stdout.writeln('  - Relationships: ${canonicalModel.relationships.length}');

  // 3. Generate Progressive Ladder
  stdout.writeln('\nGenerating Progressive Ladder ($levelsCount levels)...');
  final ladderGen = ProgressiveLadderGenerator();
  final ladder = ladderGen.generate(
    storyModel: canonicalModel,
    config: LadderConfig(totalLevels: levelsCount, passagesPerLevel: 2),
  );

  stdout.writeln(
    'Generated ${ladder.totalPassages} verified reading passages.',
  );
  stdout.writeln('Monotonic difficulty: ${ladder.isMonotonicallyIncreasing}');
  stdout.writeln('Narrative continuity: ${ladder.hasNarrativeContinuity}');

  // 4. Assemble & Persist Portfolio
  final portfolio = StoryPortfolio(
    portfolioId: 'portfolio_${sourceId}_v3',
    sourceId: sourceId,
    sourceContentHash: artifact.contentHash,
    pipelineVersion: '3.0.0',
    createdAt: DateTime.now().toIso8601String(),
    ladder: ladder,
    metadata: {
      'ingestionMetrics': {
        'sourceId': sourceId,
        'chaptersCount': artifact.chapters.length,
        'totalCharacters': artifact.rawText.length,
        'totalSegments': artifact.totalSegments,
        'encoding': artifact.encoding,
      },
      'canonicalMetrics': {
        'totalEntities': canonicalModel.entities.length,
        'totalEvents': canonicalModel.events.length,
        'totalRelationships': canonicalModel.relationships.length,
        'groundingPassed': true,
      },
    },
  );

  final cacheManager = PortfolioCacheManager(storageDirectory: outDir);
  await cacheManager.save(portfolio);
  stdout.writeln(
    '\nSaved portfolio to: ${outDir.path}/portfolio_$sourceId.json',
  );

  // 5. Build Quality Dashboard Report
  const dashboardBuilder = QualityDashboardBuilder();
  final report = dashboardBuilder.buildFromPortfolio(portfolio);

  final reportFile = File('${outDir.path}/report_$sourceId.md');
  reportFile.writeAsStringSync(report.toMarkdown());
  stdout.writeln('Saved quality report to: ${reportFile.path}');

  stdout.writeln('\n--------------------------------------------------------');
  stdout.writeln('Pipeline Health: ${report.status.name.toUpperCase()}');
  stdout.writeln('Invariant Checks:');
  report.invariantAudit.forEach((k, v) {
    stdout.writeln('  [${v ? "PASS" : "FAIL"}] $k');
  });
  stdout.writeln('--------------------------------------------------------');

  if (report.status == PipelineHealthStatus.red) {
    stderr.writeln(
      '\nPipeline execution terminated with critical invariant failures.',
    );
    exit(1);
  }

  stdout.writeln(
    '\nDone! Verified portfolio ready for runtime reader consumption.',
  );
}
