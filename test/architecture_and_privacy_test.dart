import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/data/database.dart';

void main() {
  group('Architecture Boundary Checks (ARCHITECTURE.md §2, dev_graph T_TEST_001)', () {
    final domainDirs = [
      'lib/core',
      'lib/learner',
      'lib/content',
      'lib/tokenizer',
      'lib/acquisition',
      'lib/selector',
      'lib/review',
    ];

    for (final dirPath in domainDirs) {
      test('domain package "$dirPath" has ZERO Flutter widget or Riverpod imports', () {
        final dir = Directory(dirPath);
        if (!dir.existsSync()) return;

        final files = dir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in files) {
          final content = file.readAsStringSync();
          final lines = content.split('\n');

          for (final line in lines) {
            final trimmed = line.trim();
            if (trimmed.startsWith('import ')) {
              expect(
                trimmed,
                isNot(contains('package:flutter/material.dart')),
                reason:
                    'Pure Dart domain file ${file.path} must not import flutter/material',
              );
              expect(
                trimmed,
                isNot(contains('package:flutter/widgets.dart')),
                reason:
                    'Pure Dart domain file ${file.path} must not import flutter/widgets',
              );
              expect(
                trimmed,
                isNot(contains('package:flutter_riverpod')),
                reason:
                    'Pure Dart domain file ${file.path} must not import Riverpod',
              );
              expect(
                trimmed,
                isNot(contains('package:riverpod')),
                reason:
                    'Pure Dart domain file ${file.path} must not import Riverpod',
              );
            }
          }
        }
      });
    }
  });

  group(
    'Privacy Boundary Invariant Checks (AGENTS.md §6, dev_graph T_TEST_002)',
    () {
      late AppDatabase db;

      setUp(() {
        db = AppDatabase(NativeDatabase.memory());
      });

      tearDown(() async {
        await db.close();
      });

      test(
        'SQLite tables store bounded explicit aggregates only (NO behavioral telemetry)',
        () {
          final forbiddenSubstrings = [
            'hesitation',
            'speed',
            'readingspeed',
            'cursor',
            'scroll',
            'dwell',
            'engagement',
            'telemetry',
            'analytics',
            'profiling',
            'device',
            'session_duration',
          ];

          for (final table in db.allTables) {
            for (final col in table.$columns) {
              final colName = col.$name.toLowerCase();
              for (final forbidden in forbiddenSubstrings) {
                expect(
                  colName,
                  isNot(contains(forbidden)),
                  reason:
                      'Column "$colName" in table "${table.actualTableName}" violates §6 privacy invariant',
                );
              }
            }
          }
        },
      );
    },
  );
}
