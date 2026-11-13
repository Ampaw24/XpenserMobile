import 'package:hive_flutter/hive_flutter.dart';

part 'account_type.g.dart';

@HiveType(typeId: 11)
enum AccountType {
  @HiveField(0)
  cash,

  @HiveField(1)
  bank,

  @HiveField(2)
  mobileMoney,

  @HiveField(3)
  savings,
}

extension AccountTypeLabel on AccountType {
  String get label => switch (this) {
    AccountType.cash => 'Cash',
    AccountType.bank => 'Bank',
    AccountType.mobileMoney => 'Mobile Money',
    AccountType.savings => 'Savings',
  };
}
