import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/formatters/date_labels.dart';
import 'package:expenser/core/utils/formatters/money.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/models/savings_plan.dart';
import 'package:expenser/models/savings_reminder_schedule.dart';
import 'package:flutter/material.dart';

/// Goal card footer: this period's status plus a one-tap "add savings".
class SavingsCommitBar extends StatelessWidget {
  const SavingsCommitBar({
    super.key,
    required this.goal,
    required this.color,
    required this.currency,
    required this.onAdd,
  });

  final SavingsGoalModel goal;
  final Color color;
  final String currency;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (goal.isCompleted) {
      return _Status(
        icon: Icons.check_circle_rounded,
        text: 'Goal reached',
        color: palette.success,
      );
    }

    final now = DateTime.now();
    final frequency = goal.savingsFrequency;
    final last = goal.lastContributionAt;
    final doneThisPeriod = goal.contributedThisPeriod(now);
    final plan = goal.currentPlan(now);
    final String status;
    if (frequency != null) {
      final period = savingsPeriodName(frequency);
      status =
          doneThisPeriod
              ? 'Added $period'
              : plan != null
              ? '${formatMoney(plan.perPayment, currency)} due $period'
              : 'Not added $period yet';
    } else if (last != null) {
      status = 'Last added ${relativeDayLabel(last)}';
    } else {
      status = 'No savings added yet';
    }

    return Row(
      children: [
        Expanded(
          child: _Status(
            icon:
                doneThisPeriod
                    ? Icons.check_circle_rounded
                    : Icons.schedule_rounded,
            text: status,
            color: doneThisPeriod ? palette.success : palette.textSecondary,
          ),
        ),
        SizedBox(width: context.rs(8)),
        FilledButton.tonalIcon(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            // The app theme makes filled buttons full width; inside a Row
            // that is infinite, so size this one to its content.
            minimumSize: Size(0, context.rs(36)),
            backgroundColor: color.withValues(alpha: 0.14),
            foregroundColor: color,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.symmetric(
              horizontal: context.rs(14),
              vertical: context.rs(8),
            ),
          ),
          icon: Icon(AppIcons.add, size: context.rs(16)),
          label: Text(
            doneThisPeriod ? 'Add more' : 'Add savings',
            style: TextStyle(
              fontSize: context.rs(13),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: context.rs(16), color: color),
        SizedBox(width: context.rs(6)),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: context.rs(12), color: color),
          ),
        ),
      ],
    );
  }
}
