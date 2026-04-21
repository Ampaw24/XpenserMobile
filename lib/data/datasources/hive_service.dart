import 'package:hive_flutter/hive_flutter.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/account_type.dart';
import 'package:expenser/models/app_settings_model.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/recurring_frequency.dart';
import 'package:expenser/models/recurring_rule_model.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';

class HiveService {
  static const String transactions = 'transactions';
  static const String accounts = 'accounts';
  static const String categories = 'categories';
  static const String budgets = 'budgets';
  static const String savingsGoals = 'savings_goals';
  static const String recurringRules = 'recurring_rules';
  static const String settings = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(AccountTypeAdapter());
    Hive.registerAdapter(RecurringFrequencyAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(AccountModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    Hive.registerAdapter(SavingsGoalModelAdapter());
    Hive.registerAdapter(RecurringRuleModelAdapter());
    Hive.registerAdapter(AppSettingsModelAdapter());

    await Hive.openBox<TransactionModel>(transactions);
    await Hive.openBox<AccountModel>(accounts);
    await Hive.openBox<CategoryModel>(categories);
    await Hive.openBox<BudgetModel>(budgets);
    await Hive.openBox<SavingsGoalModel>(savingsGoals);
    await Hive.openBox<RecurringRuleModel>(recurringRules);
    await Hive.openBox<AppSettingsModel>(settings);
  }

  static Box<T> box<T>(String name) => Hive.box<T>(name);
}
