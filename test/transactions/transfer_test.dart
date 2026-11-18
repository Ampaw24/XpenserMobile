import 'package:expenser/core/utils/formatters/transaction_display.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/account_type.dart';
import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/models/transfer_validation.dart';
import 'package:flutter_test/flutter_test.dart';

AccountModel _account(String id, {String currency = 'GHS'}) => AccountModel(
  id: id,
  name: 'Account $id',
  type: AccountType.cash,
  initialBalance: 0,
  currencyCode: currency,
  colorHex: 'FF000000',
  iconCodePoint: 0,
  createdAt: DateTime.utc(2026),
);

TransactionModel _transaction(
  TransactionType type, {
  String categoryId = 'food',
  String? toAccountId,
}) => TransactionModel(
  id: 't1',
  amount: 100,
  type: type,
  categoryId: categoryId,
  accountId: 'a',
  toAccountId: toAccountId,
  date: DateTime.utc(2026),
  createdAt: DateTime.utc(2026),
);

void main() {
  group('validateTransfer', () {
    final from = _account('a');

    test('accepts a different account in the same currency', () {
      expect(validateTransfer(from: from, to: _account('b')), isNull);
    });

    test('requires a destination', () {
      expect(
        validateTransfer(from: from, to: null),
        TransferError.missingDestination,
      );
    });

    test('rejects transferring into the same account', () {
      expect(
        validateTransfer(from: from, to: _account('a')),
        TransferError.sameAccount,
      );
    });

    test('rejects accounts in different currencies', () {
      expect(
        validateTransfer(from: from, to: _account('b', currency: 'USD')),
        TransferError.currencyMismatch,
      );
    });
  });

  group('transactionDisplay', () {
    final accounts = [_account('a'), _account('b')];

    test('labels transfers by source and destination account', () {
      final display = transactionDisplay(
        _transaction(
          TransactionType.transfer,
          categoryId: TransactionModel.transferCategoryId,
          toAccountId: 'b',
        ),
        accounts: accounts,
      );
      expect(display.title, 'Account a → Account b');
    });

    test('marks a missing transfer account as unknown', () {
      final display = transactionDisplay(
        _transaction(TransactionType.transfer, toAccountId: 'gone'),
        accounts: accounts,
      );
      expect(display.title, 'Account a → Unknown account');
    });

    test('labels other transactions by category', () {
      final category = CategoryModel(
        id: 'food',
        name: 'Food & Dining',
        iconCodePoint: 1,
        colorHex: 'FFEF5350',
        transactionType: TransactionType.expense,
      );
      final display = transactionDisplay(
        _transaction(TransactionType.expense),
        category: category,
      );
      expect(display.title, 'Food & Dining');
      expect(display.colorHex, 'FFEF5350');
      expect(display.iconCodePoint, 1);
    });

    test('falls back when the category is missing', () {
      expect(
        transactionDisplay(_transaction(TransactionType.expense)).title,
        'Unknown',
      );
    });
  });
}
