import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/theme/input_decorations.dart';
import 'package:expenser/core/utils/widgets/app_field_label.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/core/utils/widgets/app_text_field.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/core/utils/formatters/date_labels.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/budget_period.dart';
import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/core/utils/widgets/app_primary_button.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// ─── Wizard state holder ─────────────────────────────────────────────────────

class _WizardState {
  BudgetPeriodType period = BudgetPeriodType.monthly;
  DateTime? customStart;
  DateTime? customEnd;
  double totalAmount = 0;
  String? accountId;
  List<String> selectedCategoryIds = [];
  Map<String, double> allocations = {};
  String notes = '';
  double alertThreshold = 0.8;

  /// Set when editing, so an unchanged fixed period keeps its dates.
  BudgetPeriodType? originalPeriod;
  BudgetDateRange? originalRange;

  _WizardState();

  _WizardState.fromPlan(BudgetPlan plan) {
    period = plan.period;
    originalPeriod = plan.period;
    originalRange = plan.range;
    if (plan.period == BudgetPeriodType.custom) {
      customStart = plan.range.start;
      customEnd = plan.range.end;
    }
    accountId = plan.accountId;
    selectedCategoryIds = [for (final b in plan.allocations) b.categoryId];
    allocations = {
      for (final b in plan.allocations) b.categoryId: b.limitAmount,
    };
    totalAmount = plan.totalLimit;
    notes = plan.notes ?? '';
    alertThreshold = plan.alertThreshold;
  }

  /// Dates the budget will cover, or null while custom dates are incomplete.
  BudgetDateRange? get range {
    if (period == BudgetPeriodType.custom) {
      if (customStart == null || customEnd == null) return null;
      final custom = BudgetDateRange(customStart!, customEnd!);
      return custom.isValid ? custom : null;
    }
    if (period == originalPeriod && originalRange != null) {
      return originalRange;
    }
    return BudgetDateRange.forPeriod(
      period,
      originalRange?.start ?? DateTime.now(),
    );
  }

  double get allocatedTotal => allocations.values.fold(0, (sum, v) => sum + v);

  double get remaining => totalAmount - allocatedTotal;
}

// ─── Main wizard widget ──────────────────────────────────────────────────────

class CreateBudgetWizard extends ConsumerStatefulWidget {
  const CreateBudgetWizard({super.key, this.planId});

  /// Edits this plan when set; otherwise creates a new one.
  final String? planId;

  @override
  ConsumerState<CreateBudgetWizard> createState() => _CreateBudgetWizardState();
}

