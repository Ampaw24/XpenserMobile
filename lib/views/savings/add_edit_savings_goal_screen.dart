import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/extensions/color_extensions.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_color_picker.dart';
import 'package:expenser/core/utils/widgets/app_field_label.dart';
import 'package:expenser/core/utils/widgets/app_form_layout.dart';
import 'package:expenser/core/utils/widgets/app_icon_picker.dart';
import 'package:expenser/core/utils/widgets/app_identity_preview.dart';
import 'package:expenser/core/utils/widgets/app_primary_button.dart';
import 'package:expenser/core/utils/widgets/app_tap_field.dart';
import 'package:expenser/core/utils/widgets/app_text_field.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/services/notification/fcm_service.dart';
import 'package:expenser/viewmodels/savings_goal_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
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
  final _savedCtrl = TextEditingController();

  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));
  String _colorHex = 'FF4CAF50';
  int _iconCodePoint = HugeIcons.strokeRoundedSavings.codePoint;
  SavingsGoalModel? _existing;
  bool _isLoading = false;

  bool get _isEditing => widget.goalId != null;

  static const _colors = [
    'FF4CAF50',
    'FF2196F3',
    'FFFF9800',
    'FFE91E63',
    'FF9C27B0',
    'FF00BCD4',
    'FFFF5722',
    'FF607D8B',
  ];

  static const _icons = [
    HugeIcons.strokeRoundedSavings,
    HugeIcons.strokeRoundedHome01,
    HugeIcons.strokeRoundedAirplane01,
    HugeIcons.strokeRoundedCar01,
    HugeIcons.strokeRoundedSchool01,
    HugeIcons.strokeRoundedSmartPhone01,
    HugeIcons.strokeRoundedFavourite,
    HugeIcons.strokeRoundedStar,
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
      _existing = g;
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
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null && mounted) setState(() => _targetDate = picked);
  }

  Future<void> _submit() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final name = _nameCtrl.text.trim();
    final target = double.parse(_targetCtrl.text);
    final saved = double.tryParse(_savedCtrl.text) ?? 0;
    final goal =
        _existing?.copyWith(
          name: name,
          targetAmount: target,
          savedAmount: saved,
          targetDate: _targetDate,
          colorHex: _colorHex,
          iconCodePoint: _iconCodePoint,
        ) ??
        SavingsGoalModel(
          id: const Uuid().v4(),
          name: name,
          targetAmount: target,
          savedAmount: saved,
          targetDate: _targetDate,
          colorHex: _colorHex,
          iconCodePoint: _iconCodePoint,
          createdAt: DateTime.now(),
        );

    try {
      final notifier = ref.read(savingsGoalProvider.notifier);
      if (_isEditing) {
        await notifier.updateGoal(goal);
      } else {
        await notifier.addGoal(goal);
        await ref
            .read(fcmServiceProvider)
            .showLocalNotification(
              title: 'Savings Goal Created',
              body: '"${goal.name}" savings goal has been created.',
              type: 'savings',
              route: '/savings',
            );
      }
      if (mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the goal. Please try again.'),
        ),
      );
    }
  }

  String? _validateTarget(String? value) {
    final target = double.tryParse(value ?? '');
    if (target == null || target <= 0) return 'Enter a target above zero';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = colorFromHex(_colorHex, fallback: palette.accent);
    final icon = _icons.firstWhere(
      (i) => i.codePoint == _iconCodePoint,
      orElse: () => _icons.first,
    );
    final dateLabel = DateFormat.yMMMd().format(_targetDate);
    final amountKeyboard = const TextInputType.numberWithOptions(decimal: true);
    final fieldGap = SizedBox(height: context.rs(16));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Goal' : 'New Savings Goal'),
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(AppIcons.arrowLeft, size: context.rs(22)),
          onPressed: () => context.pop(),
        ),
      ),
      body: AppFormLayout(
        formKey: _formKey,
        action: AppPrimaryButton(
          label: _isEditing ? 'Save Changes' : 'Create Goal',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
        children: [
          AppIdentityPreview(
            icon: icon,
            color: color,
            name: _nameCtrl,
            placeholder: 'Goal name',
            subtitle: 'Target date · $dateLabel',
          ),
          SizedBox(height: context.rs(28)),
          AppTextField(
            controller: _nameCtrl,
            label: 'Goal name',
            hint: 'e.g. New laptop',
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            validator:
                (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Give this goal a name'
                        : null,
          ),
          fieldGap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  controller: _targetCtrl,
                  label: 'Target amount',
                  hint: '0.00',
                  keyboardType: amountKeyboard,
                  inputFormatters: [AppTextField.decimalFormatter],
                  textInputAction: TextInputAction.next,
                  validator: _validateTarget,
                ),
              ),
              SizedBox(width: context.rs(12)),
              Expanded(
                child: AppTextField(
                  controller: _savedCtrl,
                  label: 'Already saved',
                  hint: '0.00',
                  keyboardType: amountKeyboard,
                  inputFormatters: [AppTextField.decimalFormatter],
                ),
              ),
            ],
          ),
          fieldGap,
          AppTapField(
            label: 'Target date',
            value: dateLabel,
            prefixIcon: AppIcons.calendar,
            onTap: _pickDate,
          ),
          SizedBox(height: context.rs(28)),
          const AppFieldLabel('Color'),
          AppColorPicker(
            options: _colors,
            selectedHex: _colorHex,
            onSelected: (hex) => setState(() => _colorHex = hex),
          ),
          SizedBox(height: context.rs(20)),
          const AppFieldLabel('Icon'),
          AppIconPicker(
            options: _icons,
            selectedCodePoint: _iconCodePoint,
            color: color,
            onSelected: (code) => setState(() => _iconCodePoint = code),
          ),
        ],
      ),
    );
  }
}
