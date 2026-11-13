import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_empty_state.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/viewmodels/savings_goal_viewmodel.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(savingsGoalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        leading: IconButton(
          icon: const Icon(AppIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: BrandWatermarkBackground(
        child: SafeArea(
          child:
              goals.isEmpty
                  ? const AppEmptyState(
                    icon: AppIcons.savings,
                    title: 'No savings goals yet',
                    message: 'Tap + to add a goal',
                  )
                  : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      context.contentGutter,
                      context.rs(8),
                      context.contentGutter,
                      context.rs(96),
                    ),
                    itemCount: goals.length,
                    separatorBuilder:
                        (_, __) => SizedBox(height: context.rs(12)),
                    itemBuilder: (context, i) {
                      final goal = goals[i];
                      return _SavingsGoalCard(
                        goal: goal,
                        onTap: () => context.push('/savings/${goal.id}/edit'),
                        onDelete:
                            () => ref
                                .read(savingsGoalProvider.notifier)
                                .deleteGoal(goal.id),
                      );
                    },
                  ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_savings',
        onPressed: () => context.push('/savings/add'),
        child: const Icon(AppIcons.add),
      ),
    );
  }
}

class _SavingsGoalCard extends StatelessWidget {
  const _SavingsGoalCard({
    required this.goal,
    required this.onTap,
    required this.onDelete,
  });

  final SavingsGoalModel goal;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final goalColor = _hexToColor(goal.colorHex, palette.accent);
    final isCompleted = goal.progressPercent >= 1;
    final progressColor = isCompleted ? palette.success : goalColor;
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final metaStyle = TextStyle(
      fontSize: context.rs(12),
      color: palette.textSecondary,
    );

    return Dismissible(
      key: ValueKey(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: context.rs(20)),
        decoration: BoxDecoration(
          color: palette.danger,
          borderRadius: BorderRadius.circular(context.rs(18)),
        ),
        child: Icon(AppIcons.delete, color: Colors.white, size: context.rs(22)),
      ),
      onDismissed: (_) => onDelete(),
      child: AppSurfaceCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.rs(11)),
                  decoration: BoxDecoration(
                    color: goalColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(context.rs(14)),
                  ),
                  child: Icon(
                    IconData(
                      goal.iconCodePoint,
                      fontFamily: 'HgiStrokeRounded',
                      fontPackage: 'hugeicons',
                    ),
                    color: goalColor,
                    size: context.rs(22),
                  ),
                ),
                SizedBox(width: context.rs(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.rs(15),
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      SizedBox(height: context.rs(2)),
                      Text(
                        daysLeft > 0
                            ? '$daysLeft days left'
                            : 'Target date passed',
                        style: metaStyle.copyWith(
                          color: daysLeft > 0 ? null : palette.danger,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: context.rs(8)),
                Text(
                  '${(goal.progressPercent * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                    fontSize: context.rs(17),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.rs(14)),
            ClipRRect(
              borderRadius: BorderRadius.circular(context.rs(8)),
              child: LinearProgressIndicator(
                value: goal.progressPercent,
                minHeight: context.rs(6),
                backgroundColor: palette.surfaceMuted,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
            SizedBox(height: context.rs(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Saved: ${goal.savedAmount.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: metaStyle,
                  ),
                ),
                SizedBox(width: context.rs(8)),
                Flexible(
                  child: Text(
                    'Goal: ${goal.targetAmount.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: metaStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Color _hexToColor(String hex, Color fallback) {
    try {
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}
