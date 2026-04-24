import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseTotalBalanceProvider = StreamProvider.autoDispose<double>((ref) {
  final uid = ref.watch(settingsProvider.select((s) => s.uid));
  if (uid == null) return Stream.value(0.0);

  return FirebaseDatabase.instance.ref('users/$uid').onValue.map((event) {
    if (!event.snapshot.exists || event.snapshot.value == null) return 0.0;

    final data = Map<String, dynamic>.from(event.snapshot.value as Map);

    final accountsNode = data['accounts'] as Map?;
    if (accountsNode == null) return 0.0;

    final accounts = accountsNode.values
        .map((v) => AccountModel.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList();

    final txNode = data['transactions'] as Map?;
    final transactions = txNode == null
        ? <TransactionModel>[]
        : txNode.values
            .map((v) =>
                TransactionModel.fromMap(Map<String, dynamic>.from(v as Map)))
            .toList();

    double total = 0.0;
    for (final account in accounts) {
      double balance = account.initialBalance;
      for (final tx in transactions) {
        if (tx.type == TransactionType.income && tx.accountId == account.id) {
          balance += tx.amount;
        } else if (tx.type == TransactionType.expense &&
            tx.accountId == account.id) {
          balance -= tx.amount;
        } else if (tx.type == TransactionType.transfer) {
          if (tx.accountId == account.id) balance -= tx.amount;
          if (tx.toAccountId == account.id) balance += tx.amount;
        }
      }
      total += balance;
    }
    return total;
  });
});
