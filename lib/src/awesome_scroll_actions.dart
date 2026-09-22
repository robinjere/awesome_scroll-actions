import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'arc.dart';
import 'models.dart';
import 'motion.dart';
import 'theme.dart';

part 'parts/controller.dart';
part 'parts/dial_item.dart';
part 'parts/decorations.dart';

/// Called when an action settles in the selection slot, either from a tap,
/// a finished drag or [QuickActionsController.select].
typedef QuickActionSelected = void Function(QuickAction action, int index);

/// Replaces the pill's visuals. Taps, scaling and semantics stay handled
/// by the dial, so the builder only has to paint.
typedef QuickActionPillBuilder = Widget Function(
    BuildContext context, QuickAction action, bool active);

/// Replaces the stat card's visuals.
typedef QuickActionStatBuilder = Widget Function(
    BuildContext context, QuickAction action, QuickActionStat stat);

/// Replaces the header block.
typedef QuickActionsHeaderBuilder = Widget Function(
    BuildContext context, String? title, String? subtitle);

/// Replaces the toast. Visibility and timing stay handled by the dial.
typedef QuickActionsToastBuilder = Widget Function(BuildContext context, String message);

/// Replaces the tucked-state edge handle. Call `open` to untuck.
typedef QuickActionsHandleBuilder = Widget Function(BuildContext context, VoidCallback open);

enum _DragMode { pull, dial }

/// The Awesome Scroll Actions surface.
///
/// Drag vertically to spin the dial. Drag horizontally, or tap the edge
/// handle, to tuck and untuck it. Tap a pill to jump to it. The mouse
/// wheel steps one item at a time.
///
/// It fills its parent, so give it a full-screen slot such as a
/// [Scaffold] body.
class AwesomeScrollActions extends StatefulWidget {
  const AwesomeScrollActions({
    super.key,
    required this.actions,
    this.initialActionId,
    this.startTucked = false,
    this.showGuideLine = false,
    this.controller,
    this.onActionSelected,
    this.title = 'Quick actions',
    this.subtitle = 'Pull from the side \u2022 drag the dial',
    this.showStats = true,
    this.onStatTap,
    this.showToast = true,
    this.toastMessageBuilder,
    this.showBackground = true,
    this.enableHaptics = true,
    this.arc = const QuickActionsArc(),
    this.motion = const QuickActionsMotion(),
    this.theme,
    this.pillBuilder,
    this.statBuilder,
    this.headerBuilder,
    this.toastBuilder,
    this.handleBuilder,
  }) : assert(actions.length > 0, 'AwesomeScrollActions needs at least one action.');

  final List<QuickAction> actions;

  /// Action centred on first build. Defaults to the middle action.
  final String? initialActionId;

  /// Start with the dial slid off the right edge.
  final bool startTucked;

  /// Draw the circle the items ride along. Useful when tuning [arc].
  final bool showGuideLine;

  final QuickActionsController? controller;
  final QuickActionSelected? onActionSelected;

  /// Header text. Pass null to hide either line.
  final String? title;
  final String? subtitle;

  /// Show the stat card for the selected action.
  final bool showStats;
  final QuickActionSelected? onStatTap;

  /// Show the "<label> opened" toast after a selection.
  final bool showToast;
  final String Function(QuickAction action)? toastMessageBuilder;

  /// Paint the design's grey gradient and top/bottom edge fades. Turn off
  /// to lay the dial over your own background.
  final bool showBackground;

  final bool enableHaptics;

  /// Geometry, falloff and gesture thresholds.
  final QuickActionsArc arc;

  /// Durations and curves.
  final QuickActionsMotion motion;

  /// Overrides any [AwesomeScrollActionsTheme] registered on [ThemeData].
  final AwesomeScrollActionsTheme? theme;

  /// Structural overrides. Each defaults to the shipped design.
  final QuickActionPillBuilder? pillBuilder;
  final QuickActionStatBuilder? statBuilder;
  final QuickActionsHeaderBuilder? headerBuilder;
  final QuickActionsToastBuilder? toastBuilder;
  final QuickActionsHandleBuilder? handleBuilder;

  @override
  State<AwesomeScrollActions> createState() => _AwesomeScrollActionsState();
}

