import 'package:expenser/core/utils/formatters/date_labels.dart';
import 'package:expenser/models/budget_period.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:intl/intl.dart';

String budgetMoney(String currency, double amount) =>
    '$currency ${amount.toStringAsFixed(2)}';

String budgetRangeLabel(BudgetPlan plan) =>
    dateRangeLabel(plan.range.start, plan.range.end);

/// "12 days left", "Last day", "Starts Dec 1", "Ended Oct 31" or
/// "Closed Nov 13".
String budgetStatusLabel(BudgetPlan plan, DateTime now) {
  switch (plan.status(now)) {
    case BudgetStatus.upcoming:
      return 'Starts ${DateFormat.MMMd().format(plan.range.start)}';
    case BudgetStatus.ended:
      return 'Ended ${DateFormat.MMMd().format(plan.range.end)}';
    case BudgetStatus.closed:
      return 'Closed ${DateFormat.MMMd().format(plan.lastTrackedDay)}';
    case BudgetStatus.active:
      final days = plan.range.daysLeftAt(now);
      return days <= 1 ? 'Last day' : '$days days left';
  }
}
