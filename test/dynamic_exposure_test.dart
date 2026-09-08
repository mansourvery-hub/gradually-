import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/content/content.dart';
import 'package:jianru/content/exposure_generator.dart';
import 'package:jianru/tokenizer/jieba_tokenizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JiebaTokenizer', () {
    late JiebaTokenizer tokenizer;

    setUp(() {
      tokenizer = JiebaTokenizer();
    });

    test(
      'segments Chinese text and computes exact non-overlapping character offsets',
      () {
        const text = '我想喝茶，也想吃饭。';
        final tokens = tokenizer.segmentSync(text);

        expect(tokens, isNotEmpty);
        int lastOffset = 0;
        for (final token in tokens) {
          expect(token.start, greaterThanOrEqualTo(lastOffset));
          expect(token.end, greaterThan(token.start));
          expect(text.substring(token.start, token.end), equals(token.surface));
          lastOffset = token.end;
        }
      },
    );
  });

  group('DynamicExposureGenerator (T_CONT_006)', () {
    const generator = DynamicExposureGenerator();

    test(
      'parses bootstrap_target_lexicon.json and constructs valid ContentItems',
      () {
        final file = File(
          'assets/content/curriculum/bootstrap_target_lexicon.json',
        );
        expect(file.existsSync(), isTrue);

        final jsonStr = file.readAsStringSync();
        final items = generator.parseLexiconJson(jsonStr);

        expect(items.length, greaterThanOrEqualTo(40));

        final exposureUnits = generator.generateExposureUnits(items);
        expect(exposureUnits.length, equals(items.length));

        for (int i = 0; i < exposureUnits.length; i++) {
          final unit = exposureUnits[i];
          expect(unit.type, ContentType.beginnerUnit);
          expect(unit.metadata.curriculumOrder, equals(i + 1));
          expect(unit.sections.length, 1);

          final sentence = unit.sections.first.sentences.first;
          expect(sentence.tokens.length, 1);
          expect(sentence.tokens.first.surface, equals(unit.metadata.title));
        }
      },
    );
  });
}
