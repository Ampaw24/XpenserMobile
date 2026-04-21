import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/data/repositories/interfaces/i_budget_repository.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BudgetRepository implements IBudgetRepository {
  Box<BudgetModel> get _box =>
      HiveService.box<BudgetModel>(HiveService.budgets);

  @override
  List<BudgetModel> getAll() => _box.values.toList();

  @override
  BudgetModel? getById(String id) => _box.get(id);

  @override
  List<BudgetModel> getForMonth(int month, int year) => _box.values
      .where((b) => b.month == month && b.year == year)
      .toList();

  @override
  Future<void> add(BudgetModel budget) => _box.put(budget.id, budget);

  @override
  Future<void> update(BudgetModel budget) => _box.put(budget.id, budget);

  @override
  Future<void> delete(String id) => _box.delete(id);
}

final budgetRepositoryProvider =
    Provider<IBudgetRepository>((ref) => BudgetRepository());
