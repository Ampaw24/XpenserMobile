import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/widgets/transaction_tile.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

// Placeholder display data used when no real transactions exist yet.
class _DummyTx {
  final double amount;
  final TransactionType type;
  final String categoryName;
  final String colorHex;
  final int iconCodePoint;
  final String notes;
  final DateTime date;

  const _DummyTx({
    required this.amount,
    required this.type,
    required this.categoryName,
    required this.colorHex,
    required this.iconCodePoint,
    required this.notes,
    required this.date,
  });
}

class RecentTransactionsSection extends ConsumerWidget {
  const RecentTransactionsSection({super.key});

  static List<_DummyTx> _buildDummies() {
    final now = DateTime.now();
    return [
      _DummyTx(
        amount: 3200.00,
        type: TransactionType.income,
        categoryName: 'Salary',
        colorHex: 'FF66BB6A',
        iconCodePoint: Icons.work_rounded.codePoint,
        notes: 'Monthly salary',
        date: now,
      ),
      _DummyTx(
        amount: 85.00,
        type: TransactionType.expense,
        categoryName: 'Food & Dining',
        colorHex: 'FFEF5350',
        iconCodePoint: Icons.restaurant_rounded.codePoint,
        notes: 'Dinner out',
        date: now.subtract(const Duration(days: 1)),
      ),
      _DummyTx(
        amount: 120.00,
        type: TransactionType.expense,
        categoryName: 'Transport',
        colorHex: 'FF42A5F5',
        iconCodePoint: Icons.directions_car_rounded.codePoint,
        notes: 'Fuel',
        date: now.subtract(const Duration(days: 2)),
      ),
      _DummyTx(
        amount: 250.00,
        type: TransactionType.expense,
        categoryName: 'Shopping',
        colorHex: 'FFAB47BC',
        iconCodePoint: Icons.shopping_bag_rounded.codePoint,
        notes: 'Groceries',
        date: now.subtract(const Duration(days: 2)),
      ),
      _DummyTx(
        amount: 500.00,
        type: TransactionType.income,
        categoryName: 'Freelance',
        colorHex: 'FF26A69A',
        iconCodePoint: Icons.laptop_rounded.codePoint,
        notes: 'Design project',
        date: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final txState = ref.watch(transactionProvider);
    final recent = txState.transactions.take(5).toList();
    final categoryRepo = ref.read(categoryRepositoryProvider);

    // Real transactions take priority; fall back to dummy data while no backend exists.
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

    final dummies = _buildDummies();

    if (dummies.isEmpty) {
      return Container(
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
          ],
        ),
      );
    }

    // Build a minimal TransactionModel shell for each dummy so TransactionTile
    // can render without modification. Edit/delete are intentionally no-ops.
    final now = DateTime.now();
    return Column(
      children: dummies.map((d) {
        final shell = TransactionModel(
          id: 'dummy_${d.notes.hashCode}',
          amount: d.amount,
          type: d.type,
          categoryId: '',
          accountId: '',
          date: d.date,
          notes: d.notes,
          createdAt: now,
        );
        return TransactionTile(
          transaction: shell,
          categoryName: d.categoryName,
          categoryColor: d.colorHex,
          categoryIconCode: d.iconCodePoint,
          onEdit: () {},
          onDelete: () async {},
        );
      }).toList(),
    );
  }
}
