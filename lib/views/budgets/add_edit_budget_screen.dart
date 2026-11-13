import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_amount_input.dart';
import 'package:expenser/core/utils/widgets/app_form_layout.dart';
import 'package:expenser/core/utils/widgets/app_primary_button.dart';
import 'package:expenser/core/utils/widgets/app_section_title.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/core/utils/widgets/category_picker_grid.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class AddEditBudgetScreen extends ConsumerStatefulWidget {
  final String? budgetId;
  const AddEditBudgetScreen({super.key, this.budgetId});

  @override
  ConsumerState<AddEditBudgetScreen> createState() =>
      _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends ConsumerState<AddEditBudgetScreen> {
  final _limitCtrl = TextEditingController();
  BudgetModel? _existing;
  String? _selectedCategoryId;
  double _alertThreshold = 0.8;
  String? _limitError;
  bool _showCategoryError = false;
  bool _isLoading = false;

  bool get _isEditing => widget.budgetId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  void _loadExisting() {
    final budgets = ref.read(budgetProvider).budgets;
    final b = budgets.firstWhere((b) => b.id == widget.budgetId);
    _limitCtrl.text = b.limitAmount.toStringAsFixed(2);
    setState(() {
      _existing = b;
      _selectedCategoryId = b.categoryId;
      _alertThreshold = b.alertThreshold;
    });
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  void _onLimitChanged(String _) {
    if (_limitError != null) setState(() => _limitError = null);
  }

  void _onCategorySelected(String id) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedCategoryId = id;
      _showCategoryError = false;
    });
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    final limit = double.tryParse(_limitCtrl.text);
    final limitError =
        limit == null || limit <= 0 ? 'Enter a limit above zero' : null;
    setState(() {
      _limitError = limitError;
      _showCategoryError = _selectedCategoryId == null;
    });
    if (limitError != null || _selectedCategoryId == null) return;

    setState(() => _isLoading = true);
    final now = DateTime.now();
    final budget =
        _existing?.copyWith(
          categoryId: _selectedCategoryId,
          limitAmount: limit,
          alertThreshold: _alertThreshold,
        ) ??
        BudgetModel(
          id: const Uuid().v4(),
          categoryId: _selectedCategoryId!,
          limitAmount: limit!,
          month: now.month,
          year: now.year,
          alertThreshold: _alertThreshold,
          createdAt: now,
        );

    try {
      final notifier = ref.read(budgetProvider.notifier);
      if (_isEditing) {
        await notifier.updateBudget(budget);
      } else {
        await notifier.addBudget(budget);
      }
      if (mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the budget. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final categories = ref
        .read(categoryRepositoryProvider)
        .getByType(TransactionType.expense);
    final preferredCurrency = ref.watch(
      settingsProvider.select((s) => s.preferredCurrency),
    );
    final accountId = _existing?.accountId;
    final currency =
        accountId == null
            ? preferredCurrency
            : ref
                    .watch(accountProvider)
                    .accounts
                    .where((a) => a.id == accountId)
                    .firstOrNull
                    ?.currencyCode ??
                preferredCurrency;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Budget' : 'New Budget'),
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(AppIcons.arrowLeft, size: context.rs(22)),
          onPressed: () => context.pop(),
        ),
      ),
      body: AppFormLayout(
        action: AppPrimaryButton(
          label: _isEditing ? 'Save Changes' : 'Create Budget',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
        children: [
          SizedBox(height: context.rs(8)),
          AppAmountInput(
            controller: _limitCtrl,
            currencyCode: currency,
            color: palette.accent,
            errorText: _limitError,
            autofocus: !_isEditing,
            onChanged: _onLimitChanged,
          ),
          Text(
            'Monthly limit',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.rs(13),
              color: palette.textSecondary,
            ),
          ),
          SizedBox(height: context.rs(28)),
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
          const AppSectionTitle('Alerts'),
          SizedBox(height: context.rs(12)),
          _AlertThresholdCard(
            value: _alertThreshold,
            onChanged: (v) => setState(() => _alertThreshold = v),
          ),
        ],
      ),
    );
  }
}

class _AlertThresholdCard extends StatelessWidget {
  const _AlertThresholdCard({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final percent = (value * 100).round();

    return AppSurfaceCard(
      padding: EdgeInsets.fromLTRB(
        context.rs(16),
        context.rs(14),
        context.rs(16),
        context.rs(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Notify me when spending reaches',
                  style: TextStyle(
                    fontSize: context.rs(14),
                    color: palette.textSecondary,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: context.rs(16),
                  fontWeight: FontWeight.w700,
                  color: palette.accent,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0.5,
            max: 1.0,
            divisions: 10,
            label: '$percent%',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
