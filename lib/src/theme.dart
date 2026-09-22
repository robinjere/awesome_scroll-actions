import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Per-role text overrides. Each style is merged over the design's own, so
/// setting only `fontSize` keeps the shipped weight, colour and spacing.
@immutable
class QuickActionsTextStyles {
  const QuickActionsTextStyles({
    this.title,
    this.subtitle,
    this.statLabel,
    this.statValue,
    this.statCaption,
    this.pillLabel,
    this.toast,
  });

  /// Header line, 20/w800 by default.
  final TextStyle? title;

  /// Header second line, 13/w400.
  final TextStyle? subtitle;

  /// Stat card heading, 13.5/w600.
  final TextStyle? statLabel;

  /// Stat card figure, 31/w800 with tabular figures.
  final TextStyle? statValue;

  /// Stat card chip, 13/w600.
  final TextStyle? statCaption;

  /// Label inside the selected pill, 15.5/w700.
  final TextStyle? pillLabel;

  /// Toast message, 13.5/w700.
  final TextStyle? toast;

  QuickActionsTextStyles copyWith({
    TextStyle? title,
    TextStyle? subtitle,
    TextStyle? statLabel,
    TextStyle? statValue,
    TextStyle? statCaption,
    TextStyle? pillLabel,
    TextStyle? toast,
  }) {
    return QuickActionsTextStyles(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      statLabel: statLabel ?? this.statLabel,
      statValue: statValue ?? this.statValue,
      statCaption: statCaption ?? this.statCaption,
      pillLabel: pillLabel ?? this.pillLabel,
      toast: toast ?? this.toast,
    );
  }

  static QuickActionsTextStyles lerp(
    QuickActionsTextStyles a,
    QuickActionsTextStyles b,
    double t,
  ) {
    return QuickActionsTextStyles(
      title: TextStyle.lerp(a.title, b.title, t),
      subtitle: TextStyle.lerp(a.subtitle, b.subtitle, t),
      statLabel: TextStyle.lerp(a.statLabel, b.statLabel, t),
      statValue: TextStyle.lerp(a.statValue, b.statValue, t),
      statCaption: TextStyle.lerp(a.statCaption, b.statCaption, t),
      pillLabel: TextStyle.lerp(a.pillLabel, b.pillLabel, t),
      toast: TextStyle.lerp(a.toast, b.toast, t),
    );
  }
}

/// Sizes, paddings and radii for the pill, stat card, pull handle, toast
/// and the surrounding chrome. Every field defaults to the shipped design.
@immutable
class QuickActionsMetrics {
  const QuickActionsMetrics({
    this.pillRadius = 999,
    this.pillPadding = const EdgeInsets.all(4),
    this.pillLabelPadding = const EdgeInsets.only(left: 18, right: 6),
    this.captionPaddingBelow = const EdgeInsets.only(top: 10),
    this.captionPaddingBeside = const EdgeInsets.only(right: 16),
    this.headerTop = 16,
    this.headerInset = 26,
    this.headerGap = 3,
    this.statTop = 122,
    this.statLeft = 26,
    this.statMaxWidth = 230,
    this.statTuckedOpacity = 0.35,
    this.statGapAboveDial = 28,
    this.statTopHorizontal = 68,
    this.statLabelGap = 7,
    this.statArrowGap = 9,
    this.statArrowSize = 15,
    this.statArrowOffset = 3,
    this.statArrowStroke = 2.6,
    this.chipMargin = const EdgeInsets.only(top: 14),
    this.chipPadding = const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    this.chipRadius = 999,
    this.chipBorderWidth = 1.5,
    this.handleWidth = 22,
    this.handleHeight = 96,
    this.handleSlotWidth = 30,
    this.handleRadius = 14,
    this.handleIconSize = const Size(12, 20),
    this.handleIconStroke = 2.4,
    this.toastPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
    this.toastRadius = 999,
    this.toastBottom = 26,
    this.topFadeHeight = 72,
    this.bottomFadeHeight = 30,
    this.guideStroke = 1.5,
    this.scrimOpacity = 0.45,
  });

  /// Corner radius of a pill. The default is a full stadium.
  final double pillRadius;

  /// Space around the pill's icon box.
  final EdgeInsets pillPadding;

  /// Space around the label a vertical dial unfurls inside its pill, on a
  /// screen tall enough for the wide pill. See `QuickActionsArc.compactExtent`.
  final EdgeInsets pillLabelPadding;

  /// Space above the caption a horizontal dial prints under its icon.
  final EdgeInsets captionPaddingBelow;

