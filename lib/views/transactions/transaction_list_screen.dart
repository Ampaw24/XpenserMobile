import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/core/utils/widgets/transaction_tile.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final sh = MediaQuery.of(context).size.height;
    final txState = ref.watch(transactionProvider);
    final grouped = ref.read(transactionProvider.notifier).getGrouped();
    final categoryRepo = ref.read(categoryRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.06, sh * 0.024, sw * 0.06, sh * 0.014),
              child: Text(
                'Transactions',
                style: GoogleFonts.montserrat(
                  fontSize: sw * 0.058,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(sw * 0.038),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: sw * 0.038),
                  onChanged: (v) {
                    setState(() {});
                    ref.read(transactionProvider.notifier).setSearch(v);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search transactions…',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.30),
                      fontSize: sw * 0.038,
                    ),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Colors.white.withValues(alpha: 0.35), size: sw * 0.052),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded,
                                color: Colors.white.withValues(alpha: 0.35),
                                size: sw * 0.048),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                              ref.read(transactionProvider.notifier).setSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: sh * 0.016),
                  ),
                ),
              ),
            ),
            SizedBox(height: sh * 0.014),
            if (txState.transactions.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: sw * 0.155,
                        color: Colors.white.withValues(alpha: 0.20)),
                    SizedBox(height: sh * 0.016),
                    Text(
                      'No transactions yet',
                      style: GoogleFonts.inter(
                        fontSize: sw * 0.040,
                        color: Colors.white.withValues(alpha: 0.40),
                      ),
                    ),
                    SizedBox(height: sh * 0.008),
                    Text(
                      'Tap + to add your first transaction',
                      style: GoogleFonts.inter(
                        fontSize: sw * 0.032,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(sw * 0.06, 0, sw * 0.06, sh * 0.12),
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: sh * 0.010),
                          child: Text(
                            entry.key,
                            style: GoogleFonts.inter(
                              fontSize: sw * 0.030,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.40),
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
                                  backgroundColor: const Color(0xFF1A2035),
                                  content: Text('Transaction deleted',
                                      style: GoogleFonts.inter(color: Colors.white)),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    textColor: AppColors.ACCENT,
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
        backgroundColor: AppColors.PRIMARY,
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
