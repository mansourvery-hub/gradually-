/// Contextual monolingual lookup tests (T_UI_040 acceptance criteria).
///
/// Guards:
/// - Lookup is local and monolingual — no translation field can exist.
/// - Mock dictionary parses; known words found, unknown words absent.
/// - Absent lookups fail safe (no exception, reader position preserved).
/// - Token-span reconstruction preserves sentence text exactly.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/content/content.dart';
import 'package:jianru/core/token.dart';
import 'package:jianru/dictionary/lookup.dart';

import '../helpers/corpus_loader.dart';

const mockJson = '''
{
  "version": "0.1.0-mock",
  "entries": [
    {
      "vocabId": "水",
      "surface": "水",
      "definition": "一种没有颜色的东西，可以喝。",
      "examples": ["我想喝水。"]
    },
    {
      "vocabId": "猫",
      "surface": "猫",
      "definition": "一种小动物。猫喜欢鱼。",
      "examples": ["这里有一只大猫。"]
    }
  ]
}
''';

void main() {
  group('MonolingualDictionary (pure service)', () {
    test('parses mock dictionary and finds curated words', () {
      final dict = MonolingualDictionary.fromJson(mockJson);
      expect(dict.length, 2);

      final water = dict.lookup('水');
      expect(water.isFound, isTrue);
      expect(water.entry!.definition, contains('喝'));
      expect(water.entry!.examples, isNotEmpty);
    });

    test('unknown words return absent, never throw (E-08 fail-safe)', () {
      final dict = MonolingualDictionary.fromJson(mockJson);
      final result = dict.lookup('不存在的词');
      expect(result.isFound, isFalse);
      expect(result.entry, isNull);
      expect(() => dict.lookup(''), returnsNormally);
    });

    test('empty dictionary: every lookup absent, valid degraded state', () {
      final dict = MonolingualDictionary.empty();
      expect(dict.length, 0);
      expect(dict.lookup('水').isFound, isFalse);
      expect(dict.contains('水'), isFalse);
    });

    test('lookupToken resolves through the canonical Token representation', () {
      final dict = MonolingualDictionary.fromJson(mockJson);
      const token = Token(vocabId: '猫', surface: '猫', start: 0, end: 1);
      final result = dict.lookupToken(token);
      expect(result.isFound, isTrue);
      expect(result.entry!.vocabId, '猫');
    });

    test('round-trips through toJson/fromJson losslessly', () {
      final dict = MonolingualDictionary.fromJson(mockJson);
      for (final entry in dict.allEntries) {
        final clone = DictionaryEntry.fromJson(entry.toJson());
        expect(clone.vocabId, entry.vocabId);
        expect(clone.definition, entry.definition);
        expect(clone.examples, entry.examples);
      }
    });
  });

  group('monolingual invariant (QUALITY.md P-01 (monolingual))', () {
    test('mock dictionary asset exists and parses', () {
      final file = File('assets/dictionary/mock_dictionary.json');
      expect(file.existsSync(), isTrue);
      final dict = MonolingualDictionary.fromJson(file.readAsStringSync());
      expect(dict.length, greaterThanOrEqualTo(2));
    });

    test('mock dictionary covers every lexicon word (no absent taps)', () {
      // Regression guard for the "no definition shown for any word" bug:
      // every word the learner can tap in bootstrap content must find an
      // entry, so the lookup feature is never perceived as broken.
      final file = File('assets/dictionary/mock_dictionary.json');
      final dict = MonolingualDictionary.fromJson(file.readAsStringSync());

      final lexiconFile = File(
        'assets/content/curriculum/bootstrap_target_lexicon.json',
      );
      final lex =
          jsonDecode(lexiconFile.readAsStringSync()) as Map<String, dynamic>;
      for (final raw in lex['items'] as List<dynamic>) {
        final id = (raw as Map<String, dynamic>)['id'] as String;
        expect(
          dict.contains(id),
          isTrue,
          reason:
              'lexicon word "$id" has no dictionary entry — '
              'tapping it shows the absent state',
        );
      }
    });

    test('no translation field exists in the dictionary schema or data', () {
      final file = File('assets/dictionary/mock_dictionary.json');
      final raw = file.readAsStringSync();

      // The type system enforces this at compile time (DictionaryEntry has
      // no translation field); the data check guards against accidental
      // bilingual content sneaking into the JSON.
      for (final forbidden in [
        '"translation"',
        '"english"',
        '"gloss"',
        '"meaning_en"',
      ]) {
        expect(
          raw.contains(forbidden),
          isFalse,
          reason: 'monolingual dictionary must not carry $forbidden',
        );
      }
      expect(MonolingualDictionary.fromJson(raw).length, greaterThan(0));
    });

    test('definitions contain no Latin instructional text', () {
      final file = File('assets/dictionary/mock_dictionary.json');
      final dict = MonolingualDictionary.fromJson(file.readAsStringSync());
      final latin = RegExp(r'[A-Za-z]{2,}');
      for (final entry in dict.allEntries) {
        expect(
          latin.hasMatch(entry.definition),
          isFalse,
          reason: 'definition of "${entry.surface}" must be pure Chinese',
        );
        for (final example in entry.examples) {
          expect(
            latin.hasMatch(example),
            isFalse,
            reason: 'examples must be pure Chinese',
          );
        }
      }
    });
  });

  group('reader token reconstruction (lookup preserves position)', () {
    test('token spans cover every story sentence exactly', () {
      // The span builder reconstructs sentence text from tokens + uncovered
      // gaps; a corpus-wide check guarantees no drift between tokens and
      // text (the lookup tap targets depend on exact offsets).
      final stories = fullCorpus()
          .where(
            (i) =>
                i.type == ContentType.microStory || i.type == ContentType.story,
          )
          .toList();
      expect(stories, isNotEmpty);

      for (final story in stories) {
        for (final section in story.sections) {
          for (final sentence in section.sentences) {
            var cursor = 0;
            final buffer = StringBuffer();
            for (final token in sentence.tokens) {
              if (token.start > cursor) {
                buffer.write(sentence.text.substring(cursor, token.start));
              }
              buffer.write(token.surface);
              cursor = token.end;
            }
            if (cursor < sentence.text.length) {
              buffer.write(sentence.text.substring(cursor));
            }
            expect(
              buffer.toString(),
              sentence.text,
              reason:
                  'sentence reconstruction drifted in ${story.id} '
                  '${sentence.id}',
            );
          }
        }
      }
    });
  });
}
