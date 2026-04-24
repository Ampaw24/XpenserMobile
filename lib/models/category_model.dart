import 'package:hive_flutter/hive_flutter.dart';
import 'transaction_type.dart';

part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int iconCodePoint;

  @HiveField(3)
  final String colorHex;

  @HiveField(4)
  final TransactionType transactionType;

  @HiveField(5)
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorHex,
    required this.transactionType,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconCodePoint': iconCodePoint,
        'colorHex': colorHex,
        'transactionType': transactionType.name,
        'isDefault': isDefault,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] as String,
        name: map['name'] as String,
        iconCodePoint: map['iconCodePoint'] as int,
        colorHex: map['colorHex'] as String,
        transactionType: TransactionType.values.firstWhere(
          (e) => e.name == map['transactionType'],
          orElse: () => TransactionType.expense,
        ),
        isDefault: map['isDefault'] as bool? ?? false,
      );

  CategoryModel copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    String? colorHex,
    TransactionType? transactionType,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorHex: colorHex ?? this.colorHex,
      transactionType: transactionType ?? this.transactionType,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
