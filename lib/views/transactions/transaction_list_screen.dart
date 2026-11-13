import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_empty_state.dart';
import 'package:expenser/core/utils/widgets/app_page_header.dart';
import 'package:expenser/core/utils/widgets/transaction_tile.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
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
    final txState = ref.watch(transactionProvider);
    final grouped = ref.read(transactionProvider.notifier).getGrouped();

    return Scaffold(
      body: BrandWatermarkBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AppPageHeader(title: 'Transactions'),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.contentGutter,
                ),
                child: _buildSearchField(),
              ),
              SizedBox(height: context.rs(8)),
              Expanded(
                child:
                    txState.transactions.isEmpty
                        ? const AppEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'No transactions found',
                          message: 'Tap + to add a new transaction',
                        )
                        : ListView(
                          padding: EdgeInsets.fromLTRB(
                            context.contentGutter,
                            0,
                            context.contentGutter,
                            context.rs(96),
                          ),
                          children: [
                            for (final entry in grouped.entries)
                              _buildGroup(context, entry.key, entry.value),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_transactions',
        tooltip: 'Add transaction',
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildSearchField() {
    final palette = context.palette;
    final pillBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.rs(100)),
      borderSide: BorderSide.none,
    );
    return TextField(
      controller: _searchCtrl,
      textInputAction: TextInputAction.search,
      onChanged: (v) {
        setState(() {});
        ref.read(transactionProvider.notifier).setSearch(v);
      },
      decoration: InputDecoration(
        hintText: 'Search transactions…',
        fillColor: palette.surfaceMuted,
        border: pillBorder,
        enabledBorder: pillBorder,
        focusedBorder: pillBorder,
        prefixIcon: Icon(AppIcons.search, size: context.rs(20)),
        suffixIcon:
            _searchCtrl.text.isEmpty
                ? null
                : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {});
                    ref.read(transactionProvider.notifier).setSearch('');
                  },
                ),
      ),
    );
  }

  Widget _buildGroup(
    BuildContext context,
    String label,
    List<TransactionModel> transactions,
  ) {
    final palette = context.palette;
    final categoryRepo = ref.read(categoryRepositoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: context.rs(10)),
          child: Text(
            label,
            style: TextStyle(
              fontSize: context.rs(12),
              fontWeight: FontWeight.w600,
              color: palette.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
        ),
        for (final t in transactions)
          _buildTile(t, categoryRepo.getById(t.categoryId)),
      ],
    );
  }

  Widget _buildTile(TransactionModel t, CategoryModel? category) {
    return TransactionTile(
      transaction: t,
      categoryName: category?.name ?? 'Unknown',
      categoryColor: category?.colorHex ?? 'FF78909C',
      categoryIconCode:
          category?.iconCodePoint ?? Icons.category_rounded.codePoint,
      onEdit: () => context.push('/transactions/${t.id}/edit'),
      onDelete: () => _delete(t.id),
    );
  }

  Future<void> _delete(String id) async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(transactionProvider.notifier);
    final deleted = await notifier.deleteTransaction(id);
    if (deleted == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Transaction deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => notifier.addTransaction(deleted),
        ),
      ),
    );
  }
}
