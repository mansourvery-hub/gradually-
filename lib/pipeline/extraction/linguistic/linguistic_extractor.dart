import 'package:jianru/tokenizer/jieba_tokenizer.dart';
import '../../ingestion/source_ingester.dart';
import 'linguistic_model.dart';

/// Extracts lexical, character, and frequency profiles from an ingested [SourceArtifact].
class LinguisticExtractor {
  LinguisticExtractor({JiebaTokenizer? tokenizer})
    : _tokenizer = tokenizer ?? JiebaTokenizer();

  final JiebaTokenizer _tokenizer;

  static final RegExp _hanziPattern = RegExp(r'^[\u4e00-\u9fa5]+$');

  LinguisticProfile extract(SourceArtifact artifact, {int? maxChapters}) {
    final chapters = maxChapters != null
        ? artifact.chapters.take(maxChapters).toList()
        : artifact.chapters;

    final Map<String, _WordAccumulator> wordMap = {};
    final Map<String, _HanziAccumulator> charMap = {};
    int totalWords = 0;

    for (final chapter in chapters) {
      final chIdx = chapter.chapterIndex;

      for (final seg in chapter.segments) {
        final text = seg.normalizedText;
        if (text.isEmpty) continue;

        final tokens = _tokenizer.segmentSync(text);

        for (final token in tokens) {
          final surface = token.surface;
          // Filter out non-Chinese tokens if any slipped through
          if (!_hanziPattern.hasMatch(surface)) continue;

          totalWords++;
          final rawRel = seg.rawText.indexOf(surface);
          final rawStart = rawRel != -1
              ? seg.rawStartOffset + rawRel
              : seg.rawStartOffset;
          final rawEnd = rawStart + surface.length;

          final wordAcc = wordMap.putIfAbsent(
            surface,
            () => _WordAccumulator(
              surface: surface,
              firstChapter: chIdx,
              firstSegmentId: seg.id,
              firstRawStartOffset: rawStart,
              firstRawEndOffset: rawEnd,
              characters: surface.split(''),
            ),
          );
          wordAcc.count++;

          // Track individual Hanzi
          for (int i = 0; i < surface.length; i++) {
            final char = surface[i];
            final charStart = rawStart + i;
            final charAcc = charMap.putIfAbsent(
              char,
              () => _HanziAccumulator(
                char: char,
                firstChapter: chIdx,
                firstSegmentId: seg.id,
                firstRawStartOffset: charStart,
              ),
            );
            charAcc.count++;
          }
        }
      }
    }

    final words = wordMap.map(
      (k, acc) => MapEntry(
        k,
        LexicalItem(
          id: k,
          surface: acc.surface,
          totalOccurrences: acc.count,
          firstChapter: acc.firstChapter,
          firstSegmentId: acc.firstSegmentId,
          firstRawStartOffset: acc.firstRawStartOffset,
          firstRawEndOffset: acc.firstRawEndOffset,
          characters: acc.characters,
        ),
      ),
    );

    final characters = charMap.map(
      (k, acc) => MapEntry(
        k,
        HanziItem(
          char: acc.char,
          totalOccurrences: acc.count,
          firstChapter: acc.firstChapter,
          firstSegmentId: acc.firstSegmentId,
          firstRawStartOffset: acc.firstRawStartOffset,
        ),
      ),
    );

    return LinguisticProfile(
      sourceId: artifact.sourceId,
      sourceHash: artifact.contentHash,
      tokenizerVersion: 'dart_jieba_1.0.1',
      totalWordsExtracted: totalWords,
      uniqueWordsCount: words.length,
      uniqueHanziCount: characters.length,
      words: words,
      characters: characters,
    );
  }
}

class _WordAccumulator {
  _WordAccumulator({
    required this.surface,
    required this.firstChapter,
    required this.firstSegmentId,
    required this.firstRawStartOffset,
    required this.firstRawEndOffset,
    required this.characters,
  });

  final String surface;
  final int firstChapter;
  final String firstSegmentId;
  final int firstRawStartOffset;
  final int firstRawEndOffset;
  final List<String> characters;
  int count = 0;
}

class _HanziAccumulator {
  _HanziAccumulator({
    required this.char,
    required this.firstChapter,
    required this.firstSegmentId,
    required this.firstRawStartOffset,
  });

  final String char;
  final int firstChapter;
  final String firstSegmentId;
  final int firstRawStartOffset;
  int count = 0;
}
