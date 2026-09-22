import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Where one item sits on the dial for a given scroll position.
@immutable
class ArcPlacement {
  const ArcPlacement({
    required this.center,
    required this.opacity,
    required this.scale,
    required this.distance,
  });

  /// Centre of the item's slot, in the dial's local coordinates.
  final Offset center;
  final double opacity;
  final double scale;

  /// Angular distance from the selection point, in radians. Items nearer
  /// the selection point paint on top.
  final double distance;
}

/// Geometry, falloff and gesture tuning for the dial.
///
/// The defaults reproduce the design on a 390x844 screen: a 560px circle
/// centred 230px off the left edge, with items spaced 0.232 rad apart.
/// The circle is anchored to the right edge so it adapts to any width.
///
/// Every field defaults to the shipped design, so a bare
/// `QuickActionsArc()` changes nothing.
@immutable
class QuickActionsArc {
  const QuickActionsArc({
    this.axis = Axis.vertical,
    this.radius = 560,
    this.referenceExtent = 844,
    this.adaptRadius = true,
    this.angleStep = 0.232,
    this.rightInset = 60,
    this.bottomInset = 60,
    this.centerYFactor = 430 / 844,
    this.centerXFactor = 0.5,
    this.tuckOffset = 210,
    this.pullDistance = 190,
    this.dialStep = 130,
    this.itemSlot = 52,
    this.iconBoxSize = 44,
    this.iconSize = 21,
    this.labelMaxWidth = 160,
    this.minItemGap = 24,
    this.compactExtent = 520,
    this.opacityFalloff = 1.15,
    this.scaleFalloff = 0.22,
    this.minScale = 0.78,
    this.tuckFade = 1.5,
    this.visibilityCutoff = 0.03,
    this.dragSlop = 5,
    this.flingVelocity = 400,
    this.flingProjection = 0.12,
    this.pullCommit = 0.12,
  });

  /// A horizontal dial tuned for a phone-width screen.
  ///
  /// Passing `QuickActionsArc(axis: Axis.horizontal)` keeps the radius and
  /// spacing that were tuned for the tall vertical arc, which on a ~390pt
  /// wide screen fits only the selected item and one neighbour each side,
  /// with almost no visible curve. This preset tightens both so two
  /// neighbours fit each side and the arc reads as an arc. Adjust it with
  /// [copyWith].
  static const QuickActionsArc horizontal = QuickActionsArc(
    axis: Axis.horizontal,
    radius: 340,
    referenceExtent: 390,
    angleStep: 0.24,
    bottomInset: 84,
  );

  /// Which way the dial runs.
  ///
  /// [Axis.vertical] is the shipped design: the circle is anchored to the
  /// right edge, a vertical drag spins and a horizontal drag tucks.
  ///
  /// [Axis.horizontal] mirrors it onto the bottom edge: the dial runs left
  /// to right, a horizontal drag spins and a vertical drag tucks. Pills
  /// grow upwards and the pull handle moves to the bottom edge.
  final Axis axis;

  /// Radius of the circle at [referenceExtent].
  final double radius;

  /// The screen extent along [axis] that [radius] was drawn for: height
  /// when vertical, width when horizontal.
  final double referenceExtent;

  /// Scale [radius] by how far the real screen extent differs from
  /// [referenceExtent], so the dial keeps the same number of items on
  /// screen when the phone rotates or the window resizes.
  ///
  /// At [referenceExtent] the radius is exactly [radius] either way, so
  /// this changes nothing on the size the design was drawn for. Set it
  /// false to pin the radius in logical pixels instead.
  final bool adaptRadius;

  /// Angle between neighbouring items, in radians.
  final double angleStep;

  /// Distance from the right edge to the centre of the selected item.
  /// Used when [axis] is vertical.
  final double rightInset;

  /// Distance from the bottom edge to the centre of the selected item.
  /// Used when [axis] is horizontal.
  final double bottomInset;

  /// Vertical position of the circle centre as a fraction of height.
  /// Used when [axis] is vertical.
  final double centerYFactor;

  /// Horizontal position of the circle centre as a fraction of width.
  /// Used when [axis] is horizontal.
  final double centerXFactor;

  /// How far the items slide off the anchored edge when tucked: right when
  /// [axis] is vertical, down when it is horizontal.
  final double tuckOffset;

  /// Horizontal drag distance for a full tuck/untuck.
  final double pullDistance;

  /// Drag distance along [axis] that advances the dial by one item.
  final double dialStep;

  bool get isHorizontal => axis == Axis.horizontal;

  // ------------------------------------------------------------ item metrics

  /// Height of one item's slot, and the diameter of a resting pill.
  final double itemSlot;

  /// The tappable square the icon is centred in.
  final double iconBoxSize;

  /// Glyph size inside [iconBoxSize].
  final double iconSize;

  /// Longer labels ellipsise at this width.
  final double labelMaxWidth;

  /// Below this screen extent along [axis], a vertical dial drops the wide
  /// pill and prints the label beside a plain icon circle instead. A short
  /// screen — a phone in landscape — has no room for the pill without
  /// crowding its neighbours. Set it to 0 to always keep the wide pill.
  ///
  /// A horizontal dial always captions under its icon, so this does not
  /// apply to it.
  final double compactExtent;

  /// True when [size] is too short along [axis] for the wide pill.
  bool isCompact(Size size) => !isHorizontal && extentOf(size) < compactExtent;

