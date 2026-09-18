/// Standalone curriculum validation command (CONTENT.md §1).
///
/// Validates 100% token offset exactness, prerequisite integrity,
/// curriculum ordering, target lexicon coverage, manifest parity, and
/// media references across all content data files (CONTENT IS DATA:
/// the validator is the reason content can change without code).
library;

import 'dart:convert';
import 'dart:io';

import 'package:jianru/content/content.dart';

void main(List<String> args) {
  stdout.writeln('🔍 Validating 渐入 (JianRu) Curriculum Data...');

  final contentDir = Directory('assets/content');
  if (!contentDir.existsSync()) {
    stderr.writeln('❌ Error: Directory assets/content not found.');
    exit(1);
  }

  // Target lexicon (drives generated beginner units).
  final lexFile = File(
    'assets/content/curriculum/bootstrap_target_lexicon.json',
  );
  final Set<String> lexiconIds = lexFile.existsSync()
      ? ((jsonDecode(lexFile.readAsStringSync())
                    as Map<String, dynamic>)['items']
                as List<dynamic>)
            .map((e) => (e as Map<String, dynamic>)['id'] as String)
            .toSet()
      : <String>{};

  bool isUnitId(String id) =>
      id.startsWith('unit-') && lexiconIds.any((w) => id.endsWith('-$w'));

  // 1. Load the corpus manifest (story items; units are generated from
  //    lexicon data and are not listed here).
  final manifestFile = File('assets/content/manifest.json');
  if (!manifestFile.existsSync()) {
    stderr.writeln('❌ Error: assets/content/manifest.json not found.');
    exit(1);
  }
  final manifest =
      jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
  final manifestPaths = (manifest['items'] as List<dynamic>).cast<String>();

  int totalItems = 0;
  int totalSentences = 0;
  int totalTokens = 0;
  final allItemIds = <String>{};
  final items = <ContentItem>[];
  final errors = <String>[];

  // 2. Parse each manifest-listed story file and validate token offsets.
  for (final path in manifestPaths) {
    final file = File(path);
    if (!file.existsSync()) {
      errors.add('Manifest lists missing file: $path');
      continue;
    }
    try {
      final item = ContentItem.fromJson(
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
      );
      totalItems++;

      if (allItemIds.contains(item.id)) {
        errors.add('Duplicate content ID found: "${item.id}" in $path');
      }
      allItemIds.add(item.id);
      items.add(item);

      for (final section in item.sections) {
        for (final sentence in section.sentences) {
          totalSentences++;
          int lastOffset = 0;

          for (final token in sentence.tokens) {
            totalTokens++;

            if (token.start < lastOffset) {
              errors.add(
                'Invalid token start offset (${token.start} < $lastOffset) in sentence "${sentence.id}" of ${item.id}',
              );
            }
            if (token.end <= token.start) {
              errors.add(
                'Invalid token end offset (${token.end} <= ${token.start}) in sentence "${sentence.id}" of ${item.id}',
              );
            }
            if (token.end > sentence.text.length) {
              errors.add(
                'Token out of bounds (${token.end} > ${sentence.text.length}) for word "${token.surface}" in "${sentence.id}" of ${item.id}',
              );
            } else {
              final textSlice = sentence.text.substring(token.start, token.end);
              if (textSlice != token.surface) {
                errors.add(
                  'Token mismatch in "${sentence.id}" of ${item.id}: token surface "${token.surface}" != text slice "$textSlice"',
                );
              }
            }

            lastOffset = token.end;
          }
        }
      }
    } catch (e) {
      errors.add('Failed to parse $path: $e');
    }
  }

  // 2b. Manifest parity: every content JSON on disk (excluding curriculum
  //     data and the manifest itself) must be listed, and vice versa.
  final diskPaths = contentDir
      .listSync()
      .whereType<File>()
      .where(
        (f) => f.path.endsWith('.json') && !f.path.endsWith('manifest.json'),
      )
      .map((f) => f.path)
      .toSet();
  for (final p in diskPaths) {
    if (!manifestPaths.contains(p)) {
      errors.add('Content file on disk but not in manifest: $p');
    }
  }
  for (final p in manifestPaths) {
    if (!diskPaths.contains(p)) {
      errors.add('Manifest entry not found on disk: $p');
    }
  }

  // 3. Validate prerequisites integrity (generated unit ids are valid
  //    prerequisites by convention: unit-NNN-word).
  for (final item in items) {
    for (final prereq in item.metadata.prerequisiteIds) {
      if (!allItemIds.contains(prereq) && !isUnitId(prereq)) {
        errors.add(
          'Missing prerequisite: "${item.id}" requires nonexistent item "$prereq"',
        );
      }
    }
  }

  // 4. Validate curriculum order uniqueness (stories; units are generated
  //    with order = lexicon position, unique by construction).
  final orders = items.map((i) => i.metadata.curriculumOrder).toList();
  final uniqueOrders = orders.toSet();
  if (orders.length != uniqueOrders.length) {
    errors.add('Found duplicate curriculumOrder values among story items.');
  }

  // 4b. Story orders must sit above the generated unit range (units
  //     occupy 1..N where N = lexicon size; stories start at 100).
  if (lexiconIds.isNotEmpty) {
    final unitRange = lexiconIds.length;
    for (final item in items) {
      if (item.metadata.curriculumOrder <= unitRange) {
        errors.add(
          '"${item.id}" order ${item.metadata.curriculumOrder} collides with '
          'the generated unit range (1..$unitRange); stories start at 100',
        );
      }
    }
  }

  // 5. Validate optional media references resolve (E-08: declared refs
  //    must resolve to bundled files).
  int totalVisualRefs = 0;
  for (final item in items) {
    for (final section in item.sections) {
      final visual = section.visualAsset;
      if (visual == null) continue;
      totalVisualRefs++;
      if (!File(visual).existsSync()) {
        errors.add(
          'Missing visual asset declared by "${item.id}" section '
          '"${section.id}": $visual does not exist',
        );
      } else if (!visual.endsWith('.svg') && !visual.endsWith('.png')) {
        errors.add(
          'Unsupported visual asset type declared by "${item.id}" section '
          '"${section.id}": $visual',
        );
      }
    }
  }

  // 6. Validate declared curriculum vocabulary stays inside the bootstrap
  //    lexicon (QUALITY.md D-06 + C-04). Story tokens may include
  //    incidental vocabulary, but `metadata.vocabulary` and
  //    `metadata.curriculumCriticalVocabulary` must reference only the
  //    target-led bootstrap set.
  if (lexiconIds.isNotEmpty) {
    for (final item in items) {
      for (final key in const ['vocabulary', 'curriculumCriticalVocabulary']) {
        final declared = List<String>.from(
          (item.metadata.toJson()[key] as List<dynamic>?) ?? const [],
        );
        final outOfLexicon = declared
            .where((v) => !lexiconIds.contains(v))
            .toList();
        if (outOfLexicon.isNotEmpty) {
          errors.add(
            '(D-06) "${item.id}".metadata.$key references vocabulary outside '
            'the bootstrap lexicon: ${outOfLexicon.join(', ')}',
          );
        }
      }
    }
  }

  // Summary
  if (errors.isNotEmpty) {
    stderr.writeln(
      '\n❌ Curriculum Validation FAILED with ${errors.length} errors:',
    );
    for (final err in errors) {
      stderr.writeln('  • $err');
    }
    exit(1);
  }

  stdout.writeln('✅ Curriculum Validation PASSED:');
  stdout.writeln('  • $totalItems Story/Dialogue Items parsed (manifest)');
  stdout.writeln('  • $totalSentences Sentences checked');
  stdout.writeln('  • $totalTokens Pre-tokenized tokens verified');
  stdout.writeln('  • $totalVisualRefs Visual asset references resolved');
  stdout.writeln('  • Manifest parity exact (disk ↔ manifest)');
  stdout.writeln(
    '  • ${lexiconIds.length}-word target lexicon → ${lexiconIds.length} generated units',
  );
  stdout.writeln('  • 100% token offset bounds exact and non-overlapping\n');
}