  /// Space to the right of the caption a vertical dial prints beside its
  /// icon, between the text and the circle.
  final EdgeInsets captionPaddingBeside;

  /// Header offset below the status bar, and its side inset.
  final double headerTop;
  final double headerInset;

  /// Gap between title and subtitle.
  final double headerGap;

  /// Stat card offset below the status bar, and from the left edge.
  final double statTop;
  final double statLeft;
  final double statMaxWidth;

  /// Stat card opacity while the dial is fully tucked.
  final double statTuckedOpacity;

  /// Where the stat card's strip starts when the dial is horizontal,
  /// below the safe area. [statTop] is tuned for the tall left column a
  /// vertical dial leaves free; a horizontal dial only has the strip under
  /// the header, so it starts just below it.
  final double statTopHorizontal;

  /// Gap between the stat card and the top of a horizontal dial. A
  /// horizontal dial anchors its card to the dial rather than to
  /// [statTop], so the card cannot collide with the icons when the phone
  /// rotates and the screen goes short.
  final double statGapAboveDial;

  /// Gap under the stat label, and between the figure and its arrow.
  final double statLabelGap;
  final double statArrowGap;

  /// The trend arrow beside the stat figure.
  final double statArrowSize;
  final double statArrowOffset;
  final double statArrowStroke;

  /// The caption chip under the stat figure.
  final EdgeInsets chipMargin;
  final EdgeInsets chipPadding;
  final double chipRadius;
  final double chipBorderWidth;

  /// The edge handle shown while the dial is tucked.
  final double handleWidth;
  final double handleHeight;

  /// Width of the handle's touch slot, and how far it slides out.
  final double handleSlotWidth;
  final double handleRadius;
  final Size handleIconSize;
  final double handleIconStroke;

  final EdgeInsets toastPadding;
  final double toastRadius;

  /// Toast offset above the bottom inset.
  final double toastBottom;

  /// Heights of the top and bottom background fades.
  final double topFadeHeight;
  final double bottomFadeHeight;

  /// Stroke width of the `showGuideLine` circle.
  final double guideStroke;

  /// How far the scrim dims what is behind the widget once the dial is
  /// fully out, multiplied into [AwesomeScrollActionsTheme.scrimColor]'s own
  /// alpha. Set to 0 for no scrim. The scrim sits under the design's own
  /// background, so it only shows when `showBackground` is off.
  final double scrimOpacity;

  QuickActionsMetrics copyWith({
    double? pillRadius,
    EdgeInsets? pillPadding,
    EdgeInsets? pillLabelPadding,
    EdgeInsets? captionPaddingBelow,
    EdgeInsets? captionPaddingBeside,
    double? headerTop,
    double? headerInset,
    double? headerGap,
    double? statTop,
    double? statLeft,
    double? statMaxWidth,
    double? statTuckedOpacity,
    double? statGapAboveDial,
    double? statTopHorizontal,
    double? statLabelGap,
    double? statArrowGap,
    double? statArrowSize,
    double? statArrowOffset,
    double? statArrowStroke,
    EdgeInsets? chipMargin,
    EdgeInsets? chipPadding,
    double? chipRadius,
    double? chipBorderWidth,
    double? handleWidth,
    double? handleHeight,
    double? handleSlotWidth,
    double? handleRadius,
    Size? handleIconSize,
    double? handleIconStroke,
    EdgeInsets? toastPadding,
    double? toastRadius,
    double? toastBottom,
    double? topFadeHeight,
    double? bottomFadeHeight,
    double? guideStroke,
    double? scrimOpacity,
  }) {
    return QuickActionsMetrics(
      pillRadius: pillRadius ?? this.pillRadius,
      pillPadding: pillPadding ?? this.pillPadding,
      pillLabelPadding: pillLabelPadding ?? this.pillLabelPadding,
      captionPaddingBelow: captionPaddingBelow ?? this.captionPaddingBelow,
      captionPaddingBeside: captionPaddingBeside ?? this.captionPaddingBeside,
      headerTop: headerTop ?? this.headerTop,
      headerInset: headerInset ?? this.headerInset,
      headerGap: headerGap ?? this.headerGap,
      statTop: statTop ?? this.statTop,
      statLeft: statLeft ?? this.statLeft,
      statMaxWidth: statMaxWidth ?? this.statMaxWidth,
      statTuckedOpacity: statTuckedOpacity ?? this.statTuckedOpacity,
      statGapAboveDial: statGapAboveDial ?? this.statGapAboveDial,
      statTopHorizontal: statTopHorizontal ?? this.statTopHorizontal,
      statLabelGap: statLabelGap ?? this.statLabelGap,
      statArrowGap: statArrowGap ?? this.statArrowGap,
      statArrowSize: statArrowSize ?? this.statArrowSize,
      statArrowOffset: statArrowOffset ?? this.statArrowOffset,
      statArrowStroke: statArrowStroke ?? this.statArrowStroke,
      chipMargin: chipMargin ?? this.chipMargin,
      chipPadding: chipPadding ?? this.chipPadding,
      chipRadius: chipRadius ?? this.chipRadius,
      chipBorderWidth: chipBorderWidth ?? this.chipBorderWidth,
      handleWidth: handleWidth ?? this.handleWidth,
      handleHeight: handleHeight ?? this.handleHeight,
      handleSlotWidth: handleSlotWidth ?? this.handleSlotWidth,
      handleRadius: handleRadius ?? this.handleRadius,
      handleIconSize: handleIconSize ?? this.handleIconSize,
      handleIconStroke: handleIconStroke ?? this.handleIconStroke,
      toastPadding: toastPadding ?? this.toastPadding,
      toastRadius: toastRadius ?? this.toastRadius,
      toastBottom: toastBottom ?? this.toastBottom,
      topFadeHeight: topFadeHeight ?? this.topFadeHeight,
      bottomFadeHeight: bottomFadeHeight ?? this.bottomFadeHeight,
      guideStroke: guideStroke ?? this.guideStroke,
      scrimOpacity: scrimOpacity ?? this.scrimOpacity,
    );
  }

