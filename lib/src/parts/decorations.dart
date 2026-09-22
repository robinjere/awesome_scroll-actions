part of '../awesome_scroll_actions.dart';

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle, required this.theme});

  final String? title;
  final String? subtitle;
  final AwesomeScrollActionsTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Semantics(
            header: true,
            child: Text(
              title!,
              style: theme.textStyle(
                size: 20,
                weight: FontWeight.w800,
                color: theme.titleColor,
                letterSpacing: -0.2,
                override: theme.text.title,
              ),
            ),
          ),
        if (subtitle != null)
          Padding(
            padding: EdgeInsets.only(top: theme.metrics.headerGap),
            child: Text(
              subtitle!,
              style: theme.textStyle(
                size: 13,
                weight: FontWeight.w400,
                color: theme.mutedColor,
                override: theme.text.subtitle,
              ),
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({super.key, required this.stat, required this.theme, this.onTap});

  final QuickActionStat stat;
  final AwesomeScrollActionsTheme theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final m = theme.metrics;
    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stat.label,
          style: theme.textStyle(
            size: 13.5,
            weight: FontWeight.w600,
            color: theme.mutedColor,
            override: theme.text.statLabel,
          ),
        ),
        SizedBox(height: m.statLabelGap),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                stat.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textStyle(
                  size: 31,
                  weight: FontWeight.w800,
                  color: theme.titleColor,
                  letterSpacing: -0.62,
                  features: const [FontFeature.tabularFigures()],
                  override: theme.text.statValue,
                ),
              ),
            ),
            SizedBox(width: m.statArrowGap),
            Padding(
              padding: EdgeInsets.only(top: m.statArrowOffset),
              child: CustomPaint(
                size: Size.square(m.statArrowSize),
                painter: _StrokePainter(
                  viewBox: 24,
                  strokeWidth: m.statArrowStroke,
                  color: theme.mutedColor,
                  lines: const [
                    [Offset(7, 17), Offset(17, 7)],
                    [Offset(9, 7), Offset(17, 7), Offset(17, 15)],
                  ],
                ),
              ),
            ),
          ],
        ),
        if (stat.caption != null)
          Container(
            margin: m.chipMargin,
            padding: m.chipPadding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(m.chipRadius),
              border: Border.all(color: theme.chipBorderColor, width: m.chipBorderWidth),
            ),
            child: Text(
              stat.caption!,
              style: theme.textStyle(
                size: 13,
                weight: FontWeight.w600,
                color: theme.chipTextColor,
                override: theme.text.statCaption,
              ),
            ),
          ),
      ],
    );
    if (onTap == null) return IgnorePointer(child: card);
    return Semantics(
      button: true,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: card),
    );
  }
}

class _PullHandle extends StatelessWidget {
  const _PullHandle({required this.theme, required this.arc, required this.onTap});

