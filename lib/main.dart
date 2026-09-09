/// 渐入 application entry point.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        fontFamilyFallback: const [
          'PingFang SC',
          'Hiragino Sans GB',
          'Microsoft YaHei',
          'WenQuanYi Micro Hei',
          'Noto Sans SC',
          'Noto Sans CJK SC',
          'sans-serif',
        ],
      ),
      home: const HomeScreen(),
    );
  }
}
