import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/data/repositories/interfaces/i_category_repository.dart';
import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class CategoryRepository implements ICategoryRepository {
  Box<CategoryModel> get _box =>
      HiveService.box<CategoryModel>(HiveService.categories);

  @override
  List<CategoryModel> getAll() => _box.values.toList();

  @override
  List<CategoryModel> getByType(TransactionType type) =>
      _box.values.where((c) => c.transactionType == type).toList();

  @override
  CategoryModel? getById(String id) => _box.get(id);

  @override
  Future<void> add(CategoryModel category) => _box.put(category.id, category);

  @override
  Future<void> update(CategoryModel category) =>
      _box.put(category.id, category);

  @override
  Future<void> delete(String id) => _box.delete(id);

  @override
  bool get isEmpty => _box.isEmpty;

  @override
  Future<void> seedDefaults() async {
    const uuid = Uuid();
    final expenseCategories = [
      ('Food & Dining', Icons.restaurant_rounded, 'FFEF5350'),
      ('Transport', Icons.directions_car_rounded, 'FF42A5F5'),
      ('Shopping', Icons.shopping_bag_rounded, 'FFAB47BC'),
      ('Bills & Utilities', Icons.receipt_long_rounded, 'FFFF7043'),
      ('Health', Icons.favorite_rounded, 'FFEC407A'),
      ('Entertainment', Icons.movie_rounded, 'FF26C6DA'),
      ('Other', Icons.category_rounded, 'FF78909C'),
    ];
    final incomeCategories = [
      ('Salary', Icons.work_rounded, 'FF66BB6A'),
      ('Freelance', Icons.laptop_rounded, 'FF26A69A'),
      ('Other Income', Icons.attach_money_rounded, 'FFBCAAA4'),
    ];

    for (final (name, icon, color) in expenseCategories) {
      final cat = CategoryModel(
        id: uuid.v4(),
        name: name,
        iconCodePoint: icon.codePoint,
        colorHex: color,
        transactionType: TransactionType.expense,
        isDefault: true,
      );
      await _box.put(cat.id, cat);
    }
    for (final (name, icon, color) in incomeCategories) {
      final cat = CategoryModel(
        id: uuid.v4(),
        name: name,
        iconCodePoint: icon.codePoint,
        colorHex: color,
        transactionType: TransactionType.income,
        isDefault: true,
      );
      await _box.put(cat.id, cat);
    }
  }
}

final categoryRepositoryProvider =
    Provider<ICategoryRepository>((ref) => CategoryRepository());
