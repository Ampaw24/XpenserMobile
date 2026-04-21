import 'package:expenser/core/utils/widgets/transaction_tile.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecentTransactionsSection extends ConsumerWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txState = ref.watch(transactionProvider);
    final recent = txState.transactions.take(5).toList();
    final categoryRepo = ref.read(categoryRepositoryProvider);

    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('No transactions yet',
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return Column(
      children: recent.map((t) {
        final category = categoryRepo.getById(t.categoryId);
        return TransactionTile(
          transaction: t,
          categoryName: category?.name ?? 'Unknown',
          categoryColor: category?.colorHex ?? 'FF78909C',
          categoryIconCode: category?.iconCodePoint ?? Icons.category_rounded.codePoint,
          onEdit: () => context.push('/transactions/${t.id}/edit'),
          onDelete: () => ref.read(transactionProvider.notifier).deleteTransaction(t.id),
        );
      }).toList(),
    );
  }
}
