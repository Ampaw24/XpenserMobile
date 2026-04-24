import 'package:hive_flutter/hive_flutter.dart';

part 'savings_goal_model.g.dart';

@HiveType(typeId: 4)
class SavingsGoalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double targetAmount;

  @HiveField(3)
  final double savedAmount;

  @HiveField(4)
  final DateTime targetDate;

  @HiveField(5)
  final String colorHex;

  @HiveField(6)
  final int iconCodePoint;

  @HiveField(7)
  final DateTime createdAt;

  SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.colorHex,
    required this.iconCodePoint,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'targetDate': targetDate.toIso8601String(),
        'colorHex': colorHex,
        'iconCodePoint': iconCodePoint,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) => SavingsGoalModel(
        id: map['id'] as String,
        name: map['name'] as String,
        targetAmount: (map['targetAmount'] as num).toDouble(),
        savedAmount: (map['savedAmount'] as num).toDouble(),
        targetDate: DateTime.parse(map['targetDate'] as String),
        colorHex: map['colorHex'] as String,
        iconCodePoint: map['iconCodePoint'] as int,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  double get progressPercent =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  SavingsGoalModel copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    String? colorHex,
    int? iconCodePoint,
    DateTime? createdAt,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      colorHex: colorHex ?? this.colorHex,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
