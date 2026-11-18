import 'package:expenser/core/providers/sync_version_provider.dart';
import 'package:expenser/data/repositories/account_repository.dart';
import 'package:expenser/data/repositories/transaction_repository.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/services/firebase_user_data_service.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountState {
  final List<AccountModel> accounts;
  final Map<String, double> balances;

  const AccountState({this.accounts = const [], this.balances = const {}});

  AccountState copyWith({
    List<AccountModel>? accounts,
    Map<String, double>? balances,
  }) => AccountState(
    accounts: accounts ?? this.accounts,
    balances: balances ?? this.balances,
  );
}

class AccountNotifier extends Notifier<AccountState> {
  @override
  AccountState build() {
    ref.watch(syncVersionProvider);
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
    return txs.fold(initial, (sum, t) => sum + t.balanceEffectOn(accountId));
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
    _mirror((svc, uid) => svc.saveAccount(uid, account));
  }

  Future<void> updateAccount(AccountModel account) async {
    await ref.read(accountRepositoryProvider).update(account);
    refresh();
    _mirror((svc, uid) => svc.saveAccount(uid, account));
  }

  Future<void> deleteAccount(String id) async {
    await ref.read(accountRepositoryProvider).delete(id);
    refresh();
    _mirror((svc, uid) => svc.deleteAccount(uid, id));
  }

  void _mirror(
    Future<void> Function(FirebaseUserDataService svc, String uid) fn,
  ) {
    final uid = ref.read(settingsProvider).uid;
    if (uid == null) return;
    fn(
      ref.read(firebaseUserDataServiceProvider),
      uid,
    ).catchError((e) => debugPrint('RTDB account: $e'));
  }
}

final accountProvider = NotifierProvider<AccountNotifier, AccountState>(
  AccountNotifier.new,
);
