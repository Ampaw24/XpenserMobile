import 'package:expenser/models/transaction_model.dart';

abstract class ITransactionRepository {
  List<TransactionModel> getAll();
  TransactionModel? getById(String id);
  Future<void> add(TransactionModel transaction);
  Future<void> update(TransactionModel transaction);
  Future<void> delete(String id);
  List<TransactionModel> getByAccount(String accountId);
  List<TransactionModel> getByDateRange(DateTime from, DateTime to);
  List<TransactionModel> getByCategory(String categoryId);
}
