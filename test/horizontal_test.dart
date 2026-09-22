import 'package:awesome_scroll_actions/awesome_scroll_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// The horizontal axis mirrors the vertical one onto the bottom edge.
/// Each test pins the behaviour that has to swap, so a change to one axis
/// cannot silently break the other.
void main() {
  const horizontal = QuickActionsArc(axis: Axis.horizontal);
  const vertical = QuickActionsArc();
  const size = Size(390, 844);

  late List<String> selected;

  const portraitView = Size(1170, 2532);
  const landscapeView = Size(2532, 1170);

  Future<void> pumpDial(
    WidgetTester tester, {
    QuickActionsArc arc = horizontal,
    bool startTucked = false,
    Size view = portraitView,
  }) async {
    selected = [];
    tester.view.physicalSize = view;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AwesomeScrollActions(
            actions: AwesomeScrollDefaults.actions,
            initialActionId: AwesomeScrollDefaults.initialActionId,
            arc: arc,
            startTucked: startTucked,
            enableHaptics: false,
            onActionSelected: (action, _) => selected.add(action.id),
          ),
        ),
      ),
    );
  }

  Future<void> drainToast(WidgetTester tester) => tester.pump(const Duration(seconds: 2));

  group('geometry', () {
    test('vertical is still the default', () {
      expect(const QuickActionsArc().axis, Axis.vertical);
      expect(const QuickActionsArc().isHorizontal, isFalse);
    });

    test('the selected item sits on the bottom edge, not the right', () {
      final h = horizontal.place(index: 0, position: 0, openness: 1, size: size);
      expect(h.center.dy, closeTo(size.height - horizontal.bottomInset, 0.01));
      expect(h.center.dx, closeTo(size.width * horizontal.centerXFactor, 0.01));

      final v = vertical.place(index: 0, position: 0, openness: 1, size: size);
      expect(v.center.dx, closeTo(size.width - vertical.rightInset, 0.01));
    });

    test('neighbours spread sideways and rise, mirroring the vertical arc', () {
      final centre = horizontal.place(index: 0, position: 0, openness: 1, size: size);
      final next = horizontal.place(index: 1, position: 0, openness: 1, size: size);
      final prev = horizontal.place(index: -1, position: 0, openness: 1, size: size);

      expect(next.center.dx, greaterThan(centre.center.dx)); // later items to the right
      expect(prev.center.dx, lessThan(centre.center.dx));
      expect(next.center.dy, lessThan(centre.center.dy)); // and curving upward
    });

    test('tucking slides items down, not right', () {
      final open = horizontal.place(index: 0, position: 0, openness: 1, size: size);
      final shut = horizontal.place(index: 0, position: 0, openness: 0, size: size);
      expect(shut.center.dy - open.center.dy, closeTo(horizontal.tuckOffset, 0.01));
      expect(shut.center.dx, closeTo(open.center.dx, 0.01));
      expect(shut.opacity, 0);
    });

    test('falloff is shared by both axes at the same angular step', () {
      // Pin the radius so both axes resolve the same step; the falloff
      // curve itself is axis-agnostic.
      const h = QuickActionsArc(axis: Axis.horizontal, adaptRadius: false);
      const v = QuickActionsArc(adaptRadius: false);
      final hp = h.place(index: 1, position: 0, openness: 1, size: size);
      final vp = v.place(index: 1, position: 0, openness: 1, size: size);
      expect(hp.opacity, closeTo(vp.opacity, 0.0001));
      expect(hp.scale, closeTo(vp.scale, 0.0001));
    });

    test('items keep minItemGap apart when a short screen shrinks the radius', () {
      double gapOf(QuickActionsArc arc, Size screen) {
        final a = arc.place(index: 0, position: 0, openness: 1, size: screen);
        final b = arc.place(index: 1, position: 0, openness: 1, size: screen);
        return (b.center - a.center).distance;
      }

      // At the reference extent the design's own spacing is far wider than
      // the floor, so nothing is nudged.
      expect(vertical.resolveAngleStep(size), closeTo(vertical.angleStep, 1e-9));
      expect(gapOf(vertical, size), greaterThan(120));

      // Rotated, the radius shrinks and the raw step would overlap the
      // 52pt slots. The step widens instead, so they stay clear.
      const landscape = Size(844, 390);
      expect(vertical.resolveAngleStep(landscape), greaterThan(vertical.angleStep));
      expect(
        gapOf(vertical, landscape),
        greaterThan(vertical.itemSlot),
        reason: 'items must not overlap in landscape',
      );
      // The floor is solved on the projection, so the chord between two
      // centres comes out a hair wider. It must never come out narrower.
      final floor = vertical.itemSlot + vertical.minItemGap;
      expect(gapOf(vertical, landscape), greaterThanOrEqualTo(floor));
      expect(gapOf(vertical, landscape), lessThan(floor + 4));
    });
  });

  group('gestures', () {
    testWidgets('a horizontal drag spins the dial', (tester) async {
      await pumpDial(tester);
      // Dragging left advances, the way dragging up does when vertical.
      await tester.drag(find.byType(AwesomeScrollActions), const Offset(-130, 0));
      await tester.pumpAndSettle();
      expect(selected, ['withdraw']); // index 4 -> 5 in AwesomeScrollDefaults
      await drainToast(tester);
    });

    testWidgets('a vertical drag tucks instead of spinning', (tester) async {
      await pumpDial(tester);
      await tester.drag(find.byType(AwesomeScrollActions), const Offset(0, 120));
      await tester.pumpAndSettle();

      // Tucked: nothing was selected, and the items fell under
      // visibilityCutoff so they are culled rather than merely faded.
      expect(selected, isEmpty);
      expect(find.byKey(const ValueKey('qa-scan_pay')), findsNothing);
    });

    testWidgets('the same drag on a vertical dial does the opposite', (tester) async {
      await pumpDial(tester, arc: vertical);
      await tester.drag(find.byType(AwesomeScrollActions), const Offset(-130, 0));
      await tester.pumpAndSettle();
      expect(selected, isEmpty); // horizontal drag pulls, it does not spin
    });
  });

  group('rotation', () {
    test('the radius is exact at the reference extent', () {
      expect(vertical.resolveRadius(const Size(390, 844)), closeTo(560, 0.001));
      expect(QuickActionsArc.horizontal.resolveRadius(const Size(390, 844)), closeTo(340, 0.001));
    });

    test('the radius follows the extent along the axis', () {
      const landscape = Size(844, 390);
      // A vertical dial has less height to ride, so it tightens.
      expect(vertical.resolveRadius(landscape), closeTo(560 * 390 / 844, 0.01));
      // A horizontal one gains width, so it opens out.
      expect(
        QuickActionsArc.horizontal.resolveRadius(landscape),
        closeTo(340 * 844 / 390, 0.01),
      );
    });

    test('adaptRadius: false pins the radius in logical pixels', () {
      const pinned = QuickActionsArc(adaptRadius: false);
      expect(pinned.resolveRadius(const Size(844, 390)), 560);
    });

    for (final (name, view) in [
      ('portrait', portraitView),
      ('landscape', landscapeView),
    ]) {
      for (final (axisName, arc) in [
        ('vertical', vertical),
        ('horizontal', QuickActionsArc.horizontal),
      ]) {
        testWidgets('$axisName keeps its items on screen in $name', (tester) async {
          await pumpDial(tester, arc: arc, view: view);
          final screen = tester.getRect(find.byType(AwesomeScrollActions));

          var onScreen = 0;
          for (final action in AwesomeScrollDefaults.actions) {
            final f = find.byKey(ValueKey('qa-${action.id}'));
            if (f.evaluate().isEmpty) continue;
            final slot = tester.getRect(f);
            if (screen.overlaps(slot)) onScreen++;
          }
          // The selected item plus at least one neighbour each side stay
          // reachable however the phone is held.
          expect(onScreen, greaterThanOrEqualTo(3), reason: '$axisName/$name');
        });
      }
    }
  });

  group('compact pill', () {
    test('only a short screen, and only the vertical axis, is compact', () {
      expect(vertical.isCompact(const Size(390, 844)), isFalse); // portrait
      expect(vertical.isCompact(const Size(844, 390)), isTrue); // landscape
      // A horizontal dial always captions under its icon, never "compact".
      expect(QuickActionsArc.horizontal.isCompact(const Size(844, 390)), isFalse);
      // Opt out entirely.
      expect(
        const QuickActionsArc(compactExtent: 0).isCompact(const Size(844, 390)),
        isFalse,
      );
    });

    testWidgets('portrait keeps the wide pill with the label inside', (tester) async {
      await pumpDial(tester, arc: vertical, view: portraitView);
      final label = tester.getRect(find.text('Scan & Pay'));
      final slot = tester.getRect(find.byKey(const ValueKey('qa-scan_pay')));

      // The label sits inside the pill, so the slot is wider than the icon.
      expect(slot.width, greaterThan(vertical.itemSlot));
      expect(slot.left, lessThanOrEqualTo(label.left + 1));
      expect(slot.right, greaterThanOrEqualTo(label.right - 1));
    });

    testWidgets('landscape prints the title beside an icon circle', (tester) async {
      await pumpDial(tester, arc: vertical, view: landscapeView);
      final label = tester.getRect(find.text('Scan & Pay'));
      final slot = tester.getRect(find.byKey(const ValueKey('qa-scan_pay')));

      // The pill is back to a plain circle, and the title is outside it.
      expect(slot.width, closeTo(vertical.itemSlot, 0.01));
      expect(label.right, lessThanOrEqualTo(slot.left + 1));
      expect(label.center.dy, closeTo(slot.center.dy, 2));

      // Regression: the label's box was stretched to the slot's height by
      // the tight constraint handed down to it, so the centres matched
      // while the glyphs sat at the top of an oversized box.
      expect(
        label.height,
        lessThan(vertical.itemSlot * 0.6),
        reason: 'label box should wrap its text, not fill the slot',
      );
      final icon = tester.getRect(find.byIcon(AwesomeScrollIcons.scan).first);
      expect(label.center.dy, closeTo(icon.center.dy, 1));
    });
  });

  group('chrome', () {
    for (final (name, view) in [
      ('portrait', portraitView),
      ('landscape', landscapeView),
    ]) {
      testWidgets('the stat card clears the dial in $name', (tester) async {
        await pumpDial(tester, arc: QuickActionsArc.horizontal, view: view);

        // The whole card, not just its figure: the label above it is the
        // real top edge, and measuring the figure hid a header collision.
        final card = tester
            .getRect(find.text('Last scan'))
            .expandToInclude(tester.getRect(find.text('TZS 8,500')))
            .expandToInclude(tester.getRect(find.text('Kariakoo Market')));
        for (final action in AwesomeScrollDefaults.actions) {
          final f = find.byKey(ValueKey('qa-${action.id}'));
          if (f.evaluate().isEmpty) continue;
          expect(
            tester.getRect(f).overlaps(card),
            isFalse,
            reason: '${action.id} overlaps the stat card in $name',
          );
        }
        // And it is still on screen, clear of the header, not shoved off
        // the top by items riding high up the circle off screen.
        expect(card.top, greaterThanOrEqualTo(0));
        final header = tester.getRect(find.text('Quick actions'));
        expect(card.overlaps(header), isFalse, reason: 'card overlaps header in $name');
        expect(card.top, greaterThan(header.bottom));
        // Present at a usable size, not scaled away to nothing.
        expect(card.height, greaterThan(40), reason: 'card collapsed in $name');
      });
    }
  });

  group('layout', () {
    testWidgets('the pill is an icon circle captioned underneath', (tester) async {
      await pumpDial(tester);
      final caption = tester.getRect(find.text('Scan & Pay'));
      final icon = tester.getRect(find.byIcon(AwesomeScrollIcons.scan).first);

      // The caption sits below the icon, and outside the pill entirely.
      expect(caption.top, greaterThan(icon.bottom));
      expect(caption.center.dx, closeTo(icon.center.dx, 1));
      expect(
        caption.height,
        lessThan(horizontal.itemSlot * 0.6),
        reason: 'caption box should wrap its text, not fill the slot',
      );

      // The pill stayed a square icon slot, so the row keeps its rhythm.
      final slot = tester.getRect(find.byKey(const ValueKey('qa-scan_pay')));
      expect(slot.width, closeTo(horizontal.itemSlot, 0.01));
      expect(caption.top, greaterThan(slot.bottom - 1));
    });

    testWidgets('the caption does not shift the icon off its arc point', (tester) async {
      await pumpDial(tester);
      const screen = Size(390, 844);
      // The selected item carries a caption, its neighbours do not; both
      // must still sit where the arc puts them.
      for (final (index, id) in [(4, 'scan_pay'), (5, 'withdraw')]) {
        final placed = horizontal.place(
          index: index,
          position: 4,
          openness: 1,
          size: screen,
        );
        final slot = tester.getRect(find.byKey(ValueKey('qa-$id')));
        expect(slot.center.dy, closeTo(placed.center.dy, 0.5), reason: id);
      }
    });

    testWidgets('a vertical dial keeps the label beside the icon', (tester) async {
      await pumpDial(tester, arc: vertical);
      final label = tester.getRect(find.text('Scan & Pay'));
      final icon = tester.getRect(find.byIcon(AwesomeScrollIcons.scan).first);
      expect(label.center.dx, lessThan(icon.center.dx));
      expect(label.center.dy, closeTo(icon.center.dy, 2));
    });

    testWidgets('a resting pill is a square slot, not its hidden label', (tester) async {
      // Regression: the stacked label collapsed its height but kept its
      // width, so every resting pill was as wide as its invisible text.
      await pumpDial(tester);
      for (final id in ['buy_airtime', 'withdraw']) {
        final slot = tester.getRect(find.byKey(ValueKey('qa-$id')));
        expect(slot.width, closeTo(horizontal.itemSlot, 0.01), reason: '$id slot width');
        expect(slot.height, closeTo(horizontal.itemSlot, 0.01), reason: '$id slot height');
      }
    });

    testWidgets('the selected label is shown in full, not ellipsised', (tester) async {
      // Regression: the slot clamped the pill's width, so the label
      // rendered as "Scan ...".
      await pumpDial(tester);
      final label = tester.getRect(find.text('Scan & Pay'));
      final slot = tester.getRect(find.byKey(const ValueKey('qa-scan_pay')));
      expect(label.width, greaterThan(slot.width));

      final painted = tester.renderObject<RenderParagraph>(find.text('Scan & Pay'));
      expect(painted.didExceedMaxLines, isFalse);
      expect(label.width, lessThanOrEqualTo(horizontal.labelMaxWidth));
    });

    testWidgets('a resting pill centres on its arc point', (tester) async {
      await pumpDial(tester);
      const size = Size(390, 844);
      final placed = horizontal.place(index: 5, position: 4, openness: 1, size: size);
      final slot = tester.getRect(find.byKey(const ValueKey('qa-withdraw')));
      expect(slot.center.dx, closeTo(placed.center.dx, 0.5));
    });

    testWidgets('the pull handle parks on the bottom edge', (tester) async {
      await pumpDial(tester, startTucked: true);
      final handle = tester.getRect(find.bySemanticsLabel('Show quick actions'));
      final screen = tester.getRect(find.byType(AwesomeScrollActions));

      // Wider than tall, and sitting at the bottom rather than the right.
      expect(handle.width, greaterThan(handle.height));
      expect(screen.bottom - handle.bottom, lessThan(4));
      expect(handle.center.dx, closeTo(screen.center.dx, 2));
    });

    testWidgets('the toast lifts clear of the dial band', (tester) async {
      await pumpDial(tester);
      await tester.tap(find.byKey(const ValueKey('qa-withdraw')));
      await tester.pumpAndSettle();

      final toast = tester.getRect(find.text('Withdraw opened'));
      final pill = tester.getRect(find.byKey(const ValueKey('qa-withdraw')));
      expect(toast.bottom, lessThan(pill.top));
      await drainToast(tester);
    });
  });
}
