import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:expenser/views/budgets/widgets/budget_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One category's spent-vs-limit line inside a plan.
class BudgetAllocationRow extends ConsumerWidget {
  const BudgetAllocationRow({
    super.key,
    required this.plan,
    required this.allocation,
    this.showDecimals = false,
  });

  final BudgetPlan plan;
  final BudgetModel allocation;
  final bool showDecimals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final category = ref
        .read(categoryRepositoryProvider)
        .getById(allocation.categoryId);
    final categoryColor =
        category != null
            ? Color(int.parse(category.colorHex, radix: 16))
            : palette.textMuted;
    final usage = plan.usageFor(allocation);
    final digits = showDecimals ? 2 : 0;
    final amounts =
        '${plan.currency} ${plan.spentFor(allocation).toStringAsFixed(digits)}'
        ' / ${allocation.limitAmount.toStringAsFixed(digits)}';

    return Row(
      children: [
        Container(
          width: context.rs(30),
          height: context.rs(30),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            category != null
                ? IconData(category.iconCodePoint, fontFamily: 'MaterialIcons')
                : Icons.category_rounded,
            color: categoryColor,
            size: context.rs(15),
          ),
        ),
        SizedBox(width: context.rs(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            category?.name ?? 'Deleted category',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: context.rs(13),
                              fontWeight: FontWeight.w500,
                              color: palette.textPrimary,
                            ),
                          ),
                        ),
                        if (plan.isUsedUp(allocation)) ...[
                          SizedBox(width: context.rs(6)),
                          const _UsedUpTag(),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: context.rs(6)),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        amounts,
                        style: TextStyle(
                          fontSize: context.rs(12),
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.rs(5)),
              BudgetProgressBar(
                usage: usage,
                height: context.rs(5),
                color: budgetUsageColor(
                  palette,
                  usage: usage,
                  warningAt: allocation.alertThreshold,
                  normal: categoryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UsedUpTag extends StatelessWidget {
  const _UsedUpTag();

  @override
  Widget build(BuildContext context) {
    final color = context.palette.danger;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(6),
        vertical: context.rs(1),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.rs(6)),
      ),
      child: Text(
        'Used up',
        style: TextStyle(
          fontSize: context.rs(10),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
