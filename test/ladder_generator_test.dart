import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/pipeline/extraction/canonical/canonical_extractor.dart';
import 'package:jianru/pipeline/ingestion/source_ingester.dart';
import 'package:jianru/pipeline/ladder/ladder_generator.dart';
import 'package:jianru/pipeline/ladder/ladder_model.dart';

void main() {
  group('Contract 10: Progressive Ladder Generation', () {
    late CanonicalStoryExtractor extractor;
    late ProgressiveLadderGenerator ladderGenerator;
    late SourceArtifact artifact;

    setUpAll(() {
      final file = File('assets/source/红楼梦.txt');
      expect(file.existsSync(), isTrue);
      final rawText = file.readAsStringSync();
      const ingester = SourceIngester();
      final fullArtifact = ingester.ingestString(rawText, sourceId: '红楼梦');

      // Bounded to first 4 chapters for deterministic fast test
      artifact = SourceArtifact(
        sourceId: fullArtifact.sourceId,
        contentHash: fullArtifact.contentHash,
        encoding: fullArtifact.encoding,
        rawText: fullArtifact.rawText,
        normalizedText: fullArtifact.normalizedText,
        chapters: fullArtifact.chapters.take(4).toList(),
        warnings: fullArtifact.warnings,
      );

      extractor = const CanonicalStoryExtractor();
      ladderGenerator = ProgressiveLadderGenerator();
    });

    test(
      'generates multi-tiered progressive ladder with monotonic difficulty',
      () {
        final canonicalModel = extractor.extract(artifact);

        final ladder = ladderGenerator.generate(
          storyModel: canonicalModel,
          config: const LadderConfig(
            totalLevels: 3,
            passagesPerLevel: 1,
            baseDifficulty: 1.0,
            difficultyStep: 0.8,
          ),
        );

        expect(ladder.levels.length, 3);
        expect(ladder.isMonotonicallyIncreasing, isTrue);
        expect(ladder.hasNarrativeContinuity, isTrue);
        expect(ladder.totalPassages, 3);

        // Verify Level 0 < Level 1 < Level 2 difficulty bounds
        expect(ladder.levels[0].difficultyFloor, 1.0);
        expect(ladder.levels[1].difficultyFloor, 1.8);
        expect(ladder.levels[2].difficultyFloor, 2.6);

        // Cumulative vocabulary must expand across levels
        final l0Words = ladder.levels[0].cumulativeKnownWords.length;
        final l2Words = ladder.levels[2].cumulativeKnownWords.length;
        expect(l2Words, greaterThanOrEqualTo(l0Words));

        // Each passage must have valid source references
        for (final lvl in ladder.levels) {
          for (final p in lvl.passages) {
            expect(p.sourceRefs, isNotEmpty);
            expect(p.generatedText, isNotEmpty);
          }
        }
      },
    );

    test('round-trips progressive ladder through JSON serialization', () {
      final canonicalModel = extractor.extract(artifact);

      final ladder = ladderGenerator.generate(
        storyModel: canonicalModel,
        config: const LadderConfig(totalLevels: 2, passagesPerLevel: 1),
      );

      final json = ladder.toJson();
      final reconstructed = ProgressiveLadder.fromJson(json);

      expect(reconstructed.sourceId, ladder.sourceId);
      expect(reconstructed.sourceHash, ladder.sourceHash);
      expect(reconstructed.levels.length, ladder.levels.length);
      expect(reconstructed.totalPassages, ladder.totalPassages);
      expect(reconstructed.isMonotonicallyIncreasing, isTrue);
      expect(reconstructed.hasNarrativeContinuity, isTrue);
    });
  });
}
