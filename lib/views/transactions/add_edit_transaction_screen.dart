import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/insights_viewmodel.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final String? transactionId;
  const AddEditTransactionScreen({super.key, this.transactionId});

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  bool get _isEditing => widget.transactionId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  void _loadExisting() {
    final all = ref.read(transactionProvider.notifier).getAll();
    final tx = all.firstWhere((t) => t.id == widget.transactionId,
        orElse: () => throw Exception('Not found'));
    _amountCtrl.text = tx.amount.toStringAsFixed(2);
    _notesCtrl.text = tx.notes ?? '';
    setState(() {
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.ACCENT,
            onPrimary: Colors.white,
            surface: Color(0xFF1A2035),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        _darkSnack('Select a category'),
      );
      return;
    }
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        _darkSnack('Select an account'),
      );
      return;
    }

    setState(() => _isLoading = true);
    final tx = TransactionModel(
      id: _isEditing ? widget.transactionId! : const Uuid().v4(),
      amount: double.parse(_amountCtrl.text),
      type: _type,
      categoryId: _selectedCategoryId!,
      accountId: _selectedAccountId!,
      date: _date,
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      createdAt: DateTime.now(),
    );

    final notifier = ref.read(transactionProvider.notifier);
    if (_isEditing) {
      await notifier.updateTransaction(tx);
    } else {
      await notifier.addTransaction(tx);
    }
    ref.read(insightsProvider.notifier).refresh();
    ref.read(accountProvider.notifier).refresh();
    if (mounted) context.pop();
  }

  SnackBar _darkSnack(String msg) => SnackBar(
        backgroundColor: const Color(0xFF1A2035),
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
      );

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.50)),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFFF5252)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFFF5252), width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final categories = categoryRepo.getByType(_type);
    final accounts = ref.watch(accountProvider).accounts;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          _isEditing ? 'Edit Transaction' : 'Add Transaction',
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
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: AppColors.ACCENT,
                fontWeight: FontWeight.w700,
                fontSize: sw * 0.038,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(sw * 0.06, sh * 0.010, sw * 0.06, sh * 0.06),
            children: [
              _TypeSelector(selected: _type, onChanged: (t) {
                setState(() {
                  _type = t;
                  _selectedCategoryId = null;
                });
              }),
              SizedBox(height: sh * 0.024),
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.montserrat(
                  fontSize: sw * 0.060,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                cursorColor: AppColors.ACCENT,
                decoration: _inputDeco('Amount'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              SizedBox(height: sh * 0.020),
              _Label('Category', sw),
              SizedBox(height: sh * 0.010),
              Wrap(
                spacing: sw * 0.022,
                runSpacing: sh * 0.010,
                children: categories.map((c) {
                  final isSelected = c.id == _selectedCategoryId;
                  final color = _hexToColor(c.colorHex);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryId = c.id),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.034, vertical: sh * 0.010),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.20)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(sw * 0.055),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            IconData(c.iconCodePoint,
                                fontFamily: 'MaterialIcons'),
                            size: sw * 0.040,
                            color: isSelected
                                ? color
                                : Colors.white.withValues(alpha: 0.40),
                          ),
                          SizedBox(width: sw * 0.016),
                          Text(
                            c.name,
                            style: GoogleFonts.inter(
                              fontSize: sw * 0.030,
                              color: isSelected
                                  ? color
                                  : Colors.white.withValues(alpha: 0.55),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: sh * 0.020),
              _Label('Account', sw),
              SizedBox(height: sh * 0.010),
              if (accounts.isEmpty)
                Text(
                  'No accounts yet — create one first.',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.40),
                    fontSize: sw * 0.034,
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: accounts.any((a) => a.id == _selectedAccountId)
                      ? _selectedAccountId
                      : null,
                  hint: Text(
                    'Select account',
                    style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  dropdownColor: const Color(0xFF1A2035),
                  style: GoogleFonts.inter(color: Colors.white, fontSize: sw * 0.036),
                  iconEnabledColor: Colors.white.withValues(alpha: 0.50),
                  decoration: _inputDeco(''),
                  items: accounts
                      .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name,
                              style: GoogleFonts.inter(color: Colors.white))))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedAccountId = v),
                ),
              SizedBox(height: sh * 0.020),
              _Label('Date', sw),
              SizedBox(height: sh * 0.010),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.042, vertical: sh * 0.016),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          color: Colors.white.withValues(alpha: 0.45),
                          size: sw * 0.045),
                      SizedBox(width: sw * 0.026),
                      Text(
                        '${_date.day}/${_date.month}/${_date.year}',
                        style: GoogleFonts.inter(
                          fontSize: sw * 0.038,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: sh * 0.020),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                style: GoogleFonts.inter(color: Colors.white, fontSize: sw * 0.036),
                cursorColor: AppColors.ACCENT,
                decoration: _inputDeco('Notes (optional)'),
              ),
              SizedBox(height: sh * 0.036),
              _GradientButton(
                label: _isEditing ? 'Update' : 'Add Transaction',
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

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}

class _TypeSelector extends StatelessWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;
  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(sw * 0.040),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: TransactionType.values.map((t) {
          final isSelected = t == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: sh * 0.012),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [AppColors.PRIMARY, AppColors.ACCENT],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(sw * 0.036),
                ),
                alignment: Alignment.center,
                child: Text(
                  t.name[0].toUpperCase() + t.name.substring(1),
                  style: GoogleFonts.inter(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.40),
                    fontWeight: FontWeight.w600,
                    fontSize: sw * 0.034,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final double sw;
  const _Label(this.text, this.sw);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: sw * 0.032,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.50),
        ),
      );
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
