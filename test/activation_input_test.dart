/// Semantic activation regression tests.
///
/// Space/enter/gamepad-A must advance the zen canvas through the same
/// pathway as tap (ActivateIntent — the OS-level activation semantic,
/// shared with mobile switch-access), not a desktop-only pathway.
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/app/providers.dart';
import 'package:jianru/content/content.dart';
import 'package:jianru/data/database.dart';
import 'package:jianru/data/repositories/content_repository_impl.dart';
import 'package:jianru/reader/home.dart';

Widget _app(AppDatabase db, AssetContentRepository repo) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        contentRepositoryProvider.overrideWith((ref) => repo),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );

void main() {
  testWidgets('space key advances to next content item', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const unit1 = ContentItem(
      metadata: ContentMetadata(
        id: 'unit-1',
        title: '水',
        type: ContentType.beginnerUnit,
        curriculumOrder: 1,
        vocabulary: {'水'},
        curriculumCriticalVocabulary: {'水'},
      ),
      sections: [ContentSection(id: 'sec-1', text: '水', sentences: [])],
    );
    const unit2 = ContentItem(
      metadata: ContentMetadata(
        id: 'unit-2',
        title: '茶',
        type: ContentType.beginnerUnit,
        curriculumOrder: 2,
        prerequisiteIds: {'unit-1'},
        vocabulary: {'茶'},
        curriculumCriticalVocabulary: {'茶'},
      ),
      sections: [ContentSection(id: 'sec-1', text: '茶', sentences: [])],
    );

    final repo = AssetContentRepository(db: db, initialItems: const [unit1, unit2]);
    await tester.pumpWidget(_app(db, repo));
    await tester.pumpAndSettle();

    expect(find.text('水'), findsWidgets);

    // Simulate the space-bar semantic activation.
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    expect(find.text('茶'), findsWidgets,
        reason: 'space activation must advance to the next unit');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('enter key advances to next content item', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const unit1 = ContentItem(
      metadata: ContentMetadata(
        id: 'unit-1',
        title: '水',
        type: ContentType.beginnerUnit,
        curriculumOrder: 1,
        vocabulary: {'水'},
        curriculumCriticalVocabulary: {'水'},
      ),
      sections: [ContentSection(id: 'sec-1', text: '水', sentences: [])],
    );
    const unit2 = ContentItem(
      metadata: ContentMetadata(
        id: 'unit-2',
        title: '茶',
        type: ContentType.beginnerUnit,
        curriculumOrder: 2,
        prerequisiteIds: {'unit-1'},
        vocabulary: {'茶'},
        curriculumCriticalVocabulary: {'茶'},
      ),
      sections: [ContentSection(id: 'sec-1', text: '茶', sentences: [])],
    );

    final repo = AssetContentRepository(db: db, initialItems: const [unit1, unit2]);
    await tester.pumpWidget(_app(db, repo));
    await tester.pumpAndSettle();

    expect(find.text('水'), findsWidgets);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('茶'), findsWidgets,
        reason: 'enter activation must advance to the next unit');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  });

  test('bundled CJK font asset is registered in pubspec contract', () {
    // Guards the offline tofu fix: the subset font must exist on disk so
    // first-frame Hanzi never depends on network font loading.
    final font = File('assets/fonts/NotoSansSC-Regular-subset.ttf');
    expect(font.existsSync(), isTrue,
        reason: 'bundled subset font must exist (offline-first E-14)');
    final bytes = font.lengthSync();
    expect(bytes, greaterThan(100 * 1024),
        reason: 'subset font must contain the glyph payload');
  });
}
