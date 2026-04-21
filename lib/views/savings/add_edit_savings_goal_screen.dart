import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/viewmodels/savings_goal_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class AddEditSavingsGoalScreen extends ConsumerStatefulWidget {
  final String? goalId;
  const AddEditSavingsGoalScreen({super.key, this.goalId});

  @override
  ConsumerState<AddEditSavingsGoalScreen> createState() =>
      _AddEditSavingsGoalScreenState();
}

class _AddEditSavingsGoalScreenState
    extends ConsumerState<AddEditSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _savedCtrl = TextEditingController(text: '0');

  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));
  String _colorHex = 'FF4CAF50';
  int _iconCodePoint = Icons.savings_rounded.codePoint;
  bool _isLoading = false;

  bool get _isEditing => widget.goalId != null;

  static const _colors = [
    'FF4CAF50', 'FF2196F3', 'FFFF9800', 'FFE91E63',
    'FF9C27B0', 'FF00BCD4', 'FFFF5722', 'FF607D8B',
  ];

  static const _icons = [
    Icons.savings_rounded, Icons.home_rounded, Icons.flight_rounded,
    Icons.directions_car_rounded, Icons.school_rounded,
    Icons.phone_iphone_rounded, Icons.favorite_rounded, Icons.star_rounded,
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  void _loadExisting() {
    final goals = ref.read(savingsGoalProvider);
    final g = goals.firstWhere((g) => g.id == widget.goalId);
    _nameCtrl.text = g.name;
    _targetCtrl.text = g.targetAmount.toStringAsFixed(2);
    _savedCtrl.text = g.savedAmount.toStringAsFixed(2);
    setState(() {
      _targetDate = g.targetDate;
      _colorHex = g.colorHex;
      _iconCodePoint = g.iconCodePoint;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _savedCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
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
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final goal = SavingsGoalModel(
      id: _isEditing ? widget.goalId! : const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      targetAmount: double.parse(_targetCtrl.text),
      savedAmount: double.tryParse(_savedCtrl.text) ?? 0,
      targetDate: _targetDate,
      colorHex: _colorHex,
      iconCodePoint: _iconCodePoint,
      createdAt: DateTime.now(),
    );
    final notifier = ref.read(savingsGoalProvider.notifier);
    if (_isEditing) {
      await notifier.updateGoal(goal);
    } else {
      await notifier.addGoal(goal);
    }
    if (mounted) context.pop();
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.50)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.ACCENT, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          _isEditing ? 'Edit Goal' : 'New Savings Goal',
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
              TextFormField(
                controller: _nameCtrl,
                style: GoogleFonts.inter(color: Colors.white, fontSize: sw * 0.038),
                cursorColor: AppColors.ACCENT,
                decoration: _inputDeco('Goal Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name required' : null,
              ),
              SizedBox(height: sh * 0.018),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.inter(
                          color: Colors.white, fontSize: sw * 0.038),
                      cursorColor: AppColors.ACCENT,
                      decoration: _inputDeco('Target Amount'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: sw * 0.030),
                  Expanded(
                    child: TextFormField(
                      controller: _savedCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.inter(
                          color: Colors.white, fontSize: sw * 0.038),
                      cursorColor: AppColors.ACCENT,
                      decoration: _inputDeco('Already Saved'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.018),
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
                        'Target: ${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                        style: GoogleFonts.inter(
                          fontSize: sw * 0.036,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: sh * 0.024),
              Text(
                'Color',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: sw * 0.032,
                  color: Colors.white.withValues(alpha: 0.50),
                ),
              ),
              SizedBox(height: sh * 0.012),
              Wrap(
                spacing: sw * 0.030,
                runSpacing: sh * 0.012,
                children: _colors.map((hex) {
                  final color = Color(int.parse(hex, radix: 16));
                  final isSelected = _colorHex == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _colorHex = hex),
                    child: Container(
                      width: sw * 0.090,
                      height: sw * 0.090,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: color.withValues(alpha: 0.55),
                                    blurRadius: 10)
                              ]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: sh * 0.024),
              Text(
                'Icon',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: sw * 0.032,
                  color: Colors.white.withValues(alpha: 0.50),
                ),
              ),
              SizedBox(height: sh * 0.012),
              Wrap(
                spacing: sw * 0.030,
                runSpacing: sh * 0.012,
                children: _icons.map((icon) {
                  final isSelected = icon.codePoint == _iconCodePoint;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _iconCodePoint = icon.codePoint),
                    child: Container(
                      width: sw * 0.120,
                      height: sw * 0.120,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.ACCENT.withValues(alpha: 0.20)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(sw * 0.030),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.ACCENT
                              : Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? AppColors.ACCENT
                            : Colors.white.withValues(alpha: 0.40),
                        size: sw * 0.058,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: sh * 0.036),
              _GradientButton(
                label: _isEditing ? 'Update Goal' : 'Create Goal',
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
