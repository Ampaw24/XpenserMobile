import 'package:expenser/models/transaction_model.dart';

/// Balance the source account of [updated] would be left with, or null when
/// saving it would not push that account below zero.
///
/// [previous] is the stored version when editing; its effect is reversed
/// first so only the change is checked. Accounts already below zero only
/// warn when the change makes them lower still.
double? overdraftAfter({
  required double currentBalance,
  required TransactionModel updated,
  TransactionModel? previous,
}) {
  final accountId = updated.accountId;
  final projected =
      currentBalance -
      (previous?.balanceEffectOn(accountId) ?? 0) +
      updated.balanceEffectOn(accountId);
  return projected < 0 && projected < currentBalance ? projected : null;
}
