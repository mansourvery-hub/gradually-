/// Local monolingual contextual lookup (T_UI_040, AGENTS.md §3.1).
///
/// Pure Dart domain service. Lookup is Chinese-only: entries carry Chinese
/// definitions and Chinese example sentences from actual content. No
/// translation field exists anywhere in this subsystem — the type system
/// enforces the monolingual invariant by having no field to hold a
/// translation.
library;

import 'dart:convert';

import '../core/token.dart';

/// A single monolingual dictionary entry.
final class DictionaryEntry {
  const DictionaryEntry({
    required this.vocabId,
    required this.surface,
    required this.definition,
    this.examples = const [],
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    final rawExamples = json['examples'] as List<dynamic>? ?? const [];
    return DictionaryEntry(
      vocabId: json['vocabId'] as String,
      surface: json['surface'] as String,
      definition: json['definition'] as String,
      examples: rawExamples.cast<String>(),
    );
  }

  final String vocabId;

  /// The word form as the learner sees it in content.
  final String surface;

  /// Chinese-only definition, written with simple vocabulary.
  final String definition;

  /// Chinese example sentences drawn from actual content the learner read.
  final List<String> examples;

  Map<String, dynamic> toJson() => {
        'vocabId': vocabId,
        'surface': surface,
        'definition': definition,
        'examples': examples,
      };
}

/// The result of a lookup: entry present or absent. Absence is valid and
/// non-fatal (E-08 spirit: curated data exists where it exists).
final class LookupResult {
  const LookupResult.found(this.entry) : isFound = true;

  const LookupResult.absent() : entry = null, isFound = false;

  final DictionaryEntry? entry;
  final bool isFound;
}

/// Pure local monolingual dictionary over a curated JSON string.
///
/// Loaded once; lookups are synchronous map reads. Fails soft: unknown
/// words yield [LookupResult.absent], never an exception.
final class MonolingualDictionary {
  MonolingualDictionary._(this._entries);

  final Map<String, DictionaryEntry> _entries;

  /// Parses a dictionary JSON payload ([Map] with `entries` list).
  factory MonolingualDictionary.fromJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final rawEntries = decoded['entries'] as List<dynamic>? ?? const [];
    final entries = <String, DictionaryEntry>{
      for (final raw in rawEntries)
        (raw as Map<String, dynamic>)['vocabId'] as String:
            DictionaryEntry.fromJson(raw),
    };
    return MonolingualDictionary._(entries);
  }

  /// Empty dictionary: every lookup is absent (valid degraded state).
  MonolingualDictionary.empty() : this._(const {});

  /// Number of curated entries.
  int get length => _entries.length;

  /// Whether the dictionary has an entry for [vocabId].
  bool contains(String vocabId) => _entries.containsKey(vocabId);

  /// Looks up a vocabulary id. Absent entries return [LookupResult.absent].
  LookupResult lookup(String vocabId) {
    final entry = _entries[vocabId];
    if (entry == null) return const LookupResult.absent();
    return LookupResult.found(entry);
  }

  /// Looks up a [Token] from content directly.
  LookupResult lookupToken(Token token) => lookup(token.vocabId);

  /// All entries, for validation and tests.
  Iterable<DictionaryEntry> get allEntries => _entries.values;
}
