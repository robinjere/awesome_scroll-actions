import 'package:awesome_scroll_actions/awesome_scroll_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> selected;

  Future<void> pumpDial(
    WidgetTester tester, {
    QuickActionsController? controller,
    bool startTucked = false,
  }) async {
    selected = [];
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AwesomeScrollActions(
            actions: AwesomeScrollDefaults.actions,
            initialActionId: AwesomeScrollDefaults.initialActionId,
            controller: controller,
            startTucked: startTucked,
            enableHaptics: false,
            onActionSelected: (action, _) => selected.add(action.id),
          ),
        ),
      ),
    );
  }

  // The toast hides itself on a timer; let it expire before the test ends.
  Future<void> drainToast(WidgetTester tester) => tester.pump(const Duration(seconds: 2));

  testWidgets('starts on the initial action with its stat card', (tester) async {
    await pumpDial(tester);
    expect(find.text('Last scan'), findsOneWidget);
    expect(find.text('TZS 8,500'), findsOneWidget);
    expect(find.text('Kariakoo Market'), findsOneWidget);
  });

  testWidgets('tapping a neighbour snaps to it and shows the toast', (tester) async {
    await pumpDial(tester);
    await tester.tap(find.byIcon(AwesomeScrollIcons.moneyChange));
    await tester.pumpAndSettle();
    expect(selected, ['withdraw']);
    expect(find.text('Withdraw opened'), findsOneWidget);
    expect(find.text('Withdrawn in June'), findsOneWidget);
    await drainToast(tester);
  });

  testWidgets('dragging up one step advances the dial', (tester) async {
    await pumpDial(tester);
    await tester.timedDrag(
      find.byType(AwesomeScrollActions),
      const Offset(0, -130),
      const Duration(milliseconds: 800),
    );
    await tester.pumpAndSettle();
    expect(selected, ['withdraw']);
    await drainToast(tester);
  });

  testWidgets('horizontal pull tucks the dial', (tester) async {
    final controller = QuickActionsController();
    await pumpDial(tester, controller: controller);
    expect(controller.isOpen, isTrue);
    await tester.timedDrag(
      find.byType(AwesomeScrollActions),
      const Offset(200, 0),
      const Duration(milliseconds: 500),
    );
    await tester.pumpAndSettle();
    expect(controller.isOpen, isFalse);
  });

  testWidgets('controller opens a tucked dial and selects by id', (tester) async {
    final controller = QuickActionsController();
    await pumpDial(tester, controller: controller, startTucked: true);
    expect(controller.isOpen, isFalse);

    expect(controller.selectById('cards'), isTrue);
    await tester.pumpAndSettle();
    expect(controller.isOpen, isTrue);
    expect(controller.selectedAction?.id, 'cards');
    expect(selected, ['cards']);
    expect(controller.selectById('nope'), isFalse);
    await drainToast(tester);
  });
}
