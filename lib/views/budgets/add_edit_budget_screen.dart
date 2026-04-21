import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _limitCtrl = TextEditingController();
  String? _selectedCategoryId;
  double _alertThreshold = 0.8;
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
      _selectedCategoryId = b.categoryId;
      _alertThreshold = b.alertThreshold;
    });
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select a category')));
      return;
    }
    setState(() => _isLoading = true);
    final now = DateTime.now();
    final budget = BudgetModel(
      id: _isEditing ? widget.budgetId! : const Uuid().v4(),
      categoryId: _selectedCategoryId!,
      limitAmount: double.parse(_limitCtrl.text),
      month: now.month,
      year: now.year,
      alertThreshold: _alertThreshold,
      createdAt: DateTime.now(),
    );
    final notifier = ref.read(budgetProvider.notifier);
    if (_isEditing) {
      await notifier.updateBudget(budget);
    } else {
      await notifier.addBudget(budget);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref
        .read(categoryRepositoryProvider)
        .getByType(TransactionType.expense);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Budget' : 'New Budget'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Category',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((c) {
                  final isSelected = c.id == _selectedCategoryId;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategoryId = c.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.PRIMARY.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.PRIMARY
                                : Colors.transparent),
                      ),
                      child: Text(c.name,
                          style: TextStyle(
                              fontSize: 13,
                              color: isSelected
                                  ? AppColors.PRIMARY
                                  : Colors.grey[700],
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _limitCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monthly Limit',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.PRIMARY),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter limit amount';
                  if (double.tryParse(v) == null) return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Alert at',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey)),
                  Text('${(_alertThreshold * 100).toInt()}%',
                      style: const TextStyle(
                          color: AppColors.PRIMARY,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _alertThreshold,
                min: 0.5,
                max: 1.0,
                divisions: 10,
                activeColor: AppColors.PRIMARY,
                onChanged: (v) => setState(() => _alertThreshold = v),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.PRIMARY,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'Update Budget' : 'Create Budget',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
