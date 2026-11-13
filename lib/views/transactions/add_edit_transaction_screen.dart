import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/extensions/color_extensions.dart';
import 'package:expenser/core/utils/formatters/date_labels.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_amount_input.dart';
import 'package:expenser/core/utils/widgets/app_form_layout.dart';
import 'package:expenser/core/utils/widgets/category_picker_grid.dart';
import 'package:expenser/core/utils/widgets/app_option_sheet.dart';
import 'package:expenser/core/utils/widgets/app_primary_button.dart';
import 'package:expenser/core/utils/widgets/app_section_title.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/insights_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:expenser/views/transactions/widgets/transaction_detail_rows.dart';
import 'package:expenser/views/transactions/widgets/transaction_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final String? transactionId;
  final TransactionType? initialType;
  const AddEditTransactionScreen({
    super.key,
    this.transactionId,
    this.initialType,
  });

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  TransactionModel? _existing;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  DateTime _date = DateTime.now();
  String? _amountError;
  bool _showCategoryError = false;
  bool _isLoading = false;

  bool get _isEditing => widget.transactionId != null;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? _type;
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  void _loadExisting() {
    final all = ref.read(transactionProvider.notifier).getAll();
    final tx = all.firstWhere(
      (t) => t.id == widget.transactionId,
      orElse: () => throw Exception('Not found'),
    );
    _amountCtrl.text = tx.amount.toStringAsFixed(2);
    _notesCtrl.text = tx.notes ?? '';
    setState(() {
      _existing = tx;
      _type = tx.type;
      _selectedCategoryId = tx.categoryId;
      _selectedAccountId = tx.accountId;
      _date = tx.date;
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  /// New transactions default to the first account; edits never silently
  /// re-point to a different account.
  AccountModel? _resolveAccount(List<AccountModel> accounts) {
    if (_selectedAccountId != null) {
      for (final account in accounts) {
        if (account.id == _selectedAccountId) return account;
      }
      return null;
    }
    if (_isEditing || accounts.isEmpty) return null;
    return accounts.first;
  }

  void _onTypeChanged(TransactionType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      _selectedCategoryId = null;
    });
  }

  void _onAmountChanged(String _) {
    if (_amountError != null) setState(() => _amountError = null);
  }

  void _onCategorySelected(String id) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedCategoryId = id;
      _showCategoryError = false;
    });
  }

  Future<void> _pickAccount(List<AccountModel> accounts) async {
    FocusScope.of(context).unfocus();
    if (accounts.isEmpty) {
      context.push('/accounts/add');
      return;
    }
    final palette = context.palette;
    final id = await showAppOptionSheet<String>(
      context,
      title: 'Select account',
      selected: _resolveAccount(accounts)?.id,
      options: [
        for (final account in accounts)
          AppSelectOption(
            value: account.id,
            label: account.name,
            subtitle: account.currencyCode,
            icon: IconData(account.iconCodePoint, fontFamily: 'MaterialIcons'),
            color: colorFromHex(account.colorHex, fallback: palette.accent),
          ),
      ],
    );
    if (id != null && mounted) setState(() => _selectedAccountId = id);
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    final amount = double.tryParse(_amountCtrl.text);
    final account = _resolveAccount(ref.read(accountProvider).accounts);
    final amountError =
        amount == null || amount <= 0 ? 'Enter an amount above zero' : null;
    setState(() {
      _amountError = amountError;
      _showCategoryError = _selectedCategoryId == null;
    });
    if (amountError != null || _selectedCategoryId == null) return;
    if (account == null) {
      _showMessage('Select an account');
      return;
    }

    setState(() => _isLoading = true);
    final notes = _notesCtrl.text.trim();
    final existing = _existing;
    final tx = TransactionModel(
      id: existing?.id ?? const Uuid().v4(),
      amount: amount!,
      type: _type,
      categoryId: _selectedCategoryId!,
      accountId: account.id,
      toAccountId: existing?.toAccountId,
      date: _date,
      notes: notes.isEmpty ? null : notes,
      tags: existing?.tags,
      isRecurring: existing?.isRecurring ?? false,
      recurringRuleId: existing?.recurringRuleId,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    try {
      final notifier = ref.read(transactionProvider.notifier);
      if (_isEditing) {
        await notifier.updateTransaction(tx);
      } else {
        await notifier.addTransaction(tx);
      }
      ref.read(insightsProvider.notifier).refresh();
      ref.read(accountProvider.notifier).refresh();
      if (mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Could not save the transaction. Please try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final categories = ref.read(categoryRepositoryProvider).getByType(_type);
    final accounts = ref.watch(accountProvider).accounts;
    final account = _resolveAccount(accounts);
    final preferredCurrency = ref.watch(
      settingsProvider.select((s) => s.preferredCurrency),
    );
    final currency = account?.currencyCode ?? preferredCurrency;
    final typeColor = TransactionTypeSelector.colorFor(_type, palette);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_isEditing ? 'Edit Transaction' : 'New Transaction'),
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(AppIcons.arrowLeft, size: context.rs(22)),
          onPressed: () => context.pop(),
        ),
      ),
      body: AppFormLayout(
        action: AppPrimaryButton(
          label: _isEditing ? 'Save Changes' : 'Add Transaction',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
        children: [
          TransactionTypeSelector(selected: _type, onChanged: _onTypeChanged),
          SizedBox(height: context.rs(28)),
          AppAmountInput(
            controller: _amountCtrl,
            currencyCode: currency,
            color: typeColor,
            errorText: _amountError,
            autofocus: !_isEditing,
            onChanged: _onAmountChanged,
          ),
          SizedBox(height: context.rs(24)),
          AppSectionTitle(
            'Category',
            trailing: _showCategoryError ? 'Pick a category' : null,
          ),
          SizedBox(height: context.rs(12)),
          CategoryPickerGrid(
            categories: categories,
            selectedId: _selectedCategoryId,
            onSelected: _onCategorySelected,
          ),
          SizedBox(height: context.rs(28)),
          const AppSectionTitle('Details'),
          SizedBox(height: context.rs(12)),
          AppSurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                TransactionDetailRow(
                  icon: AppIcons.wallet,
                  title: 'Account',
                  value:
                      accounts.isEmpty
                          ? 'Add account'
                          : account?.name ?? 'Select',
                  valueColor: account == null ? palette.accent : null,
                  onTap: () => _pickAccount(accounts),
                ),
                const _RowDivider(),
                TransactionDetailRow(
                  icon: AppIcons.calendar,
                  iconColor: palette.info,
                  title: 'Date',
                  value: relativeDayLabel(_date),
                  onTap: _pickDate,
                ),
                const _RowDivider(),
                TransactionNoteRow(controller: _notesCtrl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, indent: context.rs(62), endIndent: context.rs(14));
}
