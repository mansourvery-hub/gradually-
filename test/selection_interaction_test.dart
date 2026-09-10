/// Selection + interaction coexistence tests.
///
/// Text is selectable everywhere for copy/paste (QUALITY.md P-03 (legitimate controls) legitimate
/// control), and the monolingual toolbar shows 复制 — while the tap-anywhere
/// reading cadence and token-lookup taps keep working: selection claims
/// only long-press/drag, never taps.
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/app/providers.dart';
import 'package:jianru/content/content.dart';
import 'package:jianru/core/token.dart';
import 'package:jianru/data/database.dart';
import 'package:jianru/data/repositories/content_repository_impl.dart';
import 'package:jianru/dictionary/lookup.dart';
import 'package:jianru/main.dart';

void main() {
  const story = ContentItem(
    metadata: ContentMetadata(
      id: 'story-select-test',
      title: '测试',
      type: ContentType.microStory,
      curriculumOrder: 1,
      vocabulary: {'水', '茶'},
      curriculumCriticalVocabulary: {'水'},
    ),
    sections: [
      ContentSection(
        id: 'sec-1',
        text: '我想喝水。',
        sentences: [
          ContentSentence(
            id: 's-1',
            text: '我想喝水。',
            tokens: [
              Token(vocabId: '我', surface: '我', start: 0, end: 1),
              Token(vocabId: '想', surface: '想', start: 1, end: 2),
              Token(vocabId: '喝', surface: '喝', start: 2, end: 3),
              Token(vocabId: '水', surface: '水', start: 3, end: 4),
            ],
          ),
        ],
      ),
      ContentSection(
        id: 'sec-2',
        text: '我也想喝茶。',
        sentences: [
          ContentSentence(
            id: 's-2',
            text: '我也想喝茶。',
            tokens: [
              Token(vocabId: '我', surface: '我', start: 0, end: 1),
              Token(vocabId: '也', surface: '也', start: 1, end: 2),
              Token(vocabId: '想', surface: '想', start: 2, end: 3),
              Token(vocabId: '喝', surface: '喝', start: 3, end: 4),
              Token(vocabId: '茶', surface: '茶', start: 4, end: 5),
            ],
          ),
        ],
      ),
    ],
  );

  const dictJson = '''
    {"version": "test", "entries": [
      {"vocabId": "水", "surface": "水",
       "definition": "人要天天喝的东西。", "examples": ["我想喝水。"]}
    ]}
  ''';

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    final repo = AssetContentRepository(db: db, initialItems: const [story]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          contentRepositoryProvider.overrideWith((ref) => repo),
          dictionaryProvider.overrideWith(
            (ref) async => MonolingualDictionary.fromJson(dictJson),
          ),
        ],
        child: const JianruApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Glyph-precise tap/long-press helper: locates a single character's
  /// rect inside the story RichText and acts at its center.
  Future<Offset> centerOfGlyph(WidgetTester tester, String surface) async {
    final richText = tester.renderObjectList<RenderParagraph>(
      find.byType(RichText),
    );
    for (final paragraph in richText) {
      final text = paragraph.text.toPlainText();
      final index = text.indexOf(surface);
      if (index < 0) continue;
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: index, extentOffset: index + surface.length),
      );
      if (boxes.isEmpty) continue;
      final box = boxes.first;
      final origin = paragraph.localToGlobal(Offset.zero);
      return origin +
          Offset((box.left + box.right) / 2, (box.top + box.bottom) / 2);
    }
    throw StateError('glyph "$surface" not found in any story RichText');
  }

  Future<void> unmountCleanly(WidgetTester tester) async {
    // Cancel drift stream subscriptions before teardown so no timer pends.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('long-press selects text; tap still advances', (tester) async {
    await pumpApp(tester);

    // Tap-to-advance: tap the illustration area (top of the screen).
    await tester.tapAt(const Offset(400, 100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('我也想喝茶。', findRichText: true),
      findsWidgets,
      reason: 'blank-tap must advance the section',
    );

    // Long-press on story text: selection starts, position does not advance.
    final glyph = await centerOfGlyph(tester, '茶');
    await tester.longPressAt(glyph);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Story content unchanged (selection never advances the reader).
    expect(
      find.text('我也想喝茶。', findRichText: true),
      findsWidgets,
      reason: 'selection must preserve reading position',
    );
    await unmountCleanly(tester);
  });

  testWidgets('token tap opens the lookup sheet with the Chinese definition', (
    tester,
  ) async {
    await pumpApp(tester);

    final glyph = await centerOfGlyph(tester, '水');
    await tester.tapAt(glyph);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('人要天天喝的东西。'),
      findsOneWidget,
      reason: 'curated definition must render in the sheet',
    );
    expect(
      find.text('复制'),
      findsNothing,
      reason: 'no selection started by a plain tap',
    );
    await unmountCleanly(tester);
  });

  testWidgets('selection toolbar shows Chinese copy label (复制)', (
    tester,
  ) async {
    await pumpApp(tester);

    final glyph = await centerOfGlyph(tester, '水');
    await tester.longPressAt(glyph);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Material zh localization: copy button is 复制 — never "Copy".
    expect(
      find.text('复制'),
      findsWidgets,
      reason: 'monolingual invariant covers selection chrome',
    );
    expect(find.text('Copy'), findsNothing);
    await unmountCleanly(tester);
  });
}
