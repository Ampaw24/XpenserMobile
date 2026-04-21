import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BudgetRepository {
  Box<BudgetModel> get _box =>
      HiveService.box<BudgetModel>(HiveService.budgets);

  List<BudgetModel> getAll() => _box.values.toList();

  BudgetModel? getById(String id) => _box.get(id);

  List<BudgetModel> getForMonth(int month, int year) => _box.values
      .where((b) => b.month == month && b.year == year)
      .toList();

  Future<void> add(BudgetModel b) => _box.put(b.id, b);

  Future<void> update(BudgetModel b) => _box.put(b.id, b);

  Future<void> delete(String id) => _box.delete(id);
}

final budgetRepositoryProvider =
    Provider<BudgetRepository>((ref) => BudgetRepository());
