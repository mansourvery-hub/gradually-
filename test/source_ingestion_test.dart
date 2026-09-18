import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/pipeline/ingestion/source_ingester.dart';

void main() {
  group('Contract 2: Source Ingestion', () {
    const ingester = SourceIngester();

    test(
      'recovers exact substrings from source offsets on synthetic dirty fixture',
      () {
        final file = File('test/fixtures/ingestion/dirty_sample.txt');
        expect(file.existsSync(), isTrue);

        final rawText = file.readAsStringSync();
        final artifact = ingester.ingestString(
          rawText,
          sourceId: 'dirty_fixture',
        );

        expect(artifact.sourceId, 'dirty_fixture');
        expect(artifact.contentHash, isNotEmpty);
        expect(artifact.chapters.length, 2);

        // Verify exact raw offset recoverability
        for (final chapter in artifact.chapters) {
          for (final seg in chapter.segments) {
            final extracted = rawText.substring(
              seg.rawStartOffset,
              seg.rawEndOffset,
            );
            expect(extracted, seg.rawText);
            expect(seg.normalizedText, isNotEmpty);
          }
        }

        final report = artifact.toReport();
        expect(report['chapters'], 2);
        expect(report['segments'], artifact.totalSegments);
        expect(report['source_hash'], artifact.contentHash);
      },
    );

    test('deterministic content hash on repeated ingestion', () {
      const sample = '第1章 标题一\n第一行内容。\n\n第2章 标题二\n第二行内容。\n';
      final a1 = ingester.ingestString(sample);
      final a2 = ingester.ingestString(sample);

      expect(a1.contentHash, a2.contentHash);
      expect(a1.chapters.length, a2.chapters.length);
      expect(a1.totalSegments, a2.totalSegments);
    });

    test('handles empty and whitespace-only text gracefully', () {
      final artifact = ingester.ingestString('   \n\n\t  \n');
      expect(artifact.chapters, isEmpty);
      expect(artifact.totalSegments, 0);
      expect(
        artifact.warnings,
        contains('Source contained no non-empty structural segments'),
      );
    });

    test('full real 红楼梦.txt ingestion test', () {
      final file = File('assets/source/红楼梦.txt');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'assets/source/红楼梦.txt must exist',
      );

      final rawBytes = file.readAsBytesSync();
      final artifact = ingester.ingestBytes(rawBytes, sourceId: 'hongloumeng');

      expect(artifact.encoding, 'utf-8');
      expect(
        artifact.chapters.length,
        120,
        reason: '红楼梦 has exactly 120 chapters',
      );
      expect(artifact.chapters.first.chapterIndex, 1);
      expect(artifact.chapters.last.chapterIndex, 120);
      expect(artifact.totalSegments, greaterThan(3000));

      final report = artifact.toReport();
      expect(report['chapters'], 120);
      expect(report['source_hash'], isNotEmpty);

      // Verify exact raw string recovery for sampled chapters & segments
      final rawString = artifact.rawText;
      final ch1 = artifact.chapters.first;
      expect(ch1.title, contains('第1章'));

      for (final seg in ch1.segments.take(5)) {
        final recovered = rawString.substring(
          seg.rawStartOffset,
          seg.rawEndOffset,
        );
        expect(recovered, seg.rawText);
      }

      final ch120 = artifact.chapters.last;
      expect(ch120.title, contains('第120章'));
      for (final seg in ch120.segments.take(5)) {
        final recovered = rawString.substring(
          seg.rawStartOffset,
          seg.rawEndOffset,
        );
        expect(recovered, seg.rawText);
      }
    });
  });
}
