// Widget smoke test: app boots to the minimal home screen. The reader
// contains no learning logic (ARCHITECTURE.md §2) — this only pins the
// wiring. The content repository is overridden with the REAL corpus
// built from data files (proving the boot path end-to-end without the
// asset bundle, which widget tests cannot load).
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/app/providers.dart';
import 'package:jianru/data/database.dart';
import 'package:jianru/data/repositories/content_repository_impl.dart';
import 'package:jianru/main.dart';

import 'helpers/corpus_loader.dart';

void main() {
  testWidgets('app boots to 渐入 home screen', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final contentRepo = AssetContentRepository(
      db: db,
      initialItems: fullCorpus(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          contentRepositoryProvider.overrideWith((ref) => contentRepo),
        ],
        child: const JianruApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('水'), findsWidgets);

    // Cleanly unmount before teardown
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
