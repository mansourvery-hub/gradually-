/// Story authoring tool: turns raw Chinese text into pre-tokenized,
/// schema-valid content JSON (ADR-005 authoring pipeline).
///
/// CONTENT IS DATA — this is how stories are added to the corpus:
///
///   1. write the story in a source file (plain Chinese text, one
///      sentence per line, `---` between sections)
///   2. run: `dart run tool/author_story.dart source.txt --id ...`
///   3. add the output file to assets/content/manifest.json
///   4. run ./verify (validator + tests treat content as code)
///
/// Segmentation is lexicon-constrained (C-01 target-led): the target
/// lexicon (`bootstrap_target_lexicon.json`) plus an incidental-word
/// whitelist drive a deterministic longest-match tokenizer, so every
/// declared token maps to a lexicon word by construction (D-06). The
/// runtime tokenizer (dart_jieba) remains the single service for free
/// text (E-07); authored content is pre-tokenized at authoring time
/// (ADR-005), and this tool is that authoring-time process.
library;

import 'dart:convert';
import 'dart:io';

import 'package:jianru/content/content.dart';
import 'package:jianru/content/corpus.dart';
import 'package:jianru/core/token.dart';

/// Incidental multi-character words allowed as tokens (story glue words
/// that are not part of the 45-word target lexicon). Single characters
/// outside the lexicon are also permitted as incidental tokens; neither
/// is ever declared in `metadata.vocabulary` (D-06: declared curriculum
/// vocabulary stays inside the lexicon).
const List<String> kIncidentalWords = [
  '他们',
  '她们',
  '拿着',
  '外面',
  '天上',
  '哪里',
  '什么',
  '因为',
  '所以',
  '但是',
  '可是',
  '然后',
  '这边',
  '那边',
  '快去',
  '从小',
];

const Set<String> _sentenceEnders = {'。', '！', '？', '；'};

/// Lexicon-constrained deterministic segmenter for authored content.
final class LexiconSegmenter {
  LexiconSegmenter({Set<String>? lexicon, Set<String>? incidental})
    : _lexicon = _byLength(lexicon ?? const {}),
      _incidental = _byLength({...?incidental, ...kIncidentalWords});

  final List<String> _lexicon;
  final List<String> _incidental;

  static List<String> _byLength(Set<String> words) {
    final sorted = words.toList()..sort((a, b) => b.length.compareTo(a.length));
    return sorted;
  }

  String? _match(List<String> candidates, String text, int start) {
    for (final word in candidates) {
      if (text.startsWith(word, start)) return word;
    }
    return null;
  }

  /// Segments [text] into tokens with exact offsets (D-05). Punctuation
  /// and whitespace are skipped (they stay as uncovered gaps in the
  /// reader). Lexicon words win over incidental; longest match wins;
  /// a lone non-lexicon character becomes a single-char incidental token.
  List<Token> segment(String text) {
    final tokens = <Token>[];
    int i = 0;
    while (i < text.length) {
      final ch = text[i];

      // Skip whitespace and punctuation (uncovered text in the reader).
      if (ch.trim().isEmpty || _isPunctuation(ch)) {
        i++;
        continue;
      }

      final lexiconHit = _match(_lexicon, text, i);
      if (lexiconHit != null) {
        tokens.add(
          Token(
            vocabId: lexiconHit,
            surface: lexiconHit,
            start: i,
            end: i + lexiconHit.length,
          ),
        );
        i += lexiconHit.length;
        continue;
      }

      final incidentalHit = _match(_incidental, text, i);
      if (incidentalHit != null) {
        tokens.add(
          Token(
            vocabId: incidentalHit,
            surface: incidentalHit,
            start: i,
            end: i + incidentalHit.length,
          ),
        );
        i += incidentalHit.length;
        continue;
      }

      // Fallback: single character (incidental; e.g. proper names).
      tokens.add(Token(vocabId: ch, surface: ch, start: i, end: i + 1));
      i++;
    }
    return tokens;
  }

  static bool _isPunctuation(String ch) {
    const marks = '。，、；：？！“”‘’（）《》【】—…·.,!?:"\'()[]-#*';
    return marks.contains(ch);
  }
}