  final AwesomeScrollActionsTheme theme;
  final QuickActionsArc arc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = theme.metrics;
    final horizontal = arc.isHorizontal;
    return Semantics(
      button: true,
      label: 'Show quick actions',
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Align(
          alignment: horizontal ? Alignment.bottomCenter : Alignment.centerRight,
          child: Container(
            width: horizontal ? m.handleHeight : m.handleWidth,
            height: horizontal ? m.handleWidth : m.handleHeight,
            decoration: BoxDecoration(
              color: theme.accentColor,
              borderRadius: horizontal
                  ? BorderRadius.vertical(top: Radius.circular(m.handleRadius))
                  : BorderRadius.horizontal(left: Radius.circular(m.handleRadius)),
              boxShadow: [theme.handleShadow],
            ),
            alignment: Alignment.center,
            // The chevron points away from the edge it is parked on.
            child: CustomPaint(
              size: horizontal ? m.handleIconSize.flipped : m.handleIconSize,
              painter: _StrokePainter(
                viewBox: horizontal ? 12 : 20,
                viewBoxWidth: horizontal ? 20 : 12,
                strokeWidth: m.handleIconStroke,
                color: theme.activeForegroundColor,
                lines: horizontal
                    ? const [
                        [Offset(2, 9), Offset(10, 2), Offset(18, 9)],
                      ]
                    : const [
                        [Offset(9, 2), Offset(2, 10), Offset(9, 18)],
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast({required this.message, required this.theme});

  final String message;
  final AwesomeScrollActionsTheme theme;

  @override
  Widget build(BuildContext context) {
    final m = theme.metrics;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: m.toastPadding,
        decoration: BoxDecoration(
          color: theme.accentColor,
          borderRadius: BorderRadius.circular(m.toastRadius),
          boxShadow: [theme.toastShadow],
        ),
        child: Text(
          message,
          maxLines: 1,
          softWrap: false,
          style: theme.textStyle(
            size: 13.5,
            weight: FontWeight.w700,
            color: theme.activeForegroundColor,
            override: theme.text.toast,
          ),
        ),
      ),
    );
  }
}

/// Draws round-capped polylines given in SVG viewBox units.
class _StrokePainter extends CustomPainter {
  const _StrokePainter({
    required this.lines,
    required this.viewBox,
    required this.strokeWidth,
    required this.color,
    this.viewBoxWidth,
  });

  final List<List<Offset>> lines;
  final double viewBox;
  final double? viewBoxWidth;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / (viewBoxWidth ?? viewBox);
    final sy = size.height / viewBox;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * sx
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final line in lines) {
      final path = Path()..moveTo(line.first.dx * sx, line.first.dy * sy);
      for (final p in line.skip(1)) {
        path.lineTo(p.dx * sx, p.dy * sy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StrokePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth || old.lines != lines;
}

/// Draws the run of circle the items ride on. Only that stretch: a whole
/// circle puts its far side back on screen as a stray line. Its alpha
/// follows the items', so the guide is brightest under an icon and tapers
/// to nothing past the outermost one instead of stopping dead.
class _GuidePainter extends CustomPainter {
  const _GuidePainter({
    required this.center,
    required this.radius,
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
    required this.stops,
  });

  final Offset center;
  final double radius;
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  /// One (angle, opacity) per placed item, ascending by angle.
  final List<(double, double)> stops;

  @override
  void paint(Canvas canvas, Size size) {
    if (sweepAngle <= 0 || radius <= 0) return;
    final rect = Rect.fromCircle(center: center, radius: radius);
    // No shader means no item is visible enough to light the arc, which is
    // what a tucked dial looks like. Drawing it flat instead would leave a
    // stub of line behind after the dial has slid away.
    final shader = _fade(rect);
    if (shader == null) return;
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );
  }

  /// A sweep gradient over the same angular span as the arc, keyed to where
  /// the icons actually sit. Transparent at both ends, so the line fades out
  /// with them as the dial spins or tucks.
  Shader? _fade(Rect rect) {
    final colors = <Color>[color.withValues(alpha: 0)];
    final offsets = <double>[0];
    for (final (angle, opacity) in stops) {
      final t = ((angle - startAngle) / sweepAngle).clamp(0.0, 1.0);
      // A gradient needs strictly increasing stops; two items can round to
      // the same one when the dial is packed tight.
      if (t <= offsets.last) continue;
      offsets.add(t);
      colors.add(color.withValues(alpha: color.a * opacity));
    }
    if (offsets.last < 1) {
      offsets.add(1);
      colors.add(color.withValues(alpha: 0));
    }
    if (colors.length < 3) return null;
    // Skia folds a fragment's angle into [0, 2pi) before scaling it against
    // the sweep, so a negative `startAngle` sends the whole half above the
    // centre past the end of the gradient, where it clamps to transparent.
    // Keep the sweep at 0..sweepAngle and rotate it into place instead.
    return SweepGradient(
      startAngle: 0,
      endAngle: sweepAngle,
      colors: colors,
      stops: offsets,
      transform: GradientRotation(startAngle),
    ).createShader(rect);
  }

  @override
  bool shouldRepaint(_GuidePainter old) =>
      old.center != center ||
      old.radius != radius ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.startAngle != startAngle ||
      old.sweepAngle != sweepAngle ||
      !listEquals(old.stops, stops);
}
