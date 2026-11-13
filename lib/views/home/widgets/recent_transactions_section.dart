import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/widgets/transaction_tile.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class RecentTransactionsSection extends ConsumerWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txState = ref.watch(transactionProvider);
    final recent = txState.transactions.take(5).toList();

    final cardBg = context.palette.surface;
    final borderColor = context.palette.border;

    if (recent.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(context.rs(20)),
          border: Border.all(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.symmetric(vertical: context.rs(4)),
        child: Column(
          children: [
            for (var i = 0; i < recent.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  indent: context.rs(16),
                  endIndent: context.rs(16),
                  color: borderColor,
                ),
              _buildTile(context, ref, recent[i]),
            ],
          ],
        ),
      );
    }
    final iconColor = context.palette.textMuted;
    final titleColor = context.palette.textPrimary;
    final subtitleColor = context.palette.textSecondary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: context.rs(36),
        horizontal: context.rs(20),
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(context.rs(20)),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        children: [
          HugeIcon(
            icon: AppIcons.emptyState,
            color: iconColor,
            size: context.rs(40),
          ),
          SizedBox(height: context.rs(12)),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: context.rs(14),
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          SizedBox(height: context.rs(4)),
          Text(
            'Add your first transaction to get started',
            style: TextStyle(fontSize: context.rs(12), color: subtitleColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, WidgetRef ref, TransactionModel t) {
    final category = ref.read(categoryRepositoryProvider).getById(t.categoryId);
    return TransactionTile(
      transaction: t,
      embedded: true,
      categoryName: category?.name ?? 'Unknown',
      categoryColor: category?.colorHex ?? 'FF78909C',
      categoryIconCode:
          category?.iconCodePoint ?? Icons.category_rounded.codePoint,
      onEdit: () => context.push('/transactions/${t.id}/edit'),
      onDelete:
          () => ref.read(transactionProvider.notifier).deleteTransaction(t.id),
    );
  }
}
