/// Tokenizer + data-driven exposure generation tests.
///
/// The beginner exposure units are GENERATED from lexicon data
/// (assets/content/curriculum/bootstrap_target_lexicon.json) — these
/// tests pin that the data pipeline produces valid, correctly-ordered,
/// stable-id content without any code-side curriculum.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/content/content.dart';
import 'package:jianru/content/corpus.dart';
import 'package:jianru/tokenizer/jieba_tokenizer.dart';

import 'helpers/corpus_loader.dart';

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

  group('Data-driven exposure unit generation', () {
    test('lexicon data generates valid beginner units with stable ids', () {
      final items = parseLexiconJson(lexiconJson());
      expect(items.length, greaterThanOrEqualTo(40));

      final units = buildBeginnerUnits(items);
      expect(units.length, equals(items.length));

      for (int i = 0; i < units.length; i++) {
        final unit = units[i];
        expect(unit.type, ContentType.beginnerUnit);
        expect(unit.metadata.curriculumOrder, equals(i + 1));
        expect(unit.sections.length, 1);
        // Stable id convention: unit-NNN-word.
        expect(
          unit.id,
          beginnerUnitId(i, items[i].id),
          reason: 'unit ids must remain stable for persisted progress',
        );

        final sentence = unit.sections.first.sentences.first;
        expect(sentence.tokens.length, 1);
        expect(sentence.tokens.first.surface, equals(unit.metadata.title));
      }
    });

    test('beginner units carry NO prerequisite chain (sequencing is selector '
        'policy, not data structure)', () {
      for (final unit in beginnerUnits()) {
        expect(
          unit.metadata.prerequisiteIds,
          isEmpty,
          reason:
              'unit ${unit.id} declares prerequisites; eligibility belongs '
              'to the selector, not the dataset',
        );
      }
    });

    test('unit media are optional data: visuals resolve or are absent', () {
      for (final unit in beginnerUnits()) {
        // The lexicon may declare an asset path; absence is valid (E-08).
        // When declared, it must follow the ASCII-safe convention.
        final asset = unit.sections.firstOrNull?.visualAsset;
        if (asset != null) {
          expect(
            RegExp(r'^[a-zA-Z0-9/._-]+$').hasMatch(asset),
            isTrue,
            reason: 'R-05: asset path must be ASCII-safe: $asset',
          );
        }
      }
    });
  });
}
