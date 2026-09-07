// Riverpod smoke test (D-03): providers compose domain services and stay
// testable with overridden dependencies. Widgets never contain logic.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/learner/learner_state.dart';

// A provider that will later compose the real learner-state repository.
final learnerStateProvider = Provider<LearnerState>((ref) {
  return const LearnerState();
});

void main() {
  test('providers are overridable for tests (DI boundary works)', () {
    const modified = LearnerState(knownVocabulary: {'吃'});

    final container = ProviderContainer(
      overrides: [learnerStateProvider.overrideWithValue(modified)],
    );
    addTearDown(container.dispose);

    expect(container.read(learnerStateProvider).knownVocabulary, {'吃'});
  });

  test('default provider returns the empty initial learner state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(learnerStateProvider).knownVocabulary, isEmpty);
  });
}
