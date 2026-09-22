import 'package:awesome_scroll_actions/awesome_scroll_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const AwesomeScrollDemoApp());

class AwesomeScrollDemoApp extends StatelessWidget {
  const AwesomeScrollDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awesome Scroll Actions',
      debugShowCheckedModeBanner: false,
      // The dial picks its palette off whichever ThemeData is in force, so
      // registering both makes it follow the system light/dark switch.
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1A2A3A),
        extensions: const [AwesomeScrollActionsTheme()],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF1A2A3A),
        extensions: const [AwesomeScrollActionsTheme.dark],
      ),
      themeMode: ThemeMode.system,
      home: const AwesomeScrollActionsScreen(),
    );
  }
}

class AwesomeScrollActionsScreen extends StatefulWidget {
  const AwesomeScrollActionsScreen({super.key});

  @override
  State<AwesomeScrollActionsScreen> createState() => _AwesomeScrollActionsScreenState();
}

class _AwesomeScrollActionsScreenState extends State<AwesomeScrollActionsScreen> {
  final _controller = QuickActionsController();
  bool _showGuide = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(QuickAction action, int index) {
    // Route to the real flow here, e.g. Navigator.pushNamed(context, '/${action.id}').
    debugPrint('Quick action: ${action.id}');
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        // The dial laid over the app's own page: `showBackground: false`
        // drops its gradient and the scrim dims the page behind it as the
        // dial is pulled out. Tap the edge handle or drag sideways.
        body: Stack(
          children: [
            const _AccountPage(),
            GestureDetector(
              // Long-press anywhere to toggle the arc guide while tuning.
              onLongPress: () => setState(() => _showGuide = !_showGuide),
              child: AwesomeScrollActions(
                actions: AwesomeScrollDefaults.actions,
                initialActionId: AwesomeScrollDefaults.initialActionId,
                controller: _controller,
                showGuideLine: _showGuide,
                showBackground: false,
                startTucked: true,
                // arc: QuickActionsArc.horizontal,
                onActionSelected: _open,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stand-in for the host app's page, so the scrim has something to dim. Its
/// list starts below the dial's own header and stat card rather than
/// printing a second balance under them.
class _AccountPage extends StatelessWidget {
  const _AccountPage();

  static const _rows = [
    ('Salary – CBT Bank', '+ 2,400,000', 'Today'),
    ('Luku token', '- 30,000', 'Today'),
    ('Ramadhani M.', '- 145,000', 'Yesterday'),
    ('Azam TV', '- 32,000', 'Yesterday'),
    ('Fatuma S.', '+ 80,000', 'Mon'),
    ('Vodacom bundle', '- 10,000', 'Mon'),
    ('Water bill', '- 18,500', 'Sun'),
  ];

  @override
  Widget build(BuildContext context) {
    final qa = Theme.of(context).extension<AwesomeScrollActionsTheme>()!;
    return ColoredBox(
      color: qa.backgroundTop,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(26, 300, 26, 24),
          children: [
            Text('Recent',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: qa.titleColor)),
            for (final (name, amount, day) in _rows)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(name, style: TextStyle(fontSize: 15, color: qa.titleColor)),
                subtitle: Text(day, style: TextStyle(color: qa.mutedColor)),
                trailing: Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: amount.startsWith('+')
                        ? (qa.backgroundTop.computeLuminance() > 0.5
                            ? const Color(0xFF1B7F4B)
                            : const Color(0xFF4ECB8B))
                        : qa.titleColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
