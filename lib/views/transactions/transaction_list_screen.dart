import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/core/utils/widgets/transaction_tile.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState
    extends ConsumerState<TransactionListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);
    final grouped = ref.read(transactionProvider.notifier).getGrouped();
    final categoryRepo = ref.read(categoryRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Transactions',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    ref.read(transactionProvider.notifier).setSearch(v),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Colors.grey),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref.read(transactionProvider.notifier).setSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (txState.transactions.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No transactions yet',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Tap + to add your first transaction',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ...entry.value.map((t) {
                          final category = categoryRepo.getById(t.categoryId);
                          return TransactionTile(
                            transaction: t,
                            categoryName: category?.name ?? 'Unknown',
                            categoryColor: category?.colorHex ?? 'FF78909C',
                            categoryIconCode: category?.iconCodePoint ??
                                Icons.category_rounded.codePoint,
                            onEdit: () =>
                                context.push('/transactions/${t.id}/edit'),
                            onDelete: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final deleted = await ref
                                  .read(transactionProvider.notifier)
                                  .deleteTransaction(t.id);
                              if (deleted == null) return;
                              messenger.showSnackBar(
                                SnackBar(
                                  content: const Text('Transaction deleted'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () => ref
                                        .read(transactionProvider.notifier)
                                        .addTransaction(deleted),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.PRIMARY,
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
