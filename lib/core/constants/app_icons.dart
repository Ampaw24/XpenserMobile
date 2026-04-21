import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Centralised icon map — swap any HugeIcons name here, nowhere else.
class AppIcons {
  AppIcons._();

  // ── Navigation ────────────────────────────────────────────────────────────
  static const IconData navHome         = HugeIcons.strokeRoundedHome01;
  static const IconData navTransactions = HugeIcons.strokeRoundedTransaction;
  static const IconData navBudgets      = HugeIcons.strokeRoundedPieChart01;
  static const IconData navAccounts     = HugeIcons.strokeRoundedWallet01;
  static const IconData navSettings     = HugeIcons.strokeRoundedSettings01;

  // ── Actions ───────────────────────────────────────────────────────────────
  static const IconData add             = HugeIcons.strokeRoundedAdd01;
  static const IconData transfer        = HugeIcons.strokeRoundedExchange01;
  static const IconData analytics       = HugeIcons.strokeRoundedAnalytics01;
  static const IconData savings         = HugeIcons.strokeRoundedSavings;

  // ── Status / Indicators ───────────────────────────────────────────────────
  static const IconData arrowUp         = HugeIcons.strokeRoundedArrowUp01;
  static const IconData arrowDown       = HugeIcons.strokeRoundedArrowDown01;
  static const IconData bell            = HugeIcons.strokeRoundedNotification01;
  static const IconData emptyState      = HugeIcons.strokeRoundedInvoice01;
  static const IconData edit            = HugeIcons.strokeRoundedPencilEdit01;
  static const IconData delete          = HugeIcons.strokeRoundedDelete02;
}
