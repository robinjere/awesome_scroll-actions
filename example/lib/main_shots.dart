// Screenshot harness: renders one dial configuration per `?shot=` value so
// the README images can be regenerated deterministically. Not part of the
// demo — see main.dart for that.
//
//   flutter build web -t lib/main_shots.dart
//   <serve it>/?shot=guide
import 'package:awesome_scroll_actions/awesome_scroll_actions.dart';
import 'package:flutter/material.dart';

void main() => runApp(ShotApp(Uri.base.queryParameters['shot'] ?? 'open'));

class ShotApp extends StatelessWidget {
  const ShotApp(this.shot, {super.key});

  final String shot;

  @override
  Widget build(BuildContext context) {
    final dark = shot == 'dark';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: dark ? Brightness.dark : Brightness.light,
        colorSchemeSeed: const Color(0xFF1A2A3A),
        extensions: [
          dark ? AwesomeScrollActionsTheme.dark : const AwesomeScrollActionsTheme(),
        ],
      ),
      home: Scaffold(
        body: AwesomeScrollActions(
          actions: AwesomeScrollDefaults.actions,
          initialActionId: AwesomeScrollDefaults.initialActionId,
          showGuideLine: shot == 'guide',
          arc: shot == 'horizontal'
              ? QuickActionsArc.horizontal
              : const QuickActionsArc(),
          // Toast fires on selection, not on first build, so shots are clean.
          onActionSelected: (_, _) {},
        ),
      ),
    );
  }
}
