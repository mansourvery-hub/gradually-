// Smoke test for the dart_jieba dependency (D-02): the single tokenizer
// service (E-07). Verifies deterministic segmentation and the canonical
// example from the package docs.
import 'package:dart_jieba/dart_jieba.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dart_jieba segments the canonical example deterministically', () {
    final jieba = JiebaSegmenter();
    jieba.initializeSync();

    final first = jieba.cut('我来到北京清华大学');
    final second = jieba.cut('我来到北京清华大学');

    expect(
      first,
      equals(second),
      reason: 'tokenizer must be deterministic (E-07)',
    );
    expect(first, equals(['我', '来到', '北京', '清华大学']));
  });

  test('dart_jieba handles simple beginner content', () {
    final jieba = JiebaSegmenter();
    jieba.initializeSync();

    // Typical early vocabulary sentence: subject + verb + object.
    final words = jieba.cut('我吃米饭');

    expect(words, isNotEmpty);
    expect(
      words.join(''),
      '我吃米饭',
      reason: 'segmentation must reconstruct the original text',
    );
  });
}
