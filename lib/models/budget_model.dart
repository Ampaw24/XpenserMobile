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

  @HiveField(7)
  final String? accountId;

  @HiveField(8)
  final String? period; // 'monthly','quarterly','semi_annual','annual','custom'

  @HiveField(9)
  final String? planId; // UUID shared across all category entries in one plan

  @HiveField(10)
  final String? notes;

  @HiveField(11)
  final DateTime? startDate;

  @HiveField(12)
  final DateTime? endDate;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.year,
    this.alertThreshold = 0.8,
    required this.createdAt,
    this.accountId,
    this.period = 'monthly',
    this.planId,
    this.notes,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryId': categoryId,
    'limitAmount': limitAmount,
    'month': month,
    'year': year,
    'alertThreshold': alertThreshold,
    'createdAt': createdAt.toIso8601String(),
    'accountId': accountId,
    'period': period,
    'planId': planId,
    'notes': notes,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
  };

  factory BudgetModel.fromMap(Map<String, dynamic> map) => BudgetModel(
    id: map['id'] as String,
    categoryId: map['categoryId'] as String,
    limitAmount: (map['limitAmount'] as num).toDouble(),
    month: map['month'] as int,
    year: map['year'] as int,
    alertThreshold: (map['alertThreshold'] as num?)?.toDouble() ?? 0.8,
    createdAt: DateTime.parse(map['createdAt'] as String),
    accountId: map['accountId'] as String?,
    period: map['period'] as String?,
    planId: map['planId'] as String?,
    notes: map['notes'] as String?,
    startDate: map['startDate'] != null
        ? DateTime.parse(map['startDate'] as String)
        : null,
    endDate: map['endDate'] != null
        ? DateTime.parse(map['endDate'] as String)
        : null,
  );

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? limitAmount,
    int? month,
    int? year,
    double? alertThreshold,
    DateTime? createdAt,
    String? accountId,
    String? period,
    String? planId,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      month: month ?? this.month,
      year: year ?? this.year,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      createdAt: createdAt ?? this.createdAt,
      accountId: accountId ?? this.accountId,
      period: period ?? this.period,
      planId: planId ?? this.planId,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
