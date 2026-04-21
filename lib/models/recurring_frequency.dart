import 'package:hive_flutter/hive_flutter.dart';

part 'recurring_frequency.g.dart';

@HiveType(typeId: 12)
enum RecurringFrequency {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,

  @HiveField(2)
  monthly,
}