class _AwesomeScrollActionsState extends State<AwesomeScrollActions>
    with TickerProviderStateMixin {
  late AnimationController _pos;
  late final AnimationController _open;

  /// Index shown as selected, or null while the dial is being spun.
  int? _active;
  late int _statIndex;
  late List<int> _popTokens;

  String _toastMessage = '';
  bool _toastVisible = false;
  Timer? _toastTimer;

  bool _reduceMotion = false;

  _DragMode? _mode;
  Offset _dragStart = Offset.zero;
  double _startPos = 0;
  double _startOpen = 1;

  int get _count => widget.actions.length;
  double get _maxPos => (_count - 1).toDouble();

  @override
  void initState() {
    super.initState();
    final initial = _indexOf(widget.initialActionId) ?? (_count - 1) ~/ 2;
    _pos = _makePosController(initial.toDouble());
    _open = AnimationController(vsync: this, value: widget.startTucked ? 0 : 1)
      ..addStatusListener(_onOpenStatus);
    _active = initial;
    _statIndex = initial;
    _popTokens = List<int>.filled(_count, 0);
    widget.controller?._attach(this);
  }

  AnimationController _makePosController(double value) => AnimationController(
        vsync: this,
        lowerBound: 0,
        upperBound: _maxPos,
        value: value.clamp(0.0, _maxPos),
      );

  int? _indexOf(String? id) {
    if (id == null) return null;
    final i = widget.actions.indexWhere((a) => a.id == id);
    return i < 0 ? null : i;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  @override
  void didUpdateWidget(AwesomeScrollActions old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (old.actions.length != widget.actions.length) {
      final value = _pos.value;
      _pos.dispose();
      _pos = _makePosController(value);
      final a = _active;
      _active = a?.clamp(0, _count - 1);
      _statIndex = _statIndex.clamp(0, _count - 1);
      _popTokens = List<int>.filled(_count, 0);
    }
    if (old.initialActionId != widget.initialActionId) {
      final i = _indexOf(widget.initialActionId);
      if (i != null) _jumpTo(i);
    }
    if (old.startTucked != widget.startTucked) {
      _setOpen(widget.startTucked ? 0 : 1);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _toastTimer?.cancel();
    _pos.dispose();
    _open.dispose();
    super.dispose();
  }

  Duration _d(Duration d) => _reduceMotion ? Duration.zero : d;

  void _onOpenStatus(AnimationStatus status) {
    if (status.isCompleted || status.isDismissed) widget.controller?._notify();
  }

  // ---------------------------------------------------------------- motion

  void _jumpTo(int index) {
    _pos.stop();
    setState(() {
      _pos.value = index.toDouble();
      _active = index;
      _statIndex = index;
    });
    widget.controller?._notify();
  }

  void _snapTo(int target) {
    final t = target.clamp(0, _count - 1);
    _pos
        .animateTo(t.toDouble(), duration: _d(widget.motion.snap), curve: widget.motion.snapCurve)
        .orCancel
        .then((_) {
      if (mounted) _onSelected(t);
    }, onError: (Object _) {});
  }

  Future<void> _setOpen(double target) {
    return _open
        .animateTo(target, duration: _d(widget.motion.tuck), curve: widget.motion.tuckCurve)
        .orCancel
        .catchError((Object _) {});
  }

  void _onSelected(int index) {
    final action = widget.actions[index];
    setState(() {
      _active = index;
      _statIndex = index;
      _popTokens[index]++;
      if (widget.showToast) {
        _toastMessage = widget.toastMessageBuilder?.call(action) ?? '${action.label} opened';
        _toastVisible = true;
        _toastTimer?.cancel();
        _toastTimer = Timer(widget.motion.toastDwell, _hideToast);
      }
    });
    if (widget.enableHaptics) HapticFeedback.selectionClick();
    widget.onActionSelected?.call(action, index);
    widget.controller?._notify();
  }

  void _hideToast() {
    _toastTimer?.cancel();
    if (mounted && _toastVisible) setState(() => _toastVisible = false);
  }

  void _clearSelection() {
    if (_active == null && !_toastVisible) return;
    setState(() {
      _active = null;
      _toastVisible = false;
    });
    _toastTimer?.cancel();
  }

  // ------------------------------------------------------ controller hooks

  void _select(int index) {
    final i = index.clamp(0, _count - 1);
    if (_open.value < 0.5) _setOpen(1);
    _snapTo(i);
  }

  // -------------------------------------------------------------- gestures

  void _onTapItem(int index) {
    if (_open.value < 0.5) {
      _setOpen(1);
    } else {
      _snapTo(index);
    }
  }

  void _onTapBackground() {
    if (_open.value < 0.5) _setOpen(1);
  }

  void _onPanStart(DragStartDetails d) {
    _dragStart = d.globalPosition;
    _startPos = _pos.value;
    _startOpen = _open.value;
    _mode = null;
    _pos.stop();
    _open.stop();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final delta = d.globalPosition - _dragStart;
    if (_mode == null) {
      final arc = widget.arc;
      final slop = arc.dragSlop;
      if (delta.dx.abs() <= slop && delta.dy.abs() <= slop) return;
      // Along the axis spins; across it pulls. A tucked dial only pulls.
      final spin = arc.isHorizontal ? delta.dx.abs() : delta.dy.abs();
      final pull = arc.isHorizontal ? delta.dy.abs() : delta.dx.abs();
      _mode = (_open.value < 0.5 || pull > spin) ? _DragMode.pull : _DragMode.dial;
      if (_mode == _DragMode.dial) _clearSelection();
    }
    switch (_mode!) {
      case _DragMode.pull:
        final across = widget.arc.isHorizontal ? delta.dy : delta.dx;
        _open.value = (_startOpen - across / widget.arc.pullDistance).clamp(0.0, 1.0);
      case _DragMode.dial:
        final along = widget.arc.isHorizontal ? delta.dx : delta.dy;
        _pos.value = (_startPos - along / widget.arc.dialStep).clamp(0.0, _maxPos);
    }
  }

  void _onPanEnd(DragEndDetails d) {
    final mode = _mode;
    _mode = null;
    switch (mode) {
      case null:
        return;
      case _DragMode.pull:
        _settlePull();
      case _DragMode.dial:
        var target = _pos.value;
        final arc = widget.arc;
        final v = arc.isHorizontal
            ? d.velocity.pixelsPerSecond.dx
            : d.velocity.pixelsPerSecond.dy;
        // A light fling projection so quick flicks travel a little further.
        if (v.abs() > arc.flingVelocity) {
          target -= v / arc.dialStep * arc.flingProjection;
        }
        _snapTo(target.round());
    }
  }

  void _onPanCancel() {
    final mode = _mode;
    _mode = null;
    if (mode == _DragMode.pull) _settlePull();
    if (mode == _DragMode.dial) _snapTo(_pos.value.round());
  }

  void _settlePull() {
    final open = _open.value;
    final commit = widget.arc.pullCommit;
    final double target = (open - _startOpen > commit)
        ? 1
        : (_startOpen - open > commit)
            ? 0
            : open.roundToDouble();
    if (target == 0) _hideToast();
    _setOpen(target).then((_) {
      if (mounted && target == 1 && _active == null) _snapTo(_pos.value.round());
    });
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (e) {
      final scroll = e as PointerScrollEvent;
      final d = scroll.scrollDelta;
      final step = widget.arc.isHorizontal && d.dx != 0 ? d.dx : d.dy;
      if (step == 0) return;
      _pos.stop();
      _hideToast();
      if (_open.value < 0.5) {
        _setOpen(1);
        return;
      }
      _clearSelection();
      _snapTo(_pos.value.round() + (step > 0 ? 1 : -1));
    });
  }

  // ----------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    // An explicit theme wins, then one registered on ThemeData, and failing
    // both the shipped design picked by the ambient brightness, so the dial
    // follows the system setting without having to be wired up first.
    final themeData = Theme.of(context);
    final theme = widget.theme ??
        themeData.extension<AwesomeScrollActionsTheme>() ??
        (themeData.brightness == Brightness.dark
            ? AwesomeScrollActionsTheme.dark
            : const AwesomeScrollActionsTheme());
    final padding = MediaQuery.paddingOf(context);

    return Listener(
      onPointerSignal: _onPointerSignal,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onTap: _onTapBackground,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onPanCancel: _onPanCancel,
        child: ClipRect(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              return AnimatedBuilder(
                animation: Listenable.merge([_pos, _open]),
                builder: (context, _) => _buildStack(context, size, padding, theme),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Lets a horizontal pill paint outside its square slot: wider than the
  /// slot once its label unfurls, and taller as the label stacks above the
  /// icon. The slot itself stays centred on the arc point.
  Widget _overflowSlot(bool horizontal, Widget child) => horizontal
      ? OverflowBox(
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          alignment: Alignment.bottomCenter,
          child: child,
        )
      : child;

  /// Fits the stat card into the strip above a horizontal dial, anchored to
  /// the bottom of it and scaled down if the strip is shorter than the card.
  Widget _fitAboveDial(bool horizontal, Widget child) => horizontal
      ? FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.bottomLeft, child: child)
      : child;

  Widget _buildStack(
    BuildContext context,
    Size size,
    EdgeInsets padding,
    AwesomeScrollActionsTheme theme,
  ) {
    final arc = widget.arc;
    final motion = widget.motion;
    final m = theme.metrics;
    final open = _open.value;
    final pos = _pos.value;
    final center = arc.center(size);

    final placed = <(int, ArcPlacement)>[
      for (var i = 0; i < _count; i++)
        (i, arc.place(index: i, position: pos, openness: open, size: size)),
    ].where((e) => e.$2.opacity >= arc.visibilityCutoff).toList()
      ..sort((a, b) => b.$2.distance.compareTo(a.$2.distance));

    final stat = widget.actions[_statIndex].stat;

    // The stretch of circle the items actually occupy, so the guide can be
    // drawn as that arc instead of a full circle whose far side comes back
    // on screen. Vertical rides cos/sin, horizontal sin/cos, so the angle
    // a placement sits at differs by axis.
    final step = arc.resolveAngleStep(size);
    final phis = placed.map((e) => (e.$1 - pos) * step).toList();
    final loPhi = (phis.isEmpty ? 0.0 : phis.reduce(math.min)) - step * 0.6;
    final hiPhi = (phis.isEmpty ? 0.0 : phis.reduce(math.max)) + step * 0.6;
    final guideStart = arc.isHorizontal ? math.pi / 2 - hiPhi : loPhi;
    final guideSweep = hiPhi - loPhi;

    // Where each icon sits on that arc and how visible it is, so the guide
    // can be lit by the icons rather than painted a flat colour.
    final guideStops = [
      for (final (i, p) in placed)
        (
          arc.isHorizontal ? math.pi / 2 - (i - pos) * step : (i - pos) * step,
          p.opacity,
        ),
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    // Topmost edge the icons reach, used to keep the chrome off the dial.
    // Only items actually on screen count: the far ones ride high up the
    // circle but sit well outside it, and would shove the chrome off the top.
    final onScreen = placed.where((e) => e.$2.center.dx > 0 && e.$2.center.dx < size.width);
    final dialTop = onScreen.isEmpty
        ? size.height
        : onScreen.map((e) => e.$2.center.dy).reduce(math.min) - arc.itemSlot / 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dims what is behind the widget as the dial comes out, so the dial
        // reads as an overlay over the host content. It sits under the
        // design's own background, so it only shows through when
        // `showBackground` is off.
        if (m.scrimOpacity > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: theme.scrimColor
                    .withValues(alpha: theme.scrimColor.a * m.scrimOpacity * open),
              ),
            ),
          ),
        if (widget.showBackground)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.backgroundTop, theme.backgroundBottom],
                ),
              ),
            ),
          ),
        if (widget.showGuideLine)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                key: const ValueKey('qa-guide'),
                painter: _GuidePainter(
                  center: center,
                  radius: arc.resolveRadius(size),
                  color: theme.guideColor,
                  strokeWidth: m.guideStroke,
                  startAngle: guideStart,
                  sweepAngle: guideSweep,
                  stops: guideStops,
                ),
              ),
            ),
          ),

        for (final (i, p) in placed)
          Positioned(
            key: ValueKey('qa-${widget.actions[i].id}'),
            // A vertical pill pins its right edge to the arc point and grows
            // left, so its slot is left unconstrained. A horizontal one keeps
            // a square slot centred on the arc point and overflows out of it,
            // because its width is not known until the label lays out. That
            // keeps the hit target on the icon either way.
            right: arc.isHorizontal ? null : size.width - (p.center.dx + arc.itemSlot / 2),
            left: arc.isHorizontal ? p.center.dx - arc.itemSlot / 2 : null,
            top: arc.isHorizontal ? null : p.center.dy - arc.itemSlot / 2,
            bottom: arc.isHorizontal ? size.height - (p.center.dy + arc.itemSlot / 2) : null,
            width: arc.isHorizontal ? arc.itemSlot : null,
            height: arc.itemSlot,
            child: _overflowSlot(
              arc.isHorizontal,
              Opacity(
                opacity: p.opacity,
                child: Align(
                  alignment: arc.isHorizontal ? Alignment.bottomCenter : Alignment.centerRight,
                  // Shrink-wrap both ways, or the slot expands to fill the
                  // stack and the pill stops sitting on its arc point.
                  widthFactor: 1,
                  heightFactor: arc.isHorizontal ? 1 : null,
                  child: _DialItem(
                    action: widget.actions[i],
                    active: i == _active,
                    scale: p.scale,
                    popToken: _popTokens[i],
                    theme: theme,
                    arc: arc,
                    motion: motion,
                    reduceMotion: _reduceMotion,
                    compact: arc.isCompact(size),
                    onTap: () => _onTapItem(i),
                    builder: widget.pillBuilder,
                  ),
                ),
              ),
            ),
          ),

        if (widget.showBackground) ...[
          Positioned(
            top: 0, left: 0, right: 0, height: padding.top + m.topFadeHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.56, 1],
                    colors: [
                      theme.backgroundTop,
                      theme.backgroundTop,
                      theme.backgroundTop.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0, height: padding.bottom + m.bottomFadeHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.72, 1],
                    colors: [
                      theme.backgroundBottom.withValues(alpha: 0),
                      theme.backgroundBottom,
                      theme.backgroundBottom,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],

        if (widget.title != null || widget.subtitle != null)
          Positioned(
            top: padding.top + m.headerTop,
            left: m.headerInset,
            right: m.headerInset,
            child: IgnorePointer(
              child: widget.headerBuilder?.call(context, widget.title, widget.subtitle) ??
                  _Header(title: widget.title, subtitle: widget.subtitle, theme: theme),
            ),
          ),

        if (widget.showStats)
          Positioned(
            // A vertical dial leaves the whole left column free, so the card
            // just hangs from the top. A horizontal one owns the bottom band,
            // so the card gets the strip between the header and the icons and
            // sits at the bottom of it. On a short screen that strip is
            // smaller than the card, so it scales down rather than growing up
            // into the header.
            top: padding.top + (arc.isHorizontal ? m.statTopHorizontal : m.statTop),
            bottom: arc.isHorizontal
                ? math.max(0, size.height - dialTop + m.statGapAboveDial)
                : null,
            left: m.statLeft,
            child: Opacity(
              opacity: m.statTuckedOpacity + (1 - m.statTuckedOpacity) * open,
              child: _fitAboveDial(
                arc.isHorizontal,
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: m.statMaxWidth),
                  child: AnimatedSwitcher(
                  duration: _d(motion.statSwitch),
                  switchInCurve: motion.statCurve,
                  switchOutCurve: motion.statCurve,
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topLeft,
                    children: [...previous, ?current],
                  ),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(begin: motion.statSlide, end: Offset.zero).animate(animation),
                      child: child,
                    ),
                  ),
                  child: stat == null
                      ? SizedBox.shrink(key: ValueKey('stat-none-$_statIndex'))
                      : widget.statBuilder?.call(
                            context,
                            widget.actions[_statIndex],
                            stat,
                          ) ??
                          _StatCard(
                            key: ValueKey('stat-$_statIndex'),
                            stat: stat,
                            theme: theme,
                            onTap: widget.onStatTap == null
                                ? null
                                : () => widget.onStatTap!(widget.actions[_statIndex], _statIndex),
                          ),
                  ),
                ),
              ),
            ),
          ),

        Positioned(
          right: arc.isHorizontal ? null : 0,
          bottom: arc.isHorizontal ? 0 : null,
          left: arc.isHorizontal ? center.dx - m.handleHeight / 2 : null,
          top: arc.isHorizontal ? null : center.dy - m.handleHeight / 2,
          width: arc.isHorizontal ? m.handleHeight : m.handleSlotWidth,
          height: arc.isHorizontal ? m.handleSlotWidth : m.handleHeight,
          child: IgnorePointer(
            ignoring: open > 0.6,
            child: Opacity(
              opacity: math.pow(1 - open, 1.2).toDouble(),
              child: Transform.translate(
                offset: arc.isHorizontal
                    ? Offset(0, open * m.handleSlotWidth)
                    : Offset(open * m.handleSlotWidth, 0),
                child: widget.handleBuilder?.call(context, () => _setOpen(1)) ??
                    _PullHandle(theme: theme, arc: arc, onTap: () => _setOpen(1)),
              ),
            ),
          ),
        ),

        if (widget.showToast)
          Positioned(
            left: 0,
            right: 0,
            // A horizontal dial occupies the bottom, so lift the toast clear.
            bottom: arc.isHorizontal
                ? padding.bottom + arc.bottomInset + arc.itemSlot + m.toastBottom
                : padding.bottom + m.toastBottom,
            child: IgnorePointer(
              child: Center(
                child: AnimatedSlide(
                  offset: _toastVisible ? Offset.zero : motion.toastSlide,
                  duration: _d(motion.toast),
                  curve: motion.toastCurve,
                  child: AnimatedOpacity(
                    opacity: _toastVisible ? 1 : 0,
                    duration: _d(motion.toast),
                    curve: motion.toastCurve,
                    child: widget.toastBuilder?.call(context, _toastMessage) ??
                        _Toast(message: _toastMessage, theme: theme),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
