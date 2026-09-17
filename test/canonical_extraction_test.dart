import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/pipeline/extraction/canonical/canonical_extractor.dart';
import 'package:jianru/pipeline/extraction/canonical/canonical_grounding_validator.dart';
import 'package:jianru/pipeline/extraction/canonical/canonical_model.dart';
import 'package:jianru/pipeline/ingestion/source_ingester.dart';

void main() {
  group('Contract 3: Canonical Story Extraction', () {
    const ingester = SourceIngester();
    const extractor = CanonicalStoryExtractor();
    const validator = CanonicalGroundingValidator();

    late SourceArtifact artifact;
    late CanonicalStoryModel model;

    setUpAll(() {
      final file = File('test/fixtures/ingestion/dirty_sample.txt');
      artifact = ingester.ingestString(
        file.readAsStringSync(),
        sourceId: 'test_sample',
      );
      model = extractor.extract(artifact);
    });

    test(
      'extracts canonical story model and validates source grounding on fixture',
      () {
        expect(model.sourceId, 'test_sample');
        expect(model.characters.length, greaterThanOrEqualTo(2));
        expect(model.events.length, greaterThanOrEqualTo(2));

        final report = model.toReport();
        expect(report['total_objects'], greaterThan(0));
        expect(report['provenance_coverage'], 1.0);
        expect(report['unsupported_objects'], 0);

        final valResult = validator.validate(model: model, artifact: artifact);
        expect(
          valResult.passed,
          isTrue,
          reason: 'Grounding failures: ${valResult.failures}',
        );
        expect(valResult.failures, isEmpty);
      },
    );

    test('extracts bounded chapters from real text quickly (< 500ms)', () {
      final file = File('assets/source/红楼梦.txt');
      expect(file.existsSync(), isTrue);

      final hlmArtifact = ingester.ingestBytes(
        file.readAsBytesSync(),
        sourceId: 'hongloumeng',
      );
      // Process first 5 chapters for fast unit verification
      final hlmModel = extractor.extract(hlmArtifact, maxChapters: 5);

      expect(hlmModel.characters.length, greaterThan(5));
      expect(hlmModel.events.length, greaterThanOrEqualTo(5));

      final valResult = validator.validate(
        model: hlmModel,
        artifact: hlmArtifact,
      );
      expect(valResult.passed, isTrue);
    });

    test('independent validator rejects ungrounded entities', () {
      const badEntity = CanonicalEntity(
        id: 'char_hallucinated',
        name: '虚构角色',
        type: EntityType.character,
        kind: FactKind.derivedFact,
        evidence: [],
        confidence: 0.1,
        firstChapter: 1,
      );

      final corruptedModel = CanonicalStoryModel(
        sourceId: model.sourceId,
        sourceHash: model.sourceHash,
        entities: [...model.entities, badEntity],
        relationships: model.relationships,
        events: model.events,
      );

      final valResult = validator.validate(
        model: corruptedModel,
        artifact: artifact,
      );
      expect(valResult.passed, isFalse);
      expect(
        valResult.failures,
        anyElement(contains('has no provenance evidence')),
      );
    });

    test('independent validator rejects missing relationship endpoints', () {
      const brokenRel = CanonicalRelationship(
        id: 'rel_broken',
        fromEntityId: 'char_nonexistent_1',
        toEntityId: 'char_nonexistent_2',
        relationType: 'friend',
        kind: FactKind.derivedFact,
        evidence: [
          SourceEvidence(
            segmentId: 'seg_dummy',
            chapterIndex: 1,
            rawStartOffset: 0,
            rawEndOffset: 5,
            snippet: 'test',
          ),
        ],
        confidence: 0.5,
      );

      final corruptedModel = CanonicalStoryModel(
        sourceId: model.sourceId,
        sourceHash: model.sourceHash,
        entities: model.entities,
        relationships: [...model.relationships, brokenRel],
        events: model.events,
      );

      final valResult = validator.validate(
        model: corruptedModel,
        artifact: artifact,
      );
      expect(valResult.passed, isFalse);
      expect(
        valResult.failures,
        anyElement(contains('references missing fromEntityId')),
      );
    });
  });
}
