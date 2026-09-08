import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/app/providers.dart';
import 'package:jianru/content/content.dart';
import 'package:jianru/data/database.dart';
import 'package:jianru/data/repositories/content_repository_impl.dart';
import 'package:jianru/reader/home.dart';

void main() {
  testWidgets(
    'Reader starts on Unit 1 (水) and advances to Unit 2 (茶) on completion',
    (tester) async {
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

      final contentRepo = AssetContentRepository(
        db: db,
        initialItems: const [unit1, unit2],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            contentRepositoryProvider.overrideWith((ref) => contentRepo),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Initial pump and settle to load async providers
      await tester.pumpAndSettle();

      // 1. Verify Unit 1 (水) is presented prominently
      expect(find.text('水'), findsWidgets);
      expect(find.text('继续'), findsOneWidget);

      // Verify Invariant: No English translation, no XP, no streak, no levels
      expect(find.textContaining('Level'), findsNothing);
      expect(find.textContaining('water'), findsNothing);
      expect(find.textContaining('XP'), findsNothing);
      expect(find.textContaining('Streak'), findsNothing);

      // 2. Tap "继续" to complete Unit 1
      await tester.tap(find.text('继续'));
      await tester.pumpAndSettle();

      // 3. Verify seamless progression: Unit 2 (茶) is now selected and rendered
      expect(find.text('茶'), findsWidgets);

      // Cleanly unmount widget tree so all stream subscriptions cancel before teardown
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    },
  );
}
