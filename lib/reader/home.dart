/// Reader UI: widgets only (ARCHITECTURE.md §2).
///
/// Learning logic lives in domain services, never here. This placeholder
/// renders until the selector-driven experience exists (build-order step 4).
library;

import 'package:flutter/material.dart';

/// Home screen: consumes the selector's single output. Deliberately empty
/// of decisions, menus, and dashboards (AGENTS.md §3, §4).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('渐入')));
  }
}