  static QuickActionsMetrics lerp(QuickActionsMetrics a, QuickActionsMetrics b, double t) {
    double d(double x, double y) => lerpDouble(x, y, t)!;
    EdgeInsets e(EdgeInsets x, EdgeInsets y) => EdgeInsets.lerp(x, y, t)!;
    return QuickActionsMetrics(
      pillRadius: d(a.pillRadius, b.pillRadius),
      pillPadding: e(a.pillPadding, b.pillPadding),
      pillLabelPadding: e(a.pillLabelPadding, b.pillLabelPadding),
      captionPaddingBelow: e(a.captionPaddingBelow, b.captionPaddingBelow),
      captionPaddingBeside: e(a.captionPaddingBeside, b.captionPaddingBeside),
      headerTop: d(a.headerTop, b.headerTop),
      headerInset: d(a.headerInset, b.headerInset),
      headerGap: d(a.headerGap, b.headerGap),
      statTop: d(a.statTop, b.statTop),
      statLeft: d(a.statLeft, b.statLeft),
      statMaxWidth: d(a.statMaxWidth, b.statMaxWidth),
      statTuckedOpacity: d(a.statTuckedOpacity, b.statTuckedOpacity),
      statGapAboveDial: d(a.statGapAboveDial, b.statGapAboveDial),
      statTopHorizontal: d(a.statTopHorizontal, b.statTopHorizontal),
      statLabelGap: d(a.statLabelGap, b.statLabelGap),
      statArrowGap: d(a.statArrowGap, b.statArrowGap),
      statArrowSize: d(a.statArrowSize, b.statArrowSize),
      statArrowOffset: d(a.statArrowOffset, b.statArrowOffset),
      statArrowStroke: d(a.statArrowStroke, b.statArrowStroke),
      chipMargin: e(a.chipMargin, b.chipMargin),
      chipPadding: e(a.chipPadding, b.chipPadding),
      chipRadius: d(a.chipRadius, b.chipRadius),
      chipBorderWidth: d(a.chipBorderWidth, b.chipBorderWidth),
      handleWidth: d(a.handleWidth, b.handleWidth),
      handleHeight: d(a.handleHeight, b.handleHeight),
      handleSlotWidth: d(a.handleSlotWidth, b.handleSlotWidth),
      handleRadius: d(a.handleRadius, b.handleRadius),
      handleIconSize: Size.lerp(a.handleIconSize, b.handleIconSize, t)!,
      handleIconStroke: d(a.handleIconStroke, b.handleIconStroke),
      toastPadding: e(a.toastPadding, b.toastPadding),
      toastRadius: d(a.toastRadius, b.toastRadius),
      toastBottom: d(a.toastBottom, b.toastBottom),
      topFadeHeight: d(a.topFadeHeight, b.topFadeHeight),
      bottomFadeHeight: d(a.bottomFadeHeight, b.bottomFadeHeight),
      guideStroke: d(a.guideStroke, b.guideStroke),
      scrimOpacity: d(a.scrimOpacity, b.scrimOpacity),
    );
  }
}

