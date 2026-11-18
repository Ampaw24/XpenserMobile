import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Resolves persisted icon code points back to const [IconData] so release
/// builds can tree-shake icon fonts. Any icon that can be stored on a model
/// must be listed here.
class IconRegistry {
  IconRegistry._();

  static const IconData defaultCategory = Icons.category_rounded;
  static const IconData defaultAccount = Icons.wallet_rounded;
  static const IconData defaultSavingsGoal = HugeIcons.strokeRoundedSavings;

  static const List<IconData> accountOptions = [
    Icons.wallet_rounded,
    Icons.account_balance_rounded,
    Icons.phone_android_rounded,
    Icons.savings_rounded,
    Icons.credit_card_rounded,
    Icons.attach_money_rounded,
  ];

  static const List<IconData> savingsGoalOptions = [
    HugeIcons.strokeRoundedSavings,
    HugeIcons.strokeRoundedHome01,
    HugeIcons.strokeRoundedAirplane01,
    HugeIcons.strokeRoundedCar01,
    HugeIcons.strokeRoundedSchool01,
    HugeIcons.strokeRoundedSmartPhone01,
    HugeIcons.strokeRoundedFavourite,
    HugeIcons.strokeRoundedStar,
  ];

  static const List<IconData> _categoryIcons = [
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.shopping_bag_rounded,
    Icons.receipt_long_rounded,
    Icons.favorite_rounded,
    Icons.movie_rounded,
    Icons.category_rounded,
    Icons.work_rounded,
    Icons.laptop_rounded,
    Icons.attach_money_rounded,
    Icons.savings_rounded,
    Icons.swap_horiz_rounded,
    Icons.payments_rounded,
  ];

  static final Map<int, IconData> _materialByCodePoint = {
    for (final icon in [...accountOptions, ..._categoryIcons])
      icon.codePoint: icon,
  };

  static final Map<int, IconData> _savingsGoalByCodePoint = {
    for (final icon in savingsGoalOptions) icon.codePoint: icon,
  };

  /// Material icon stored on categories, accounts and transactions.
  static IconData material(
    int codePoint, {
    IconData fallback = defaultCategory,
  }) => _materialByCodePoint[codePoint] ?? fallback;

  static IconData account(int codePoint) =>
      material(codePoint, fallback: defaultAccount);

  static IconData savingsGoal(int codePoint) =>
      _savingsGoalByCodePoint[codePoint] ?? defaultSavingsGoal;
}
