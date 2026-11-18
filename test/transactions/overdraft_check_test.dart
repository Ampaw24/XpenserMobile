import 'package:expenser/models/overdraft_check.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionModel _tx(
  TransactionType type,
  double amount, {
  String accountId = 'a',
  String? toAccountId,
}) => TransactionModel(
  id: 't1',
  amount: amount,
  type: type,
  categoryId: 'c',
  accountId: accountId,
  toAccountId: toAccountId,
  date: DateTime.utc(2026),
  createdAt: DateTime.utc(2026),
);

void main() {
  group('balanceEffectOn', () {
    test('income adds and expense subtracts on their own account only', () {
      expect(_tx(TransactionType.income, 50).balanceEffectOn('a'), 50);
      expect(_tx(TransactionType.expense, 50).balanceEffectOn('a'), -50);
      expect(_tx(TransactionType.expense, 50).balanceEffectOn('b'), 0);
    });

    test('transfer moves money from source to destination', () {
      final transfer = _tx(TransactionType.transfer, 30, toAccountId: 'b');
      expect(transfer.balanceEffectOn('a'), -30);
      expect(transfer.balanceEffectOn('b'), 30);
      expect(transfer.balanceEffectOn('c'), 0);
    });
  });

  group('overdraftAfter', () {
    test('allows spending within the balance, down to exactly zero', () {
      expect(
        overdraftAfter(
          currentBalance: 100,
          updated: _tx(TransactionType.expense, 100),
        ),
        isNull,
      );
    });

    test('returns the negative balance a new expense would leave', () {
      expect(
        overdraftAfter(
          currentBalance: 100,
          updated: _tx(TransactionType.expense, 150),
        ),
        -50,
      );
    });

    test('warns for transfers out of the source account', () {
      expect(
        overdraftAfter(
          currentBalance: 20,
          updated: _tx(TransactionType.transfer, 50, toAccountId: 'b'),
        ),
        -30,
      );
    });

    test('never warns for income', () {
      expect(
        overdraftAfter(
          currentBalance: -40,
          updated: _tx(TransactionType.income, 10),
        ),
        isNull,
      );
    });

    test('only checks the increase when editing an expense', () {
      // Balance 20 already reflects the stored 100 expense.
      expect(
        overdraftAfter(
          currentBalance: 20,
          previous: _tx(TransactionType.expense, 100),
          updated: _tx(TransactionType.expense, 110),
        ),
        isNull,
      );
      expect(
        overdraftAfter(
          currentBalance: 20,
          previous: _tx(TransactionType.expense, 100),
          updated: _tx(TransactionType.expense, 130),
        ),
        -10,
      );
    });

    test('does not warn when reducing spend on an overdrawn account', () {
      expect(
        overdraftAfter(
          currentBalance: -50,
          previous: _tx(TransactionType.expense, 100),
          updated: _tx(TransactionType.expense, 80),
        ),
        isNull,
      );
    });

    test('checks the new account in full when an expense is moved', () {
      expect(
        overdraftAfter(
          currentBalance: 40,
          previous: _tx(TransactionType.expense, 60, accountId: 'b'),
          updated: _tx(TransactionType.expense, 60),
        ),
        -20,
      );
    });
  });
}
