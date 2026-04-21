import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/views/shell/widgets/bottom_nav_bar.dart';
import 'package:expenser/views/shell/widgets/nav_tab_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    NavTabItem(icon: AppIcons.navHome,         label: 'Home'),
    NavTabItem(icon: AppIcons.navTransactions, label: 'Txns'),
    NavTabItem(icon: AppIcons.navBudgets,      label: 'Budgets'),
    NavTabItem(icon: AppIcons.navAccounts,     label: 'Accounts'),
    NavTabItem(icon: AppIcons.navSettings,     label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: shell,
      bottomNavigationBar: BottomNavBar(
        tabs: _tabs,
        currentIndex: shell.currentIndex,
        onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}
