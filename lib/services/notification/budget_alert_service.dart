import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/data/repositories/notification_repository.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/budget_period.dart';
import 'package:expenser/services/notification/fcm_service.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Watch this from a widget that lives for the signed-in session to send a
/// notification when spending first passes a category's warning level or
/// its limit. Each level alerts at most once per allocation.
final budgetAlertsProvider = Provider<void>((ref) {
  ref.listen<BudgetState>(budgetProvider, (previous, next) {
    if (previous == null) return;
    BudgetAlertService(ref).checkCrossings(previous, next);
  });
});

class BudgetAlertService {
  BudgetAlertService(this._ref);

  final Ref _ref;

  static const _limitLevel = 1.0;

  void checkCrossings(BudgetState previous, BudgetState next) {
    final previousUsage = <String, double>{
      for (final plan in previous.plans)
        for (final b in plan.allocations) b.id: plan.usageFor(b),
    };

    for (final plan in next.activePlans(DateTime.now())) {
      for (final allocation in plan.allocations) {
        // Only react to spending changes on budgets we were already tracking,
        // so syncing data onto a new device doesn't trigger a burst of alerts.
        final before = previousUsage[allocation.id];
        if (before == null) continue;
        final after = plan.usageFor(allocation);
        final level = _highestCrossedLevel(
          before,
          after,
          allocation.alertThreshold,
        );
        if (level != null) _notify(plan, allocation, level);
      }
    }
  }

  double? _highestCrossedLevel(double before, double after, double warning) {
    for (final level in [_limitLevel, warning]) {
      if (before < level && after >= level) return level;
    }
    return null;
  }

  void _notify(BudgetPlan plan, BudgetModel allocation, double level) {
    final id = 'budget-alert-${allocation.id}-${(level * 100).round()}';
    if (_ref.read(notificationRepositoryProvider).exists(id)) return;

    final category =
        _ref
            .read(categoryRepositoryProvider)
            .getById(allocation.categoryId)
            ?.name ??
        'Category';
    final spent = plan.spentFor(allocation);
    final money =
        '${plan.currency} ${spent.toStringAsFixed(2)} of '
        '${allocation.limitAmount.toStringAsFixed(2)}';
    final periodName =
        plan.period == BudgetPeriodType.custom
            ? 'budget'
            : '${plan.period.label.toLowerCase()} budget';

    final isOver = level >= _limitLevel;
    _ref
        .read(fcmServiceProvider)
        .showLocalNotification(
          id: id,
          type: 'budget',
          route: '/shell/budgets',
          title:
              isOver
                  ? '$category budget reached'
                  : '$category budget at ${(level * 100).round()}%',
          body:
              isOver
                  ? "You've spent $money on your $category $periodName."
                  : "You've spent $money on your $category $periodName. "
                      'Slow down to stay on track.',
        )
        .catchError((Object e) => debugPrint('Budget alert failed: $e'));
  }
}
