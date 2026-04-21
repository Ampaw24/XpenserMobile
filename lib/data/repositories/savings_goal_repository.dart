import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SavingsGoalRepository {
  Box<SavingsGoalModel> get _box =>
      HiveService.box<SavingsGoalModel>(HiveService.savingsGoals);

  List<SavingsGoalModel> getAll() => _box.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  SavingsGoalModel? getById(String id) => _box.get(id);

  Future<void> add(SavingsGoalModel g) => _box.put(g.id, g);

  Future<void> update(SavingsGoalModel g) => _box.put(g.id, g);

  Future<void> delete(String id) => _box.delete(id);
}

final savingsGoalRepositoryProvider =
    Provider<SavingsGoalRepository>((ref) => SavingsGoalRepository());
