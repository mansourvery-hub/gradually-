/// Zen monolingual contextual lookup sheet (T_UI_040, QUALITY.md P-01 (monolingual)).
///
/// Widgets only. Shows a Chinese-only dictionary entry: surface form,
/// Chinese definition, Chinese examples. Contains no translation logic
/// and no learner-facing internals.
library;

import 'package:flutter/material.dart';

import '../../dictionary/lookup.dart';

/// Presents a [LookupResult] in the calm paper aesthetic.
///
/// Absent results render a serene empty state — lookup never strands the
/// learner (E-08) and never interrupts reading position.
class ContextLookupSheet extends StatelessWidget {
  const ContextLookupSheet({super.key, required this.result});

  final LookupResult result;

  /// Shows the sheet over the current reader without disturbing position.
  static Future<void> show(BuildContext context, LookupResult result) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFBF9F5),
      barrierColor: Colors.black.withValues(alpha: 0.25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (_) => ContextLookupSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!result.isFound || result.entry == null) {
      return const _SheetBody(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_rounded,
              size: 40,
              color: Color(0xFF9E9689),
            ),
            SizedBox(height: 20),
            Text(
              '……',
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF6B6B6B),
                letterSpacing: 6,
              ),
            ),
          ],
        ),
      );
    }

    final entry = result.entry!;
    return _SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The word, large and centered
          Text(
            entry.surface,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1E1E1E),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 28),

          // Chinese-only definition
          Text(
            entry.definition,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              height: 1.7,
              color: Color(0xFF3A3A3A),
              letterSpacing: 1.5,
            ),
          ),

          // Example sentences from actual content, when curated
          if (entry.examples.isNotEmpty) ...[
            const SizedBox(height: 24),
            for (final example in entry.examples)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  example,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.6,
                    color: Color(0xFF6B6B6B),
                    letterSpacing: 1,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 36),
        child: child,
      ),
    );
  }
}
