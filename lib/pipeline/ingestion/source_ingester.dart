import 'dart:convert';
import 'package:crypto/crypto.dart';

/// A segment in the ingested source text with exact character offsets.
class SourceSegment {
  const SourceSegment({
    required this.id,
    required this.chapterIndex,
    required this.segmentIndex,
    required this.rawText,
    required this.normalizedText,
    required this.rawStartOffset,
    required this.rawEndOffset,
    required this.isChapterHeader,
  });

  final String id;
  final int chapterIndex;
  final int segmentIndex;
  final String rawText;
  final String normalizedText;
  final int rawStartOffset;
  final int rawEndOffset;
  final bool isChapterHeader;

  Map<String, dynamic> toJson() => {
    'id': id,
    'chapterIndex': chapterIndex,
    'segmentIndex': segmentIndex,
    'rawText': rawText,
    'normalizedText': normalizedText,
    'rawStartOffset': rawStartOffset,
    'rawEndOffset': rawEndOffset,
    'isChapterHeader': isChapterHeader,
  };

  factory SourceSegment.fromJson(Map<String, dynamic> json) => SourceSegment(
    id: json['id'] as String,
    chapterIndex: json['chapterIndex'] as int,
    segmentIndex: json['segmentIndex'] as int,
    rawText: json['rawText'] as String,
    normalizedText: json['normalizedText'] as String,
    rawStartOffset: json['rawStartOffset'] as int,
    rawEndOffset: json['rawEndOffset'] as int,
    isChapterHeader: json['isChapterHeader'] as bool,
  );
}

/// A chapter in the ingested source artifact.
class SourceChapter {
  const SourceChapter({
    required this.chapterIndex,
    required this.title,
    required this.rawStartOffset,
    required this.rawEndOffset,
    required this.segments,
  });

  final int chapterIndex;
  final String title;
  final int rawStartOffset;
  final int rawEndOffset;
  final List<SourceSegment> segments;

  Map<String, dynamic> toJson() => {
    'chapterIndex': chapterIndex,
    'title': title,
    'rawStartOffset': rawStartOffset,
    'rawEndOffset': rawEndOffset,
    'segments': segments.map((s) => s.toJson()).toList(),
  };

