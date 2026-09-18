import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/pipeline/dashboard/quality_dashboard.dart';
import 'package:jianru/pipeline/mother_story_pipeline.dart';

void main() {
  group('Contract 14: Automated Quality Dashboard / Report', () {
    late String sourceContent;
    late PipelineExecutionResult execution;
    const builder = QualityDashboardBuilder();

    setUpAll(() {
      final file = File('assets/source/红楼梦.txt');
      expect(file.existsSync(), isTrue);
      sourceContent = file.readAsStringSync();
      final pipeline = MotherStoryPipeline();
      execution = pipeline.run(
        rawSourceText: sourceContent,
        maxChapters: 2,
        stepsToGenerate: 2,
      );
    });

    test(
      'generates comprehensive QualityDashboardReport from pipeline execution',
      () {
        final report = builder.buildFromExecution(execution: execution);

        expect(
          report.status,
          anyOf(PipelineHealthStatus.green, PipelineHealthStatus.yellow),
        );
        expect(report.sourceId, '红楼梦');
        expect(report.sourceContentHash, isNotEmpty);
        expect(report.ingestionMetrics['chaptersCount'], 2);
        expect(report.canonicalMetrics['totalEntities'], greaterThan(0));
        expect(report.canonicalMetrics['groundingPassed'], isTrue);
        expect(report.validationMetrics['passRate'], 100.0);
        expect(
          report
              .invariantAudit['V3-01: Zero Chinese knowledge operator assurance'],
          isTrue,
        );
        expect(
          report
              .invariantAudit['V3-05: Monolingual learner surface (Invariant P-01)'],
          isTrue,
        );
      },
    );

    test(
      'formats human-readable Markdown dashboard suitable for zero-knowledge operator',
      () {
        final report = builder.buildFromExecution(execution: execution);
        final md = report.toMarkdown();

        expect(
          md,
          contains('# JianRu V3 Automated Quality & Pipeline Health Report'),
        );
        expect(md, contains('**Status:** `'));
        expect(md, contains('## 1. Source Ingestion Metrics'));
        expect(md, contains('## 2. Canonical Story Knowledge'));
        expect(md, contains('## 3. Linguistic Profiling'));
        expect(md, contains('## 4. Multi-Layer Validation Stack'));
        expect(md, contains('## 6. Authoritative V3 Invariant Audit'));
        expect(md, contains('[PASS]'));
      },
    );

    test('serializes dashboard report to structured JSON', () {
      final report = builder.buildFromExecution(execution: execution);
      final json = report.toJson();

      expect(json['status'], isNotEmpty);
      expect(json['sourceId'], '红楼梦');
      expect(json['ingestionMetrics'], isA<Map<String, dynamic>>());
      expect(json['canonicalMetrics'], isA<Map<String, dynamic>>());
      expect(json['invariantAudit'], isA<Map<String, dynamic>>());
    });
  });
}