void main(List<String> args) {
  if (args.isEmpty || args.any((a) => a == '-h' || a == '--help')) {
    _usage();
    exit(64);
  }

  final positional = <String>[];
  String? id, title, type, out, prereqs, tags, visuals, extras;
  int order = 0, difficulty = 2;

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--id':
        id = args[++i];
      case '--title':
        title = args[++i];
      case '--type':
        type = args[++i];
      case '--order':
        order = int.tryParse(args[++i]) ?? 0;
      case '--difficulty':
        difficulty = int.tryParse(args[++i]) ?? 2;
      case '--prereq':
        prereqs = args[++i];
      case '--tag':
        tags = args[++i];
      case '--visuals':
        visuals = args[++i];
      case '--extra':
        extras = args[++i];
      case '--out':
        out = args[++i];
      default:
        positional.add(args[i]);
    }
  }

  final sourcePath = positional.first;
  final sourceFile = File(sourcePath);
  if (!sourceFile.existsSync()) {
    stderr.writeln('❌ source file not found: $sourcePath');
    exit(1);
  }
  id ??= _defaultId(sourcePath);
  title ??= id;
  final contentType = ContentType.fromName(type ?? 'microStory');

  // Lexicon data drives segmentation (C-01: target-led).
  final lexiconFile = File(
    'assets/content/curriculum/bootstrap_target_lexicon.json',
  );
  if (!lexiconFile.existsSync()) {
    stderr.writeln('❌ target lexicon not found: ${lexiconFile.path}');
    exit(1);
  }
  final lexicon = parseLexiconJson(lexiconFile.readAsStringSync());
  final lexiconSurfaces = lexicon.map((i) => i.surface).toSet();

  final segmenter = LexiconSegmenter(
    lexicon: lexiconSurfaces,
    incidental: (extras ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet(),
  );

  final raw = sourceFile.readAsStringSync();
  final sections = _parseSections(raw);
  if (sections.isEmpty) {
    stderr.writeln('❌ no non-empty sections found in $sourcePath');
    exit(1);
  }

  final visualList = (visuals ?? '')
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  final outSections = <ContentSection>[];
  final vocabulary = <String>{};
  final recurrence = <String, int>{};

  for (var s = 0; s < sections.length; s++) {
    final sentences = <ContentSentence>[];
    for (final line in sections[s]) {
      // Split each source line into sentences at final punctuation.
      for (final sentenceText in _splitSentences(line)) {
        final tokens = segmenter.segment(sentenceText);
        if (tokens.isEmpty) continue;
        for (final t in tokens) {
          if (lexiconSurfaces.contains(t.vocabId)) {
            vocabulary.add(t.vocabId);
            recurrence[t.vocabId] = (recurrence[t.vocabId] ?? 0) + 1;
          }
        }
        sentences.add(
          ContentSentence(
            id: 's${s + 1}-${sentences.length + 1}',
            text: sentenceText,
            tokens: tokens,
          ),
        );
      }
    }
    outSections.add(
      ContentSection(
        id: 'sec-${s + 1}',
        text: sections[s].join(),
        visualAsset: visualList.length > s ? visualList[s] : null,
        sentences: sentences,
      ),
    );
  }

  // Critical vocabulary: recurring lexicon words (recurrence is the V1
  // acquisition signal). Editor can refine in the JSON afterwards.
  final critical = recurrence.entries
      .where((e) => e.value > 1)
      .map((e) => e.key)
      .toSet();

  final item = ContentItem(
    metadata: ContentMetadata(
      id: id,
      title: title,
      type: contentType,
      curriculumOrder: order != 0 ? order : kStoryOrderFloor,
      prerequisiteIds: (prereqs ?? '')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toSet(),
      difficultyEstimate: difficulty,
      vocabulary: vocabulary,
      curriculumCriticalVocabulary: critical,
      tags: (tags ?? '')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toSet(),
    ),
    sections: outSections,
  );

  final json = const JsonEncoder.withIndent('  ').convert(item.toJson());

  out ??= 'assets/content/${_fileNameFor(id)}.json';
  File(out).writeAsStringSync('$json\n');
  stdout.writeln('✅ authored $id → $out');
  stdout.writeln(
    '   ${item.sections.length} sections · ${vocabulary.length} lexicon words · order ${item.metadata.curriculumOrder}',
  );
  stdout.writeln(
    '   next: add "$out" to assets/content/manifest.json, then ./verify',
  );
}

String _defaultId(String sourcePath) {
  final base = sourcePath
      .split(Platform.pathSeparator)
      .last
      .replaceFirst(RegExp(r'\.txt$'), '');
  return 'story-${base.replaceAll('_', '-')}';
}

String _fileNameFor(String id) => id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-');

/// Splits a line into sentences at sentence-final punctuation, keeping
/// the punctuation attached to each sentence.
List<String> _splitSentences(String line) {
  final sentences = <String>[];
  final buffer = StringBuffer();
  for (final ch in line.split('')) {
    buffer.write(ch);
    if (_sentenceEnders.contains(ch)) {
      final s = buffer.toString().trim();
      if (s.isNotEmpty) sentences.add(s);
      buffer.clear();
    }
  }
  final rest = buffer.toString().trim();
  if (rest.isNotEmpty) sentences.add(rest);
  return sentences;
}

List<List<String>> _parseSections(String raw) {
  final sections = <List<String>>[];
  final lines = raw
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
  var current = <String>[];
  for (final line in lines) {
    if (line == '---') {
      if (current.isNotEmpty) sections.add(current);
      current = [];
      continue;
    }
    current.add(line);
  }
  if (current.isNotEmpty) sections.add(current);
  return sections;
}

void _usage() {
  stdout.writeln('''
用法: dart run tool/author_story.dart <source.txt> [options]

Options:
  --id <id>          stable content id (default: derived from filename)
  --title <标题>      display title (default: id)
  --type <type>      microStory | story | dialogue | sentence | article
  --order <n>        curriculum order (stories start at 100)
  --difficulty <n>   difficulty estimate, 1=easiest (default 2)
  --prereq <ids>     comma-separated prerequisite content ids
  --tag <tags>       comma-separated editorial tags
  --visuals <paths>  comma-separated section visual assets (by section)
  --extra <words>    comma-separated incidental multi-char words allowed
                     as tokens beyond the target lexicon
  --out <file>       output path (default: assets/content/<id>.json)

Source format: one sentence per line; `---` separates sections.
Segmentation is lexicon-constrained: tokens map to target-lexicon words
by construction, plus whitelisted incidental words and single characters.
''');
}
