import 'package:hive_flutter/hive_flutter.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double limitAmount;

  @HiveField(3)
  final int month;

  @HiveField(4)
  final int year;

  @HiveField(5)
  final double alertThreshold;

  @HiveField(6)
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.year,
    this.alertThreshold = 0.8,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'categoryId': categoryId,
        'limitAmount': limitAmount,
        'month': month,
        'year': year,
        'alertThreshold': alertThreshold,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BudgetModel.fromMap(Map<String, dynamic> map) => BudgetModel(
        id: map['id'] as String,
        categoryId: map['categoryId'] as String,
        limitAmount: (map['limitAmount'] as num).toDouble(),
        month: map['month'] as int,
        year: map['year'] as int,
        alertThreshold: (map['alertThreshold'] as num?)?.toDouble() ?? 0.8,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? limitAmount,
    int? month,
    int? year,
    double? alertThreshold,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      month: month ?? this.month,
      year: year ?? this.year,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
