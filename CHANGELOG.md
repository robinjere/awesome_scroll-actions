## 2.1.0

- New `onActionTapped` fires only when a pill is tapped. `onActionSelected`
  still fires on every settle, spins included, so move navigation to
  `onActionTapped` if a spin should only highlight.
- With `showBackground: false`, a tucked dial no longer swallows touches:
  only its edge handle does, and the page underneath works as normal.
  Starting a pull now means starting it on the handle.
- With `showBackground: false`, a tap outside the open dial tucks it.
- Lowered the floor to Flutter 3.38 / Dart 3.10.

## 2.0.1

- Added screenshots to the README and the pub.dev listing, plus a live web
  demo published to GitHub Pages from `example/`.
- `example/lib/main_shots.dart` renders one dial configuration per `?shot=`
  value, so the images can be regenerated after a visual change.
- Install instructions now point at the published package rather than a
  local path.

## 2.0.0

Renamed the package and dropped the `CooPesa` brand prefix. Breaking:
there is no deprecation shim, so update imports and names in one pass.

- `coopesa_quick_actions` is now `awesome_scroll_actions`, and the library
  entry moves with it:
  `package:awesome_scroll_actions/awesome_scroll_actions.dart`.
- `CooPesaQuickActions` -> `AwesomeScrollActions`,
  `CooPesaQuickActionsTheme` -> `AwesomeScrollActionsTheme`,
  `CooPesaDefaults` -> `AwesomeScrollDefaults`, `CooPesaIcons` ->
  `AwesomeScrollIcons`.
- The `QuickAction` vocabulary is unchanged. `QuickAction`,
  `QuickActionStat`, `QuickActionsArc`, `QuickActionsController`,
  `QuickActionsMotion`, `QuickActionsMetrics`, `QuickActionsTextStyles`,
  `QuickActionSelected` and the five builder typedefs keep their names:
  they describe the feature, not the brand.
- The bundled icon font's family is now `AwesomeScrollIcons`. Only matters
  if you referenced the family by name rather than through
  `AwesomeScrollIcons`.
- The header's default `title` is still the copy `'Quick actions'`, which
  describes the feature rather than the package. Pass your own to change it.

## 1.3.0

- The `showGuideLine` arc is now lit by the items instead of painted a flat
  colour: its alpha follows each icon's own opacity and tapers to nothing
  past the outermost one, so it fades at both ends and with the tuck. A
  tucked dial leaves no stub of the line behind.
- `AwesomeScrollActionsTheme.dark`: the design inverted for a dark surface.
  Register it as the dark theme's extension beside the bare constructor on
  the light one and the dial follows the system setting; the two lerp, so
  the switch animates. With no extension registered at all the dial now
  picks the shipped light or dark design off the ambient brightness,
  instead of always falling back to the light one.
- Overlay scrim: with `showBackground: false` the dial dims whatever is
  behind it as it is pulled out. `theme.scrimColor` and
  `theme.metrics.scrimOpacity` (0.45) control it; `0` removes it. No
  effect while `showBackground` is on, so the shipped design is unchanged.

## 1.2.0

- `QuickActionsArc.axis` runs the dial horizontally along the bottom edge.
  A horizontal drag spins it, a vertical drag tucks it down, the pull
  handle moves to the bottom and the scroll wheel follows the axis.
  `Axis.vertical` stays the default and is unchanged.
- `QuickActionsArc.horizontal` is a preset tuned for phone width. A bare
  `QuickActionsArc(axis: Axis.horizontal)` keeps the radius and spacing
  drawn for the tall vertical arc, which fits only three items across.
- A horizontal pill is an icon circle captioned underneath, rather than a
  wide pill with the label inside. New `metrics.captionPaddingBelow` and
  `theme.captionColor`.
- `compactExtent`: below that screen extent a vertical dial also drops the
  wide pill and prints the title beside a plain icon circle, since a short
  screen has no room for the pill without crowding its neighbours. Above
  it — any phone in portrait — the design's wide pill is unchanged. New
  `metrics.captionPaddingBeside`. Set `compactExtent: 0` to always keep
  the wide pill.
- `minItemGap`: when a short screen shrinks the radius, `angleStep` widens
  so items keep this much air instead of crowding; fewer fit on screen
  instead. Far below the design's own spacing, so it never fires at
  `referenceExtent`.
- `showGuideLine` draws only the stretch of circle the items ride on. It
  drew the whole circle, whose far side came back on screen as a stray
  arc across the top.
- Rotation: `adaptRadius` (on by default) scales the radius by the screen
  extent along the axis, against `referenceExtent`. At the reference
  extent the radius is exactly `radius`, so nothing changes on the size
  the design was drawn for. A vertical dial in landscape used to show
  three items; it now keeps its full spread.
- A horizontal dial anchors its stat card to the strip between the header
  and the icons (`statTopHorizontal`, `statGapAboveDial`) and scales it
  down if that strip is short, so the card never collides with the icons
  or the header on a rotated phone.

## 1.1.0

- Everything is now customizable, with every default unchanged. Upgrading
  without touching any call site renders exactly as 1.0.0 did.
- `QuickActionsMotion`: all durations and curves (snap, tuck, pill, label,
  icon tint, pop, stat switch, toast, toast dwell), plus `scaled()` to
  stretch the whole feel at once.
- `QuickActionsArc` gains item metrics (`itemSlot`, `iconBoxSize`,
  `iconSize`, `labelMaxWidth`), falloff constants (`opacityFalloff`,
  `scaleFalloff`, `minScale`, `tuckFade`, `visibilityCutoff`), gesture
  thresholds (`dragSlop`, `flingVelocity`, `flingProjection`,
  `pullCommit`) and a `copyWith`.
- `AwesomeScrollActionsTheme` gains `text` (per-role `TextStyle` overrides,
  merged over the design's own) and `metrics` (radii, paddings, handle and
  chrome layout). Both lerp with the theme.
- Structural escape hatches on the widget: `pillBuilder`, `statBuilder`,
  `headerBuilder`, `toastBuilder`, `handleBuilder`.

## 1.0.0

- Initial release: arc dial, side pull/tuck, stat card, toast, controller,
  theme extension, bundled Iconsax subset and Plus Jakarta Sans.
