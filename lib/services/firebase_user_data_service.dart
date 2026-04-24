import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/models/recurring_rule_model.dart';

class SyncPayload {
  final List<AccountModel> accounts;
  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;
  final List<BudgetModel> budgets;
  final List<SavingsGoalModel> savingsGoals;
  final List<RecurringRuleModel> recurringRules;

  const SyncPayload({
    this.accounts = const [],
    this.transactions = const [],
    this.categories = const [],
    this.budgets = const [],
    this.savingsGoals = const [],
    this.recurringRules = const [],
  });

  factory SyncPayload.empty() => const SyncPayload();

  bool get isEmpty =>
      accounts.isEmpty && transactions.isEmpty && categories.isEmpty;
}

class FirebaseUserDataService {
  DatabaseReference _col(String uid, String collection) =>
      FirebaseDatabase.instance.ref('users/$uid/$collection');

  // ─── Bulk fetch (single round trip) ──────────────────────────────────────

  Future<SyncPayload> fetchAll(String uid) async {
    final snap =
        await FirebaseDatabase.instance.ref('users/$uid').get();
    if (!snap.exists || snap.value == null) return SyncPayload.empty();

    final data = Map<String, dynamic>.from(snap.value as Map);

    List<T> parse<T>(
        String key, T Function(Map<String, dynamic>) fromMap) {
      final node = data[key];
      if (node == null) return [];
      return (node as Map)
          .values
          .map((v) => fromMap(Map<String, dynamic>.from(v as Map)))
          .toList();
    }

    return SyncPayload(
      accounts: parse('accounts', AccountModel.fromMap),
      transactions: parse('transactions', TransactionModel.fromMap),
      categories: parse('categories', CategoryModel.fromMap),
      budgets: parse('budgets', BudgetModel.fromMap),
      savingsGoals: parse('savings_goals', SavingsGoalModel.fromMap),
      recurringRules:
          parse('recurring_rules', RecurringRuleModel.fromMap),
    );
  }

  // ─── Seed initial data for new users ─────────────────────────────────────

  Future<void> seedToRTDB(
    String uid, {
    required List<AccountModel> accounts,
    required List<CategoryModel> categories,
  }) async {
    final batch = <String, dynamic>{};
    for (final a in accounts) {
      batch['users/$uid/accounts/${a.id}'] = a.toMap();
    }
    for (final c in categories) {
      batch['users/$uid/categories/${c.id}'] = c.toMap();
    }
    if (batch.isNotEmpty) {
      await FirebaseDatabase.instance.ref().update(batch);
    }
  }

  // ─── Accounts ─────────────────────────────────────────────────────────────

  Future<void> saveAccount(String uid, AccountModel a) =>
      _col(uid, 'accounts').child(a.id).set(a.toMap());

  Future<void> deleteAccount(String uid, String id) =>
      _col(uid, 'accounts').child(id).remove();

  // ─── Transactions ─────────────────────────────────────────────────────────

  Future<void> saveTransaction(String uid, TransactionModel t) =>
      _col(uid, 'transactions').child(t.id).set(t.toMap());

  Future<void> deleteTransaction(String uid, String id) =>
      _col(uid, 'transactions').child(id).remove();

  // ─── Categories ───────────────────────────────────────────────────────────

  Future<void> saveCategory(String uid, CategoryModel c) =>
      _col(uid, 'categories').child(c.id).set(c.toMap());

  Future<void> deleteCategory(String uid, String id) =>
      _col(uid, 'categories').child(id).remove();

  // ─── Budgets ──────────────────────────────────────────────────────────────

  Future<void> saveBudget(String uid, BudgetModel b) =>
      _col(uid, 'budgets').child(b.id).set(b.toMap());

  Future<void> deleteBudget(String uid, String id) =>
      _col(uid, 'budgets').child(id).remove();

  // ─── Savings Goals ────────────────────────────────────────────────────────

  Future<void> saveSavingsGoal(String uid, SavingsGoalModel g) =>
      _col(uid, 'savings_goals').child(g.id).set(g.toMap());

  Future<void> deleteSavingsGoal(String uid, String id) =>
      _col(uid, 'savings_goals').child(id).remove();

  // ─── Recurring Rules ──────────────────────────────────────────────────────

  Future<void> saveRecurringRule(String uid, RecurringRuleModel r) =>
      _col(uid, 'recurring_rules').child(r.id).set(r.toMap());

  Future<void> deleteRecurringRule(String uid, String id) =>
      _col(uid, 'recurring_rules').child(id).remove();
}

final firebaseUserDataServiceProvider =
    Provider<FirebaseUserDataService>((ref) => FirebaseUserDataService());
