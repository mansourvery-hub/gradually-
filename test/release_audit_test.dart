/// Release audit (QUALITY.md P-02 / P-03 / P-07).
///
/// Mechanical anti-feature scan over `lib/`:
/// - No course/level/deck/catalog/ranked-list surfaces
/// - No gamification chrome (XP, streaks, badges, leaderboards,
///   daily goals, "continue" buttons — tap-anywhere cadence is the
///   legitimate control)
/// - No surfaced internals: difficulty scores, i+1 ranks, intervals,
///   ease factors, word-status colors
/// - No behavioral-tracking signals anywhere in learner code paths
///
/// Together with `test/compliance_audit_test.dart` this guarantees the
/// anti-feature gates from `docs/adr/DECISIONS.md` (LingQ/Migaku/Du
/// rejected affordances) never reappear in learner-facing code.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Patterns that would indicate a removed anti-feature has crept back in.
/// Each entry maps to the QUALITY invariant it violates.
const Map<String, String> _forbiddenAffordances = {
  // P-03 — zero unnecessary decisions
  'XP': 'P-03: gamification (XP) violates zero-unnecessary-decisions',
  'Streak': 'P-03: gamification (streaks) violates zero-unnecessary-decisions',
  'badge': 'P-03: gamification (badges) violates zero-unnecessary-decisions',
  'Leaderboard':
      'P-03: gamification (leaderboard) violates zero-unnecessary-decisions',
  'dailyGoal':
      'P-03: gamification (daily goals) violates zero-unnecessary-decisions',
  // P-02 — system chooses ONE
  'CourseCatalog': 'P-02: course catalog violates the ONE-experience rule',
  'LevelSelect': 'P-02: level selection violates the ONE-experience rule',
  'DeckPicker': 'P-02: deck picker violates the ONE-experience rule',
  'RankedList': 'P-02: ranked list violates the ONE-experience rule',
  // P-07 — internals stay internal
  'i1Score': 'P-07: i+1 score must not surface in the learner UI',
  'difficultyScore':
      'P-07: difficulty score must not surface in the learner UI',
  'intervalDays': 'P-07: SRS interval must not surface in the learner UI',
  'easeFactor': 'P-07: SRS ease factor must not surface in the learner UI',
  'wordStatusColor':
      'P-07: word-status color must not surface in the learner UI',
  // Behavioral tracking (AGENTS §6 / D-03)
  'hesitationTime': 'D-03: hesitation timing is a behavioral signal',
  'dwellTime': 'D-03: dwell time is a behavioral signal',
  'scrollDepth': 'D-03: scroll depth is a behavioral signal',
  'engagementScore': 'D-03: engagement score is a behavioral signal',
};

void main() {
  group('Release audit — anti-feature surface scan', () {
    final libDir = Directory('lib');
    if (!libDir.existsSync()) return;

    final libFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
        .toList();

    /// Strip Dart comments so documentation mentioning a forbidden affordance
    /// (e.g. "we don't show XP here") doesn't trip the scanner.
    String stripDartComments(String src) {
      final out = StringBuffer();
      var i = 0;
      while (i < src.length) {
        if (i + 1 < src.length && src[i] == '/' && src[i + 1] == '*') {
          final end = src.indexOf('*/', i + 2);
          if (end == -1) break;
          i = end + 2;
          continue;
        }
        if (i + 1 < src.length && src[i] == '/' && src[i + 1] == '/') {
          final eol = src.indexOf('\n', i + 2);
          i = eol == -1 ? src.length : eol;
          continue;
        }
        if (src[i] == "'" || src[i] == '"') {
          final quote = src[i];
          out.write(quote);
          i++;
          while (i < src.length) {
            if (src[i] == r'\') {
              out.write(src[i]);
              i++;
              if (i < src.length) {
                out.write(src[i]);
                i++;
              }
              continue;
            }
            out.write(src[i]);
            if (src[i] == quote) {
              i++;
              break;
            }
            i++;
          }
          continue;
        }
        out.write(src[i]);
        i++;
      }
      return out.toString();
    }

    /// A word-boundary regex that matches identifiers, comments, or string
    /// literals (handles `XP`, `'XP'`, `// XP`, `XP()`, etc.).
    RegExp affordancePattern(String word) =>
        RegExp("(^|[^a-zA-Z0-9_])$word([^a-zA-Z0-9_]|\\\$)");

    test('lib/ has no anti-feature identifiers or strings', () {
      for (final f in libFiles) {
        final stripped = stripDartComments(f.readAsStringSync());
        final offenders = <String>[];
        for (final entry in _forbiddenAffordances.entries) {
          if (affordancePattern(entry.key).hasMatch(stripped)) {
            offenders.add(entry.key);
          }
        }
        expect(
          offenders,
          isEmpty,
          reason:
              'P-02/P-03/P-07 violation in ${f.path}: '
              'forbidden affordances found: ${offenders.join(', ')}. '
              'See docs/adr/DECISIONS.md rejected affordances.',
        );
      }
    });

    test('lib/ has no common translation/dictionary anti-patterns', () {
      // Additional P-01 guards: things that historically crept into
      // translation-first competitors.
      final libSrc = libFiles.map((f) => f.readAsStringSync()).join('\n');
      final patterns = {
        'translateToEnglish': 'P-01: must not translate to English',
        'glossEn': 'P-01: English gloss must not exist',
        'englishMeaning': 'P-01: englishMeaning must not exist',
      };
      for (final entry in patterns.entries) {
        expect(
          RegExp(entry.key).hasMatch(libSrc),
          isFalse,
          reason: '${entry.value}',
        );
      }
    });

    test('app/ does not wire behavioral telemetry sinks', () {
      final appFiles = libFiles
          .where((f) => f.path.startsWith('lib/app/'))
          .toList();
      final behavioralImports = [
        'firebase_analytics',
        'firebase_crashlytics',
        'sentry_flutter',
        'mixpanel_flutter',
        'amplitude_flutter',
        'posthog_flutter',
      ];
      for (final f in appFiles) {
        final src = f.readAsStringSync();
        for (final pkg in behavioralImports) {
          expect(
            RegExp("package:$pkg").hasMatch(src),
            isFalse,
            reason:
                'D-03 violation in ${f.path}: behavioral analytics '
                'package "$pkg" imported. Learner state derives only from '
                'explicit learning events.',
          );
        }
      }
    });
  });
}
