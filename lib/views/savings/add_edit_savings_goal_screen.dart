import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/constants/icon_registry.dart';
import 'package:expenser/core/utils/extensions/color_extensions.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_color_picker.dart';
import 'package:expenser/core/utils/widgets/app_feedback_dialog.dart';
import 'package:expenser/core/utils/widgets/app_field_label.dart';
import 'package:expenser/core/utils/widgets/app_form_layout.dart';
import 'package:expenser/core/utils/widgets/app_icon_picker.dart';
import 'package:expenser/core/utils/widgets/app_identity_preview.dart';
import 'package:expenser/core/utils/widgets/app_primary_button.dart';
import 'package:expenser/core/utils/widgets/app_tap_field.dart';
import 'package:expenser/core/utils/widgets/app_text_field.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/recurring_frequency.dart';
import 'package:expenser/models/savings_affordability.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/models/savings_plan.dart';
import 'package:expenser/models/savings_reminder_schedule.dart';
import 'package:expenser/services/notification/fcm_service.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/savings_capacity_viewmodel.dart';
import 'package:expenser/viewmodels/savings_goal_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/savings/widgets/funding_account_picker.dart';
import 'package:expenser/views/savings/widgets/savings_plan_fields.dart';
import 'package:expenser/views/savings/widgets/savings_plan_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final _planAmountCtrl = TextEditingController();

  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));
  String _colorHex = 'FF4CAF50';
  int _iconCodePoint = IconRegistry.defaultSavingsGoal.codePoint;
  RecurringFrequency? _savingsFrequency;
  bool _remindersOn = false;
  DateTime? _reminderAt;
  String? _fundingAccountId;

  /// Amount we last filled in automatically; replaced as the plan changes
  /// until the user types their own.
  String? _autoFilledAmount;
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
    _planAmountCtrl.text = g.contributionAmount?.toStringAsFixed(2) ?? '';
    setState(() {
      _existing = g;
      _targetDate = g.targetDate;
      _colorHex = g.colorHex;
      _iconCodePoint = g.iconCodePoint;
      _savingsFrequency = g.savingsFrequency;
      _remindersOn = g.reminderAt != null;
      _reminderAt = g.reminderAt;
      _fundingAccountId = g.fundingAccountId;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _savedCtrl.dispose();
    _planAmountCtrl.dispose();
    super.dispose();
  }

  void _onFrequencyChanged(RecurringFrequency? frequency) {
    _savingsFrequency = frequency;
    _onPlanInputsChanged();
  }

  void _onRemindersChanged(bool on) {
    _remindersOn = on;
    if (on) _reminderAt ??= _defaultReminderStart(DateTime.now());
    _onPlanInputsChanged();
  }

  /// Rebuilds the plan and keeps an auto-filled amount at its minimum.
  void _onPlanInputsChanged() {
    final plan = _plan(DateTime.now());
    final typed = _planAmountCtrl.text.trim();
    if (plan != null && (typed.isEmpty || typed == _autoFilledAmount)) {
      final suggested = plan.perPayment.toStringAsFixed(2);
      _planAmountCtrl.text = suggested;
      _autoFilledAmount = suggested;
    }
    setState(() {});
  }

  SavingsPlan? _plan(DateTime now) {
    final frequency = _savingsFrequency;
    final target = double.tryParse(_targetCtrl.text);
    if (frequency == null || target == null || target <= 0) return null;
    final lastPaid = _existing?.lastContributionAt;
    return savingsPlan(
      frequency: frequency,
      targetAmount: target,
      savedAmount: double.tryParse(_savedCtrl.text) ?? 0,
      targetDate: _targetDate,
      now: now,
      startAt: _remindersOn ? _reminderAt : null,
      paidThisPeriod:
          lastPaid != null && isSameSavingsPeriod(frequency, lastPaid, now),
    );
  }

  /// Next 9:00 AM, a sensible first nudge before the day's spending.
  static DateTime _defaultReminderStart(DateTime now) {
    final today = DateTime(now.year, now.month, now.day, 9);
    return today.isAfter(now) ? today : today.add(const Duration(days: 1));
  }

  Future<void> _pickReminderStart() async {
    FocusScope.of(context).unfocus();
    final current = _reminderAt ?? _defaultReminderStart(DateTime.now());
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current.isBefore(now) ? now : current,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'First reminder',
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;
    _reminderAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    _onPlanInputsChanged();
  }

  Future<void> _pickFundingAccount(List<AccountModel> eligible) async {
    FocusScope.of(context).unfocus();
    if (eligible.isEmpty) {
      context.push('/accounts/add');
      return;
    }
    final id = await pickFundingAccount(
      context,
      eligible: eligible,
      selectedId: _fundingAccountId,
    );
    if (id != null && mounted) setState(() => _fundingAccountId = id);
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked == null || !mounted) return;
    _targetDate = picked;
    _onPlanInputsChanged();
  }

  Future<void> _submit() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final name = _nameCtrl.text.trim();
    final target = double.parse(_targetCtrl.text);
    final saved = double.tryParse(_savedCtrl.text) ?? 0;
    final existing = _existing;
    final frequency = _savingsFrequency;
    final goal = SavingsGoalModel(
      id: existing?.id ?? const Uuid().v4(),
      name: name,
      targetAmount: target,
      savedAmount: saved,
      targetDate: _targetDate,
      colorHex: _colorHex,
      iconCodePoint: _iconCodePoint,
      createdAt: existing?.createdAt ?? DateTime.now(),
      contributionAmount: double.tryParse(_planAmountCtrl.text.trim()),
      savingsFrequency: frequency,
      reminderAt: frequency != null && _remindersOn ? _reminderAt : null,
      lastContributionAt: existing?.lastContributionAt,
      fundingAccountId: _fundingAccountId,
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
      AppDialogs.showError(
        context,
        title: 'Could Not Save Goal',
        message:
            'An error occurred while saving the savings goal. Please try again.',
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
    final icon = IconRegistry.savingsGoal(_iconCodePoint);
    final dateLabel = DateFormat.yMMMd().format(_targetDate);
    final amountKeyboard = const TextInputType.numberWithOptions(decimal: true);
    final fieldGap = SizedBox(height: context.rs(16));
    final currency = ref.watch(
      settingsProvider.select((s) => s.preferredCurrency),
    );
    final notificationsEnabled = ref.watch(
      settingsProvider.select((s) => s.notificationsEnabled),
    );
    final eligibleAccounts = savingsFundingAccounts(
      ref.watch(accountProvider).accounts,
      currency,
    );
    final fundingAccountName =
        eligibleAccounts
            .where((a) => a.id == _fundingAccountId)
            .firstOrNull
            ?.name;
    final now = DateTime.now();
    final plan = _plan(now);
    final capacity = ref.watch(savingsCapacityProvider(widget.goalId));
    final target = double.tryParse(_targetCtrl.text) ?? 0;
    final planSummary =
        _savingsFrequency == null || target <= 0
            ? null
            : SavingsPlanSummary(
              plan: plan,
              affordability:
                  plan == null ? null : assessSavingsPlan(plan, capacity, now),
              currency: currency,
              targetDate: _targetDate,
              isReached: (double.tryParse(_savedCtrl.text) ?? 0) >= target,
            );

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
                  onChanged: (_) => _onPlanInputsChanged(),
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
                  onChanged: (_) => _onPlanInputsChanged(),
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
            options: IconRegistry.savingsGoalOptions,
            selectedCodePoint: _iconCodePoint,
            color: color,
            onSelected: (code) => setState(() => _iconCodePoint = code),
          ),
          SizedBox(height: context.rs(28)),
          SavingsPlanFields(
            amountController: _planAmountCtrl,
            frequency: _savingsFrequency,
            minimumAmount: plan?.perPayment,
            currency: currency,
            summary: planSummary,
            remindersOn: _remindersOn,
            reminderAt: _reminderAt,
            accountName: fundingAccountName,
            notificationsEnabled: notificationsEnabled,
            onFrequencyChanged: _onFrequencyChanged,
            onRemindersChanged: _onRemindersChanged,
            onPickReminderStart: _pickReminderStart,
            onPickAccount: () => _pickFundingAccount(eligibleAccounts),
          ),
        ],
      ),
    );
  }
}
