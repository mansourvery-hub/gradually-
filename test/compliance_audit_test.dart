/// End-to-end compliance regression for `QUALITY.md` invariants that the
/// existing suite doesn't yet cover mechanically:
///
/// - **P-01** Monolingual: no English chrome can ever reach the learner UI.
/// - **D-06 / C-04** Vocabulary declared in any content item must be a
///   subset of the bootstrap target-led lexicon. Enforced against BOTH
///   the corpus data files AND the runtime-assembled corpus.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/content/corpus.dart' show parseLexiconJson;

import 'helpers/corpus_loader.dart';

void main() {
  final lexiconIds = parseLexiconJson(lexiconJson()).map((i) => i.id).toSet();

  group(
    'D-06 + C-04 — declared curriculum vocabulary stays inside the lexicon',
    () {
      test('every corpus item declares a lexicon-only vocabulary', () {
        for (final item in fullCorpus()) {
          final declaredVocab = item.metadata.vocabulary;
          final out = declaredVocab
              .where((v) => !lexiconIds.contains(v))
              .toList();
          expect(
            out,
            isEmpty,
            reason:
                '${item.id}.metadata.vocabulary declares non-lexicon '
                'vocabulary: ${out.join(', ')} (QUALITY.md D-06)',
          );
          // Critical vocabulary is by definition lexicon-bounded.
          final crit = item.metadata.curriculumCriticalVocabulary;
          final critOut = crit.where((v) => !lexiconIds.contains(v)).toList();
          expect(
            critOut,
            isEmpty,
            reason:
                '${item.id}.metadata.curriculumCriticalVocabulary declares '
                'non-lexicon: ${critOut.join(', ')} (QUALITY.md D-06)',
          );
        }
      });

      test('every story token surface is a substring of its sentence', () {
        // Defends against typos / drift between authored surface and text.
        for (final item in fullCorpus()) {
          for (final section in item.sections) {
            for (final sentence in section.sentences) {
              for (final token in sentence.tokens) {
                final slice = sentence.text.substring(token.start, token.end);
                expect(
                  slice,
                  token.surface,
                  reason:
                      'token surface mismatch in '
                      '${item.id}/${sentence.id}',
                );
              }
            }
          }
        }
      });

      test(
        'token vocab ids outside the lexicon are never declared critical',
        () {
          // Incidental tokens (他们, single chars) may exist in story text
          // for naturalness, but they must never enter the curriculum
          // vocabulary declaration that drives acquisition.
          for (final item in manifestStories()) {
            final declared = item.metadata.vocabulary;
            final incidental = <String>{};
            for (final section in item.sections) {
              for (final sentence in section.sentences) {
                for (final token in sentence.tokens) {
                  if (!lexiconIds.contains(token.vocabId)) {
                    incidental.add(token.vocabId);
                  }
                }
              }
            }
            for (final v in declared) {
              expect(
                incidental.contains(v),
                isFalse,
                reason:
                    '${item.id} declares "$v" as curriculum vocabulary, but it '
                    'is an incidental (non-lexicon) token (D-06)',
              );
            }
          }
        },
      );
    },
  );

  group('P-01 — no English chrome anywhere the learner can see', () {
    // Material chrome is driven by localization delegates + the custom
    // lookup sheet's definition string. The selection toolbar is the most
    // realistic place for an English leak (Flutter's default Material
    // localization is en when no delegate is provided).
    final materialStringsLeaked = <String>[
      'Copy',
      'Select all',
      'Cut',
      'Paste',
      'Delete',
    ];
    final libSrc = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'));

    /// Remove Dart `//` and `/* ... */` comments so comment-only mentions of
    /// forbidden strings don't trip the audit. String literals inside
    /// Dart code are preserved exactly as they appear.
    String stripDartComments(String src) {
      final out = StringBuffer();
      var i = 0;
      while (i < src.length) {
        // Block comment
        if (i + 1 < src.length && src[i] == '/' && src[i + 1] == '*') {
          final end = src.indexOf('*/', i + 2);
          if (end == -1) break;
          i = end + 2;
          continue;
        }
        // Line comment
        if (i + 1 < src.length && src[i] == '/' && src[i + 1] == '/') {
          final eol = src.indexOf('\n', i + 2);
          i = eol == -1 ? src.length : eol;
          continue;
        }
        // String literal — keep verbatim (contents must be auditable).
        if (src[i] == "'" || src[i] == '"') {
          final quote = src[i];
          out.write(quote);
          i++;
          while (i < src.length) {
            if (src[i] == r'\') {
              out.write(src[i]);
              i++;
              if (i < src.length) {
                out.write(src[i]);
                i++;
              }
              continue;
            }
            out.write(src[i]);
            if (src[i] == quote) {
              i++;
              break;
            }
            i++;
          }
          continue;
        }
        out.write(src[i]);
        i++;
      }
      return out.toString();
    }

    test('lib/ never embeds English material chrome strings', () {
      for (final f in libSrc) {
        if (f.path.contains('test/')) continue;
        final raw = f.readAsStringSync();
        final stripped = stripDartComments(raw);
        for (final s in materialStringsLeaked) {
          final pattern = RegExp("['\"]($s)['\"]");
          final hits = pattern.allMatches(stripped).toList();
          if (hits.isNotEmpty) {
            fail(
              'P-01 violation in ${f.path}: hardcoded "$s". Material '
              'chrome must come from flutter_localizations (zh), never a '
              'literal.',
            );
          }
        }
      }
    });

    test(
      'lib/reader/widgets/context_lookup_sheet.dart renders in Chinese only',
      () {
        final sheet = File(
          'lib/reader/widgets/context_lookup_sheet.dart',
        ).readAsStringSync();
        final literalPattern = RegExp("Text\\(\\s*['\"]([^'\\\"]+)['\"]");
        final latinPattern = RegExp(r'[A-Za-z]{3,}');
        for (final m in literalPattern.allMatches(sheet)) {
          final text = m.group(1)!;
          if (latinPattern.hasMatch(text)) {
            fail(
              'P-01 violation: context_lookup_sheet renders Latin text: '
              '"$text"',
            );
          }
        }
      },
    );

    test('mock dictionary surface + definition are pure Chinese', () {
      final dictFile = File('assets/dictionary/mock_dictionary.json');
      final dict =
          jsonDecode(dictFile.readAsStringSync()) as Map<String, dynamic>;
      final latinPattern = RegExp(r'[A-Za-z]');
      for (final entry in dict['entries'] as List<dynamic>) {
        final e = entry as Map<String, dynamic>;
        expect(
          latinPattern.hasMatch(e['surface'] as String),
          isFalse,
          reason: 'surface must be pure Chinese: ${e['surface']}',
        );
        expect(
          latinPattern.hasMatch(e['definition'] as String),
          isFalse,
          reason: 'definition must be pure Chinese: ${e['vocabId']}',
        );
        for (final ex in (e['examples'] as List<dynamic>).cast<String>()) {
          expect(
            latinPattern.hasMatch(ex),
            isFalse,
            reason: 'example must be pure Chinese: ${e['vocabId']}',
          );
        }
      }
    });
  });
}
