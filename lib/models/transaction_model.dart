import 'package:hive_flutter/hive_flutter.dart';
import 'transaction_type.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final TransactionType type;

  @HiveField(3)
  final String categoryId;

  @HiveField(4)
  final String accountId;

  @HiveField(5)
  final String? toAccountId;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final String? tags;

  @HiveField(9)
  final bool isRecurring;

  @HiveField(10)
  final String? recurringRuleId;

  @HiveField(11)
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    required this.date,
    this.notes,
    this.tags,
    this.isRecurring = false,
    this.recurringRuleId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'accountId': accountId,
      'date': date.toIso8601String(),
      'isRecurring': isRecurring,
      'createdAt': createdAt.toIso8601String(),
    };
    if (toAccountId != null) map['toAccountId'] = toAccountId;
    if (notes != null) map['notes'] = notes;
    if (tags != null) map['tags'] = tags;
    if (recurringRuleId != null) map['recurringRuleId'] = recurringRuleId;
    return map;
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
        id: map['id'] as String,
        amount: (map['amount'] as num).toDouble(),
        type: TransactionType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => TransactionType.expense,
        ),
        categoryId: map['categoryId'] as String,
        accountId: map['accountId'] as String,
        toAccountId: map['toAccountId'] as String?,
        date: DateTime.parse(map['date'] as String),
        notes: map['notes'] as String?,
        tags: map['tags'] as String?,
        isRecurring: map['isRecurring'] as bool? ?? false,
        recurringRuleId: map['recurringRuleId'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  TransactionModel copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    String? toAccountId,
    DateTime? date,
    String? notes,
    String? tags,
    bool? isRecurring,
    String? recurringRuleId,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
