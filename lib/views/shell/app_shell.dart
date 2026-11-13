import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/services/notification/budget_alert_service.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:expenser/views/shell/widgets/bottom_nav_bar.dart';
import 'package:expenser/views/shell/widgets/nav_tab_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _leadingTabs = [
    NavTabItem(icon: AppIcons.navHome, label: 'Home', branchIndex: 0),
    NavTabItem(icon: AppIcons.navBudgets, label: 'Budgets', branchIndex: 2),
  ];

  static const _centerTab = NavTabItem(
    icon: AppIcons.navCenter,
    label: 'Transactions',
    branchIndex: 1,
  );

  static const _trailingTabs = [
    NavTabItem(icon: AppIcons.navAccounts, label: 'Accounts', branchIndex: 3),
    NavTabItem(icon: AppIcons.navProfile, label: 'Profile', branchIndex: 4),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(budgetLiveSyncProvider);
    ref.watch(budgetAlertsProvider);
    return Scaffold(
      body: shell,
      bottomNavigationBar: BottomNavBar(
        leadingTabs: _leadingTabs,
        centerTab: _centerTab,
        trailingTabs: _trailingTabs,
        currentIndex: shell.currentIndex,
        onTap:
            (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}
