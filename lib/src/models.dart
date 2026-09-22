import 'package:flutter/widgets.dart';

/// Summary figure shown in the stat card while an action is selected.
@immutable
class QuickActionStat {
  const QuickActionStat({required this.label, required this.value, this.caption});

  /// Small heading, e.g. "Last scan".
  final String label;

  /// Headline figure, e.g. "TZS 8,500".
  final String value;

  /// Optional pill underneath, e.g. "Kariakoo Market".
  final String? caption;
}

/// One entry on the dial.
@immutable
class QuickAction {
  const QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    this.stat,
    this.semanticLabel,
  });

  /// Stable identifier used for selection and widget keys.
  final String id;

  /// Text revealed inside the pill when the action is centred.
  final String label;

  final IconData icon;

  /// Shown in the stat card when this action is selected. Null hides the card.
  final QuickActionStat? stat;

  /// Screen-reader label. Defaults to [label].
  final String? semanticLabel;
}
