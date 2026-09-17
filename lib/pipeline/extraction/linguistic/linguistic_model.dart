/// A single lexical word item extracted from the source novel with provenance and occurrence statistics.
class LexicalItem {
  const LexicalItem({
    required this.id,
    required this.surface,
    required this.totalOccurrences,
    required this.firstChapter,
    required this.firstSegmentId,
    required this.firstRawStartOffset,
    required this.firstRawEndOffset,
    required this.characters,
  });

  final String id;
  final String surface;
  final int totalOccurrences;
  final int firstChapter;
  final String firstSegmentId;
  final int firstRawStartOffset;
  final int firstRawEndOffset;
  final List<String> characters;

  Map<String, dynamic> toJson() => {
    'id': id,
    'surface': surface,
    'totalOccurrences': totalOccurrences,
    'firstChapter': firstChapter,
    'firstSegmentId': firstSegmentId,
    'firstRawStartOffset': firstRawStartOffset,
    'firstRawEndOffset': firstRawEndOffset,
    'characters': characters,
  };

  factory LexicalItem.fromJson(Map<String, dynamic> json) => LexicalItem(
    id: json['id'] as String,
    surface: json['surface'] as String,
    totalOccurrences: json['totalOccurrences'] as int,
    firstChapter: json['firstChapter'] as int,
    firstSegmentId: json['firstSegmentId'] as String,
    firstRawStartOffset: json['firstRawStartOffset'] as int,
    firstRawEndOffset: json['firstRawEndOffset'] as int,
    characters: (json['characters'] as List<dynamic>).cast<String>(),
  );
}

/// A single unique Chinese character (Hanzi) item with provenance.
class HanziItem {
  const HanziItem({
    required this.char,
    required this.totalOccurrences,
    required this.firstChapter,
    required this.firstSegmentId,
    required this.firstRawStartOffset,
  });

  final String char;
  final int totalOccurrences;
  final int firstChapter;
  final String firstSegmentId;
  final int firstRawStartOffset;

  Map<String, dynamic> toJson() => {
    'char': char,
    'totalOccurrences': totalOccurrences,
    'firstChapter': firstChapter,
    'firstSegmentId': firstSegmentId,
    'firstRawStartOffset': firstRawStartOffset,
  };

  factory HanziItem.fromJson(Map<String, dynamic> json) => HanziItem(
    char: json['char'] as String,
    totalOccurrences: json['totalOccurrences'] as int,
    firstChapter: json['firstChapter'] as int,
    firstSegmentId: json['firstSegmentId'] as String,
    firstRawStartOffset: json['firstRawStartOffset'] as int,
  );
}

/// Complete linguistic profile extracted from the source novel.
class LinguisticProfile {
  const LinguisticProfile({
    required this.sourceId,
    required this.sourceHash,
    required this.tokenizerVersion,
    required this.totalWordsExtracted,
    required this.uniqueWordsCount,
    required this.uniqueHanziCount,
    required this.words,
    required this.characters,
  });

  final String sourceId;
  final String sourceHash;
  final String tokenizerVersion;
  final int totalWordsExtracted;
  final int uniqueWordsCount;
  final int uniqueHanziCount;
  final Map<String, LexicalItem> words;
  final Map<String, HanziItem> characters;

  Map<String, dynamic> toJson() => {
    'sourceId': sourceId,
    'sourceHash': sourceHash,
    'tokenizerVersion': tokenizerVersion,
    'totalWordsExtracted': totalWordsExtracted,
    'uniqueWordsCount': uniqueWordsCount,
    'uniqueHanziCount': uniqueHanziCount,
    'words': words.map((k, v) => MapEntry(k, v.toJson())),
    'characters': characters.map((k, v) => MapEntry(k, v.toJson())),
  };

  factory LinguisticProfile.fromJson(Map<String, dynamic> json) =>
      LinguisticProfile(
        sourceId: json['sourceId'] as String,
        sourceHash: json['sourceHash'] as String,
        tokenizerVersion: json['tokenizerVersion'] as String,
        totalWordsExtracted: json['totalWordsExtracted'] as int,
        uniqueWordsCount: json['uniqueWordsCount'] as int,
        uniqueHanziCount: json['uniqueHanziCount'] as int,
        words: (json['words'] as Map<String, dynamic>).map(
          (k, v) =>
              MapEntry(k, LexicalItem.fromJson(v as Map<String, dynamic>)),
        ),
        characters: (json['characters'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, HanziItem.fromJson(v as Map<String, dynamic>)),
        ),
      );

  Map<String, dynamic> toReport() => {
    'source_id': sourceId,
    'source_hash': sourceHash,
    'tokenizer': tokenizerVersion,
    'total_words': totalWordsExtracted,
    'unique_words': uniqueWordsCount,
    'unique_hanzi': uniqueHanziCount,
  };
}
