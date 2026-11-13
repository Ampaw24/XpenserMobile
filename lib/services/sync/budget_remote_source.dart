import 'package:expenser/models/budget_model.dart';

/// Server-side store that is the source of truth for budgets.
abstract interface class BudgetRemoteSource {
  /// Emits the user's full budget list on every server or local change.
  Stream<List<BudgetModel>> watchBudgets(String uid);

  /// Emits true whenever the app (re)connects to the server.
  Stream<bool> watchConnection();

  Future<void> saveBudget(String uid, BudgetModel budget);

  Future<void> deleteBudget(String uid, String id);
}
