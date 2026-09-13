/// Pure-exposure gate tests (T_ENG_020 acceptance criteria).
///
/// Guards:
/// - Below 500 total exposures, no recall or SRS review is available.
/// - Exposure mass crammed into few words does NOT open the gate.
/// - The first unlocked session is a paced cohort, not the full backlog.
/// - No behavioral signal can unlock the gate (only explicit exposures).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/core/simulated_level.dart';
import 'package:jianru/learner/exposure_gate.dart';
import 'package:jianru/learner/learner_state.dart';

import 'helpers/corpus_loader.dart';

ExposureAggregate _agg(String id, int count, {DateTime? firstSeen}) {
  final seen = firstSeen ?? DateTime(2026, 9, 1);
  return ExposureAggregate(
    vocabId: id,
    encounterCount: count,
    contentItemIds: {'unit-$id'},
    firstSeen: seen,
    lastSeen: seen.add(Duration(hours: count)),
  );
}

LearnerState _state(Map<String, int> exposures) {
  return LearnerState(
    exposure: {for (final e in exposures.entries) e.key: _agg(e.key, e.value)},
  );
}

void main() {
  group('gate boundaries (CHOICES.md §1)', () {
    test('fresh learner: gate locked, zero exposure', () {
      final status = evaluateExposureGate(const LearnerState());
      expect(status.isUnlocked, isFalse);
      expect(status.totalExposures, 0);
      expect(status.reviewReadyVocab, isEmpty);
      expect(firstUnlockCohort(status), isEmpty);
    });

    test('499 total exposures: still locked (exact boundary)', () {
      // 11 words at 4 encounters = 44... build to exactly 499 total with
      // 10 ready words: 9 words x 4 = 36, one word with 463.
      final status = evaluateExposureGate(
        _state({
          for (var i = 0; i < 9; i++) 'w$i': 4,
          'bulk': 463, // 36 + 463 = 499
        }),
      );
      expect(status.totalExposures, 499);
      expect(
        status.isUnlocked,
        isFalse,
        reason: 'total below 500 must keep recall locked',
      );
    });

    test('500 total exposures + 10 ready words: unlocked (exact boundary)', () {
      // 9 x 4 = 36 + one word 464 = 500, 10 words meet the floor.
      final status = evaluateExposureGate(
        _state({
          for (var i = 0; i < 9; i++) 'w$i': 4,
          'bulk': 464, // 36 + 464 = 500, and bulk >= 4 so 10 ready words
        }),
      );
      expect(status.totalExposures, 500);
      expect(
        status.reviewReadyVocab.length,
        10,
        reason: 'all 10 words meet the per-word floor',
      );
      expect(
        status.isUnlocked,
        isTrue,
        reason: '500 total + cohort minimum reached must unlock',
      );
    });

    test('503 total but only 9 ready words: still locked (cohort minimum)', () {
      // 9 ready words (8 x 4 = 32) + bulk 468 = 500... build: ready = 8 'w'
      // + bulk = 9 ready; thin words stay below the floor.
      final status = evaluateExposureGate(
        _state({
          for (var i = 0; i < 8; i++) 'w$i': 4, // 8 ready
          'bulk': 468, // 32 + 468 = 500, bulk >= 4 → 9th ready word
          'thin1': 1, 'thin2': 1, 'thin3': 1, // below floor, not ready
          // total = 500 + 3 = 503, ready = 9 < 10
        }),
      );
      expect(status.totalExposures, 503);
      expect(status.reviewReadyVocab.length, 9);
      expect(
        status.isUnlocked,
        isFalse,
        reason:
            'exposure mass spread over only 9 words must not unlock; '
            'broad coverage is required',
      );
    });

    test('cramming 500 exposures into a single word: locked forever', () {
      final status = evaluateExposureGate(_state({'bulk': 500}));
      expect(status.totalExposures, 500);
      expect(status.reviewReadyVocab.length, 1);
      expect(
        status.isUnlocked,
        isFalse,
        reason: 'one over-exposed word is not a reviewable lexicon',
      );
    });
  });

  group('per-word exposure floor paces eligibility', () {
    test('words below 4 encounters are never review-ready', () {
      final status = evaluateExposureGate(
        _state({'a': 3, 'b': 3, 'c': 2, 'd': 1}),
      );
      expect(
        status.reviewReadyVocab,
        isEmpty,
        reason: '3/3/2/1 encounters are still absorption, not recall',
      );
    });

    test('ready cohort is ordered by oldest absorption first', () {
      final base = DateTime(2026, 9, 1);
      final exposure = <String, ExposureAggregate>{
        'later': _agg('later', 5, firstSeen: base.add(const Duration(days: 9))),
        'middle': _agg(
          'middle',
          5,
          firstSeen: base.add(const Duration(days: 4)),
        ),
        'early': _agg('early', 5, firstSeen: base),
      };
      final status = evaluateExposureGate(LearnerState(exposure: exposure));
      expect(status.reviewReadyVocab, [
        'early',
        'middle',
        'later',
      ], reason: 'earliest-absorbed words review first (stable order)');
    });
  });

  group('first-session pacing (unlock ramp)', () {
    test('first cohort is capped and takes earliest-absorbed words', () {
      final words = <String, int>{};
      final base = DateTime(2026, 9, 1);
      final exposure = <String, ExposureAggregate>{};
      for (var i = 0; i < 20; i++) {
        final id = 'w${i.toString().padLeft(2, '0')}';
        exposure[id] = _agg(id, 25, firstSeen: base.add(Duration(hours: i)));
        words[id] = 25;
      }
      final status = evaluateExposureGate(LearnerState(exposure: exposure));
      expect(status.isUnlocked, isTrue);
      expect(status.reviewReadyVocab.length, 20);

      final cohort = firstUnlockCohort(status);
      expect(
        cohort.length,
        kFirstSessionCohortSize,
        reason: 'first session after unlock is a small paced cohort',
      );
      expect(
        cohort,
        status.reviewReadyVocab.take(kFirstSessionCohortSize),
        reason: 'cohort takes the earliest-absorbed ready words',
      );
    });

    test(
      'no behavioral inputs: gate is a pure function of exposure records',
      () {
        // Two states with identical explicit exposure records evaluate
        // identically regardless of anything else the state carries.
        final a = _state({'x': 600, 'y': 600});
        final b = LearnerState(
          exposure: {'x': _agg('x', 600), 'y': _agg('y', 600)},
          knownVocabulary: {'x', 'y', 'unrelated'},
          progress: const {},
        );
        final sa = evaluateExposureGate(a);
        final sb = evaluateExposureGate(b);
        expect(sa.isUnlocked, sb.isUnlocked);
        expect(sa.totalExposures, sb.totalExposures);
        expect(sa.reviewReadyVocab, sb.reviewReadyVocab);
      },
    );
  });

  group('constants match CHOICES.md §1', () {
    test('exposure phase constants', () {
      expect(kExposurePhaseTotal, 500);
      expect(
        kPerWordExposureFloor,
        4,
        reason: 'bottom of the 4-6 encounters-per-word band',
      );
      expect(kUnlockCohortMinimum, 10);
      expect(kFirstSessionCohortSize, 5);
    });
  });

  group('simulated LEVEL injection maps to sensible gate states', () {
    test('LEVEL=0: exposure phase, gate locked', () {
      final gate = evaluateExposureGate(buildSimulatedLearnerState(0));
      expect(gate.isUnlocked, isFalse);
      expect(gate.totalExposures, 0);
    });

    test('LEVEL=25: mid exposure phase, gate still locked', () {
      final gate = evaluateExposureGate(
        buildSimulatedLearnerState(25, corpus: fullCorpus()),
      );
      expect(
        gate.isUnlocked,
        isFalse,
        reason: 'a quarter through the curriculum is still pure exposure',
      );
      expect(gate.totalExposures, greaterThan(0));
    });

    test('LEVEL=50: exposure phase complete, gate unlocked with cohort', () {
      final gate = evaluateExposureGate(
        buildSimulatedLearnerState(50, corpus: fullCorpus()),
      );
      expect(
        gate.isUnlocked,
        isTrue,
        reason: 'exposure phase done at ~500 exposures (CHOICES §4)',
      );
      final cohort = firstUnlockCohort(gate);
      expect(cohort, isNotEmpty);
      expect(cohort.length, lessThanOrEqualTo(kFirstSessionCohortSize));
    });

    test('LEVEL=100: full mastery, gate unlocked', () {
      final gate = evaluateExposureGate(
        buildSimulatedLearnerState(100, corpus: fullCorpus()),
      );
      expect(gate.isUnlocked, isTrue);
    });
  });
}
