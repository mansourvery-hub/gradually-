// Widget smoke test: app boots to the minimal home screen. The reader
// contains no learning logic (ARCHITECTURE.md §2) — this only pins the
// wiring.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/main.dart';

void main() {
  testWidgets('app boots to 渐入 home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: JianruApp()));

    expect(find.text('渐入'), findsOneWidget);
  });
}