  /// Smallest gap between neighbouring items, in logical pixels along the
  /// arc. When a short screen shrinks the radius, [angleStep] is widened
  /// so items keep this much air rather than crowding together; fewer of
  /// them fit on screen instead. The design's own gap is far wider, so
  /// this never fires at [referenceExtent].
  final double minItemGap;

  // ----------------------------------------------------------------- falloff

  /// How fast neighbours fade with angular distance. Higher is tighter.
  final double opacityFalloff;

  /// How fast neighbours shrink with angular distance.
  final double scaleFalloff;

  /// Smallest an off-centre item shrinks to.
  final double minScale;

  /// Exponent on the tuck fade. Higher fades later in the pull.
  final double tuckFade;

  /// Items fainter than this are not built at all.
  final double visibilityCutoff;

  // ---------------------------------------------------------------- gestures

  /// Movement before a drag commits to spinning or pulling.
  final double dragSlop;

  /// Speed along [axis], in px/s, above which a flick travels further.
  final double flingVelocity;

  /// How far a flick projects, in items per px/s of velocity.
  final double flingProjection;

  /// Fraction of [pullDistance] that commits a tuck or untuck.
  final double pullCommit;

  /// The screen extent the dial runs along.
  double extentOf(Size size) => isHorizontal ? size.width : size.height;

  /// [radius] adjusted for the real screen extent. See [adaptRadius].
  double resolveRadius(Size size) =>
      adaptRadius ? radius * extentOf(size) / referenceExtent : radius;

  Offset center(Size size) {
    final r = resolveRadius(size);
    return isHorizontal
        ? Offset(size.width * centerXFactor, size.height - bottomInset - r)
        : Offset(size.width - rightInset - r, size.height * centerYFactor);
  }

  /// [angleStep] widened, if needed, to hold [minItemGap] between items at
  /// the radius this screen resolves to.
  double resolveAngleStep(Size size) {
    final r = resolveRadius(size);
    if (r <= 0) return angleStep;
    final needed = math.asin(((itemSlot + minItemGap) / r).clamp(-1.0, 1.0));
    return math.max(angleStep, needed);
  }

  ArcPlacement place({
    required int index,
    required double position,
    required double openness,
    required Size size,
  }) {
    final phi = (index - position) * resolveAngleStep(size);
    final ad = phi.abs();
    final c = center(size);
    final r = resolveRadius(size);
    final tuck = (1 - openness) * tuckOffset;
    // Vertical rides the right of the circle; horizontal rides the bottom,
    // so the trig swaps and the tuck slides along the other edge.
    final x = isHorizontal ? c.dx + r * math.sin(phi) : c.dx + r * math.cos(phi) + tuck;
    final y = isHorizontal ? c.dy + r * math.cos(phi) + tuck : c.dy + r * math.sin(phi);
    final fade = math.pow(math.max(0.0, openness), tuckFade).toDouble();
    final opacity = (1 - ad * opacityFalloff).clamp(0.0, 1.0) * fade;
    final scale = math.max(minScale, 1 - ad * scaleFalloff);
    return ArcPlacement(center: Offset(x, y), opacity: opacity, scale: scale, distance: ad);
  }

  QuickActionsArc copyWith({
    Axis? axis,
    double? radius,
    double? referenceExtent,
    bool? adaptRadius,
    double? angleStep,
    double? rightInset,
    double? bottomInset,
    double? centerYFactor,
    double? centerXFactor,
    double? tuckOffset,
    double? pullDistance,
    double? dialStep,
    double? itemSlot,
    double? iconBoxSize,
    double? iconSize,
    double? labelMaxWidth,
    double? minItemGap,
    double? compactExtent,
    double? opacityFalloff,
    double? scaleFalloff,
    double? minScale,
    double? tuckFade,
    double? visibilityCutoff,
    double? dragSlop,
    double? flingVelocity,
    double? flingProjection,
    double? pullCommit,
  }) {
    return QuickActionsArc(
      axis: axis ?? this.axis,
      radius: radius ?? this.radius,
      referenceExtent: referenceExtent ?? this.referenceExtent,
      adaptRadius: adaptRadius ?? this.adaptRadius,
      angleStep: angleStep ?? this.angleStep,
      rightInset: rightInset ?? this.rightInset,
      bottomInset: bottomInset ?? this.bottomInset,
      centerYFactor: centerYFactor ?? this.centerYFactor,
      centerXFactor: centerXFactor ?? this.centerXFactor,
      tuckOffset: tuckOffset ?? this.tuckOffset,
      pullDistance: pullDistance ?? this.pullDistance,
      dialStep: dialStep ?? this.dialStep,
      itemSlot: itemSlot ?? this.itemSlot,
      iconBoxSize: iconBoxSize ?? this.iconBoxSize,
      iconSize: iconSize ?? this.iconSize,
      labelMaxWidth: labelMaxWidth ?? this.labelMaxWidth,
      minItemGap: minItemGap ?? this.minItemGap,
      compactExtent: compactExtent ?? this.compactExtent,
      opacityFalloff: opacityFalloff ?? this.opacityFalloff,
      scaleFalloff: scaleFalloff ?? this.scaleFalloff,
      minScale: minScale ?? this.minScale,
      tuckFade: tuckFade ?? this.tuckFade,
      visibilityCutoff: visibilityCutoff ?? this.visibilityCutoff,
      dragSlop: dragSlop ?? this.dragSlop,
      flingVelocity: flingVelocity ?? this.flingVelocity,
      flingProjection: flingProjection ?? this.flingProjection,
      pullCommit: pullCommit ?? this.pullCommit,
    );
  }
}
