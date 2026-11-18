import 'package:expenser/core/utils/formatters/money.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/models/savings_affordability.dart';
import 'package:expenser/models/savings_plan.dart';
import 'package:expenser/models/savings_reminder_schedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shows the payment breakdown for a goal and whether it looks realistic.
class SavingsPlanSummary extends StatelessWidget {
  const SavingsPlanSummary({
    super.key,
    required this.plan,
    required this.affordability,
    required this.currency,
    required this.targetDate,
    required this.isReached,
  });

  final SavingsPlan? plan;
  final SavingsAffordability? affordability;
  final String currency;
  final DateTime targetDate;
  final bool isReached;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final plan = this.plan;
    if (isReached) {
      return _Note(
        icon: Icons.check_circle_rounded,
        color: palette.success,
        text: "You've already saved the full target.",
      );
    }
    if (plan == null) {
      return _Note(
        icon: Icons.event_busy_rounded,
        color: palette.danger,
        text: 'The target date has passed. Pick a later date to see a plan.',
      );
    }

    final period = savingsPeriodNoun(plan.frequency);
    final date = DateFormat.yMMMd().format(targetDate);
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatMoney(plan.perPayment, currency)} / $period',
            style: TextStyle(
              fontSize: context.rs(20),
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
          SizedBox(height: context.rs(4)),
          Text(
            '${plan.payments} ${plan.payments == 1 ? 'payment' : 'payments'} '
            'to save ${formatMoney(plan.remaining, currency)} by $date',
            style: TextStyle(
              fontSize: context.rs(13),
              color: palette.textSecondary,
            ),
          ),
          if (affordability != null) ...[
            SizedBox(height: context.rs(12)),
            _affordabilityNote(context, plan, affordability!),
          ],
        ],
      ),
    );
  }

  Widget _affordabilityNote(
    BuildContext context,
    SavingsPlan plan,
    SavingsAffordability result,
  ) {
    final palette = context.palette;
    final capacity = result.monthlyCapacity;
    switch (result.fit) {
      case SavingsFit.unknown:
        return _Note(
          icon: Icons.info_outline_rounded,
          color: palette.info,
          text:
              'Record your income and spending for a month to check whether '
              'this plan is realistic.',
        );
      case SavingsFit.fits:
        return _Note(
          icon: Icons.check_circle_rounded,
          color: palette.success,
          text:
              'Looks realistic. About ${formatMoney(plan.perMonth, currency)} '
              'a month, and you have had about '
              '${formatMoney(capacity!, currency)} a month to spare recently.',
        );
      case SavingsFit.exceeds:
        final spare =
            capacity! > 0
                ? 'you have had about ${formatMoney(capacity, currency)} '
                    'a month to spare recently'
                : 'your recent spending has used up your income';
        final suggested = result.suggestedTargetDate;
        return _Note(
          icon: Icons.warning_amber_rounded,
          color: palette.warning,
          text:
              'This may be hard to keep up. It needs about '
              '${formatMoney(plan.perMonth, currency)} a month, but $spare.'
              '${suggested == null ? ' Try a smaller target or a later date.' : ' At that pace you could reach it around ${DateFormat.yMMM().format(suggested)}.'}',
        );
    }
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: context.rs(18), color: color),
        SizedBox(width: context.rs(8)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: context.rs(13),
              color: context.palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
