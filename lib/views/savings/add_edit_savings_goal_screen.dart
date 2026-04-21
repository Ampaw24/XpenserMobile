import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/viewmodels/savings_goal_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    Icons.directions_car_rounded, Icons.school_rounded, Icons.phone_iphone_rounded,
    Icons.favorite_rounded, Icons.star_rounded,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Goal' : 'New Savings Goal'),
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
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Goal Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.PRIMARY),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _targetCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Target Amount',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.PRIMARY),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _savedCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Already Saved',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.PRIMARY),
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_rounded, color: Colors.grey, size: 18),
                    const SizedBox(width: 10),
                    Text('Target: ${_targetDate.day}/${_targetDate.month}/${_targetDate.year}'),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Color', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: _colors.map((hex) {
                  final color = Color(int.parse(hex, radix: 16));
                  return GestureDetector(
                    onTap: () => setState(() => _colorHex = hex),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _colorHex == hex ? Border.all(color: Colors.black, width: 3) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: _icons.map((icon) {
                  final isSelected = icon.codePoint == _iconCodePoint;
                  return GestureDetector(
                    onTap: () => setState(() => _iconCodePoint = icon.codePoint),
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.PRIMARY.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected ? Border.all(color: AppColors.PRIMARY) : null,
                      ),
                      child: Icon(icon, color: isSelected ? AppColors.PRIMARY : Colors.grey[600]),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.PRIMARY,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'Update Goal' : 'Create Goal',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
