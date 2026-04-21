import 'package:expenser/data/repositories/account_repository.dart';
import 'package:expenser/data/repositories/transaction_repository.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountState {
  final List<AccountModel> accounts;
  final Map<String, double> balances;

  const AccountState({
    this.accounts = const [],
    this.balances = const {},
  });

  AccountState copyWith({
    List<AccountModel>? accounts,
    Map<String, double>? balances,
  }) =>
      AccountState(
        accounts: accounts ?? this.accounts,
        balances: balances ?? this.balances,
      );
}

class AccountNotifier extends Notifier<AccountState> {
  @override
  AccountState build() {
    final accounts = ref.read(accountRepositoryProvider).getAll();
    final balances = <String, double>{};
    for (final a in accounts) {
      balances[a.id] = _computeBalance(a.id, a.initialBalance);
    }
    return AccountState(accounts: accounts, balances: balances);
  }

  double _computeBalance(String accountId, double initial) {
    final txRepo = ref.read(transactionRepositoryProvider);
    final txs = txRepo.getByAccount(accountId);
    double balance = initial;
    for (final t in txs) {
      if (t.type == TransactionType.income && t.accountId == accountId) {
        balance += t.amount;
      } else if (t.type == TransactionType.expense && t.accountId == accountId) {
        balance -= t.amount;
      } else if (t.type == TransactionType.transfer) {
        if (t.accountId == accountId) balance -= t.amount;
        if (t.toAccountId == accountId) balance += t.amount;
      }
    }
    return balance;
  }

  void refresh() {
    final accounts = ref.read(accountRepositoryProvider).getAll();
    final balances = <String, double>{};
    for (final a in accounts) {
      balances[a.id] = _computeBalance(a.id, a.initialBalance);
    }
    state = AccountState(accounts: accounts, balances: balances);
  }

  Future<void> addAccount(AccountModel account) async {
    await ref.read(accountRepositoryProvider).add(account);
    refresh();
  }

  Future<void> updateAccount(AccountModel account) async {
    await ref.read(accountRepositoryProvider).update(account);
    refresh();
  }

  Future<void> deleteAccount(String id) async {
    await ref.read(accountRepositoryProvider).delete(id);
    refresh();
  }

  double get totalBalance =>
      state.balances.values.fold(0.0, (a, b) => a + b);
}

final accountProvider =
    NotifierProvider<AccountNotifier, AccountState>(AccountNotifier.new);
