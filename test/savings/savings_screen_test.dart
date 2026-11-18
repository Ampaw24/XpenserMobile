import 'package:expenser/core/utils/theme/themes.dart';
import 'package:expenser/models/app_settings_model.dart';
import 'package:expenser/models/recurring_frequency.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/viewmodels/savings_goal_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/savings/savings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGoals extends SavingsGoalNotifier {
  @override
  List<SavingsGoalModel> build() => [
    SavingsGoalModel(
      id: 'a',
      name: 'Laptop',
      targetAmount: 1000,
      savedAmount: 200,
      // Far enough ahead that the plan exists whenever the test runs.
      targetDate: DateTime(2035),
      colorHex: 'FF4CAF50',
      iconCodePoint: 0xe000,
      createdAt: DateTime(2026),
      savingsFrequency: RecurringFrequency.weekly,
      reminderAt: DateTime(2026, 11, 2, 9),
    ),
    SavingsGoalModel(
      id: 'b',
      name: 'Done',
      targetAmount: 100,
      savedAmount: 100,
      targetDate: DateTime(2027),
      colorHex: 'FF2196F3',
      iconCodePoint: 0xe000,
      createdAt: DateTime(2026),
    ),
  ];
}

class _FakeSettings extends SettingsNotifier {
  @override
  AppSettingsModel build() => AppSettingsModel(preferredCurrency: 'GHS');
}

void main() {
  // Regression: the theme's full-width FilledButton inside the card's Row
  // threw a layout error, leaving the goals list blank.
  testWidgets('lists goals with their add-savings action', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savingsGoalProvider.overrideWith(_FakeGoals.new),
          settingsProvider.overrideWith(_FakeSettings.new),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const SavingsScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Add savings'), findsOneWidget);
    expect(find.textContaining('GHS'), findsOneWidget);
    expect(find.textContaining('due this week'), findsOneWidget);
    expect(find.text('Goal reached'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
