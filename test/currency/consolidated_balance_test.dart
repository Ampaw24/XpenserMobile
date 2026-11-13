import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/account_type.dart';
import 'package:expenser/models/consolidated_balance.dart';
import 'package:expenser/models/exchange_rates.dart';
import 'package:flutter_test/flutter_test.dart';

AccountModel _account(String id, String currency) => AccountModel(
  id: id,
  name: id,
  type: AccountType.cash,
  initialBalance: 0,
  currencyCode: currency,
  colorHex: '#000000',
  iconCodePoint: 0,
  createdAt: DateTime.utc(2026),
);

final _rates = ExchangeRates(
  base: 'USD',
  rates: const {'GHS': 15.0, 'EUR': 0.9},
  updatedAt: DateTime.utc(2026, 11, 13, 9),
  fetchedAt: DateTime.utc(2026, 11, 13, 9),
);

void main() {
  test('single-currency totals need no rates and are exact', () {
    final balance = ConsolidatedBalance.compute(
      accounts: [_account('a', 'GHS'), _account('b', 'GHS')],
      balances: {'a': 100, 'b': 50.5},
      currency: 'GHS',
    );
    expect(balance.total, 150.5);
    expect(balance.isEstimate, isFalse);
    expect(balance.ratesUpdatedAt, isNull);
  });

  test('converts foreign balances into the display currency', () {
    final balance = ConsolidatedBalance.compute(
      accounts: [
        _account('a', 'GHS'),
        _account('b', 'USD'),
        _account('c', 'EUR'),
      ],
      balances: {'a': 100, 'b': 10, 'c': 9},
      currency: 'GHS',
      rates: _rates,
    );
    // 100 GHS + 10 USD * 15 + 9 EUR * (15 / 0.9)
    expect(balance.total, closeTo(400, 1e-9));
    expect(balance.convertedCurrencies, {'USD', 'EUR'});
    expect(balance.ratesUpdatedAt, _rates.updatedAt);
  });

  test('excludes currencies without a rate instead of adding raw values', () {
    final balance = ConsolidatedBalance.compute(
      accounts: [_account('a', 'GHS'), _account('b', 'USD')],
      balances: {'a': 100, 'b': 10},
      currency: 'GHS',
    );
    expect(balance.total, 100);
    expect(balance.unconverted, {'USD': 10});
    expect(balance.isPartial, isTrue);
  });

  test('marks stale only when a conversion actually used the rates', () {
    final balance = ConsolidatedBalance.compute(
      accounts: [_account('a', 'GHS')],
      balances: {'a': 1},
      currency: 'GHS',
      rates: _rates,
      ratesStale: true,
    );
    expect(balance.ratesStale, isFalse);
  });
}
