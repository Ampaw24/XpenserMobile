import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1A2035),
          content: Text('Select a category',
              style: GoogleFonts.inter(color: Colors.white)),
        ),
      );
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
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final categories = ref
        .read(categoryRepositoryProvider)
        .getByType(TransactionType.expense);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          _isEditing ? 'Edit Budget' : 'New Budget',
          style: GoogleFonts.montserrat(
            fontSize: sw * 0.046,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(sw * 0.06, sh * 0.010, sw * 0.06, sh * 0.06),
            children: [
              Text(
                'Category',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: sw * 0.032,
                  color: Colors.white.withValues(alpha: 0.50),
                ),
              ),
              SizedBox(height: sh * 0.012),
              Wrap(
                spacing: sw * 0.022,
                runSpacing: sh * 0.010,
                children: categories.map((c) {
                  final isSelected = c.id == _selectedCategoryId;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryId = c.id),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.038, vertical: sh * 0.012),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.ACCENT.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(sw * 0.055),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.ACCENT
                              : Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Text(
                        c.name,
                        style: GoogleFonts.inter(
                          fontSize: sw * 0.032,
                          color: isSelected
                              ? AppColors.ACCENT
                              : Colors.white.withValues(alpha: 0.55),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: sh * 0.024),
              TextFormField(
                controller: _limitCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.inter(color: Colors.white, fontSize: sw * 0.038),
                cursorColor: AppColors.ACCENT,
                decoration: InputDecoration(
                  labelText: 'Monthly Limit',
                  labelStyle: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.50)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.ACCENT, width: 1.5),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter limit amount';
                  if (double.tryParse(v) == null) return 'Enter valid number';
                  return null;
                },
              ),
              SizedBox(height: sh * 0.024),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alert at',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: sw * 0.032,
                      color: Colors.white.withValues(alpha: 0.50),
                    ),
                  ),
                  Text(
                    '${(_alertThreshold * 100).toInt()}%',
                    style: GoogleFonts.montserrat(
                      color: AppColors.ACCENT,
                      fontWeight: FontWeight.w700,
                      fontSize: sw * 0.038,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.ACCENT,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
                  thumbColor: AppColors.ACCENT,
                  overlayColor: AppColors.ACCENT.withValues(alpha: 0.15),
                ),
                child: Slider(
                  value: _alertThreshold,
                  min: 0.5,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (v) => setState(() => _alertThreshold = v),
                ),
              ),
              SizedBox(height: sh * 0.036),
              _GradientButton(
                label: _isEditing ? 'Update Budget' : 'Create Budget',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submit,
                sw: sw,
                sh: sh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double sw, sh;
  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: sh * 0.065,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.PRIMARY, AppColors.ACCENT],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(sw * 0.042),
          boxShadow: [
            BoxShadow(
              color: AppColors.ACCENT.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
