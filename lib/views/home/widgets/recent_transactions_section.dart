import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/utils/widgets/transaction_tile.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class RecentTransactionsSection extends ConsumerWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txState = ref.watch(transactionProvider);
    final recent = txState.transactions.take(5).toList();
    final categoryRepo = ref.read(categoryRepositoryProvider);

    if (recent.isNotEmpty) {
      return Column(
        children: recent.map((t) {
          final category = categoryRepo.getById(t.categoryId);
          return TransactionTile(
            transaction: t,
            categoryName: category?.name ?? 'Unknown',
            categoryColor: category?.colorHex ?? 'FF78909C',
            categoryIconCode:
                category?.iconCodePoint ?? Icons.category_rounded.codePoint,
            onEdit: () => context.push('/transactions/${t.id}/edit'),
            onDelete: () =>
                ref.read(transactionProvider.notifier).deleteTransaction(t.id),
          );
        }).toList(),
      );
    }

    final cardBg = isDark ? AppBrand.surfaceDark : Colors.white;
    final borderColor = isDark ? AppBrand.borderDark : AppBrand.borderLight;
    final iconColor = isDark ? const Color(0xFF64748B) : AppBrand.textMutedLight;
    final titleColor = isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight;
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : AppBrand.textSecondaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          HugeIcon(
            icon: AppIcons.emptyState,
            color: iconColor,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first transaction to get started',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}