class _CreateBudgetWizardState extends ConsumerState<CreateBudgetWizard>
    with SingleTickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _step = 0;
  static const int _totalSteps = 6;
  late final _WizardState _wizard;
  bool _isSubmitting = false;

  bool get _isEditing => widget.planId != null;

  late AnimationController _successCtrl;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    final existing =
        _isEditing ? ref.read(budgetProvider).planById(widget.planId!) : null;
    _wizard =
        existing != null ? _WizardState.fromPlan(existing) : _WizardState();
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = CurvedAnimation(
      parent: _successCtrl,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prev() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    final range = _wizard.range;
    if (range == null) return;
    setState(() => _isSubmitting = true);
    final now = DateTime.now();
    final planId = widget.planId ?? const Uuid().v4();
    final notes = _wizard.notes.trim();

    final budgets = [
      for (final catId in _wizard.selectedCategoryIds)
        BudgetModel(
          id: const Uuid().v4(),
          categoryId: catId,
          limitAmount: _wizard.allocations[catId] ?? 0,
          month: range.start.month,
          year: range.start.year,
          alertThreshold: _wizard.alertThreshold,
          createdAt: now,
          accountId: _wizard.accountId,
          period: _wizard.period.value,
          planId: planId,
          notes: notes.isEmpty ? null : notes,
          startDate: range.start,
          endDate: range.end,
        ),
    ];

    await ref.read(budgetProvider.notifier).savePlan(planId, budgets);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (_isEditing) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Budget updated')));
      context.pop();
      return;
    }
    _next(); // go to success step
    _successCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandWatermarkBackground(
        child: SafeArea(
          child: Column(
            children: [
              _WizardHeader(
                isEditing: _isEditing,
                step: _step,
                totalSteps: _totalSteps - 1,
                onBack: _prev,
              ),
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StepPeriod(
                      wizard: _wizard,
                      onNext: _next,
                      onChanged: () => setState(() {}),
                    ),
                    _StepTotalBudget(
                      wizard: _wizard,
                      onNext: _next,
                      onChanged: () => setState(() {}),
                    ),
                    _StepCategories(
                      wizard: _wizard,
                      onNext: _next,
                      onChanged: () => setState(() {}),
                    ),
                    _StepAllocate(
                      wizard: _wizard,
                      onNext: _next,
                      onChanged: () => setState(() {}),
                    ),
                    _StepReviewNotes(
                      wizard: _wizard,
                      isEditing: _isEditing,
                      isSubmitting: _isSubmitting,
                      onSubmit: _submit,
                      onChanged: () => setState(() {}),
                    ),
                    _StepSuccess(wizard: _wizard, scaleAnim: _successScale),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared layout helpers ───────────────────────────────────────────────────

EdgeInsets _stepPadding(BuildContext context) => EdgeInsets.symmetric(
  horizontal: context.contentGutter,
  vertical: context.rs(16),
);

/// Fill + border for a selectable tile, tinted with [color] when selected.
BoxDecoration _selectableDecoration(
  BuildContext context, {
  required bool selected,
  required Color color,
}) {
  final palette = context.palette;
  return BoxDecoration(
    color: selected ? color.withValues(alpha: 0.12) : palette.surface,
    borderRadius: BorderRadius.circular(context.rs(16)),
    border: Border.all(
      color: selected ? color : palette.border,
      width: selected ? 1.5 : 1,
    ),
  );
}

class _StepHint extends StatelessWidget {
  final String text;
  const _StepHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: context.rs(13),
        color: context.palette.textSecondary,
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final CategoryModel category;
  final Color color;
  final double diameter;

  const _CategoryIcon({
    required this.category,
    required this.color,
    required this.diameter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Icon(
        IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
        color: color,
        size: diameter * 0.5,
      ),
    );
  }
}

/// Accent-tinted pressable pill (quick-add chips, "Distribute Evenly").
class _AccentTintButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _AccentTintButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(context.rs(12));
    return Material(
      color: palette.accent.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: palette.accent.withValues(alpha: 0.30)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.rs(14),
            vertical: context.rs(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: palette.accent, size: context.rs(14)),
                SizedBox(width: context.rs(6)),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: context.rs(13),
                  color: palette.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header with progress bar ─────────────────────────────────────────────────

class _WizardHeader extends StatelessWidget {
  final bool isEditing;
  final int step;
  final int totalSteps;
  final VoidCallback onBack;

  const _WizardHeader({
    required this.isEditing,
    required this.step,
    required this.totalSteps,
    required this.onBack,
  });

  static const _labels = [
    'Choose Period',
    'Set Total Budget',
    'Choose Categories',
    'Allocate Amounts',
    'Review & Notes',
  ];

  @override
  Widget build(BuildContext context) {
    if (step >= totalSteps) return const SizedBox.shrink();
    final palette = context.palette;
    final progress = (step + 1) / totalSteps;
    final gutter = context.contentGutter;

    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, context.rs(12), gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: palette.surfaceMuted,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onBack,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(context.rs(9)),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: palette.textPrimary,
                      size: context.rs(16),
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.rs(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isEditing ? 'Edit' : 'New'} Budget  '
                      '${step + 1}/$totalSteps',
                      style: TextStyle(
                        fontSize: context.rs(11),
                        color: palette.textMuted,
                      ),
                    ),
                    SizedBox(height: context.rs(2)),
                    Text(
                      _labels[step.clamp(0, _labels.length - 1)],
                      style: TextStyle(
                        fontSize: context.rs(17),
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.rs(12)),
          ClipRRect(
            borderRadius: BorderRadius.circular(context.rs(4)),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: context.rs(4),
            ),
          ),
          SizedBox(height: context.rs(8)),
        ],
      ),
    );
  }
}

// ─── Step 1: Choose Period ────────────────────────────────────────────────────

class _StepPeriod extends StatefulWidget {
  final _WizardState wizard;
  final VoidCallback onNext;
  final VoidCallback onChanged;

  const _StepPeriod({
    required this.wizard,
    required this.onNext,
    required this.onChanged,
  });

  @override
  State<_StepPeriod> createState() => _StepPeriodState();
}

class _StepPeriodState extends State<_StepPeriod> {
  void _update(VoidCallback change) {
    setState(change);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final wizard = widget.wizard;
    final range = wizard.range;
    return ListView(
      padding: _stepPadding(context),
      children: [
        const _StepHint('Choose a period for your budget'),
        SizedBox(height: context.rs(20)),
        ...BudgetPeriodType.values.map(
          (p) => _PeriodTile(
            period: p,
            icon: _periodIcon(p),
            isSelected: wizard.period == p,
            subtitle:
                wizard.period == p && range != null
                    ? dateRangeLabel(range.start, range.end)
                    : null,
            onTap: () => _update(() => wizard.period = p),
          ),
        ),
        if (wizard.period == BudgetPeriodType.custom) ...[
          SizedBox(height: context.rs(6)),
          _DateRangePicker(wizard: wizard, onChanged: () => _update(() {})),
        ],
        SizedBox(height: context.rs(32)),
        AppPrimaryButton(
          label: 'Continue',
          onPressed: range == null ? null : widget.onNext,
        ),
      ],
    );
  }

  IconData _periodIcon(BudgetPeriodType p) {
    switch (p) {
      case BudgetPeriodType.monthly:
        return Icons.calendar_month_rounded;
      case BudgetPeriodType.quarterly:
        return Icons.date_range_rounded;
      case BudgetPeriodType.semiAnnual:
        return Icons.calendar_view_month_rounded;
      case BudgetPeriodType.annual:
        return Icons.auto_awesome_mosaic_rounded;
      case BudgetPeriodType.custom:
        return Icons.tune_rounded;
    }
  }
}

class _PeriodTile extends StatelessWidget {
  final BudgetPeriodType period;
  final IconData icon;
  final bool isSelected;
  final String? subtitle;
  final VoidCallback onTap;

  const _PeriodTile({
    required this.period,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: context.rs(12)),
        padding: EdgeInsets.symmetric(
          horizontal: context.rs(18),
          vertical: context.rs(18),
        ),
        decoration: _selectableDecoration(
          context,
          selected: isSelected,
          color: palette.accent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? palette.accent : palette.textMuted,
              size: context.rs(20),
            ),
            SizedBox(width: context.rs(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    period.label,
                    style: TextStyle(
                      fontSize: context.rs(15),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isSelected
                              ? palette.textPrimary
                              : palette.textSecondary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: context.rs(12),
                        color: palette.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: context.rs(20),
                height: context.rs(20),
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: palette.onAccent,
                  size: context.rs(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangePicker extends StatelessWidget {
  final _WizardState wizard;
  final VoidCallback onChanged;
  const _DateRangePicker({required this.wizard, required this.onChanged});

  Future<void> _pick(BuildContext context, {required bool isStart}) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5);
    final lastDate = DateTime(now.year + 5, 12, 31);
    final start = wizard.customStart;
    final current = isStart ? start : wizard.customEnd;
    final earliest = isStart || start == null ? firstDate : start;
    var initial = current ?? (isStart ? now : (start ?? now));
    if (initial.isBefore(earliest)) initial = earliest;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: earliest,
      lastDate: lastDate,
    );
    if (picked == null) return;
    if (isStart) {
      wizard.customStart = picked;
      final end = wizard.customEnd;
      if (end != null && end.isBefore(picked)) wizard.customEnd = null;
    } else {
      wizard.customEnd = picked;
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    return Row(
      children: [
        Expanded(
          child: _DateChip(
            label:
                wizard.customStart != null
                    ? fmt.format(wizard.customStart!)
                    : 'Start date',
            onTap: () => _pick(context, isStart: true),
          ),
        ),
        SizedBox(width: context.rs(10)),
        Expanded(
          child: _DateChip(
            label:
                wizard.customEnd != null
                    ? fmt.format(wizard.customEnd!)
                    : 'End date',
            onTap: () => _pick(context, isStart: false),
          ),
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppSurfaceCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(14),
        vertical: context.rs(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            color: palette.accent,
            size: context.rs(15),
          ),
          SizedBox(width: context.rs(8)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: context.rs(12),
                color: palette.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Set Total Budget ─────────────────────────────────────────────────

class _StepTotalBudget extends ConsumerStatefulWidget {
  final _WizardState wizard;
  final VoidCallback onNext;
  final VoidCallback onChanged;

  const _StepTotalBudget({
    required this.wizard,
    required this.onNext,
    required this.onChanged,
  });

  @override
  ConsumerState<_StepTotalBudget> createState() => _StepTotalBudgetState();
}

class _StepTotalBudgetState extends ConsumerState<_StepTotalBudget> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.wizard.totalAmount > 0) {
      _ctrl.text = widget.wizard.totalAmount.toStringAsFixed(2);
    }
    if (widget.wizard.accountId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final accounts = ref.read(accountProvider).accounts;
        if (accounts.isNotEmpty) {
          setState(() => widget.wizard.accountId = accounts.first.id);
        }
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _validate() {
    final v = double.tryParse(_ctrl.text);
    if (v == null || v <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    setState(() {
      widget.wizard.totalAmount = v;
      _error = null;
    });
    widget.onChanged();
    widget.onNext();
  }

  void _quickAdd(double amount) {
    final current = double.tryParse(_ctrl.text) ?? 0;
    final next = current + amount;
    _ctrl.text = next.toStringAsFixed(2);
    widget.wizard.totalAmount = next;
    widget.onChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accounts = ref.watch(accountProvider).accounts;
    final selectedAccount =
        accounts.isEmpty
            ? null
            : accounts.firstWhere(
              (a) => a.id == widget.wizard.accountId,
              orElse: () => accounts.first,
            );
    final amountStyle = TextStyle(
      fontSize: context.rs(28),
      fontWeight: FontWeight.w700,
      color: palette.textPrimary,
    );

    return ListView(
      padding: _stepPadding(context),
      children: [
        const _StepHint('Enter the total amount you want to budget'),
        SizedBox(height: context.rs(24)),
        AppSurfaceCard(
          borderColor: _error != null ? palette.danger : null,
          padding: EdgeInsets.symmetric(
            horizontal: context.rs(18),
            vertical: context.rs(22),
          ),
          child: Column(
            children: [
              Text(
                selectedAccount?.currencyCode ??
                    ref.read(settingsProvider).preferredCurrency,
                style: TextStyle(
                  fontSize: context.rs(13),
                  color: palette.textMuted,
                ),
              ),
              SizedBox(height: context.rs(8)),
              TextField(
                controller: _ctrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                style: amountStyle,
                decoration: bareInputDecoration(
                  hintText: '0.00',
                  hintStyle: amountStyle.copyWith(color: palette.textMuted),
                ),
                onChanged: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null) {
                    widget.wizard.totalAmount = parsed;
                    widget.onChanged();
                  }
                },
              ),
              if (_error != null) ...[
                SizedBox(height: context.rs(8)),
                Text(
                  _error!,
                  style: TextStyle(
                    fontSize: context.rs(11),
                    color: palette.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: context.rs(14)),
        Wrap(
          spacing: context.rs(10),
          runSpacing: context.rs(10),
          children:
              [100.0, 500.0, 1000.0]
                  .map(
                    (v) => _AccentTintButton(
                      label: '+${v.toInt()}',
                      onTap: () => _quickAdd(v),
                    ),
                  )
                  .toList(),
        ),
        SizedBox(height: context.rs(24)),
        const AppFieldLabel('Budget account'),
        if (accounts.isEmpty)
          Text(
            'No accounts found. Create one first.',
            style: TextStyle(
              fontSize: context.rs(13),
              color: palette.textMuted,
            ),
          )
        else
          SizedBox(
            height: context.rs(100),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: accounts.length,
              separatorBuilder: (_, __) => SizedBox(width: context.rs(10)),
              itemBuilder: (ctx, i) {
                final acc = accounts[i];
                return _AccountOption(
                  name: acc.name,
                  currencyCode: acc.currencyCode,
                  iconCodePoint: acc.iconCodePoint,
                  color: Color(int.parse(acc.colorHex, radix: 16)),
                  isSelected: widget.wizard.accountId == acc.id,
                  onTap: () {
                    setState(() => widget.wizard.accountId = acc.id);
                    widget.onChanged();
                  },
                );
              },
            ),
          ),
        SizedBox(height: context.rs(32)),
        AppPrimaryButton(label: 'Continue', onPressed: _validate),
      ],
    );
  }
}

class _AccountOption extends StatelessWidget {
  final String name;
  final String currencyCode;
  final int iconCodePoint;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountOption({
    required this.name,
    required this.currencyCode,
    required this.iconCodePoint,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: context.rs(140),
        padding: EdgeInsets.all(context.rs(14)),
        decoration: _selectableDecoration(
          context,
          selected: isSelected,
          color: color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
              color: isSelected ? color : palette.textMuted,
              size: context.rs(18),
            ),
            SizedBox(height: context.rs(6)),
            Text(
              name,
              maxLines: 1,
              style: TextStyle(
                fontSize: context.rs(12),
                fontWeight: FontWeight.w600,
                color: isSelected ? palette.textPrimary : palette.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              currencyCode,
              maxLines: 1,
              style: TextStyle(
                fontSize: context.rs(11),
                color: isSelected ? color : palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 3: Choose Categories ────────────────────────────────────────────────

class _StepCategories extends ConsumerWidget {
  final _WizardState wizard;
  final VoidCallback onNext;
  final VoidCallback onChanged;

  const _StepCategories({
    required this.wizard,
    required this.onNext,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref
        .read(categoryRepositoryProvider)
        .getByType(TransactionType.expense);

    return StatefulBuilder(
      builder: (ctx, localSet) {
        return ListView(
          padding: _stepPadding(context),
          children: [
            const _StepHint('Select categories to include in your budget'),
            SizedBox(height: context.rs(20)),
            ...categories.map((c) {
              final isSelected = wizard.selectedCategoryIds.contains(c.id);
              return _CategoryOption(
                category: c,
                color: Color(int.parse(c.colorHex, radix: 16)),
                isSelected: isSelected,
                onTap: () {
                  localSet(() {
                    if (isSelected) {
                      wizard.selectedCategoryIds = List.from(
                        wizard.selectedCategoryIds,
                      )..remove(c.id);
                      wizard.allocations = Map.from(wizard.allocations)
                        ..remove(c.id);
                    } else {
                      wizard.selectedCategoryIds = [
                        ...wizard.selectedCategoryIds,
                        c.id,
                      ];
                    }
                  });
                  onChanged();
                },
              );
            }),
            SizedBox(height: context.rs(28)),
            AppPrimaryButton(
              label: 'Continue (${wizard.selectedCategoryIds.length} selected)',
              onPressed: wizard.selectedCategoryIds.isEmpty ? null : onNext,
            ),
          ],
        );
      },
    );
  }
}

class _CategoryOption extends StatelessWidget {
  final CategoryModel category;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryOption({
    required this.category,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: context.rs(10)),
        padding: EdgeInsets.symmetric(
          horizontal: context.rs(16),
          vertical: context.rs(14),
        ),
        decoration: _selectableDecoration(
          context,
          selected: isSelected,
          color: color,
        ),
        child: Row(
          children: [
            _CategoryIcon(
              category: category,
              color: color,
              diameter: context.rs(36),
            ),
            SizedBox(width: context.rs(14)),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: context.rs(14),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected ? palette.textPrimary : palette.textSecondary,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: context.rs(20),
              height: context.rs(20),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? color : palette.border),
              ),
              // White check sits on the data-driven category color.
              child:
                  isSelected
                      ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: context.rs(12),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 4: Allocate Amounts ─────────────────────────────────────────────────

class _StepAllocate extends ConsumerStatefulWidget {
  final _WizardState wizard;
  final VoidCallback onNext;
  final VoidCallback onChanged;

  const _StepAllocate({
    required this.wizard,
    required this.onNext,
    required this.onChanged,
  });

  @override
  ConsumerState<_StepAllocate> createState() => _StepAllocateState();
}

class _StepAllocateState extends ConsumerState<_StepAllocate> {
  final Map<String, TextEditingController> _ctrls = {};

  @override
  void initState() {
    super.initState();
    for (final id in widget.wizard.selectedCategoryIds) {
      final existing = widget.wizard.allocations[id];
      _ctrls[id] = TextEditingController(
        text: existing != null ? existing.toStringAsFixed(2) : '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _distributeEvenly() {
    if (widget.wizard.selectedCategoryIds.isEmpty) return;
    final each =
        widget.wizard.totalAmount / widget.wizard.selectedCategoryIds.length;
    for (final id in widget.wizard.selectedCategoryIds) {
      _ctrls[id]?.text = each.toStringAsFixed(2);
      widget.wizard.allocations = {...widget.wizard.allocations, id: each};
    }
    widget.onChanged();
    setState(() {});
  }

  bool get _isValid {
    final allFilled = widget.wizard.selectedCategoryIds.every(
      (id) => (widget.wizard.allocations[id] ?? 0) > 0,
    );
    return allFilled &&
        widget.wizard.allocatedTotal <= widget.wizard.totalAmount + 0.01;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final remaining = widget.wizard.remaining;
    final overBudget = remaining < -0.01;
    final remainingColor =
        overBudget
            ? palette.danger
            : remaining < widget.wizard.totalAmount * 0.1
            ? palette.warning
            : palette.accent;

    return ListView(
      padding: _stepPadding(context),
      children: [
        const _StepHint('Enter amount for each category'),
        SizedBox(height: context.rs(14)),
        AppSurfaceCard(
          padding: EdgeInsets.symmetric(
            horizontal: context.rs(16),
            vertical: context.rs(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(
                label: 'Total',
                value: widget.wizard.totalAmount,
                color: palette.textPrimary,
              ),
              _SummaryItem(
                label: 'Allocated',
                value: widget.wizard.allocatedTotal,
                color: palette.accent,
              ),
              _SummaryItem(
                label: overBudget ? 'Over' : 'Remaining',
                value: remaining.abs(),
                color: remainingColor,
              ),
            ],
          ),
        ),
        SizedBox(height: context.rs(10)),
        _AccentTintButton(
          label: 'Distribute Evenly',
          icon: Icons.auto_fix_high_rounded,
          onTap: _distributeEvenly,
        ),
        SizedBox(height: context.rs(16)),
        ...widget.wizard.selectedCategoryIds.map((id) {
          final cat = categoryRepo.getById(id);
          if (cat == null) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(bottom: context.rs(12)),
            child: _AllocationRow(
              category: cat,
              color: Color(int.parse(cat.colorHex, radix: 16)),
              controller: _ctrls[id]!,
              onChanged: (v) {
                final parsed = double.tryParse(v) ?? 0;
                widget.wizard.allocations = {
                  ...widget.wizard.allocations,
                  id: parsed,
                };
                widget.onChanged();
                setState(() {});
              },
            ),
          );
        }),
        SizedBox(height: context.rs(28)),
        AppPrimaryButton(
          label: 'Continue',
          onPressed: _isValid ? widget.onNext : null,
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: context.rs(11),
            color: context.palette.textMuted,
          ),
        ),
        SizedBox(height: context.rs(4)),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontSize: context.rs(14),
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _AllocationRow extends StatelessWidget {
  final CategoryModel category;
  final Color color;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _AllocationRow({
    required this.category,
    required this.color,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppSurfaceCard(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(16),
        vertical: context.rs(12),
      ),
      child: Row(
        children: [
          _CategoryIcon(
            category: category,
            color: color,
            diameter: context.rs(32),
          ),
          SizedBox(width: context.rs(12)),
          Expanded(
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: context.rs(13),
                color: palette.textPrimary,
              ),
            ),
          ),
          SizedBox(width: context.rs(8)),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.rs(110)),
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: context.rs(14),
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
                decoration: bareInputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    fontSize: context.rs(13),
                    color: palette.textMuted,
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 5: Review + Notes ───────────────────────────────────────────────────

class _StepReviewNotes extends ConsumerStatefulWidget {
  final _WizardState wizard;
  final bool isEditing;
  final bool isSubmitting;
  final Future<void> Function() onSubmit;
  final VoidCallback onChanged;

  const _StepReviewNotes({
    required this.wizard,
    required this.isEditing,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onChanged,
  });

  @override
  ConsumerState<_StepReviewNotes> createState() => _StepReviewNotesState();
}

class _StepReviewNotesState extends ConsumerState<_StepReviewNotes> {
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesCtrl.text = widget.wizard.notes;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.read(accountProvider);
    final account =
        widget.wizard.accountId != null
            ? accountState.accounts
                .where((a) => a.id == widget.wizard.accountId)
                .firstOrNull
            : null;

    return ListView(
      padding: _stepPadding(context),
      children: [
        const _StepHint('Review your budget before saving'),
        SizedBox(height: context.rs(16)),
        _ReviewSummaryCard(
          wizard: widget.wizard,
          currencyCode:
              account?.currencyCode ??
              ref.read(settingsProvider).preferredCurrency,
          accountName: account?.name,
          periodLabel: '${widget.wizard.period.label} Budget',
        ),
        SizedBox(height: context.rs(20)),
        AppTextField(
          controller: _notesCtrl,
          label: 'Note (optional)',
          hint: 'e.g. My June budget plan',
          minLines: 3,
          maxLines: 3,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (v) {
            widget.wizard.notes = v;
            widget.onChanged();
          },
        ),
        SizedBox(height: context.rs(20)),
        _AlertThresholdPicker(
          value: widget.wizard.alertThreshold,
          onChanged: (v) {
            setState(() => widget.wizard.alertThreshold = v);
            widget.onChanged();
          },
        ),
        SizedBox(height: context.rs(28)),
        AppPrimaryButton(
          label: widget.isEditing ? 'Save Changes' : 'Create Budget',
          isLoading: widget.isSubmitting,
          onPressed: widget.isSubmitting ? null : widget.onSubmit,
        ),
      ],
    );
  }
}

class _AlertThresholdPicker extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _AlertThresholdPicker({required this.value, required this.onChanged});

  static const _levels = [0.7, 0.8, 0.9];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppFieldLabel('Warn me when a category reaches'),
        Wrap(
          spacing: context.rs(10),
          runSpacing: context.rs(8),
          children: [
            for (final level in _levels)
              ChoiceChip(
                label: Text('${(level * 100).round()}%'),
                selected: (value - level).abs() < 0.001,
                onSelected: (_) => onChanged(level),
              ),
          ],
        ),
      ],
    );
  }
}

class _ReviewSummaryCard extends ConsumerWidget {
  final _WizardState wizard;
  final String currencyCode;
  final String? accountName;
  final String periodLabel;

  const _ReviewSummaryCard({
    required this.wizard,
    required this.currencyCode,
    required this.accountName,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final range = wizard.range;
    final rangeLabel =
        range != null ? dateRangeLabel(range.start, range.end) : '';

    return AppSurfaceCard(
      padding: EdgeInsets.all(context.rs(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Budget',
                      style: TextStyle(
                        fontSize: context.rs(11),
                        color: palette.textMuted,
                      ),
                    ),
                    SizedBox(height: context.rs(4)),
                    Text(
                      '$currencyCode ${wizard.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: context.rs(19),
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.rs(8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.rs(12),
                  vertical: context.rs(6),
                ),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(context.rs(16)),
                ),
                child: Text(
                  periodLabel,
                  style: TextStyle(
                    fontSize: context.rs(11),
                    color: palette.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.rs(8)),
          Text(
            '$rangeLabel${accountName != null ? '  ·  $accountName' : ''}',
            style: TextStyle(
              fontSize: context.rs(11),
              color: palette.textMuted,
            ),
          ),
          SizedBox(height: context.rs(16)),
          Divider(color: palette.border),
          SizedBox(height: context.rs(12)),
          ...wizard.selectedCategoryIds.map((id) {
            final cat = categoryRepo.getById(id);
            if (cat == null) return const SizedBox.shrink();
            final amount = wizard.allocations[id] ?? 0;
            final pct =
                wizard.totalAmount > 0
                    ? (amount / wizard.totalAmount * 100).toStringAsFixed(0)
                    : '0';
            return Padding(
              padding: EdgeInsets.only(bottom: context.rs(10)),
              child: Row(
                children: [
                  _CategoryIcon(
                    category: cat,
                    color: Color(int.parse(cat.colorHex, radix: 16)),
                    diameter: context.rs(28),
                  ),
                  SizedBox(width: context.rs(12)),
                  Expanded(
                    child: Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: context.rs(13),
                        color: palette.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: context.rs(11),
                      color: palette.textMuted,
                    ),
                  ),
                  SizedBox(width: context.rs(12)),
                  Text(
                    '$currencyCode ${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: context.rs(13),
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Step 6: Success ──────────────────────────────────────────────────────────

class _StepSuccess extends StatelessWidget {
  final _WizardState wizard;
  final Animation<double> scaleAnim;

  const _StepSuccess({required this.wizard, required this.scaleAnim});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final range = wizard.range;
    final badgeSize = context.rs(86);

    return LayoutBuilder(
      builder:
          (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.contentGutter,
              vertical: context.rs(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - context.rs(32),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: scaleAnim,
                    child: Container(
                      width: badgeSize,
                      height: badgeSize,
                      decoration: BoxDecoration(
                        color: palette.accent.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: palette.accent,
                        size: context.rs(50),
                      ),
                    ),
                  ),
                  SizedBox(height: context.rs(28)),
                  Text(
                    'Budget Created!',
                    style: TextStyle(
                      fontSize: context.rs(22),
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                  SizedBox(height: context.rs(8)),
                  Text(
                    'Your budget has been created\nsuccessfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.rs(13),
                      color: palette.textSecondary,
                    ),
                  ),
                  SizedBox(height: context.rs(28)),
                  SizedBox(
                    width: double.infinity,
                    child: AppSurfaceCard(
                      padding: EdgeInsets.all(context.rs(18)),
                      child: Column(
                        children: [
                          Text(
                            range != null
                                ? dateRangeLabel(range.start, range.end)
                                : '',
                            style: TextStyle(
                              fontSize: context.rs(12),
                              color: palette.textMuted,
                            ),
                          ),
                          SizedBox(height: context.rs(6)),
                          Text(
                            wizard.totalAmount.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: context.rs(21),
                              fontWeight: FontWeight.w700,
                              color: palette.textPrimary,
                            ),
                          ),
                          SizedBox(height: context.rs(8)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                color: palette.textMuted,
                                size: context.rs(13),
                              ),
                              SizedBox(width: context.rs(6)),
                              Text(
                                wizard.period.label,
                                style: TextStyle(
                                  fontSize: context.rs(12),
                                  color: palette.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: context.rs(32)),
                  AppPrimaryButton(
                    label: 'View Budget',
                    onPressed: () => context.go('/shell/budgets'),
                  ),
                  SizedBox(height: context.rs(8)),
                  TextButton(
                    onPressed: () => context.go('/shell/dashboard'),
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
