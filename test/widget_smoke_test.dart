// Widget smoke test: app boots to the minimal home screen. The reader
// contains no learning logic (ARCHITECTURE.md §2) — this only pins the
// wiring.
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/app/providers.dart';
import 'package:jianru/data/database.dart';
import 'package:jianru/main.dart';

void main() {
  testWidgets('app boots to 渐入 home screen', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const JianruApp(),
      ),
    );

    expect(find.text('渐入'), findsWidgets);

    // Cleanly unmount before teardown
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
