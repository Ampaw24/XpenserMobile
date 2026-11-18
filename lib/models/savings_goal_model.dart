import 'package:expenser/models/recurring_frequency.dart';
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

  /// Amount the user plans to save each reminder period.
  @HiveField(8)
  final double? contributionAmount;

  /// How often the user pays into the goal; null when there is no plan.
  @HiveField(9)
  final RecurringFrequency? savingsFrequency;

  /// First reminder, or null when reminders are off. Its time of day,
  /// weekday and day of month set when reminders fire.
  @HiveField(10)
  final DateTime? reminderAt;

  @HiveField(11)
  final DateTime? lastContributionAt;

  /// Account contributions are taken from by default.
  @HiveField(12)
  final String? fundingAccountId;

  SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.colorHex,
    required this.iconCodePoint,
    required this.createdAt,
    this.contributionAmount,
    this.savingsFrequency,
    this.reminderAt,
    this.lastContributionAt,
    this.fundingAccountId,
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
    if (contributionAmount != null) 'contributionAmount': contributionAmount,
    if (savingsFrequency != null) 'savingsFrequency': savingsFrequency!.name,
    if (reminderAt != null) 'reminderAt': reminderAt!.toIso8601String(),
    if (lastContributionAt != null)
      'lastContributionAt': lastContributionAt!.toIso8601String(),
    if (fundingAccountId != null) 'fundingAccountId': fundingAccountId,
  };

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) =>
      SavingsGoalModel(
        id: map['id'] as String,
        name: map['name'] as String,
        targetAmount: (map['targetAmount'] as num).toDouble(),
        savedAmount: (map['savedAmount'] as num).toDouble(),
        targetDate: DateTime.parse(map['targetDate'] as String),
        colorHex: map['colorHex'] as String,
        iconCodePoint: map['iconCodePoint'] as int,
        createdAt: DateTime.parse(map['createdAt'] as String),
        contributionAmount: (map['contributionAmount'] as num?)?.toDouble(),
        savingsFrequency:
            RecurringFrequency.values
                // 'reminderFrequency' was the key in early builds.
                .where(
                  (f) =>
                      f.name ==
                      (map['savingsFrequency'] ?? map['reminderFrequency']),
                )
                .firstOrNull,
        reminderAt: DateTime.tryParse(map['reminderAt'] as String? ?? ''),
        lastContributionAt: DateTime.tryParse(
          map['lastContributionAt'] as String? ?? '',
        ),
        fundingAccountId: map['fundingAccountId'] as String?,
      );

  double get progressPercent =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => progressPercent >= 1;

  bool get hasReminder => savingsFrequency != null && reminderAt != null;

  SavingsGoalModel copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    String? colorHex,
    int? iconCodePoint,
    DateTime? createdAt,
    DateTime? lastContributionAt,
    String? fundingAccountId,
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
      contributionAmount: contributionAmount,
      savingsFrequency: savingsFrequency,
      reminderAt: reminderAt,
      lastContributionAt: lastContributionAt ?? this.lastContributionAt,
      fundingAccountId: fundingAccountId ?? this.fundingAccountId,
    );
  }
}
