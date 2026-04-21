import 'package:hive_flutter/hive_flutter.dart';
import 'account_type.dart';

part 'account_model.g.dart';

@HiveType(typeId: 1)
class AccountModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final AccountType type;

  @HiveField(3)
  final double initialBalance;

  @HiveField(4)
  final String currencyCode;

  @HiveField(5)
  final String colorHex;

  @HiveField(6)
  final int iconCodePoint;

  @HiveField(7)
  final DateTime createdAt;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.currencyCode,
    required this.colorHex,
    required this.iconCodePoint,
    required this.createdAt,
  });

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? initialBalance,
    String? currencyCode,
    String? colorHex,
    int? iconCodePoint,
    DateTime? createdAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      currencyCode: currencyCode ?? this.currencyCode,
      colorHex: colorHex ?? this.colorHex,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
