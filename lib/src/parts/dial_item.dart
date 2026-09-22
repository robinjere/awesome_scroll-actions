part of '../awesome_scroll_actions.dart';

/// One pill on the dial. It grows away from the edge the dial is anchored
/// to: leftwards from its right edge when vertical, upwards from its bottom
/// edge when horizontal. It is aligned to that edge inside its slot.
class _DialItem extends StatefulWidget {
  const _DialItem({
    required this.action,
    required this.active,
    required this.scale,
    required this.popToken,
    required this.theme,
    required this.arc,
    required this.motion,
    required this.reduceMotion,
    required this.compact,
    required this.onTap,
    this.builder,
  });

  final QuickAction action;
  final bool active;
  final double scale;
  final int popToken;
  final AwesomeScrollActionsTheme theme;
  final QuickActionsArc arc;
  final QuickActionsMotion motion;
  final bool reduceMotion;

  /// Screen too short for the wide pill; print the label beside the icon.
  final bool compact;

  final VoidCallback onTap;
  final QuickActionPillBuilder? builder;

  @override
  State<_DialItem> createState() => _DialItemState();
}

class _DialItemState extends State<_DialItem> with SingleTickerProviderStateMixin {
  late final AnimationController _pop =
      AnimationController(vsync: this, duration: widget.motion.pop);

  late Animation<double> _popScale = _buildPopScale();

  Animation<double> _buildPopScale() => TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: widget.motion.popScale), weight: 40),
        TweenSequenceItem(tween: Tween(begin: widget.motion.popScale, end: 1.0), weight: 60),
      ]).animate(CurvedAnimation(parent: _pop, curve: widget.motion.popCurve));

  @override
  void didUpdateWidget(_DialItem old) {
    super.didUpdateWidget(old);
    final motion = widget.motion;
    if (motion.pop != old.motion.pop) _pop.duration = motion.pop;
    if (motion.popScale != old.motion.popScale || motion.popCurve != old.motion.popCurve) {
      _popScale = _buildPopScale();
    }
    if (widget.popToken != old.popToken && !widget.reduceMotion) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  Duration _d(Duration d) => widget.reduceMotion ? Duration.zero : d;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final m = t.metrics;
    final arc = widget.arc;
    final motion = widget.motion;
    final active = widget.active;
    final action = widget.action;
    final horizontal = arc.isHorizontal;

    final icon = ScaleTransition(
      scale: _popScale,
      child: SizedBox.square(
        dimension: arc.iconBoxSize,
        child: Center(
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: active ? t.activeForegroundColor : t.iconColor),
            duration: _d(motion.iconColor),
            curve: motion.iconColorCurve,
            builder: (context, color, _) => Icon(action.icon, size: arc.iconSize, color: color),
          ),
        ),
      ),
    );

    Widget labelText(Color color) => ConstrainedBox(
          constraints: BoxConstraints(maxWidth: arc.labelMaxWidth),
          child: Text(
            action.label,
            maxLines: 1,
            softWrap: false,
            textAlign: horizontal ? TextAlign.center : TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: t.textStyle(
              size: 15.5,
              weight: FontWeight.w700,
              color: color,
              override: t.text.pillLabel,
            ),
          ),
        );

    // On a tall screen a vertical dial keeps the design's wide pill, with
    // the label unfurling inside it beside the icon. A horizontal dial, and
    // a vertical one on a screen too short for that pill, keep the pill a
    // plain icon circle and print the label outside it. An outside label
    // never takes layout space, so it cannot shift the icon off its arc
    // point and a resting circle stays the width of its slot.
    final compact = widget.compact;
    final labelOutside = horizontal || compact;

    final Widget shape = AnimatedContainer(
      duration: _d(motion.pill),
      curve: motion.pillCurve,
      padding: m.pillPadding,
      decoration: BoxDecoration(
        color: active ? t.accentColor : t.surfaceColor,
        borderRadius: BorderRadius.circular(m.pillRadius),
        boxShadow: [active ? t.activeShadow : t.restingShadow],
      ),
      child: labelOutside
          ? icon
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(end: active ? 1 : 0),
                  duration: _d(motion.label),
                  curve: motion.labelCurve,
                  builder: (context, v, child) => ClipRect(
                    child: Align(
                      alignment: Alignment.centerRight,
                      widthFactor: v,
                      child: Opacity(opacity: (v * 1.3).clamp(0.0, 1.0), child: child),
                    ),
                  ),
                  child: Padding(
                    padding: m.pillLabelPadding,
                    child: labelText(t.activeForegroundColor),
                  ),
                ),
                icon,
              ],
            ),
    );

    Widget reveal({required Offset from, required Widget child}) =>
        TweenAnimationBuilder<double>(
          tween: Tween(end: active ? 1 : 0),
          duration: _d(motion.label),
          curve: motion.labelCurve,
          builder: (context, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(offset: from * (1 - v), child: child),
          ),
          child: child,
        );

    // A zero-sized box on the label's axis: it is laid out, then allowed to
    // overflow into the space the dial leaves free.
    Widget caption({
      required double width,
      required double height,
      required Alignment alignment,
      required EdgeInsets padding,
      required Offset from,
    }) =>
        SizedBox(
          width: width,
          height: height,
          child: OverflowBox(
            alignment: alignment,
            // Release the minimums too: the sized box hands down a tight
            // constraint, which would stretch the label to the slot's size
            // and strand the glyphs at one edge of it.
            minWidth: 0,
            minHeight: 0,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: reveal(
              from: from,
              child: Padding(
                padding: padding,
                child: labelText(t.captionColor ?? t.titleColor),
              ),
            ),
          ),
        );

    final Widget laidOut;
    if (horizontal) {
      laidOut = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          shape,
          caption(
            width: arc.itemSlot,
            height: 0,
            alignment: Alignment.topCenter,
            padding: m.captionPaddingBelow,
            from: const Offset(0, -6),
          ),
        ],
      );
    } else if (compact) {
      laidOut = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          caption(
            width: 0,
            height: arc.itemSlot,
            alignment: Alignment.centerRight,
            padding: m.captionPaddingBeside,
            from: const Offset(8, 0),
          ),
          shape,
        ],
      );
    } else {
      laidOut = shape;
    }

    final pill = widget.builder?.call(context, action, active) ?? laidOut;

    return Semantics(
      container: true,
      button: true,
      selected: active,
      label: action.semanticLabel ?? action.label,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Transform.scale(
          scale: active ? 1 : widget.scale,
          alignment: horizontal ? Alignment.bottomCenter : Alignment.centerRight,
          child: pill,
        ),
      ),
    );
  }
}
