import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/widgets/app_feedback_dialog.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/overdraft_check.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/core/utils/formatters/money.dart';
import 'package:flutter/material.dart';

/// Asks before saving [updated] would leave [account] below zero. Lets the
/// user save anyway: the balance may be missing income, and blocking would
/// push them to record spending inaccurately.
Future<bool> confirmOverdraftIfNeeded(
  BuildContext context, {
  required AccountModel account,
  required double? currentBalance,
  required TransactionModel updated,
  TransactionModel? previous,
}) async {
  if (currentBalance == null) return true;
  final projected = overdraftAfter(
    currentBalance: currentBalance,
    updated: updated,
    previous: previous,
  );
  if (projected == null) return true;
  final formatted = formatMoney(projected, account.currencyCode);
  return AppDialogs.confirm(
    context,
    title: 'Balance Will Go Negative',
    message:
        'This leaves ${account.name} at $formatted. '
        'Your balance may be missing some income.',
    confirmText: 'Save Anyway',
    cancelText: 'Edit Amount',
    icon: AppIcons.warning,
  );
}
