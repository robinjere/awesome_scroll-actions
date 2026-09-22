import 'package:flutter/material.dart';

import 'icons.dart';
import 'models.dart';

/// The ten actions and sample figures from the shipped design.
abstract final class AwesomeScrollDefaults {
  static const String initialActionId = 'scan_pay';

  static const List<QuickAction> actions = [
    QuickAction(
      id: 'send_money', label: 'Send Money', icon: AwesomeScrollIcons.arrowUp,
      stat: QuickActionStat(label: 'Sent this month', value: 'TZS 412,500', caption: '12 transfers'),
    ),
    QuickAction(
      id: 'request', label: 'Request', icon: AwesomeScrollIcons.arrowDown,
      stat: QuickActionStat(label: 'Pending requests', value: 'TZS 96,000', caption: '3 awaiting'),
    ),
    QuickAction(
      id: 'pay_bills', label: 'Pay Bills', icon: AwesomeScrollIcons.flash,
      stat: QuickActionStat(label: 'Bills due this week', value: 'TZS 184,200', caption: 'LUKU \u2022 DSTV'),
    ),
    QuickAction(
      id: 'buy_airtime', label: 'Buy Airtime', icon: AwesomeScrollIcons.mobile,
      stat: QuickActionStat(label: 'Airtime this month', value: 'TZS 24,000', caption: '2 numbers'),
    ),
    QuickAction(
      id: 'scan_pay', label: 'Scan & Pay', icon: AwesomeScrollIcons.scan,
      stat: QuickActionStat(label: 'Last scan', value: 'TZS 8,500', caption: 'Kariakoo Market'),
    ),
    QuickAction(
      id: 'withdraw', label: 'Withdraw', icon: AwesomeScrollIcons.moneyChange,
      stat: QuickActionStat(label: 'Withdrawn in June', value: 'TZS 150,000', caption: '2 agent visits'),
    ),
    QuickAction(
      id: 'statements', label: 'Statements', icon: AwesomeScrollIcons.barGraph,
      stat: QuickActionStat(label: 'June transactions', value: '148', caption: 'TZS 1.2M volume'),
    ),
    QuickAction(
      id: 'cards', label: 'Cards', icon: AwesomeScrollIcons.bankCard,
      stat: QuickActionStat(label: 'Card spend', value: 'TZS 236,400', caption: 'Visa \u2022\u2022 4821'),
    ),
    QuickAction(
      id: 'top_up', label: 'Top Up', icon: AwesomeScrollIcons.addCircle,
      stat: QuickActionStat(label: 'Wallet top-ups', value: 'TZS 300,000', caption: '3 deposits'),
    ),
    QuickAction(
      id: 'add_shortcut', label: 'Add shortcut', icon: Icons.add_rounded,
      stat: QuickActionStat(label: 'Shortcuts', value: '9 active', caption: 'Tap to customize'),
    ),
  ];
}
