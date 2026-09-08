import 'package:flutter_test/flutter_test.dart';
import 'package:jianru/core/hanzi.dart';
import 'package:jianru/core/vocab.dart';
import 'package:jianru/learner/known.dart';

void main() {
  final now = DateTime(2026, 9, 8);

  group('computeIsVocabularyKnown', () {
    test('returns false when history is empty', () {
      expect(computeIsVocabularyKnown([]), isFalse);
    });

    test('returns false when latest evidence is forgotten', () {
      final history = [
        MasteryEvidence(
          vocabId: '你好',
          kind: MasteryEvidenceKind.meaning,
          grade: RecallGrade.remembered,
          at: now.subtract(const Duration(days: 2)),
        ),
        MasteryEvidence(
          vocabId: '你好',
          kind: MasteryEvidenceKind.meaning,
          grade: RecallGrade.forgotten,
          at: now,
        ),
      ];

      expect(computeIsVocabularyKnown(history), isFalse);
    });

    test('returns true when latest evidence is remembered', () {
      final history = [
        MasteryEvidence(
          vocabId: '你好',
          kind: MasteryEvidenceKind.meaning,
          grade: RecallGrade.remembered,
          at: now,
        ),
      ];

      expect(computeIsVocabularyKnown(history), isTrue);
    });

    test('returns true when latest evidence is partiallyRemembered', () {
      final history = [
        MasteryEvidence(
          vocabId: '你好',
          kind: MasteryEvidenceKind.meaning,
          grade: RecallGrade.partiallyRemembered,
          at: now,
        ),
      ];

      expect(computeIsVocabularyKnown(history), isTrue);
    });
  });

  group('deriveKnownHanzi', () {
    test('extracts Chinese characters from known vocabulary surface forms', () {
      const knownVocab = {
        VocabularyItem(
          id: '你好',
          surface: '你好',
          pinyin: 'nǐ hǎo',
          isSpecialItem: false,
        ),
        VocabularyItem(
          id: '吃米饭',
          surface: '吃米饭',
          pinyin: 'chī mǐ fàn',
          isSpecialItem: false,
        ),
      };

      final hanziSet = deriveKnownHanzi(
        knownVocabulary: knownVocab,
        hanziEvidence: [],
      );

      expect(hanziSet, {
        const Hanzi(character: '你'),
        const Hanzi(character: '好'),
        const Hanzi(character: '吃'),
        const Hanzi(character: '米'),
        const Hanzi(character: '饭'),
      });
    });

    test('adds Hanzi directly recognized in Hanzi-kind evidence', () {
      final hanziEvidence = [
        MasteryEvidence(
          vocabId: '水',
          kind: MasteryEvidenceKind.hanzi,
          grade: RecallGrade.remembered,
          at: now,
        ),
      ];

      final hanziSet = deriveKnownHanzi(
        knownVocabulary: {},
        hanziEvidence: hanziEvidence,
      );

      expect(hanziSet, {const Hanzi(character: '水')});
    });
  });
}
