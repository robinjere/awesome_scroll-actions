import 'package:flutter/widgets.dart';

/// Every duration and curve the dial animates with.
///
/// The defaults are the timings the design ships with, so passing a bare
/// `QuickActionsMotion()` changes nothing. Scale the whole feel with
/// [scaled], or override individual beats with [copyWith].
///
/// Durations are ignored when the platform asks for reduced motion.
@immutable
class QuickActionsMotion {
  const QuickActionsMotion({
    this.snap = const Duration(milliseconds: 340),
    this.snapCurve = Curves.easeOutCubic,
    this.tuck = const Duration(milliseconds: 320),
    this.tuckCurve = Curves.easeOutCubic,
    this.pill = const Duration(milliseconds: 320),
    this.pillCurve = Curves.ease,
    this.label = const Duration(milliseconds: 340),
    this.labelCurve = Curves.ease,
    this.iconColor = const Duration(milliseconds: 300),
    this.iconColorCurve = Curves.ease,
    this.pop = const Duration(milliseconds: 500),
    this.popCurve = Curves.ease,
    this.popScale = 1.1,
    this.statSwitch = const Duration(milliseconds: 320),
    this.statCurve = const Interval(0.5, 1, curve: Curves.ease),
    this.statSlide = const Offset(0, 0.06),
    this.toast = const Duration(milliseconds: 250),
    this.toastCurve = Curves.ease,
    this.toastSlide = const Offset(0, 0.3),
    this.toastDwell = const Duration(milliseconds: 1400),
  });

  /// Settling onto an item after a drag, a fling or a tap.
  final Duration snap;
  final Curve snapCurve;

  /// Sliding the dial off and back onto the right edge.
  final Duration tuck;
  final Curve tuckCurve;

  /// The pill's background colour and shape as it becomes selected.
  final Duration pill;
  final Curve pillCurve;

  /// The label unfurling inside the selected pill.
  final Duration label;
  final Curve labelCurve;

  /// The icon tinting between resting and selected.
  final Duration iconColor;
  final Curve iconColorCurve;

  /// The bounce on the icon when an item is chosen.
  final Duration pop;
  final Curve popCurve;

  /// Peak of the pop bounce. 1 disables it.
  final double popScale;

  /// Cross-fading the stat card between actions.
  final Duration statSwitch;
  final Curve statCurve;

  /// How far the incoming stat card slides up, as a fraction of its height.
  final Offset statSlide;

  /// The toast fading and sliding in and out.
  final Duration toast;
  final Curve toastCurve;

  /// How far the toast slides up, as a fraction of its height.
  final Offset toastSlide;

  /// How long the toast stays before it hides itself.
  final Duration toastDwell;

  /// Every duration multiplied by [factor], curves untouched. `2` is a
  /// useful slow motion for inspecting the animations.
  QuickActionsMotion scaled(double factor) {
    Duration d(Duration v) => Duration(microseconds: (v.inMicroseconds * factor).round());
    return copyWith(
      snap: d(snap),
      tuck: d(tuck),
      pill: d(pill),
      label: d(label),
      iconColor: d(iconColor),
      pop: d(pop),
      statSwitch: d(statSwitch),
      toast: d(toast),
      toastDwell: d(toastDwell),
    );
  }

  QuickActionsMotion copyWith({
    Duration? snap,
    Curve? snapCurve,
    Duration? tuck,
    Curve? tuckCurve,
    Duration? pill,
    Curve? pillCurve,
    Duration? label,
    Curve? labelCurve,
    Duration? iconColor,
    Curve? iconColorCurve,
    Duration? pop,
    Curve? popCurve,
    double? popScale,
    Duration? statSwitch,
    Curve? statCurve,
    Offset? statSlide,
    Duration? toast,
    Curve? toastCurve,
    Offset? toastSlide,
    Duration? toastDwell,
  }) {
    return QuickActionsMotion(
      snap: snap ?? this.snap,
      snapCurve: snapCurve ?? this.snapCurve,
      tuck: tuck ?? this.tuck,
      tuckCurve: tuckCurve ?? this.tuckCurve,
      pill: pill ?? this.pill,
      pillCurve: pillCurve ?? this.pillCurve,
      label: label ?? this.label,
      labelCurve: labelCurve ?? this.labelCurve,
      iconColor: iconColor ?? this.iconColor,
      iconColorCurve: iconColorCurve ?? this.iconColorCurve,
      pop: pop ?? this.pop,
      popCurve: popCurve ?? this.popCurve,
      popScale: popScale ?? this.popScale,
      statSwitch: statSwitch ?? this.statSwitch,
      statCurve: statCurve ?? this.statCurve,
      statSlide: statSlide ?? this.statSlide,
      toast: toast ?? this.toast,
      toastCurve: toastCurve ?? this.toastCurve,
      toastSlide: toastSlide ?? this.toastSlide,
      toastDwell: toastDwell ?? this.toastDwell,
    );
  }
}
