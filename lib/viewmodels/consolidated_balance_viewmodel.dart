import 'package:expenser/models/consolidated_balance.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/exchange_rates_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Total balance across all accounts in the user's preferred currency.
/// Rates are only loaded when an account uses a different currency.
final consolidatedBalanceProvider = Provider<ConsolidatedBalance>((ref) {
  final accountState = ref.watch(accountProvider);
  final currency = ref.watch(
    settingsProvider.select((s) => s.preferredCurrency),
  );

  final needsRates = accountState.accounts.any(
    (account) => account.currencyCode != currency,
  );
  final rates = needsRates ? ref.watch(exchangeRatesProvider) : null;

  return ConsolidatedBalance.compute(
    accounts: accountState.accounts,
    balances: accountState.balances,
    currency: currency,
    rates: rates?.rates,
    ratesStale: rates?.isStale ?? false,
  );
});
