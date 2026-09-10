/// 渐入 application entry point.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/l10n.dart';
import 'reader/home.dart';

void main() {
  runApp(const ProviderScope(child: JianruApp()));
}

/// Root widget. Deliberately empty of learning logic (ARCHITECTURE.md §2):
/// the home screen will consume the selector's single output once it exists.
class JianruApp extends StatelessWidget {
  const JianruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '渐入',
      // Monolingual: all material chrome (copy toolbar 复制, selection
      // menus, a11y labels) resolves to Chinese on every platform.
      supportedLocales: kSupportedLocales,
      locale: const Locale('zh'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: resolveMonolingualLocale,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'NotoSansSC',
        fontFamilyFallback: const [
          'PingFang SC',
          'Hiragino Sans GB',
          'Microsoft YaHei',
          'WenQuanYi Micro Hei',
          'Noto Sans CJK SC',
          'sans-serif',
        ],
      ),
      // App-wide text selection: long-press/drag selects any learner-facing
      // text for copy (a legitimate control, QUALITY.md P-03 (legitimate controls)) without
      // disturbing the tap-anywhere reading cadence — taps keep winning the
      // gesture arena, selection only claims long-press and drag.
      // Wrapped around the home screen (inside the Navigator/Overlay) so
      // the selection region can present its toolbar.
      // App-wide text selection: long-press/drag selects any learner-facing
      // text for copy (a legitimate control, QUALITY.md P-03 (legitimate controls)) without
      // disturbing the tap-anywhere reading cadence — taps keep winning the
      // gesture arena, selection only claims long-press and drag.
      // Wrapped around the home screen (inside the Navigator/Overlay) so
      // the selection region can present its toolbar.
      home: const SelectionArea(child: HomeScreen()),
    );
  }
}
