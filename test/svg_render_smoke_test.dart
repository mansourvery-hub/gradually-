/// Renders every bundled SVG through flutter_svg exactly as the reader does.
///
/// Guards against files that are valid XML but unrenderable by
/// vector_graphics (flutter_svg's engine) — the reader silently falls back
/// to the paper-tone container for such files, which appears to the learner
/// as "missing pictures" (CHOICES.md §3B: every declared visual must render).
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifestFile = File('assets/images/manifests/bootstrap_visuals.json');
  final manifest =
      jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
  final paths = <String>[
        ...(manifest['concepts'] as Map<String, dynamic>)
            .values
            .map((v) => (v as Map<String, dynamic>)['path'] as String),
        ...(manifest['scenes'] as Map<String, dynamic>).values.cast<String>(),
      ]..sort();

  testWidgets('every bundled SVG renders through flutter_svg', (tester) async {
    final failures = <String>[];
    for (final path in paths) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SvgPicture.asset(path)),
        ),
      );
      try {
        await tester.pumpAndSettle();
        // If the SVG failed to parse/load, Flutter reports an error →
        // tester.takeException() is non-null.
        final exception = tester.takeException();
        if (exception != null) {
          failures.add('$path: $exception');
        }
      } catch (e) {
        failures.add('$path: $e');
      }
    }
    expect(failures, isEmpty,
        reason: 'all ${paths.length} declared visuals must render');
  });
}
