import 'package:expenser/view/home/model/featuremodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreenProvider {
  //This class provides the necessary data and methods for the HomeScreen widget.
  static final featureData = Provider<List<FeatureModel>>((ref){
    return [
      FeatureModel(
        title: 'Currency Converter',
        subtitle: 'Convert between currencies',
        icon: Icons.currency_exchange_rounded,
        color: const Color(0xFF4CAF50),
      ),
      FeatureModel(
        title: 'Expense Tracker',
        subtitle: 'Track your daily expenses',
        icon: Icons.pie_chart_rounded,
        color: const Color(0xFF2196F3),
      ),
      FeatureModel(
        title: 'Budget Planner',
        subtitle: 'Plan your monthly budget',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFFFF9800),
      ),
    ];
  });
}