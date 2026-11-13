import 'package:expenser/core/constants/branding.dart';
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

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txState = ref.watch(transactionProvider);
    final grouped = ref.read(transactionProvider.notifier).getGrouped();
    final categoryRepo = ref.read(categoryRepositoryProvider);

    final titleColor = isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight;
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : AppBrand.textSecondaryLight;
    final searchBg = isDark ? AppBrand.surfaceDark : Colors.white;
    final searchBorder = isDark ? AppBrand.borderDark : AppBrand.borderLight;
    final iconColor = isDark ? const Color(0xFF94A3B8) : AppBrand.textSecondaryLight;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.05, 16, sw * 0.05, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Transactions',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
              child: Container(
                decoration: BoxDecoration(
                  color: searchBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: searchBorder,
                    width: 1.0,
                  ),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: titleColor,
                    fontSize: 14,
                  ),
                  onChanged: (v) {
                    setState(() {});
                    ref.read(transactionProvider.notifier).setSearch(v);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search transactions…',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      color: subtitleColor.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: iconColor,
                      size: 20,
                    ),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: iconColor,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                              ref
                                  .read(transactionProvider.notifier)
                                  .setSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (txState.transactions.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 52,
                      color: iconColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'No transactions found',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap + to add a new transaction',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    sw * 0.05,
                    0,
                    sw * 0.05,
                    100,
                  ),
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: subtitleColor,
                              letterSpacing: 0.4,
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
                                  backgroundColor: isDark
                                      ? AppBrand.surfaceDarkElevated
                                      : AppBrand.spruceDark,
                                  content: const Text(
                                    'Transaction deleted',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Colors.white,
                                    ),
                                  ),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    textColor: AppBrand.mintAccent,
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
        heroTag: 'fab_transactions',
        backgroundColor: AppBrand.tealPrimary,
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
