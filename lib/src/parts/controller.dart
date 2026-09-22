part of '../awesome_scroll_actions.dart';

/// Drives a [AwesomeScrollActions] from outside, and reports its state.
///
/// Listeners fire when a selection settles and when the dial finishes
/// opening or tucking.
class QuickActionsController extends ChangeNotifier {
  _AwesomeScrollActionsState? _state;

  bool get isAttached => _state != null;

  /// Currently selected index, or null while the dial is spinning.
  int? get selectedIndex => _state?._active;

  QuickAction? get selectedAction {
    final s = _state;
    final i = s?._active;
    return (s == null || i == null) ? null : s.widget.actions[i];
  }

  bool get isOpen => (_state?._open.value ?? 0) >= 0.5;

  /// Animate to [index], opening the dial first if it is tucked.
  void select(int index) => _state?._select(index);

  /// Animate to the action with [id]. Returns false if no action matches.
  bool selectById(String id) {
    final s = _state;
    if (s == null) return false;
    final i = s._indexOf(id);
    if (i == null) return false;
    s._select(i);
    return true;
  }

  void open() => _state?._setOpen(1);
  void tuck() => _state?._setOpen(0);
  void toggle() => isOpen ? tuck() : open();

  void _attach(_AwesomeScrollActionsState state) {
    assert(_state == null || _state == state,
        'A QuickActionsController can only drive one AwesomeScrollActions at a time.');
    _state = state;
  }

  void _detach(_AwesomeScrollActionsState state) {
    if (_state == state) _state = null;
  }

  void _notify() => notifyListeners();
}
