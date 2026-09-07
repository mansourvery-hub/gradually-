// Acquisition promotion tests (ARCHITECTURE.md §7): the [PROPOSED] V1
// promotion rule from LEARNING_ENGINE.md §3. Never `unknown == flashcard`.
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/acquisition/acquisition.dart';

void main() {
  const rule = V1PromotionRule();

  test('single unknown encounter does NOT promote (unknown != flashcard)', () {
    const candidate = AcquisitionCandidate(
      vocabId: '米饭',
      encounterCount: 1,
      distinctContentItems: 1,
      curriculumCritical: false,
    );

    expect(rule.shouldPromote(candidate), isFalse);
  });

  test('recurrence across two stories promotes an ordinary word', () {
    const candidate = AcquisitionCandidate(
      vocabId: '米饭',
      encounterCount: 3,
      distinctContentItems: 2,
      curriculumCritical: false,
    );

    expect(rule.shouldPromote(candidate), isTrue);
  });

  test('recurrence inside ONE story alone does not promote', () {
    const candidate = AcquisitionCandidate(
      vocabId: '米饭',
      encounterCount: 5,
      distinctContentItems: 1,
      curriculumCritical: false,
    );

    expect(
      rule.shouldPromote(candidate),
      isFalse,
      reason:
          'a word reread many times in one story may be a name or '
          'theme word; distinct-content recurrence is required',
    );
  });

  test('curriculum-critical words promote on first encounter', () {
    const candidate = AcquisitionCandidate(
      vocabId: '我',
      encounterCount: 1,
      distinctContentItems: 1,
      curriculumCritical: true,
    );

    expect(rule.shouldPromote(candidate), isTrue);
  });
}
