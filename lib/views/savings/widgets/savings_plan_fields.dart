import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/formatters/money.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_option_sheet.dart';
import 'package:expenser/core/utils/widgets/app_section_title.dart';
import 'package:expenser/core/utils/widgets/app_select_field.dart';
import 'package:expenser/core/utils/widgets/app_tap_field.dart';
import 'package:expenser/core/utils/widgets/app_text_field.dart';
import 'package:expenser/models/recurring_frequency.dart';
import 'package:expenser/models/savings_reminder_schedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Goal form section: how often to save, the amount, the paying account
/// and optional reminders. [summary] shows the calculated plan.
class SavingsPlanFields extends StatelessWidget {
  const SavingsPlanFields({
    super.key,
    required this.amountController,
    required this.frequency,
    required this.minimumAmount,
    required this.currency,
    required this.summary,
    required this.remindersOn,
    required this.reminderAt,
    required this.accountName,
    required this.notificationsEnabled,
    required this.onFrequencyChanged,
    required this.onRemindersChanged,
    required this.onPickReminderStart,
    required this.onPickAccount,
  });

  final TextEditingController amountController;
  final RecurringFrequency? frequency;

  /// Smallest amount per period that still reaches the target on time.
  final double? minimumAmount;
  final String currency;
  final Widget? summary;
  final bool remindersOn;
  final DateTime? reminderAt;
  final String? accountName;
  final bool notificationsEnabled;
  final ValueChanged<RecurringFrequency?> onFrequencyChanged;
  final ValueChanged<bool> onRemindersChanged;
  final VoidCallback onPickReminderStart;
  final VoidCallback onPickAccount;

  static const _off = 'off';

  String? _validateAmount(String? value) {
    final text = value?.trim() ?? '';
    final minimum = minimumAmount;
    if (text.isEmpty) {
      return minimum == null
          ? null
          : 'Enter at least ${formatMoney(minimum, currency)}';
    }
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) return 'Enter an amount above zero';
    if (minimum != null && amount < minimum) {
      return 'At least ${formatMoney(minimum, currency)} to reach the target on time';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final gap = SizedBox(height: context.rs(16));
    final frequency = this.frequency;
    final reminderAt = this.reminderAt;
    final summary = this.summary;
    final hintStyle = TextStyle(
      fontSize: context.rs(12),
      color: palette.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionTitle('Savings plan'),
        SizedBox(height: context.rs(12)),
        AppSelectField<String>(
          label: 'Save every',
          value: frequency?.name ?? _off,
          prefixIcon: AppIcons.calendar,
          options: const [
            AppSelectOption(value: _off, label: 'No plan'),
            AppSelectOption(value: 'daily', label: 'Day'),
            AppSelectOption(value: 'weekly', label: 'Week'),
            AppSelectOption(value: 'monthly', label: 'Month'),
          ],
          onChanged:
              (value) => onFrequencyChanged(
                value == _off ? null : RecurringFrequency.values.byName(value),
              ),
        ),
        if (summary != null) ...[gap, summary],
        gap,
        AppTextField(
          controller: amountController,
          label:
              frequency == null
                  ? 'Usual amount (optional)'
                  : 'Amount each ${savingsPeriodNoun(frequency)}',
          hint: '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [AppTextField.decimalFormatter],
          validator: _validateAmount,
        ),
        gap,
        AppTapField(
          label: 'Pay from',
          value: accountName,
          placeholder: 'Choose account',
          prefixIcon: AppIcons.wallet,
          onTap: onPickAccount,
        ),
        if (frequency != null) ...[
          SizedBox(height: context.rs(8)),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Remind me to save',
              style: TextStyle(
                fontSize: context.rs(14),
                color: palette.textPrimary,
              ),
            ),
            value: remindersOn,
            onChanged: onRemindersChanged,
          ),
          if (remindersOn && reminderAt != null) ...[
            AppTapField(
              label: 'First reminder',
              value:
                  '${DateFormat.yMMMd().format(reminderAt)} · '
                  '${DateFormat.jm().format(reminderAt)}',
              prefixIcon: AppIcons.calendar,
              onTap: onPickReminderStart,
            ),
            SizedBox(height: context.rs(8)),
            Text(
              reminderScheduleLabel(frequency, reminderAt),
              style: hintStyle,
            ),
            if (!notificationsEnabled) ...[
              SizedBox(height: context.rs(4)),
              Text(
                'Notifications are off. Turn them on in Settings to get reminders.',
                style: hintStyle.copyWith(color: palette.danger),
              ),
            ],
          ],
        ],
      ],
    );
  }
}
