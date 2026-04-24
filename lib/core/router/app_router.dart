import 'package:expenser/core/router/route_guard.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/auth/forgot_password_screen.dart';
import 'package:expenser/views/auth/login_screen.dart';
import 'package:expenser/views/auth/register_screen.dart';
import 'package:expenser/views/onboarding/onboarding_screen.dart';
import 'package:expenser/views/shell/app_shell.dart';
import 'package:expenser/views/splash/splash_screen.dart';
import 'package:expenser/views/home/dashboard_screen.dart';
import 'package:expenser/views/transactions/transaction_list_screen.dart';
import 'package:expenser/views/transactions/add_edit_transaction_screen.dart';
import 'package:expenser/views/budgets/budgets_screen.dart';
import 'package:expenser/views/budgets/add_edit_budget_screen.dart';
import 'package:expenser/views/accounts/accounts_screen.dart';
import 'package:expenser/views/accounts/add_edit_account_screen.dart';
import 'package:expenser/views/savings/savings_screen.dart';
import 'package:expenser/views/savings/add_edit_savings_goal_screen.dart';
import 'package:expenser/views/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(settingsProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>(
  (ref) => RouterNotifier(ref),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final settings = ref.read(settingsProvider);
      return RouteGuard(settings).redirect(state.uri.path);
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/shell/dashboard',
              builder: (_, __) => const DashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/shell/transactions',
              builder: (_, __) => const TransactionListScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/shell/budgets',
              builder: (_, __) => const BudgetsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/shell/accounts',
              builder: (_, __) => const AccountsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/shell/settings',
              builder: (_, __) => const SettingsScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/transactions/add',
        builder: (_, __) => const AddEditTransactionScreen(),
      ),
      GoRoute(
        path: '/transactions/:id/edit',
        builder: (_, state) =>
            AddEditTransactionScreen(transactionId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/accounts/add',
        builder: (_, __) => const AddEditAccountScreen(),
      ),
      GoRoute(
        path: '/accounts/:id/edit',
        builder: (_, state) =>
            AddEditAccountScreen(accountId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/budgets/add',
        builder: (_, __) => const AddEditBudgetScreen(),
      ),
      GoRoute(
        path: '/budgets/:id/edit',
        builder: (_, state) =>
            AddEditBudgetScreen(budgetId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/savings',
        builder: (_, __) => const SavingsScreen(),
      ),
      GoRoute(
        path: '/savings/add',
        builder: (_, __) => const AddEditSavingsGoalScreen(),
      ),
      GoRoute(
        path: '/savings/:id/edit',
        builder: (_, state) =>
            AddEditSavingsGoalScreen(goalId: state.pathParameters['id']),
      ),
    ],
  );
});
