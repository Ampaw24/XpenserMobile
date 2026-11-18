import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/extensions/color_extensions.dart';
import 'package:expenser/core/utils/formatters/money.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_amount_input.dart';
import 'package:expenser/core/utils/widgets/app_primary_button.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/core/utils/widgets/sheet_title.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/models/savings_plan.dart';
import 'package:expenser/models/savings_reminder_schedule.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/savings_goal_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/savings/widgets/funding_account_picker.dart';
import 'package:expenser/views/transactions/widgets/overdraft_confirmation.dart';
import 'package:expenser/views/transactions/widgets/transaction_detail_rows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Quick "commit" flow: add this period's savings without editing the goal.
Future<void> showAddSavingsSheet(BuildContext context, SavingsGoalModel goal) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => AddSavingsSheet(goal: goal),
  );
}

class AddSavingsSheet extends ConsumerStatefulWidget {
  const AddSavingsSheet({super.key, required this.goal});

  final SavingsGoalModel goal;

  @override
  ConsumerState<AddSavingsSheet> createState() => _AddSavingsSheetState();
}

class _AddSavingsSheetState extends ConsumerState<AddSavingsSheet> {
  late final DateTime _openedAt = DateTime.now();
  late final SavingsPlan? _plan = widget.goal.currentPlan(_openedAt);
  late final bool _paidThisPeriod = widget.goal.contributedThisPeriod(
    _openedAt,
  );
  late final TextEditingController _amountCtrl = TextEditingController(
    text: _suggestedAmount()?.toStringAsFixed(2) ?? '',
  );

  /// The plan's amount due, or the user's usual amount if that is higher.
  double? _suggestedAmount() {
    final due = _plan?.perPayment;
    final usual = widget.goal.contributionAmount;
    if (due == null) return usual;
    return usual != null && usual > due ? usual : due;
  }

  /// Payments below what's due are allowed (the money was really saved),
  /// but the user should know later payments must rise to finish on time.
  String? _belowDueNote(String currency) {
    final plan = _plan;
    final amount = double.tryParse(_amountCtrl.text);
    if (plan == null || _paidThisPeriod || amount == null || amount <= 0) {
      return null;
    }
    if (amount >= plan.perPayment) return null;
    return 'Below the ${formatMoney(plan.perPayment, currency)} due '
        '${savingsPeriodName(plan.frequency)}. Later payments will need to be '
        'higher to reach your goal on time.';
  }

  String? _accountId;
  String? _amountError;
  String? _saveError;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAccount(List<AccountModel> eligible) async {
    FocusScope.of(context).unfocus();
    if (eligible.isEmpty) {
      context.push('/accounts/add');
      return;
    }
    final id = await pickFundingAccount(
      context,
      eligible: eligible,
      selectedId: resolveFundingAccount(eligible, _preferredAccountId)?.id,
    );
    if (id != null && mounted) setState(() => _accountId = id);
  }

  String? get _preferredAccountId => _accountId ?? widget.goal.fundingAccountId;

  Future<void> _submit(AccountModel? account) async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Enter an amount above zero');
      return;
    }
    if (account == null) {
      setState(() => _saveError = 'Add an account to pay from first.');
      return;
    }

    final notifier = ref.read(savingsGoalProvider.notifier);
    final transaction = notifier.contributionTransaction(
      goal: widget.goal,
      amount: amount,
      account: account,
    );
    final proceed = await confirmOverdraftIfNeeded(
      context,
      account: account,
      currentBalance: ref.read(accountProvider).balances[account.id],
      updated: transaction,
    );
    if (!proceed || !mounted) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    try {
      await notifier.commitContribution(widget.goal.id, transaction);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = 'Could not add your savings. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final currency = ref.watch(
      settingsProvider.select((s) => s.preferredCurrency),
    );
    final eligible = savingsFundingAccounts(
      ref.watch(accountProvider).accounts,
      currency,
    );
    final account = resolveFundingAccount(eligible, _preferredAccountId);
    final belowDueNote = _belowDueNote(currency);
    final goalColor = colorFromHex(
      widget.goal.colorHex,
      fallback: palette.accent,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        context.contentGutter,
        0,
        context.contentGutter,
        MediaQuery.viewInsetsOf(context).bottom + context.rs(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetTitle('Add to ${widget.goal.name}'),
          SizedBox(height: context.rs(20)),
          AppAmountInput(
            controller: _amountCtrl,
            currencyCode: currency,
            color: goalColor,
            errorText: _amountError,
            autofocus: _amountCtrl.text.isEmpty,
            onChanged: (_) => setState(() => _amountError = null),
          ),
          if (belowDueNote != null) ...[
            SizedBox(height: context.rs(8)),
            Text(
              belowDueNote,
              style: TextStyle(
                fontSize: context.rs(12),
                color: palette.warning,
              ),
            ),
          ],
          SizedBox(height: context.rs(20)),
          AppSurfaceCard(
            padding: EdgeInsets.zero,
            child: TransactionDetailRow(
              icon: AppIcons.wallet,
              title: 'Pay from',
              value: account?.name ?? 'Add a $currency account',
              valueColor: account == null ? palette.accent : null,
              onTap: () => _pickAccount(eligible),
            ),
          ),
          SizedBox(height: context.rs(8)),
          Text(
            'Recorded as Savings spending from this account.',
            style: TextStyle(
              fontSize: context.rs(12),
              color: palette.textSecondary,
            ),
          ),
          if (_saveError != null) ...[
            SizedBox(height: context.rs(12)),
            Text(
              _saveError!,
              style: TextStyle(fontSize: context.rs(13), color: palette.danger),
            ),
          ],
          SizedBox(height: context.rs(20)),
          AppPrimaryButton(
            label: 'Add to Goal',
            isLoading: _isSaving,
            onPressed: () => _submit(account),
          ),
        ],
      ),
    );
  }
}
