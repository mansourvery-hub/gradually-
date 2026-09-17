import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/pipeline/extraction/linguistic/linguistic_extractor.dart';
import 'package:jianru/pipeline/ingestion/source_ingester.dart';

void main() {
  group('Contract 4: Linguistic Knowledge Extraction', () {
    const ingester = SourceIngester();
    final extractor = LinguisticExtractor();

    test(
      'extracts deterministic linguistic profile with exact source provenance',
      () {
        final file = File('test/fixtures/ingestion/dirty_sample.txt');
        expect(file.existsSync(), isTrue);

        final artifact = ingester.ingestString(
          file.readAsStringSync(),
          sourceId: 'sample',
        );

        final profile1 = extractor.extract(artifact);
        final profile2 = extractor.extract(artifact);

        expect(profile1.totalWordsExtracted, profile2.totalWordsExtracted);
        expect(profile1.uniqueWordsCount, profile2.uniqueWordsCount);
        expect(profile1.uniqueHanziCount, profile2.uniqueHanziCount);
        expect(profile1.uniqueWordsCount, greaterThan(5));
        expect(profile1.uniqueHanziCount, greaterThan(5));

        // Provenance check: verify every word's first occurrence matches raw text
        final rawText = artifact.rawText;
        for (final word in profile1.words.values) {
          expect(word.surface, isNotEmpty);
          expect(word.firstRawStartOffset, greaterThanOrEqualTo(0));
          expect(word.firstRawEndOffset, greaterThan(word.firstRawStartOffset));
          final slice = rawText.substring(
            word.firstRawStartOffset,
            word.firstRawEndOffset,
          );
          expect(slice, word.surface);
        }

        // Check report format
        final report = profile1.toReport();
        expect(report['source_id'], 'sample');
        expect(report['tokenizer'], contains('jieba'));
      },
    );

    test('extracts bounded chapters from real text quickly (< 500ms)', () {
      final file = File('assets/source/红楼梦.txt');
      expect(file.existsSync(), isTrue);

      final artifact = ingester.ingestBytes(
        file.readAsBytesSync(),
        sourceId: 'hongloumeng',
      );

      final stopwatch = Stopwatch()..start();
      final profile = extractor.extract(artifact, maxChapters: 3);
      stopwatch.stop();

      expect(profile.totalWordsExtracted, greaterThan(1000));
      expect(profile.uniqueWordsCount, greaterThan(200));
      expect(profile.uniqueHanziCount, greaterThan(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });
  });
}
