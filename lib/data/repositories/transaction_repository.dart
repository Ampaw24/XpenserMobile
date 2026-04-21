import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/data/repositories/interfaces/i_transaction_repository.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TransactionRepository implements ITransactionRepository {
  Box<TransactionModel> get _box =>
      HiveService.box<TransactionModel>(HiveService.transactions);

  @override
  List<TransactionModel> getAll() => _box.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  @override
  TransactionModel? getById(String id) => _box.get(id);

  @override
  Future<void> add(TransactionModel transaction) =>
      _box.put(transaction.id, transaction);

  @override
  Future<void> update(TransactionModel transaction) =>
      _box.put(transaction.id, transaction);

  @override
  Future<void> delete(String id) => _box.delete(id);

  @override
  List<TransactionModel> getByAccount(String accountId) => _box.values
      .where((t) => t.accountId == accountId || t.toAccountId == accountId)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  @override
  List<TransactionModel> getByDateRange(DateTime from, DateTime to) =>
      _box.values
          .where((t) =>
              t.date.isAfter(from.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(to.add(const Duration(seconds: 1))))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  @override
  List<TransactionModel> getByCategory(String categoryId) =>
      _box.values.where((t) => t.categoryId == categoryId).toList();
}

final transactionRepositoryProvider =
    Provider<ITransactionRepository>((ref) => TransactionRepository());
