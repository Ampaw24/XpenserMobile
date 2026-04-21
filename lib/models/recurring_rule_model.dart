import 'package:hive_flutter/hive_flutter.dart';
import 'recurring_frequency.dart';

part 'recurring_rule_model.g.dart';

@HiveType(typeId: 5)
class RecurringRuleModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final RecurringFrequency frequency;

  @HiveField(2)
  final DateTime startDate;

  @HiveField(3)
  final DateTime? endDate;

  @HiveField(4)
  final DateTime lastGeneratedDate;

  RecurringRuleModel({
    required this.id,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.lastGeneratedDate,
  });

  RecurringRuleModel copyWith({
    String? id,
    RecurringFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastGeneratedDate,
  }) {
    return RecurringRuleModel(
      id: id ?? this.id,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
    );
  }
}
