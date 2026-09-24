import 'package:awesome_scroll_actions/awesome_scroll_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int pageTaps;
  late List<String> selected;
  late List<String> tapped;

  Future<QuickActionsController> pumpOverlay(WidgetTester tester, {bool startTucked = false}) async {
    pageTaps = 0;
    selected = [];
    tapped = [];
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final controller = QuickActionsController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => pageTaps++,
              ),
            ),
            AwesomeScrollActions(
              actions: AwesomeScrollDefaults.actions,
              initialActionId: AwesomeScrollDefaults.initialActionId,
              controller: controller,
              startTucked: startTucked,
              showBackground: false,
              showToast: false,
              enableHaptics: false,
              onActionSelected: (a, _) => selected.add(a.id),
              onActionTapped: (a, _) => tapped.add(a.id),
            ),
          ]),
        ),
      ),
    );
    return controller;
  }

  testWidgets('a tucked overlay lets taps through to the page', (tester) async {
    final controller = await pumpOverlay(tester, startTucked: true);
    await tester.tapAt(const Offset(60, 400));
    expect(pageTaps, 1);
    expect(controller.isOpen, isFalse);

    await tester.tap(find.bySemanticsLabel('Show quick actions'));
    await tester.pumpAndSettle();
    expect(controller.isOpen, isTrue);
  });

  testWidgets('tapping outside an open overlay tucks it', (tester) async {
    final controller = await pumpOverlay(tester);
    await tester.tapAt(const Offset(60, 400));
    await tester.pumpAndSettle();
    expect(controller.isOpen, isFalse);
    expect(pageTaps, 0);
  });

  testWidgets('spinning highlights, tapping a pill fires onActionTapped', (tester) async {
    await pumpOverlay(tester);
    await tester.timedDrag(
      find.byType(AwesomeScrollActions),
      const Offset(0, -130),
      const Duration(milliseconds: 800),
    );
    await tester.pumpAndSettle();
    expect(selected, ['withdraw']);
    expect(tapped, isEmpty);

    await tester.tap(find.byKey(const ValueKey('qa-withdraw')));
    await tester.pumpAndSettle();
    expect(tapped, ['withdraw']);
  });
}
