/// End-to-end compliance regression for `QUALITY.md` invariants that the
/// existing suite doesn't yet cover mechanically:
///
/// - **P-01** Monolingual: no English chrome can ever reach the learner UI.
/// - **D-06 / C-04** Vocabulary declared in any content item must be a
///   subset of the bootstrap target-led lexicon. (Validators enforce
///   this against content JSON; this test enforces it against the Dart
///   corpus — the data the running app actually consumes.)
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/content/bootstrap_corpus.dart';

void main() {
  group(
    'D-06 + C-04 — declared curriculum vocabulary stays inside the lexicon',
    () {
      final lexFile = File(
        'assets/content/curriculum/bootstrap_target_lexicon.json',
      );
      final lex =
          jsonDecode(lexFile.readAsStringSync()) as Map<String, dynamic>;
      final lexiconIds = (lex['items'] as List<dynamic>)
          .map((i) => (i as Map<String, dynamic>)['id'] as String)
          .toSet();

      test(
        'every item in bootstrapCurriculum declares a lexicon-only vocabulary',
        () {
          for (final item in bootstrapCurriculum) {
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
        },
      );

      test('every story token surface is a substring of its sentence', () {
        // Defends against typos / drift between authored surface and text.
        for (final item in bootstrapCurriculum) {
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
        // Strip comments before scanning: a comment mentioning the
        // forbidden string is documentation, not UI. Multiline /// and /*
        // comments are stripped; string literals inside Dart comments
        // don't reach the learner.
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
        // The sheet is the learner-facing definition surface; its literal
        // text must contain no Latin letters in the rendered empty-state or
        // definitions passed to Text widgets.
        final sheet = File(
          'lib/reader/widgets/context_lookup_sheet.dart',
        ).readAsStringSync();
        // The single visible literal is "……" — confirm no other UI literals
        // contain Latin letters.
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
      // The mock dictionary is the only learner-consumed data source for
      // definitions/examples; a regression test prevents future entries
      // from sneaking Latin back in.
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
