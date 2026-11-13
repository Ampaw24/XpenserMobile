import 'package:expenser/models/budget_model.dart';

abstract class IBudgetRepository {
  List<BudgetModel> getAll();
  BudgetModel? getById(String id);
  List<BudgetModel> getForMonth(int month, int year);
  Future<void> add(BudgetModel budget);
  Future<void> update(BudgetModel budget);
  Future<void> delete(String id);

  /// Makes the local copy match [budgets] exactly.
  Future<void> replaceAll(List<BudgetModel> budgets);
}
