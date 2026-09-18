/// App-side l10n configuration (learner-facing chrome language).
///
/// The app is inherently monolingual: the selection/copy toolbar (复制)
/// and every other material chrome string must render in Chinese
/// everywhere — no English strings in the learner experience
/// (QUALITY.md P-01 (monolingual) includes UI chrome; §3.3: no locale decisions).
library;

import 'package:flutter/material.dart';

/// Only Chinese is supported. Locale resolution always yields zh so the
/// copy/paste toolbar shows 复制, never "Copy".
const List<Locale> kSupportedLocales = [Locale('zh')];

/// Forces zh regardless of device locale — the reader never faces a
/// language decision (QUALITY.md P-03 (legitimate controls)).
Locale resolveMonolingualLocale(
  Locale? deviceLocale,
  Iterable<Locale> supported,
) {
  return const Locale('zh');
}
