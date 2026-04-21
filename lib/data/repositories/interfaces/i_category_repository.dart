import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/transaction_type.dart';

abstract class ICategoryRepository {
  List<CategoryModel> getAll();
  List<CategoryModel> getByType(TransactionType type);
  CategoryModel? getById(String id);
  Future<void> add(CategoryModel category);
  Future<void> update(CategoryModel category);
  Future<void> delete(String id);
  bool get isEmpty;
  Future<void> seedDefaults();
}
