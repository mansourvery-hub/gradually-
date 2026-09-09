/// Visual manifest integrity tests (T_VIS_002 acceptance criteria).
///
/// Validates that every concept and scene reference resolves to an existing,
/// well-formed SVG, and that no bilingual instructional text is embedded
/// (AGENTS.md §3.1 monolingual invariant).
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifestFile = File('assets/images/manifests/bootstrap_visuals.json');
  final lexiconFile =
      File('assets/content/curriculum/bootstrap_target_lexicon.json');

  group('visual manifest (T_VIS_002)', () {
    test('manifest exists and parses', () {
      expect(manifestFile.existsSync(), isTrue,
          reason: 'bootstrap_visuals.json must exist');
      final manifest =
          jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      expect(manifest['version'], isNotNull);
      expect(manifest['concepts'], isA<Map<String, dynamic>>());
      expect(manifest['scenes'], isA<Map<String, dynamic>>());
    });

    test('every manifest concept resolves to a valid SVG file', () {
      final manifest =
          jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      final concepts = manifest['concepts'] as Map<String, dynamic>;
      expect(concepts.length, 45,
          reason: 'all 45 bootstrap concepts must be covered');

      for (final entry in concepts.entries) {
        final path = (entry.value as Map<String, dynamic>)['path'] as String;
        final f = File(path);
        expect(f.existsSync(), isTrue,
            reason: 'concept ${entry.key} asset missing at $path');
        final content = f.readAsStringSync();
        expect(content.startsWith('<svg'), isTrue,
            reason: '$path is not an SVG');
        expect(content.contains('</svg>'), isTrue,
            reason: '$path is truncated');
      }
    });

    test('every manifest scene resolves to a valid SVG file', () {
      final manifest =
          jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      final scenes = manifest['scenes'] as Map<String, dynamic>;
      expect(scenes.length, 17,
          reason: 'Story1(3) + Story2(4) + Story3(4) + ChildrenStory(6) '
              '= 17 scenes');

      for (final entry in scenes.entries) {
        final path = entry.value as String;
        final f = File(path);
        expect(f.existsSync(), isTrue,
            reason: 'scene ${entry.key} asset missing at $path');
        expect(f.readAsStringSync().contains('</svg>'), isTrue,
            reason: '$path is truncated');
      }
    });

    test('manifest concept coverage matches target lexicon exactly', () {
      final lexicon =
          jsonDecode(lexiconFile.readAsStringSync()) as Map<String, dynamic>;
      final lexIds = (lexicon['items'] as List<dynamic>)
          .map((i) => (i as Map<String, dynamic>)['id'] as String)
          .toSet();
      final manifest =
          jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      final manifestIds =
          (manifest['concepts'] as Map<String, dynamic>).keys.toSet();

      expect(manifestIds.difference(lexIds), isEmpty,
          reason: 'manifest has concepts outside the target lexicon');
      expect(lexIds.difference(manifestIds), isEmpty,
          reason: 'target lexicon concepts missing from manifest');
    });

    test('no English instructional text embedded in any SVG', () {
      final manifest =
          jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      final allPaths = <String>[
        ...(manifest['concepts'] as Map<String, dynamic>)
            .values
            .map((v) => (v as Map<String, dynamic>)['path'] as String),
        ...(manifest['scenes'] as Map<String, dynamic>).values.cast<String>(),
      ];

      final englishText = RegExp(r'>[A-Za-z]{2,}<');
      for (final path in allPaths) {
        final content = File(path).readAsStringSync();
        expect(englishText.hasMatch(content), isFalse,
            reason: '$path embeds Latin instructional text (monolingual '
                'invariant violation)');
      }
    });

    test('no bilingual overlays: SVGs contain no text elements at all', () {
      final manifest =
          jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      final allPaths = <String>[
        ...(manifest['concepts'] as Map<String, dynamic>)
            .values
            .map((v) => (v as Map<String, dynamic>)['path'] as String),
        ...(manifest['scenes'] as Map<String, dynamic>).values.cast<String>(),
      ];

      for (final path in allPaths) {
        final content = File(path).readAsStringSync();
        expect(content.contains('<text'), isFalse,
            reason: '$path contains a text element — visuals must be purely '
                'pictographic (E-01 monolingual)');
      }
    });
  });
}