  factory SourceChapter.fromJson(Map<String, dynamic> json) => SourceChapter(
    chapterIndex: json['chapterIndex'] as int,
    title: json['title'] as String,
    rawStartOffset: json['rawStartOffset'] as int,
    rawEndOffset: json['rawEndOffset'] as int,
    segments: (json['segments'] as List<dynamic>)
        .map((s) => SourceSegment.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}

/// An immutable, stable source artifact ingested from a raw literary TXT.
class SourceArtifact {
  const SourceArtifact({
    required this.sourceId,
    required this.contentHash,
    required this.encoding,
    required this.rawText,
    required this.normalizedText,
    required this.chapters,
    required this.warnings,
  });

  final String sourceId;
  final String contentHash;
  final String encoding;
  final String rawText;
  final String normalizedText;
  final List<SourceChapter> chapters;
  final List<String> warnings;

  int get totalSegments =>
      chapters.fold(0, (sum, ch) => sum + ch.segments.length);

  Map<String, dynamic> toJson() => {
    'sourceId': sourceId,
    'contentHash': contentHash,
    'encoding': encoding,
    'chapters': chapters.map((c) => c.toJson()).toList(),
    'warnings': warnings,
    'totalSegments': totalSegments,
  };

  /// Machine-readable summary ingestion report.
  Map<String, dynamic> toReport() => {
    'source_id': sourceId,
    'source_hash': contentHash,
    'encoding': encoding,
    'raw_character_count': rawText.length,
    'chapters': chapters.length,
    'segments': totalSegments,
    'warnings': warnings,
  };
}

/// Ingests a raw Chinese literary TXT into a verified, stable [SourceArtifact].
class SourceIngester {
  const SourceIngester();

  static final RegExp _chapterPattern = RegExp(
    r'^(?:第\s*([0-9零一二三四五六七八九十百千万]+)\s*[章回卷节]|Chapter\s*(\d+))(?:\s+|$)',
  );

  /// Ingests raw UTF-8 bytes into a [SourceArtifact].
  SourceArtifact ingestBytes(
    List<int> bytes, {
    String sourceId = 'novel_source',
  }) {
    String encoding = 'utf-8';
    String rawText;
    final List<String> warnings = [];

    try {
      rawText = utf8.decode(bytes);
    } catch (_) {
      try {
        rawText = latin1.decode(bytes);
        encoding = 'latin1';
        warnings.add('UTF-8 decode failed; fell back to latin1');
      } catch (e) {
        throw FormatException('Unable to decode source bytes: $e');
      }
    }

    return ingestString(
      rawText,
      sourceId: sourceId,
      encoding: encoding,
      warnings: warnings,
    );
  }

  /// Ingests raw text into a [SourceArtifact].
  SourceArtifact ingestString(
    String rawText, {
    String sourceId = 'novel_source',
    String encoding = 'utf-8',
    List<String> warnings = const [],
    int? maxChapters,
  }) {
    final activeWarnings = List<String>.from(warnings);
    final contentHash = sha256.convert(utf8.encode(rawText)).toString();

    // Line and offset tracking preserving exact character boundaries.
    final List<SourceChapter> chapters = [];
    final List<_RawLineInfo> rawLines = _splitLinesWithOffsets(rawText);

    int currentChapterIndex = 0;
    String currentChapterTitle = '序 / 前言';
    int chapterStartOffset = 0;
    List<SourceSegment> currentSegments = [];
    int segmentCounter = 0;

    for (int i = 0; i < rawLines.length; i++) {
      final lineInfo = rawLines[i];
      final trimmed = lineInfo.line.trim();

      if (trimmed.isEmpty) {
        continue;
      }

      final chapterMatch = _chapterPattern.firstMatch(trimmed);
      if (chapterMatch != null) {
        // Finalize previous chapter if it has segments
        if (currentSegments.isNotEmpty) {
          final chapterEnd = currentSegments.last.rawEndOffset;
          chapters.add(
            SourceChapter(
              chapterIndex: currentChapterIndex,
              title: currentChapterTitle,
              rawStartOffset: chapterStartOffset,
              rawEndOffset: chapterEnd,
              segments: List.unmodifiable(currentSegments),
            ),
          );
          currentSegments = [];
          if (maxChapters != null && chapters.length >= maxChapters) {
            break;
          }
        }

        // Parse numerical or Chinese chapter number if present
        int parsedIndex = currentChapterIndex + 1;
        if (chapterMatch.group(1) != null) {
          final chNumStr = chapterMatch.group(1)!;
          final maybeInt = int.tryParse(chNumStr);
          if (maybeInt != null) {
            parsedIndex = maybeInt;
          }
        } else if (chapterMatch.group(2) != null) {
          final maybeInt = int.tryParse(chapterMatch.group(2)!);
          if (maybeInt != null) {
            parsedIndex = maybeInt;
          }
        }

        currentChapterIndex = parsedIndex;
        currentChapterTitle = trimmed;
        chapterStartOffset = lineInfo.startOffset;

        final normalized = _normalizeText(trimmed);
        currentSegments.add(
          SourceSegment(
            id: '${sourceId}_ch${currentChapterIndex}_seg0',
            chapterIndex: currentChapterIndex,
            segmentIndex: 0,
            rawText: lineInfo.line,
            normalizedText: normalized,
            rawStartOffset: lineInfo.startOffset,
            rawEndOffset: lineInfo.endOffset,
            isChapterHeader: true,
          ),
        );
        segmentCounter = 1;
      } else {
        if (currentChapterIndex == 0) {
          // preamble segment
        }
        final normalized = _normalizeText(lineInfo.line);
        if (normalized.isNotEmpty) {
          currentSegments.add(
            SourceSegment(
              id: '${sourceId}_ch${currentChapterIndex}_seg$segmentCounter',
              chapterIndex: currentChapterIndex,
              segmentIndex: segmentCounter,
              rawText: lineInfo.line,
              normalizedText: normalized,
              rawStartOffset: lineInfo.startOffset,
              rawEndOffset: lineInfo.endOffset,
              isChapterHeader: false,
            ),
          );
          segmentCounter++;
        }
      }
    }

    if (currentSegments.isNotEmpty) {
      chapters.add(
        SourceChapter(
          chapterIndex: currentChapterIndex,
          title: currentChapterTitle,
          rawStartOffset: chapterStartOffset,
          rawEndOffset: currentSegments.last.rawEndOffset,
          segments: List.unmodifiable(currentSegments),
        ),
      );
    }

    if (chapters.isEmpty) {
      activeWarnings.add('Source contained no non-empty structural segments');
    }

    final normalizedFull = chapters
        .expand((ch) => ch.segments.map((s) => s.normalizedText))
        .join('\n');

    return SourceArtifact(
      sourceId: sourceId,
      contentHash: contentHash,
      encoding: encoding,
      rawText: rawText,
      normalizedText: normalizedFull,
      chapters: List.unmodifiable(chapters),
      warnings: List.unmodifiable(activeWarnings),
    );
  }

  /// Splits raw text into lines while preserving exact raw character offsets.
  List<_RawLineInfo> _splitLinesWithOffsets(String text) {
    final List<_RawLineInfo> lines = [];
    int offset = 0;
    final int length = text.length;

    while (offset < length) {
      final start = offset;
      final nextNewline = text.indexOf('\n', offset);
      if (nextNewline == -1) {
        final line = text.substring(start);
        lines.add(
          _RawLineInfo(line: line, startOffset: start, endOffset: length),
        );
        break;
      } else {
        final end = nextNewline;
        // Check for preceding \r
        if (end > start && text[end - 1] == '\r') {
          final line = text.substring(start, end - 1);
          lines.add(
            _RawLineInfo(line: line, startOffset: start, endOffset: end - 1),
          );
        } else {
          final line = text.substring(start, end);
          lines.add(
            _RawLineInfo(line: line, startOffset: start, endOffset: end),
          );
        }
        offset = nextNewline + 1;
      }
    }

    return lines;
  }

  /// Normalizes whitespace and Chinese fullwidth punctuation anomalies while preserving semantic text.
  String _normalizeText(String input) {
    var s = input;
    // Replace fullwidth spaces (U+3000) and repeated whitespaces
    s = s.replaceAll('　', ' ');
    s = s.replaceAll(RegExp(r'[ \t\f]+'), ' ');
    return s.trim();
  }
}

class _RawLineInfo {
  const _RawLineInfo({
    required this.line,
    required this.startOffset,
    required this.endOffset,
  });

  final String line;
  final int startOffset;
  final int endOffset;
}
