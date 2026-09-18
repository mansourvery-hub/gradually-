/// Shared test fixture: builds the real corpus from the content DATA
/// files (lexicon + manifest), exactly as the running app loads it.
///
/// Tests use this instead of a compiled Dart corpus — proving content
/// changes never require test/code changes (CONTENT IS DATA).
library;

import 'dart:convert';
import 'dart:io';

import 'package:jianru/content/content.dart';
import 'package:jianru/content/corpus.dart';

/// Loads the target lexicon data file.
String lexiconJson() => File(
  'assets/content/curriculum/bootstrap_target_lexicon.json',
).readAsStringSync();

/// Builds the beginner units from lexicon data (as the app does).
List<ContentItem> beginnerUnits() =>
    buildBeginnerUnits(parseLexiconJson(lexiconJson()));

/// Loads all story/dialogue payloads listed in the corpus manifest.
List<ContentItem> manifestStories() {
  final manifest =
      jsonDecode(File('assets/content/manifest.json').readAsStringSync())
          as Map<String, dynamic>;
  final paths = (manifest['items'] as List<dynamic>).cast<String>();
  return [
    for (final p in paths)
      ContentItem.fromJson(
        jsonDecode(File(p).readAsStringSync()) as Map<String, dynamic>,
      ),
  ];
}

/// The full runtime corpus: units + stories (availability-filtered).
List<ContentItem> fullCorpus() {
  final items = [...beginnerUnits(), ...manifestStories()];
  return items
      .where((i) => i.metadata.status == ContentStatus.available)
      .toList();
}