/// Visual tokens for [AwesomeScrollActions]. Register it as a
/// [ThemeExtension] or pass it directly to the widget.
@immutable
class AwesomeScrollActionsTheme extends ThemeExtension<AwesomeScrollActionsTheme> {
  const AwesomeScrollActionsTheme({
    this.accentColor = const Color(0xFF1A2A3A),
    this.surfaceColor = const Color(0xFFFFFFFF),
    this.iconColor = const Color(0xFF1A2A3A),
    this.activeForegroundColor = const Color(0xFFFFFFFF),
    this.titleColor = const Color(0xFF16212E),
    this.mutedColor = const Color(0xFF8A95A1),
    this.chipBorderColor = const Color(0xFFD5DAE1),
    this.chipTextColor = const Color(0xFF5A6673),
    this.guideColor = const Color(0xFFDDE1E7),
    this.backgroundTop = const Color(0xFFEEF0F4),
    this.backgroundBottom = const Color(0xFFE4E7EC),
    this.restingShadow = const BoxShadow(
      color: Color(0x66172334), offset: Offset(0, 12), blurRadius: 26, spreadRadius: -16),
    this.activeShadow = const BoxShadow(
      color: Color(0x9E0A1626), offset: Offset(0, 20), blurRadius: 42, spreadRadius: -18),
    this.handleShadow = const BoxShadow(
      color: Color(0x8C0A1626), offset: Offset(0, 14), blurRadius: 30, spreadRadius: -14),
    this.toastShadow = const BoxShadow(
      color: Color(0x80101E32), offset: Offset(0, 16), blurRadius: 34, spreadRadius: -12),
    this.captionColor,
    this.scrimColor = const Color(0xFF0A1626),
    this.fontFamily = 'PlusJakartaSans',
    this.fontPackage = 'awesome_scroll_actions',
    this.text = const QuickActionsTextStyles(),
    this.metrics = const QuickActionsMetrics(),
  });

  /// Selected pill, pull handle and toast background.
  final Color accentColor;

  /// Resting pill background.
  final Color surfaceColor;
  final Color iconColor;

  /// Icon and label colour on the selected pill.
  final Color activeForegroundColor;
  final Color titleColor;
  final Color mutedColor;
  final Color chipBorderColor;
  final Color chipTextColor;
  final Color guideColor;
  final Color backgroundTop;
  final Color backgroundBottom;
  final BoxShadow restingShadow;
  final BoxShadow activeShadow;
  final BoxShadow handleShadow;
  final BoxShadow toastShadow;

  /// Colour of the caption a horizontal dial prints under each icon.
  /// Defaults to [titleColor].
  final Color? captionColor;

  /// Dims whatever is behind the widget while the dial is out. Scaled by
  /// [QuickActionsMetrics.scrimOpacity].
  final Color scrimColor;

  /// Defaults to the bundled Plus Jakarta Sans. Set both this and
  /// [fontPackage] to null to inherit the app's font instead.
  final String? fontFamily;
  final String? fontPackage;

  /// Per-role text overrides, merged over the design's own styles.
  final QuickActionsTextStyles text;

  /// Sizes, paddings and radii.
  final QuickActionsMetrics metrics;

  /// The design inverted for a dark surface. Register it as the dark
  /// theme's extension beside the bare constructor on the light one:
  ///
  /// ```dart
  /// MaterialApp(
  ///   theme: ThemeData(extensions: const [AwesomeScrollActionsTheme()]),
  ///   darkTheme: ThemeData.dark().copyWith(
  ///     extensions: const [AwesomeScrollActionsTheme.dark],
  ///   ),
  /// )
  /// ```
  ///
  /// The two lerp into each other, so a theme switch animates.
  static const AwesomeScrollActionsTheme dark = AwesomeScrollActionsTheme(
    // The selected pill swaps ends with the resting one: light on dark.
    accentColor: Color(0xFFF1F5F9),
    activeForegroundColor: Color(0xFF141E28),
    surfaceColor: Color(0xFF222D3A),
    iconColor: Color(0xFFE8EDF3),
    titleColor: Color(0xFFF1F5F9),
    mutedColor: Color(0xFF8D99A6),
    chipBorderColor: Color(0xFF35414F),
    chipTextColor: Color(0xFFAFBAC6),
    guideColor: Color(0xFF3A4654),
    backgroundTop: Color(0xFF151C24),
    backgroundBottom: Color(0xFF0D131A),
    scrimColor: Color(0xFF000000),
    // Navy-tinted shadows vanish on a dark ground; these are near-black
    // and a touch deeper so the pills still lift off it.
    restingShadow: BoxShadow(
      color: Color(0x99000000), offset: Offset(0, 12), blurRadius: 26, spreadRadius: -16),
    activeShadow: BoxShadow(
      color: Color(0xB3000000), offset: Offset(0, 20), blurRadius: 42, spreadRadius: -18),
    handleShadow: BoxShadow(
      color: Color(0xA6000000), offset: Offset(0, 14), blurRadius: 30, spreadRadius: -14),
    toastShadow: BoxShadow(
      color: Color(0x99000000), offset: Offset(0, 16), blurRadius: 34, spreadRadius: -12),
  );

