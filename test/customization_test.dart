import 'package:awesome_scroll_actions/awesome_scroll_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every knob added for full customization, checked against the value it
/// replaced. A default-constructed config must still paint the design, so
/// each test pins both the default and the override.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    QuickActionsArc arc = const QuickActionsArc(),
    QuickActionsMotion motion = const QuickActionsMotion(),
    AwesomeScrollActionsTheme theme = const AwesomeScrollActionsTheme(),
    QuickActionPillBuilder? pillBuilder,
    QuickActionStatBuilder? statBuilder,
    QuickActionsHeaderBuilder? headerBuilder,
    QuickActionsToastBuilder? toastBuilder,
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AwesomeScrollActions(
            actions: AwesomeScrollDefaults.actions,
            initialActionId: AwesomeScrollDefaults.initialActionId,
            enableHaptics: false,
            arc: arc,
            motion: motion,
            theme: theme,
            pillBuilder: pillBuilder,
            statBuilder: statBuilder,
            headerBuilder: headerBuilder,
            toastBuilder: toastBuilder,
          ),
        ),
      ),
    );
  }

  Future<void> drainToast(WidgetTester tester) => tester.pump(const Duration(seconds: 2));

  group('arc', () {
    test('falloff constants are the design values by default', () {
      const arc = QuickActionsArc();
      expect(arc.opacityFalloff, 1.15);
      expect(arc.scaleFalloff, 0.22);
      expect(arc.minScale, 0.78);
      expect(arc.itemSlot, 52);
      expect(arc.iconBoxSize, 44);
      expect(arc.iconSize, 21);
    });

    test('overriding falloff changes placement', () {
      const size = Size(390, 844);
      ArcPlacement neighbour(QuickActionsArc arc) =>
          arc.place(index: 1, position: 0, openness: 1, size: size);

      final loose = neighbour(const QuickActionsArc(opacityFalloff: 0.4));
      final tight = neighbour(const QuickActionsArc(opacityFalloff: 3));
      expect(loose.opacity, greaterThan(tight.opacity));

      // The floor still clamps however hard the falloff is driven.
      final steep = neighbour(const QuickActionsArc(scaleFalloff: 99, minScale: 0.5));
      expect(steep.scale, 0.5);
    });

    test('copyWith keeps untouched fields', () {
      final arc = const QuickActionsArc().copyWith(iconSize: 30);
      expect(arc.iconSize, 30);
      expect(arc.radius, 560);
      expect(arc.minScale, 0.78);
    });

    testWidgets('item slot drives the laid-out pill height', (tester) async {
      await pump(tester, arc: const QuickActionsArc(itemSlot: 80, iconBoxSize: 70));
      final box = tester.getSize(
        find.byKey(const ValueKey('qa-scan_pay')).first,
      );
      expect(box.height, 80);
    });
  });

  group('motion', () {
    test('defaults are the shipped timings', () {
      const m = QuickActionsMotion();
      expect(m.snap, const Duration(milliseconds: 340));
      expect(m.toastDwell, const Duration(milliseconds: 1400));
      expect(m.popScale, 1.1);
    });

    test('scaled multiplies durations and leaves curves alone', () {
      final slow = const QuickActionsMotion().scaled(2);
      expect(slow.snap, const Duration(milliseconds: 680));
      expect(slow.toastDwell, const Duration(milliseconds: 2800));
      expect(slow.snapCurve, Curves.easeOutCubic);
    });

    testWidgets('toastDwell controls how long the toast stays', (tester) async {
      // The toast is faded, never unmounted, so read the opacity target.
      double opacity() => tester
          .widget<AnimatedOpacity>(
            find
                .ancestor(
                  of: find.text('Cards opened'),
                  matching: find.byType(AnimatedOpacity),
                )
                .first,
          )
          .opacity;

      await pump(tester, motion: const QuickActionsMotion(toastDwell: Duration(seconds: 5)));
      await tester.tap(find.byKey(const ValueKey('qa-cards')));
      await tester.pumpAndSettle();
      expect(opacity(), 1);

      // Past the stock 1400ms dwell, still up because we asked for 5s.
      await tester.pump(const Duration(milliseconds: 2000));
      expect(opacity(), 1);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(opacity(), 0);
    });
  });

  group('theme', () {
    test('text overrides merge over the design style, not replace it', () {
      const theme = AwesomeScrollActionsTheme(
        text: QuickActionsTextStyles(title: TextStyle(fontSize: 40)),
      );
      final style = theme.textStyle(
        size: 20,
        weight: FontWeight.w800,
        color: const Color(0xFF000000),
        override: theme.text.title,
      );
      expect(style.fontSize, 40); // overridden
      expect(style.fontWeight, FontWeight.w800); // kept
      expect(style.fontFamily, 'packages/awesome_scroll_actions/PlusJakartaSans'); // kept
    });

    test('metrics default to the design and lerp', () {
      const a = QuickActionsMetrics();
      expect(a.pillRadius, 999);
      expect(a.chipBorderWidth, 1.5);

      final mid = QuickActionsMetrics.lerp(a, a.copyWith(pillRadius: 0), 0.5);
      expect(mid.pillRadius, 499.5);
      expect(mid.chipBorderWidth, 1.5);
    });

    test('theme lerp carries text and metrics', () {
      const a = AwesomeScrollActionsTheme();
      final b = a.copyWith(metrics: const QuickActionsMetrics(statTop: 222));
      final mid = a.lerp(b, 0.5);
      expect(mid.metrics.statTop, 172); // 122 -> 222
    });

    testWidgets('title text size follows the override', (tester) async {
      await pump(
        tester,
        theme: const AwesomeScrollActionsTheme(
          text: QuickActionsTextStyles(title: TextStyle(fontSize: 44)),
        ),
      );
      final title = tester.widget<Text>(find.text('Quick actions'));
      expect(title.style?.fontSize, 44);
      expect(title.style?.fontWeight, FontWeight.w800);
    });
  });

  group('builders', () {
    testWidgets('pillBuilder replaces the pill but keeps taps', (tester) async {
      var tapped = '';
      await pump(
        tester,
        pillBuilder: (context, action, active) => SizedBox(
          width: 40,
          child: Text(active ? 'ON:${action.id}' : 'off:${action.id}'),
        ),
      );
      expect(find.text('ON:scan_pay'), findsOneWidget);
      expect(find.text('off:cards'), findsOneWidget);

      await pump(
        tester,
        pillBuilder: (context, action, active) => GestureDetector(
          onTap: () => tapped = action.id,
          child: SizedBox(width: 40, child: Text('p:${action.id}')),
        ),
      );
      await tester.tap(find.text('p:cards'));
      await tester.pumpAndSettle();
      expect(tapped, 'cards');
      await drainToast(tester);
    });

    testWidgets('header, stat and toast builders replace the defaults', (tester) async {
      await pump(
        tester,
        headerBuilder: (context, title, subtitle) => Text('H:$title'),
        statBuilder: (context, action, stat) => Text('S:${stat.value}'),
        toastBuilder: (context, message) => Text('T:$message'),
      );
      expect(find.text('H:Quick actions'), findsOneWidget);
      expect(find.text('Quick actions'), findsNothing);
      expect(find.text('S:TZS 8,500'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('qa-cards')));
      await tester.pumpAndSettle();
      expect(find.text('T:Cards opened'), findsOneWidget);
      await drainToast(tester);
    });
  });

  group('overlay scrim', () {
    // Scaffold paints its own ColoredBox above the widget, so look inside.
    final scrimFinder = find.descendant(
      of: find.byType(AwesomeScrollActions),
      matching: find.byType(ColoredBox),
    );
    Color scrimOf(WidgetTester tester) =>
        tester.widget<ColoredBox>(scrimFinder).color;

    testWidgets('fades in with the pull and honours both knobs', (tester) async {
      const theme = AwesomeScrollActionsTheme(scrimColor: Color(0xFFFF0000));
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      Future<void> pumpScrim({required bool startTucked}) => tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AwesomeScrollActions(
                  key: ValueKey(startTucked),
                  actions: AwesomeScrollDefaults.actions,
                  enableHaptics: false,
                  showBackground: false,
                  startTucked: startTucked,
                  theme: theme,
                ),
              ),
            ),
          );

      await pumpScrim(startTucked: true);
      expect(scrimOf(tester).a, 0, reason: 'tucked: nothing dimmed');

      await pumpScrim(startTucked: false);
      await tester.pumpAndSettle();
      expect(scrimOf(tester).r, 1, reason: 'uses scrimColor');
      expect(scrimOf(tester).a, closeTo(0.45, 0.01),
          reason: 'open: dimmed by scrimOpacity');
    });

    testWidgets('scrimOpacity 0 drops the layer', (tester) async {
      await pump(
        tester,
        theme: const AwesomeScrollActionsTheme(
          metrics: QuickActionsMetrics(scrimOpacity: 0),
        ),
      );
      // Only the background gradient's DecoratedBoxes remain, no ColoredBox.
      expect(scrimFinder, findsNothing);
    });
  });

  group('dark preset', () {
    const light = AwesomeScrollActionsTheme();
    const dark = AwesomeScrollActionsTheme.dark;

    test('inverts the surfaces and keeps text readable on them', () {
      // Background and resting pill both go dark, the selected pill goes
      // light, and each foreground stays on the far side of its ground.
      expect(dark.backgroundTop.computeLuminance(), lessThan(0.1));
      expect(dark.surfaceColor.computeLuminance(), lessThan(0.2));
      expect(dark.accentColor.computeLuminance(), greaterThan(0.8));

      expect(dark.iconColor.computeLuminance(),
          greaterThan(dark.surfaceColor.computeLuminance()));
      expect(dark.activeForegroundColor.computeLuminance(),
          lessThan(dark.accentColor.computeLuminance()));
      expect(dark.titleColor.computeLuminance(),
          greaterThan(dark.backgroundTop.computeLuminance()));
      expect(dark.guideColor.computeLuminance(),
          greaterThan(dark.backgroundTop.computeLuminance()),
          reason: 'the arc guide must show against the dark ground');
    });

    test('shares light metrics, motion and font', () {
      expect(dark.metrics.scrimOpacity, light.metrics.scrimOpacity);
      expect(dark.fontFamily, light.fontFamily);
      expect(dark.text, isA<QuickActionsTextStyles>());
    });

    test('lerps into the light theme, so a mode switch animates', () {
      final mid = light.lerp(dark, 0.5);
      expect(mid.backgroundTop,
          Color.lerp(light.backgroundTop, dark.backgroundTop, 0.5));
    });

    testWidgets('follows the ambient brightness with nothing registered',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      Future<Color> backgroundUnder(Brightness brightness) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: Scaffold(
              body: AwesomeScrollActions(
                key: ValueKey(brightness),
                actions: AwesomeScrollDefaults.actions,
                enableHaptics: false,
              ),
            ),
          ),
        );
        // MaterialApp lerps between themes, so the first frame after a
        // switch is still the old one.
        await tester.pumpAndSettle();
        final box = tester.widget<DecoratedBox>(
          find.descendant(
            of: find.byType(AwesomeScrollActions),
            matching: find.byType(DecoratedBox),
          ).first,
        );
        return ((box.decoration as BoxDecoration).gradient! as LinearGradient)
            .colors
            .first;
      }

      // No extension registered at all: the dial still has to pick the
      // right shipped palette off the app's brightness.
      expect(await backgroundUnder(Brightness.light), light.backgroundTop);
      expect(await backgroundUnder(Brightness.dark), dark.backgroundTop);
    });

    testWidgets('a registered extension wins over the brightness',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          // Deliberately mismatched: a light extension on a dark app must
          // still be honoured, or explicit theming becomes unpredictable.
          theme: ThemeData(
            brightness: Brightness.dark,
            extensions: const [AwesomeScrollActionsTheme()],
          ),
          home: Scaffold(
            body: AwesomeScrollActions(
              actions: AwesomeScrollDefaults.actions,
              enableHaptics: false,
            ),
          ),
        ),
      );
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(AwesomeScrollActions),
          matching: find.byType(DecoratedBox),
        ).first,
      );
      expect(
        ((box.decoration as BoxDecoration).gradient! as LinearGradient)
            .colors
            .first,
        light.backgroundTop,
      );
    });

    testWidgets('picked up from ThemeData.extensions', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            extensions: const [AwesomeScrollActionsTheme.dark],
          ),
          home: Scaffold(
            body: AwesomeScrollActions(
              actions: AwesomeScrollDefaults.actions,
              enableHaptics: false,
            ),
          ),
        ),
      );
      final gradient = tester
          .widget<DecoratedBox>(
            find.descendant(
              of: find.byType(AwesomeScrollActions),
              matching: find.byType(DecoratedBox),
            ).first,
          )
          .decoration as BoxDecoration;
      expect((gradient.gradient! as LinearGradient).colors.first,
          dark.backgroundTop);
    });
  });

  group('guide fade', () {
    // The fade is a SweepGradient, which asserts if its stops are not
    // strictly increasing or do not match its colours. Two items rounding
    // to the same stop, a tucked dial with nothing placed and a half-spun
    // dial are the ways that happens, so walk through them on both axes.
    testWidgets('leaves nothing behind once the dial is tucked',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AwesomeScrollActions(
              actions: AwesomeScrollDefaults.actions,
              enableHaptics: false,
              showGuideLine: true,
              startTucked: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Every item has faded out, so there is nothing to light the arc and
      // no stub of it may be left on screen.
      expect(find.byKey(const ValueKey('qa-guide')), paintsNothing);
    });

    for (final (name, arc) in [
      ('vertical', const QuickActionsArc()),
      ('horizontal', QuickActionsArc.horizontal),
      // A tiny radius packs every item onto nearly the same angle.
      ('crowded', const QuickActionsArc(radius: 90, adaptRadius: false)),
    ]) {
      testWidgets('paints at any dial position: $name', (tester) async {
        tester.view.physicalSize = const Size(1170, 2532);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        for (final tucked in [false, true]) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AwesomeScrollActions(
                  key: ValueKey('$name-$tucked'),
                  actions: AwesomeScrollDefaults.actions,
                  enableHaptics: false,
                  showGuideLine: true,
                  startTucked: tucked,
                  arc: arc,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'tucked: $tucked');

          // Mid-spin, so the stops land on fractional angles.
          final centre = tester.getCenter(find.byType(AwesomeScrollActions));
          final drag = await tester.startGesture(centre);
          await drag.moveBy(arc.isHorizontal
              ? const Offset(-70, 0)
              : const Offset(0, -70));
          await tester.pump();
          expect(tester.takeException(), isNull, reason: 'mid-spin');
          await drag.up();
          await tester.pumpAndSettle();
        }
      });
    }

  });
}
