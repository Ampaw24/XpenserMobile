import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// ─── Period enum ─────────────────────────────────────────────────────────────

enum BudgetPeriodType {
  monthly('Monthly', 'monthly'),
  quarterly('Quarterly', 'quarterly'),
  semiAnnual('Semi-Annual', 'semi_annual'),
  annual('Annual', 'annual'),
  custom('Custom', 'custom');

  final String label;
  final String value;
  const BudgetPeriodType(this.label, this.value);
}

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

  _WizardState();

  double get allocatedTotal =>
      allocations.values.fold(0, (sum, v) => sum + v);

  double get remaining => totalAmount - allocatedTotal;
}

// ─── Main wizard widget ──────────────────────────────────────────────────────

class CreateBudgetWizard extends ConsumerStatefulWidget {
  const CreateBudgetWizard({super.key});

  @override
  ConsumerState<CreateBudgetWizard> createState() => _CreateBudgetWizardState();
}

class _CreateBudgetWizardState extends ConsumerState<CreateBudgetWizard>
    with SingleTickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _step = 0;
  static const int _totalSteps = 6;
  final _wizard = _WizardState();
  bool _isSubmitting = false;

  late AnimationController _successCtrl;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
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
    setState(() => _isSubmitting = true);
    final now = DateTime.now();
    final planId = const Uuid().v4();

    final budgets = _wizard.selectedCategoryIds.map((catId) {
      return BudgetModel(
        id: const Uuid().v4(),
        categoryId: catId,
        limitAmount: _wizard.allocations[catId] ?? 0,
        month: now.month,
        year: now.year,
        alertThreshold: 0.8,
        createdAt: now,
        accountId: _wizard.accountId,
        period: _wizard.period.value,
        planId: planId,
        notes: _wizard.notes.isEmpty ? null : _wizard.notes,
        startDate: _wizard.period == BudgetPeriodType.custom
            ? _wizard.customStart
            : null,
        endDate: _wizard.period == BudgetPeriodType.custom
            ? _wizard.customEnd
            : null,
      );
    }).toList();

    await ref.read(budgetProvider.notifier).addPlan(budgets);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _next(); // go to success step
    _successCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Column(
          children: [
            _WizardHeader(
              step: _step,
              totalSteps: _totalSteps - 1,
              onBack: _prev,
              sw: sw,
              sh: sh,
            ),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepPeriod(
                    wizard: _wizard,
                    onNext: _next,
                    sw: sw,
                    sh: sh,
                    onChanged: () => setState(() {}),
                  ),
                  _StepTotalBudget(
                    wizard: _wizard,
                    onNext: _next,
                    sw: sw,
                    sh: sh,
                    onChanged: () => setState(() {}),
                  ),
                  _StepCategories(
                    wizard: _wizard,
                    onNext: _next,
                    sw: sw,
                    sh: sh,
                    onChanged: () => setState(() {}),
                  ),
                  _StepAllocate(
                    wizard: _wizard,
                    onNext: _next,
                    sw: sw,
                    sh: sh,
                    onChanged: () => setState(() {}),
                  ),
                  _StepReviewNotes(
                    wizard: _wizard,
                    isSubmitting: _isSubmitting,
                    onSubmit: _submit,
                    sw: sw,
                    sh: sh,
                    onChanged: () => setState(() {}),
                  ),
                  _StepSuccess(
                    wizard: _wizard,
                    scaleAnim: _successScale,
                    sw: sw,
                    sh: sh,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header with progress bar ─────────────────────────────────────────────────

class _WizardHeader extends StatelessWidget {
  final int step;
  final int totalSteps;
  final VoidCallback onBack;
  final double sw, sh;

  const _WizardHeader({
    required this.step,
    required this.totalSteps,
    required this.onBack,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    if (step >= totalSteps) return const SizedBox.shrink();
    final progress = (step + 1) / totalSteps;
    final labels = [
      'Choose Period',
      'Set Total Budget',
      'Choose Categories',
      'Allocate Amounts',
      'Review & Notes',
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.05, sh * 0.015, sw * 0.05, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: EdgeInsets.all(sw * 0.020),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: sw * 0.042,
                  ),
                ),
              ),
              SizedBox(width: sw * 0.030),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Budget  ${step + 1}/$totalSteps',
                      style: GoogleFonts.inter(
                        fontSize: sw * 0.028,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                    SizedBox(height: sh * 0.004),
                    Text(
                      labels[step.clamp(0, labels.length - 1)],
                      style: GoogleFonts.montserrat(
                        fontSize: sw * 0.042,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.014),
          ClipRRect(
            borderRadius: BorderRadius.circular(sw * 0.010),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: sh * 0.005,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              valueColor: const AlwaysStoppedAnimation(AppColors.ACCENT),
            ),
          ),
          SizedBox(height: sh * 0.010),
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
  final double sw, sh;

  const _StepPeriod({
    required this.wizard,
    required this.onNext,
    required this.onChanged,
    required this.sw,
    required this.sh,
  });

  @override
  State<_StepPeriod> createState() => _StepPeriodState();
}

class _StepPeriodState extends State<_StepPeriod> {
  @override
  Widget build(BuildContext context) {
    final sw = widget.sw;
    final sh = widget.sh;
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.02),
      children: [
        Text(
          'Choose a period for your budget',
          style: GoogleFonts.inter(
            fontSize: sw * 0.034,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        SizedBox(height: sh * 0.024),
        ...BudgetPeriodType.values.map((p) {
          final isSelected = widget.wizard.period == p;
          return GestureDetector(
            onTap: () {
              setState(() => widget.wizard.period = p);
              widget.onChanged();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(bottom: sh * 0.014),
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.048,
                vertical: sh * 0.022,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.ACCENT.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(sw * 0.040),
                border: Border.all(
                  color: isSelected
                      ? AppColors.ACCENT
                      : Colors.white.withValues(alpha: 0.10),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _periodIcon(p),
                    color: isSelected
                        ? AppColors.ACCENT
                        : Colors.white.withValues(alpha: 0.40),
                    size: sw * 0.052,
                  ),
                  SizedBox(width: sw * 0.040),
                  Text(
                    p.label,
                    style: GoogleFonts.inter(
                      fontSize: sw * 0.038,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: sw * 0.052,
                      height: sw * 0.052,
                      decoration: const BoxDecoration(
                        color: AppColors.ACCENT,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: sw * 0.030,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (widget.wizard.period == BudgetPeriodType.custom) ...[
          SizedBox(height: sh * 0.008),
          _DateRangePicker(wizard: widget.wizard, sw: sw, sh: sh),
        ],
        SizedBox(height: sh * 0.040),
        _ContinueButton(
          label: 'Continue',
          onPressed: widget.onNext,
          sw: sw,
          sh: sh,
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

class _DateRangePicker extends StatelessWidget {
  final _WizardState wizard;
  final double sw, sh;
  const _DateRangePicker(
      {required this.wizard, required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    return Row(
      children: [
        Expanded(
          child: _DateChip(
            label: wizard.customStart != null
                ? fmt.format(wizard.customStart!)
                : 'Start date',
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: wizard.customStart ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (ctx, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.ACCENT,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (d != null) wizard.customStart = d;
            },
            sw: sw,
            sh: sh,
          ),
        ),
        SizedBox(width: sw * 0.024),
        Expanded(
          child: _DateChip(
            label: wizard.customEnd != null
                ? fmt.format(wizard.customEnd!)
                : 'End date',
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: wizard.customEnd ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (ctx, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.ACCENT,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (d != null) wizard.customEnd = d;
            },
            sw: sw,
            sh: sh,
          ),
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double sw, sh;
  const _DateChip(
      {required this.label,
      required this.onTap,
      required this.sw,
      required this.sh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.038,
          vertical: sh * 0.018,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(sw * 0.030),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                color: AppColors.ACCENT, size: sw * 0.038),
            SizedBox(width: sw * 0.020),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: sw * 0.030,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 2: Set Total Budget ─────────────────────────────────────────────────

class _StepTotalBudget extends ConsumerStatefulWidget {
  final _WizardState wizard;
  final VoidCallback onNext;
  final VoidCallback onChanged;
  final double sw, sh;

  const _StepTotalBudget({
    required this.wizard,
    required this.onNext,
    required this.onChanged,
    required this.sw,
    required this.sh,
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

  @override
  Widget build(BuildContext context) {
    final sw = widget.sw;
    final sh = widget.sh;
    final accounts = ref.watch(accountProvider).accounts;
    final selectedAccount = accounts.isEmpty
        ? null
        : accounts.firstWhere(
            (a) => a.id == widget.wizard.accountId,
            orElse: () => accounts.first,
          );

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.02),
      children: [
        Text(
          'Enter the total amount you want to budget',
          style: GoogleFonts.inter(
            fontSize: sw * 0.034,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        SizedBox(height: sh * 0.030),
        // Large amount input
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.048,
            vertical: sh * 0.028,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(sw * 0.040),
            border: Border.all(
              color: _error != null
                  ? Colors.redAccent
                  : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Column(
            children: [
              Text(
                selectedAccount?.currencyCode ?? 'GHS',
                style: GoogleFonts.inter(
                  fontSize: sw * 0.034,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
              SizedBox(height: sh * 0.008),
              TextField(
                controller: _ctrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: sw * 0.070,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                cursorColor: AppColors.ACCENT,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0.00',
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: sw * 0.070,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
                onChanged: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null) {
                    widget.wizard.totalAmount = parsed;
                    widget.onChanged();
                  }
                },
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.028,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: sh * 0.018),
        // Quick-add chips
        Row(
          children: [100.0, 500.0, 1000.0].map((v) {
            return Padding(
              padding: EdgeInsets.only(right: sw * 0.024),
              child: GestureDetector(
                onTap: () {
                  final current =
                      double.tryParse(_ctrl.text) ?? 0;
                  final next = current + v;
                  _ctrl.text = next.toStringAsFixed(2);
                  widget.wizard.totalAmount = next;
                  widget.onChanged();
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.038,
                    vertical: sh * 0.012,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ACCENT.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(sw * 0.030),
                    border: Border.all(
                      color: AppColors.ACCENT.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Text(
                    '+${v.toInt()}',
                    style: GoogleFonts.inter(
                      fontSize: sw * 0.032,
                      color: AppColors.ACCENT,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: sh * 0.030),
        // Account selector
        Text(
          'Budget Account',
          style: GoogleFonts.inter(
            fontSize: sw * 0.030,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: sh * 0.010),
        if (accounts.isEmpty)
          Text(
            'No accounts found. Create one first.',
            style: GoogleFonts.inter(
              fontSize: sw * 0.032,
              color: Colors.white.withValues(alpha: 0.40),
            ),
          )
        else
          SizedBox(
            height: sh * 0.115,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: accounts.length,
              separatorBuilder: (_, __) => SizedBox(width: sw * 0.024),
              itemBuilder: (ctx, i) {
                final acc = accounts[i];
                final isSelected = widget.wizard.accountId == acc.id;
                final color =
                    Color(int.parse(acc.colorHex, radix: 16));
                return GestureDetector(
                  onTap: () {
                    setState(() => widget.wizard.accountId = acc.id);
                    widget.onChanged();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: sw * 0.360,
                    padding: EdgeInsets.all(sw * 0.036),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(sw * 0.036),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : Colors.white.withValues(alpha: 0.10),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          IconData(acc.iconCodePoint,
                              fontFamily: 'MaterialIcons'),
                          color: isSelected
                              ? color
                              : Colors.white.withValues(alpha: 0.40),
                          size: sw * 0.046,
                        ),
                        SizedBox(height: sh * 0.006),
                        Text(
                          acc.name,
                          style: GoogleFonts.inter(
                            fontSize: sw * 0.030,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.60),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          acc.currencyCode,
                          style: GoogleFonts.inter(
                            fontSize: sw * 0.026,
                            color: isSelected
                                ? color
                                : Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        SizedBox(height: sh * 0.040),
        _ContinueButton(label: 'Continue', onPressed: _validate, sw: sw, sh: sh),
      ],
    );
  }
}

// ─── Step 3: Choose Categories ────────────────────────────────────────────────

class _StepCategories extends ConsumerWidget {
  final _WizardState wizard;
  final VoidCallback onNext;
  final VoidCallback onChanged;
  final double sw, sh;

  const _StepCategories({
    required this.wizard,
    required this.onNext,
    required this.onChanged,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories =
        ref.read(categoryRepositoryProvider).getByType(TransactionType.expense);

    return StatefulBuilder(builder: (ctx, localSet) {
      return ListView(
        padding:
            EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.02),
        children: [
          Text(
            'Select categories to include in your budget',
            style: GoogleFonts.inter(
              fontSize: sw * 0.034,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          SizedBox(height: sh * 0.024),
          ...categories.map((c) {
            final isSelected = wizard.selectedCategoryIds.contains(c.id);
            final color = Color(int.parse(c.colorHex, radix: 16));
            return GestureDetector(
              onTap: () {
                localSet(() {
                  if (isSelected) {
                    wizard.selectedCategoryIds = List.from(
                        wizard.selectedCategoryIds)
                      ..remove(c.id);
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(bottom: sh * 0.012),
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.044,
                  vertical: sh * 0.018,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(sw * 0.036),
                  border: Border.all(
                    color: isSelected
                        ? color.withValues(alpha: 0.60)
                        : Colors.white.withValues(alpha: 0.08),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: sw * 0.090,
                      height: sw * 0.090,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconData(c.iconCodePoint,
                            fontFamily: 'MaterialIcons'),
                        color: color,
                        size: sw * 0.044,
                      ),
                    ),
                    SizedBox(width: sw * 0.036),
                    Expanded(
                      child: Text(
                        c.name,
                        style: GoogleFonts.inter(
                          fontSize: sw * 0.036,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: sw * 0.052,
                      height: sw * 0.052,
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? color
                              : Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check_rounded,
                              color: Colors.white, size: sw * 0.030)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: sh * 0.032),
          _ContinueButton(
            label:
                'Continue (${wizard.selectedCategoryIds.length} selected)',
            onPressed: wizard.selectedCategoryIds.isEmpty ? null : onNext,
            sw: sw,
            sh: sh,
          ),
        ],
      );
    });
  }
}

// ─── Step 4: Allocate Amounts ─────────────────────────────────────────────────

class _StepAllocate extends ConsumerStatefulWidget {
  final _WizardState wizard;
  final VoidCallback onNext;
  final VoidCallback onChanged;
  final double sw, sh;

  const _StepAllocate({
    required this.wizard,
    required this.onNext,
    required this.onChanged,
    required this.sw,
    required this.sh,
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
    final each = widget.wizard.totalAmount /
        widget.wizard.selectedCategoryIds.length;
    for (final id in widget.wizard.selectedCategoryIds) {
      _ctrls[id]?.text = each.toStringAsFixed(2);
      widget.wizard.allocations = {
        ...widget.wizard.allocations,
        id: each,
      };
    }
    widget.onChanged();
    setState(() {});
  }

  bool get _isValid {
    final allFilled = widget.wizard.selectedCategoryIds
        .every((id) => (widget.wizard.allocations[id] ?? 0) > 0);
    return allFilled &&
        widget.wizard.allocatedTotal <= widget.wizard.totalAmount + 0.01;
  }

  @override
  Widget build(BuildContext context) {
    final sw = widget.sw;
    final sh = widget.sh;
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final remaining = widget.wizard.remaining;
    final overBudget = remaining < -0.01;
    final remainingColor = overBudget
        ? const Color(0xFFFF5252)
        : remaining < widget.wizard.totalAmount * 0.1
            ? const Color(0xFFFFAB40)
            : AppColors.ACCENT;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.02),
      children: [
        Text(
          'Enter amount for each category',
          style: GoogleFonts.inter(
            fontSize: sw * 0.034,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        SizedBox(height: sh * 0.016),
        // Summary bar
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.044,
            vertical: sh * 0.018,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(sw * 0.030),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(
                label: 'Total',
                value: widget.wizard.totalAmount,
                color: Colors.white,
                sw: sw,
                sh: sh,
              ),
              _SummaryItem(
                label: 'Allocated',
                value: widget.wizard.allocatedTotal,
                color: AppColors.ACCENT,
                sw: sw,
                sh: sh,
              ),
              _SummaryItem(
                label: overBudget ? 'Over' : 'Remaining',
                value: remaining.abs(),
                color: remainingColor,
                sw: sw,
                sh: sh,
              ),
            ],
          ),
        ),
        SizedBox(height: sh * 0.010),
        // Distribute evenly button
        GestureDetector(
          onTap: _distributeEvenly,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: sh * 0.012),
            decoration: BoxDecoration(
              color: AppColors.ACCENT.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(sw * 0.024),
              border: Border.all(
                color: AppColors.ACCENT.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_fix_high_rounded,
                    color: AppColors.ACCENT, size: sw * 0.036),
                SizedBox(width: sw * 0.016),
                Text(
                  'Distribute Evenly',
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.032,
                    color: AppColors.ACCENT,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: sh * 0.020),
        ...widget.wizard.selectedCategoryIds.map((id) {
          final cat = categoryRepo.getById(id);
          if (cat == null) return const SizedBox.shrink();
          final color = Color(int.parse(cat.colorHex, radix: 16));
          return Padding(
            padding: EdgeInsets.only(bottom: sh * 0.014),
            child: _AllocationRow(
              category: cat,
              color: color,
              controller: _ctrls[id]!,
              sw: sw,
              sh: sh,
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
        SizedBox(height: sh * 0.032),
        _ContinueButton(
          label: 'Continue',
          onPressed: _isValid ? widget.onNext : null,
          sw: sw,
          sh: sh,
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double sw, sh;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: sw * 0.026,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
        SizedBox(height: sh * 0.004),
        Text(
          value.toStringAsFixed(2),
          style: GoogleFonts.montserrat(
            fontSize: sw * 0.036,
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
  final double sw, sh;

  const _AllocationRow({
    required this.category,
    required this.color,
    required this.controller,
    required this.onChanged,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.040,
        vertical: sh * 0.014,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(sw * 0.034),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: sw * 0.080,
            height: sw * 0.080,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
              color: color,
              size: sw * 0.038,
            ),
          ),
          SizedBox(width: sw * 0.030),
          Expanded(
            child: Text(
              category.name,
              style: GoogleFonts.inter(
                fontSize: sw * 0.034,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          SizedBox(
            width: sw * 0.280,
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                fontSize: sw * 0.036,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              cursorColor: AppColors.ACCENT,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: GoogleFonts.inter(
                  fontSize: sw * 0.034,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              onChanged: onChanged,
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
  final bool isSubmitting;
  final Future<void> Function() onSubmit;
  final VoidCallback onChanged;
  final double sw, sh;

  const _StepReviewNotes({
    required this.wizard,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onChanged,
    required this.sw,
    required this.sh,
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
    final sw = widget.sw;
    final sh = widget.sh;
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final accountState = ref.read(accountProvider);
    final account = widget.wizard.accountId != null
        ? accountState.accounts
            .where((a) => a.id == widget.wizard.accountId)
            .firstOrNull
        : null;
    final now = DateTime.now();
    final monthLabel =
        DateFormat('MMMM yyyy').format(DateTime(now.year, now.month));

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.02),
      children: [
        Text(
          'Review your budget before saving',
          style: GoogleFonts.inter(
            fontSize: sw * 0.034,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        SizedBox(height: sh * 0.020),
        // Summary card
        Container(
          padding: EdgeInsets.all(sw * 0.048),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(sw * 0.040),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Budget',
                        style: GoogleFonts.inter(
                          fontSize: sw * 0.028,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      SizedBox(height: sh * 0.004),
                      Text(
                        '${account?.currencyCode ?? 'GHS'} ${widget.wizard.totalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.montserrat(
                          fontSize: sw * 0.048,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.030,
                      vertical: sh * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ACCENT.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(sw * 0.040),
                    ),
                    child: Text(
                      _periodLabel(widget.wizard.period),
                      style: GoogleFonts.inter(
                        fontSize: sw * 0.026,
                        color: AppColors.ACCENT,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.010),
              Text(
                '$monthLabel${account != null ? '  ·  ${account.name}' : ''}',
                style: GoogleFonts.inter(
                  fontSize: sw * 0.028,
                  color: Colors.white.withValues(alpha: 0.40),
                ),
              ),
              SizedBox(height: sh * 0.020),
              Divider(color: Colors.white.withValues(alpha: 0.08)),
              SizedBox(height: sh * 0.012),
              ...widget.wizard.selectedCategoryIds.map((id) {
                final cat = categoryRepo.getById(id);
                if (cat == null) return const SizedBox.shrink();
                final amount = widget.wizard.allocations[id] ?? 0;
                final pct = widget.wizard.totalAmount > 0
                    ? (amount / widget.wizard.totalAmount * 100)
                        .toStringAsFixed(0)
                    : '0';
                return Padding(
                  padding: EdgeInsets.only(bottom: sh * 0.012),
                  child: Row(
                    children: [
                      Container(
                        width: sw * 0.068,
                        height: sw * 0.068,
                        decoration: BoxDecoration(
                          color: Color(int.parse(cat.colorHex, radix: 16))
                              .withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          IconData(cat.iconCodePoint,
                              fontFamily: 'MaterialIcons'),
                          color: Color(int.parse(cat.colorHex, radix: 16)),
                          size: sw * 0.034,
                        ),
                      ),
                      SizedBox(width: sw * 0.030),
                      Expanded(
                        child: Text(
                          cat.name,
                          style: GoogleFonts.inter(
                            fontSize: sw * 0.032,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: GoogleFonts.inter(
                          fontSize: sw * 0.028,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      SizedBox(width: sw * 0.030),
                      Text(
                        '${account?.currencyCode ?? 'GHS'} ${amount.toStringAsFixed(2)}',
                        style: GoogleFonts.montserrat(
                          fontSize: sw * 0.032,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: sh * 0.024),
        // Notes field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: sw * 0.010, bottom: sh * 0.008),
              child: Text(
                'Add Note (Optional)',
                style: GoogleFonts.inter(
                  fontSize: sw * 0.030,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              maxLength: 200,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: sw * 0.034,
              ),
              cursorColor: AppColors.ACCENT,
              decoration: InputDecoration(
                hintText: 'e.g. My June budget plan',
                hintStyle: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: sw * 0.034,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                counterStyle: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.30),
                  fontSize: sw * 0.026,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sw * 0.034),
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sw * 0.034),
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sw * 0.034),
                  borderSide:
                      const BorderSide(color: AppColors.ACCENT, width: 1.5),
                ),
              ),
              onChanged: (v) {
                widget.wizard.notes = v;
                widget.onChanged();
              },
            ),
          ],
        ),
        SizedBox(height: sh * 0.032),
        _ContinueButton(
          label: 'Create Budget',
          isLoading: widget.isSubmitting,
          onPressed: widget.isSubmitting ? null : widget.onSubmit,
          sw: sw,
          sh: sh,
        ),
      ],
    );
  }

  String _periodLabel(BudgetPeriodType p) {
    switch (p) {
      case BudgetPeriodType.monthly:
        return 'Monthly Budget';
      case BudgetPeriodType.quarterly:
        return 'Quarterly Budget';
      case BudgetPeriodType.semiAnnual:
        return 'Semi-Annual Budget';
      case BudgetPeriodType.annual:
        return 'Annual Budget';
      case BudgetPeriodType.custom:
        return 'Custom Budget';
    }
  }
}

// ─── Step 6: Success ──────────────────────────────────────────────────────────

class _StepSuccess extends StatelessWidget {
  final _WizardState wizard;
  final Animation<double> scaleAnim;
  final double sw, sh;

  const _StepSuccess({
    required this.wizard,
    required this.scaleAnim,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthLabel =
        DateFormat('MMMM yyyy').format(DateTime(now.year, now.month));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: scaleAnim,
            child: Container(
              width: sw * 0.220,
              height: sw * 0.220,
              decoration: BoxDecoration(
                color: AppColors.ACCENT.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.ACCENT,
                size: sw * 0.130,
              ),
            ),
          ),
          SizedBox(height: sh * 0.036),
          Text(
            'Budget Created!',
            style: GoogleFonts.montserrat(
              fontSize: sw * 0.058,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: sh * 0.010),
          Text(
            'Your budget has been created\nsuccessfully.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: sw * 0.034,
              color: Colors.white.withValues(alpha: 0.50),
            ),
          ),
          SizedBox(height: sh * 0.036),
          Container(
            padding: EdgeInsets.all(sw * 0.048),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(sw * 0.040),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Column(
              children: [
                Text(
                  '$monthLabel Budget',
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.030,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
                SizedBox(height: sh * 0.006),
                Text(
                  wizard.totalAmount.toStringAsFixed(2),
                  style: GoogleFonts.montserrat(
                    fontSize: sw * 0.054,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: sh * 0.008),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_rounded,
                        color: Colors.white.withValues(alpha: 0.40),
                        size: sw * 0.034),
                    SizedBox(width: sw * 0.016),
                    Text(
                      wizard.period.label,
                      style: GoogleFonts.inter(
                        fontSize: sw * 0.030,
                        color: Colors.white.withValues(alpha: 0.40),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: sh * 0.040),
          _ContinueButton(
            label: 'View Budget',
            onPressed: () => context.go('/shell/budgets'),
            sw: sw,
            sh: sh,
          ),
          SizedBox(height: sh * 0.016),
          GestureDetector(
            onTap: () => context.go('/shell/dashboard'),
            child: Text(
              'Back to Home',
              style: GoogleFonts.inter(
                fontSize: sw * 0.034,
                color: AppColors.ACCENT,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared: Gradient continue button ────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double sw, sh;

  const _ContinueButton({
    required this.label,
    required this.sw,
    required this.sh,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: sh * 0.065,
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : const LinearGradient(
                  colors: [AppColors.PRIMARY, AppColors.ACCENT],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: disabled ? Colors.white.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(sw * 0.042),
          boxShadow: disabled
              ? null
              : [
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
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.inter(
                  color: disabled
                      ? Colors.white.withValues(alpha: 0.35)
                      : Colors.white,
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