  TextStyle textStyle({
    required double size,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
    List<FontFeature>? features,
    TextStyle? override,
  }) {
    final base = TextStyle(
      inherit: fontFamily == null,
      fontFamily: fontFamily,
      package: fontFamily == null ? null : fontPackage,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      fontFeatures: features,
      height: 1.2,
      decoration: TextDecoration.none,
    );
    return override == null ? base : base.merge(override);
  }

  @override
  AwesomeScrollActionsTheme copyWith({
    Color? accentColor,
    Color? surfaceColor,
    Color? iconColor,
    Color? activeForegroundColor,
    Color? titleColor,
    Color? mutedColor,
    Color? chipBorderColor,
    Color? chipTextColor,
    Color? guideColor,
    Color? backgroundTop,
    Color? backgroundBottom,
    BoxShadow? restingShadow,
    BoxShadow? activeShadow,
    BoxShadow? handleShadow,
    BoxShadow? toastShadow,
    Color? captionColor,
    Color? scrimColor,
    String? fontFamily,
    String? fontPackage,
    QuickActionsTextStyles? text,
    QuickActionsMetrics? metrics,
  }) {
    return AwesomeScrollActionsTheme(
      accentColor: accentColor ?? this.accentColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      iconColor: iconColor ?? this.iconColor,
      activeForegroundColor: activeForegroundColor ?? this.activeForegroundColor,
      titleColor: titleColor ?? this.titleColor,
      mutedColor: mutedColor ?? this.mutedColor,
      chipBorderColor: chipBorderColor ?? this.chipBorderColor,
      chipTextColor: chipTextColor ?? this.chipTextColor,
      guideColor: guideColor ?? this.guideColor,
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      restingShadow: restingShadow ?? this.restingShadow,
      activeShadow: activeShadow ?? this.activeShadow,
      handleShadow: handleShadow ?? this.handleShadow,
      toastShadow: toastShadow ?? this.toastShadow,
      captionColor: captionColor ?? this.captionColor,
      scrimColor: scrimColor ?? this.scrimColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontPackage: fontPackage ?? this.fontPackage,
      text: text ?? this.text,
      metrics: metrics ?? this.metrics,
    );
  }

  @override
  AwesomeScrollActionsTheme lerp(AwesomeScrollActionsTheme? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    BoxShadow s(BoxShadow a, BoxShadow b) => BoxShadow.lerp(a, b, t)!;
    return AwesomeScrollActionsTheme(
      accentColor: c(accentColor, other.accentColor),
      surfaceColor: c(surfaceColor, other.surfaceColor),
      iconColor: c(iconColor, other.iconColor),
      activeForegroundColor: c(activeForegroundColor, other.activeForegroundColor),
      titleColor: c(titleColor, other.titleColor),
      mutedColor: c(mutedColor, other.mutedColor),
      chipBorderColor: c(chipBorderColor, other.chipBorderColor),
      chipTextColor: c(chipTextColor, other.chipTextColor),
      guideColor: c(guideColor, other.guideColor),
      backgroundTop: c(backgroundTop, other.backgroundTop),
      backgroundBottom: c(backgroundBottom, other.backgroundBottom),
      restingShadow: s(restingShadow, other.restingShadow),
      activeShadow: s(activeShadow, other.activeShadow),
      handleShadow: s(handleShadow, other.handleShadow),
      toastShadow: s(toastShadow, other.toastShadow),
      captionColor: Color.lerp(captionColor, other.captionColor, t),
      scrimColor: c(scrimColor, other.scrimColor),
      fontFamily: t < 0.5 ? fontFamily : other.fontFamily,
      fontPackage: t < 0.5 ? fontPackage : other.fontPackage,
      text: QuickActionsTextStyles.lerp(text, other.text, t),
      metrics: QuickActionsMetrics.lerp(metrics, other.metrics, t),
    );
  }
}
