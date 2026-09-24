# awesome_scroll_actions

The Awesome Scroll Actions dial as a Flutter package.

Action pills ride along a large circle whose centre sits off the left edge
of the screen. The centred pill turns dark and expands to show its label, a
stat card above swaps to that action's figures, and a toast confirms the
choice.

**[Try the live demo](https://robinjere.github.io/awesome_scroll-actions/)** — the example app built for web.

| | | |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/robinjere/awesome_scroll-actions/main/screenshots/open.png" width="210" alt="The dial at rest"> | <img src="https://raw.githubusercontent.com/robinjere/awesome_scroll-actions/main/screenshots/dark.png" width="210" alt="The dark palette"> | <img src="https://raw.githubusercontent.com/robinjere/awesome_scroll-actions/main/screenshots/guide.png" width="210" alt="showGuideLine enabled"> |
| At rest | `AwesomeScrollActionsTheme.dark` | `showGuideLine: true` |

<img src="https://raw.githubusercontent.com/robinjere/awesome_scroll-actions/main/screenshots/horizontal.png" width="640" alt="The horizontal arc">

`QuickActionsArc.horizontal` — the dial mirrored onto the bottom edge.

| Gesture | Result |
| --- | --- |
| Vertical drag | Spin the dial; it snaps to the nearest action on release |
| Horizontal drag | Tuck the dial off the right edge, or pull it back |
| Tap a pill | Jump to that action (or open the dial if tucked) |
| Tap the edge handle | Open a tucked dial |
| Mouse wheel / trackpad | Step one action at a time |

Needs Flutter 3.38 / Dart 3.10 or newer. Pure Dart: no platform
channels, so it runs on Android, iOS, web and desktop.

## Install

```bash
flutter pub add awesome_scroll_actions
```

```yaml
dependencies:
  awesome_scroll_actions: ^2.1.0
```

## Use

```dart
Scaffold(
  body: AwesomeScrollActions(
    actions: AwesomeScrollDefaults.actions,
    initialActionId: 'scan_pay',
    onActionTapped: (action, index) {
      Navigator.pushNamed(context, '/${action.id}');
    },
  ),
)
```

`onActionTapped` fires only when a pill is tapped, so spinning just
highlights. `onActionSelected` fires on every settle, spins included; use it
to track the highlighted action, not to navigate.

The widget fills its parent and handles safe-area insets itself, so give it
the whole screen.

### Your own actions

```dart
const actions = [
  QuickAction(
    id: 'send',
    label: 'Send Money',
    icon: AwesomeScrollIcons.arrowUp,
    stat: QuickActionStat(label: 'Sent this month', value: 'TZS 412,500', caption: '12 transfers'),
  ),
  QuickAction(id: 'loans', label: 'Loans', icon: Icons.savings_outlined),
];
```

`stat` is optional; actions without one hide the card. Any `IconData` works.
`AwesomeScrollIcons` holds the Iconsax glyphs from the design: `arrowUp`,
`arrowDown`, `flash`, `mobile`, `scan`, `moneyChange`, `barGraph`,
`bankCard`, `addCircle` and `add`.

### Controller

```dart
final controller = QuickActionsController();

AwesomeScrollActions(actions: actions, controller: controller);

controller.selectById('cards'); // opens if tucked, then animates
controller.tuck();
controller.open();
controller.toggle();
controller.selectedAction;      // null while the user is spinning
controller.isOpen;
```

It is a `ChangeNotifier` and fires when a selection settles and when the
dial finishes opening or tucking.

### Options

| Parameter | Default | |
| --- | --- | --- |
| `startTucked` | `false` | Begin with the dial hidden behind the handle |
| `showGuideLine` | `false` | Draw the circle the pills ride on |
| `title`, `subtitle` | design copy | Pass `null` to hide |
| `showStats`, `onStatTap` | `true`, `null` | Stat card and its tap handler |
| `showToast`, `toastMessageBuilder` | `true`, `"<label> opened"` | Confirmation toast |
| `onActionSelected`, `onActionTapped` | `null` | Every settle; pill taps only |
| `showBackground` | `true` | Grey gradient and edge fades; turn off to overlay your own screen |
| `enableHaptics` | `true` | Selection click on each snap |
| `arc` | `QuickActionsArc()` | Axis, geometry, item metrics, falloff, drag thresholds |
| `motion` | `QuickActionsMotion()` | Every duration and curve |
| `theme` | from `ThemeData.extensions` | Colours, shadows, font, text styles, metrics |
| `pillBuilder` and friends | `null` | Replace a part's visuals outright |

### Theming

Register once on your app theme:

```dart
ThemeData(
  extensions: const [
    AwesomeScrollActionsTheme(accentColor: Color(0xFF0B5D3B)),
  ],
)
```

Text uses the bundled Plus Jakarta Sans. To inherit your app font instead,
construct the theme with `fontFamily: null, fontPackage: null` (not via
`copyWith`, which keeps existing values).

`showGuideLine` draws the circle the items ride along. It is lit by the
items: brightest under an icon, fading out past the outermost one and with
the tuck, so it never stops dead at an end. `theme.guideColor` sets its
colour and `metrics.guideStroke` its width.

### Using it as an overlay

Set `showBackground: false` and lay the dial over your own content. A scrim
fades in behind it as the dial comes out, so the content dims while the
actions are showing. While tucked, only the edge handle takes touches, so
the page underneath stays usable. While open, a tap outside the dial tucks
it:

```dart
Stack(children: [
  MyPage(),
  AwesomeScrollActions(actions: ..., showBackground: false),
])
```

`theme.scrimColor` sets its colour and `theme.metrics.scrimOpacity` how far
it dims at full pull (`0.45` by default; `0` removes it). The scrim sits
under the design's own background, so it has no effect while
`showBackground` is on.

### Light and dark

`AwesomeScrollActionsTheme.dark` is the design inverted for a dark surface:
the resting pill and background go dark, the selected pill goes light.
Register both and the dial follows the system setting:

```dart
MaterialApp(
  theme: ThemeData(extensions: const [AwesomeScrollActionsTheme()]),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: const [AwesomeScrollActionsTheme.dark],
  ),
)
```

Both share the same metrics, motion and font, and lerp into each other, so
the switch animates. Adjust either with `copyWith`.

You only need to register them to *customise* the palette. With no
extension registered the dial picks the shipped light or dark design off
the ambient `Theme.of(context).brightness`, so it follows the system
setting out of the box. Resolution order is `theme:` on the widget, then
the registered extension, then the brightness.

The system "reduce motion" setting is honoured: animations become instant.

### Everything else

Every number the design hard-coded is a field, and every field defaults to
the design, so a bare config changes nothing.

**Text** — `theme.text` overrides one role at a time. Styles are *merged*
over the design's own, so setting only a size keeps the shipped weight,
colour and tracking:

```dart
AwesomeScrollActionsTheme(
  text: QuickActionsTextStyles(
    title: TextStyle(fontSize: 24),
    pillLabel: TextStyle(letterSpacing: 0.2),
  ),
)
```

**Sizes and spacing** — `theme.metrics` holds the radii, paddings and the
placement of the header, stat card, pull handle and toast:

```dart
AwesomeScrollActionsTheme(
  metrics: QuickActionsMetrics(pillRadius: 16, statTop: 150, handleWidth: 28),
)
```

**Motion** — `QuickActionsMotion` holds every duration and curve. `scaled()`
stretches them together, which is handy for inspecting the animations:

```dart
AwesomeScrollActions(
  actions: actions,
  motion: const QuickActionsMotion(
    snap: Duration(milliseconds: 220),
    snapCurve: Curves.easeOutBack,
    toastDwell: Duration(seconds: 3),
  ).scaled(1.0),
)
```

**Geometry, falloff and gestures** — on `QuickActionsArc`: item sizes
(`itemSlot`, `iconBoxSize`, `iconSize`, `labelMaxWidth`), how fast
neighbours fade and shrink (`opacityFalloff`, `scaleFalloff`, `minScale`),
and the drag thresholds (`dragSlop`, `flingVelocity`, `flingProjection`,
`pullCommit`). Turn on `showGuideLine` while tuning.

### Axis and rotation

The dial runs vertically down the right edge by default. `axis` mirrors it
onto the bottom edge: a horizontal drag spins, a vertical drag tucks, the
handle moves to the bottom, and each pill becomes an icon circle captioned
underneath instead of a wide pill with the label inside.

```dart
AwesomeScrollActions(
  actions: actions,
  arc: QuickActionsArc.horizontal,
)
```

Use the `QuickActionsArc.horizontal` preset rather than
`QuickActionsArc(axis: Axis.horizontal)`. The bare constructor keeps the
radius and spacing tuned for the tall vertical arc, which across a phone's
width fits only the selected item and one neighbour, with almost no curve.

Both axes handle rotation. `adaptRadius` (on by default) scales the radius
by the real screen extent along the axis, measured against
`referenceExtent`. At the reference extent the radius is exactly `radius`,
so this changes nothing on the size the design was drawn for, and a
rotated phone keeps the same spread instead of collapsing to three items.
Set `adaptRadius: false` to pin the radius in logical pixels.

On a screen too short for the wide pill — a phone in landscape — a
vertical dial also drops to an icon circle with the title beside it, and
widens its spacing so the icons keep clear of each other. Both thresholds
are fields: `compactExtent` (set it to `0` to always keep the wide pill)
and `minItemGap`. In portrait the design's wide pill is untouched.

A horizontal dial also moves its stat card into the strip between the
header and the icons, and scales it down when that strip is short, so the
card never lands on the icons or the header in landscape. Tune with
`metrics.statTopHorizontal` and `metrics.statGapAboveDial`.

**Structure** — when a token is not enough, replace a part outright. Taps,
scaling, timing and semantics stay handled for you:

```dart
AwesomeScrollActions(
  actions: actions,
  pillBuilder: (context, action, active) => MyPill(action, active: active),
  statBuilder: (context, action, stat) => MyStatCard(stat),
  headerBuilder: (context, title, subtitle) => MyHeader(title),
  toastBuilder: (context, message) => MyToast(message),
  handleBuilder: (context, open) => MyHandle(onTap: open),
)
```

## Example and tests

```bash
cd example
flutter create . --platforms=android,ios   # generates the platform folders
flutter run

cd ..
flutter test
```

The web build behind the [live demo](https://robinjere.github.io/awesome_scroll-actions/)
is published from `example/` by the `demo` GitHub Actions workflow on every
push to `main`:

```bash
cd example
flutter build web --release --base-href /awesome_scroll-actions/
```

`example/lib/main_shots.dart` renders one dial configuration per `?shot=`
value; the README images are captured from it, so they can be regenerated
after a visual change:

```bash
cd example
flutter build web --release -t lib/main_shots.dart --output build/shots
# serve build/shots, then screenshot ?shot=open|dark|guide|horizontal
```
