import 'package:expenser/core/constants/icon_registry.dart';
import 'package:expenser/core/utils/extensions/color_extensions.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_option_sheet.dart';
import 'package:expenser/models/account_model.dart';
import 'package:flutter/material.dart';

/// Accounts that can fund a goal. Goals are tracked in the user's preferred
/// currency, so only accounts in that currency qualify (no conversion).
List<AccountModel> savingsFundingAccounts(
  List<AccountModel> accounts,
  String goalCurrency,
) => accounts.where((a) => a.currencyCode == goalCurrency).toList();

/// [preferredId] if it is still eligible, otherwise the first eligible one.
AccountModel? resolveFundingAccount(
  List<AccountModel> eligible,
  String? preferredId,
) {
  for (final account in eligible) {
    if (account.id == preferredId) return account;
  }
  return eligible.isEmpty ? null : eligible.first;
}

Future<String?> pickFundingAccount(
  BuildContext context, {
  required List<AccountModel> eligible,
  String? selectedId,
}) {
  final palette = context.palette;
  return showAppOptionSheet<String>(
    context,
    title: 'Pay from',
    selected: selectedId,
    options: [
      for (final account in eligible)
        AppSelectOption(
          value: account.id,
          label: account.name,
          subtitle: account.currencyCode,
          icon: IconRegistry.account(account.iconCodePoint),
          color: colorFromHex(account.colorHex, fallback: palette.accent),
        ),
    ],
  );
}
