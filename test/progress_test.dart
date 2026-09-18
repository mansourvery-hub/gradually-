import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/core/progress.dart';

void main() {
  final t0 = DateTime(2026, 9, 8, 10, 0);
  final t1 = DateTime(2026, 9, 8, 10, 15);
  final t2 = DateTime(2026, 9, 8, 11, 0);

  test('initial progress creates uncompleted record at position 0', () {
    final progress = ContentProgress.initial(contentId: 'unit-1', now: t0);

    expect(progress.contentId, 'unit-1');
    expect(progress.lastPosition, 0);
    expect(progress.completionCount, 0);
    expect(progress.rereadCount, 0);
    expect(progress.isCompleted, isFalse);
    expect(progress.firstRead, t0);
    expect(progress.lastRead, t0);
  });

  test('updatePosition modifies position and lastRead timestamp', () {
    final initial = ContentProgress.initial(contentId: 'unit-1', now: t0);
    final updated = initial.updatePosition(42, t1);

    expect(updated.lastPosition, 42);
    expect(updated.completionCount, 0);
    expect(updated.lastRead, t1);
    expect(updated.firstRead, t0);
  });

  test(
    'recordCompletion increments completionCount and rereadCount on subsequent reads',
    () {
      final initial = ContentProgress.initial(contentId: 'unit-1', now: t0);

      // First completion
      final firstDone = initial.recordCompletion(t1);
      expect(firstDone.isCompleted, isTrue);
      expect(firstDone.completionCount, 1);
      expect(firstDone.rereadCount, 0);

      // Reread completion
      final rereadDone = firstDone.recordCompletion(t2);
      expect(rereadDone.completionCount, 2);
      expect(rereadDone.rereadCount, 1);
      expect(rereadDone.lastRead, t2);
    },
  );
}
