import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TransactionRepository {
  Box<TransactionModel> get _box =>
      HiveService.box<TransactionModel>(HiveService.transactions);

  List<TransactionModel> getAll() => _box.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  TransactionModel? getById(String id) => _box.get(id);

  Future<void> add(TransactionModel t) => _box.put(t.id, t);

  Future<void> update(TransactionModel t) => _box.put(t.id, t);

  Future<void> delete(String id) => _box.delete(id);

  List<TransactionModel> getByAccount(String accountId) => _box.values
      .where((t) => t.accountId == accountId || t.toAccountId == accountId)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  List<TransactionModel> getByDateRange(DateTime from, DateTime to) =>
      _box.values
          .where((t) =>
              t.date.isAfter(from.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(to.add(const Duration(seconds: 1))))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<TransactionModel> getByCategory(String categoryId) =>
      _box.values.where((t) => t.categoryId == categoryId).toList();
}

final transactionRepositoryProvider =
    Provider<TransactionRepository>((ref) => TransactionRepository());
