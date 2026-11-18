import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:flutter/material.dart';

typedef TransactionDisplay =
    ({String title, String colorHex, int iconCodePoint});

const _fallbackColorHex = 'FF78909C';
const _transferColorHex = 'FF42A5F5';

/// List title, color and icon for [transaction]: transfers are labelled
/// "From → To" by account, everything else by its category.
TransactionDisplay transactionDisplay(
  TransactionModel transaction, {
  CategoryModel? category,
  List<AccountModel> accounts = const [],
}) {
  if (transaction.type == TransactionType.transfer) {
    String accountName(String? id) {
      for (final account in accounts) {
        if (account.id == id) return account.name;
      }
      return 'Unknown account';
    }

    return (
      title:
          '${accountName(transaction.accountId)} → '
          '${accountName(transaction.toAccountId)}',
      colorHex: _transferColorHex,
      iconCodePoint: Icons.swap_horiz_rounded.codePoint,
    );
  }
  return (
    title: category?.name ?? 'Unknown',
    colorHex: category?.colorHex ?? _fallbackColorHex,
    iconCodePoint: category?.iconCodePoint ?? Icons.category_rounded.codePoint,
  );
}
