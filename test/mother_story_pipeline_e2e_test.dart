import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/pipeline/mother_story_pipeline.dart';

void main() {
  group('Contract 9: End-to-End Red Chamber Fixture Pipeline', () {
    late String fullSourceText;
    late MotherStoryPipeline pipeline;

    setUpAll(() {
      final file = File('assets/source/红楼梦.txt');
      expect(file.existsSync(), isTrue, reason: 'Source fixture must exist');
      fullSourceText = file.readAsStringSync();
      pipeline = MotherStoryPipeline();
    });

    test(
      'executes complete pipeline on 红楼梦.txt bounded chapters in < 500ms',
      () {
        final stopwatch = Stopwatch()..start();

        final result = pipeline.run(
          rawSourceText: fullSourceText,
          sourceId: '红楼梦',
          maxChapters: 2,
          stepsToGenerate: 2,
        );

        stopwatch.stop();

        // Ensure CPU/performance rule: fast bounded execution
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));

        // 1. Ingestion assertions
        expect(result.sourceArtifact.chapters.length, 2);
        expect(
          result.sourceArtifact.chapters.first.title,
          contains('甄士隐梦幻识通灵'),
        );

        // 2. Canonical extraction & Grounding assertions
        expect(result.canonicalModel.events, isNotEmpty);
        expect(result.canonicalModel.entities, isNotEmpty);
        expect(result.canonicalValidation.passed, isTrue);
        expect(result.canonicalValidation.failures, isEmpty);

        // 3. Linguistic profile assertions
        expect(result.linguisticProfile.totalWordsExtracted, greaterThan(100));
        expect(result.linguisticProfile.words, isNotEmpty);

        // 4. Planning & Generation assertions
        expect(result.plannedTargets.length, 2);
        expect(result.generatedPassages.length, 2);
        expect(result.validationReports.length, 2);

        // 5. Independent validation assertions
        expect(result.success, isTrue);
        for (final report in result.validationReports) {
          expect(
            report.passed,
            isTrue,
            reason: 'Report failed: ${report.failures}',
          );
          expect(report.failures, isEmpty);
        }

        // 6. Provenance assertions
        for (final passage in result.generatedPassages) {
          expect(passage.sourceRefs, isNotEmpty);
          expect(
            passage.sourceRefs.first.rawStartOffset,
            greaterThanOrEqualTo(0),
          );
          expect(
            passage.sourceRefs.first.rawEndOffset,
            greaterThan(passage.sourceRefs.first.rawStartOffset),
          );
        }

        // 7. Learner state progression assertions
        expect(result.finalLearnerState.narrative.encounteredEvents.length, 2);
        expect(result.finalLearnerState.linguistic.knownWords, isNotEmpty);
        expect(result.finalLearnerState.linguistic.knownCharacters, isNotEmpty);
      },
    );

    test('serializes pipeline results to structured JSON report', () {
      final result = pipeline.run(
        rawSourceText: fullSourceText,
        sourceId: '红楼梦',
        maxChapters: 1,
        stepsToGenerate: 1,
      );

      final json = result.toJson();
      expect(json['sourceId'], '红楼梦');
      expect(json['chapterCount'], 1);
      expect(json['canonicalValid'], isTrue);
      expect(json['allValidationsPassed'], isTrue);
      expect(json['generatedPassagesCount'], 1);
    });
  });
}
