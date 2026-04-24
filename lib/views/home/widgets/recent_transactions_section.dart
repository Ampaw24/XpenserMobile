import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/widgets/transaction_tile.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class RecentTransactionsSection extends ConsumerWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: sh * 0.040),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(sw * 0.050),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          HugeIcon(
            icon: AppIcons.emptyState,
            color: Colors.white.withValues(alpha: 0.25),
            size: sw * 0.115,
          ),
          SizedBox(height: sh * 0.012),
          Text(
            'No transactions yet',
            style: GoogleFonts.inter(
              fontSize: sw * 0.036,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          SizedBox(height: sh * 0.006),
          Text(
            'Add your first transaction to get started',
            style: GoogleFonts.inter(
              fontSize: sw * 0.030,
              color: Colors.white.withValues(alpha: 0.20),
            ),
          ),
        ],
      ),
    );
  }
}
