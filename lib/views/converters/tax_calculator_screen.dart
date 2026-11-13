import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_field_label.dart';
import 'package:expenser/core/utils/widgets/app_option_sheet.dart';
import 'package:expenser/core/utils/widgets/app_select_field.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/core/utils/widgets/app_text_field.dart';
import 'package:expenser/viewmodels/tax_viewmodel.dart';
import 'package:expenser/core/utils/widgets/sheet_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaxCalculatorScreen extends ConsumerStatefulWidget {
  const TaxCalculatorScreen({super.key});

  @override
  ConsumerState<TaxCalculatorScreen> createState() =>
      _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends ConsumerState<TaxCalculatorScreen> {
  final _incomeCtrl = TextEditingController();

  static const _usFilingStatuses = [
    'Single',
    'Married Filing Jointly',
    'Married Filing Separately',
    'Head of Household',
  ];

  @override
  void dispose() {
    _incomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taxProvider);
    final notifier = ref.read(taxProvider.notifier);
    final palette = context.palette;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        context.rs(20),
        0,
        context.rs(20),
        MediaQuery.viewInsetsOf(context).bottom + context.rs(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetTitle('Tax Calculator'),
          SizedBox(height: context.rs(20)),
          const AppFieldLabel('Country'),
          Wrap(
            spacing: context.rs(8),
            runSpacing: context.rs(8),
            children:
                TaxCountry.values.map((c) {
                  final selected = c == state.country;
                  return ChoiceChip(
                    label: Text(c.label),
                    selected: selected,
                    showCheckmark: false,
                    side: BorderSide.none,
                    backgroundColor: palette.surfaceMuted,
                    selectedColor: palette.accent.withValues(alpha: 0.14),
                    labelStyle: TextStyle(
                      color: selected ? palette.accent : palette.textSecondary,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: context.rs(12),
                    ),
                    onSelected: (_) => notifier.setCountry(c),
                  );
                }).toList(),
          ),
          SizedBox(height: context.rs(16)),
          AppTextField(
            controller: _incomeCtrl,
            label: 'Annual income (${state.country.currency})',
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [AppTextField.decimalFormatter],
            onChanged: (v) => notifier.calculate(double.tryParse(v) ?? 0.0),
          ),
          if (state.country == TaxCountry.usa) ...[
            SizedBox(height: context.rs(16)),
            AppSelectField<String>(
              label: 'Filing status',
              value: state.filingStatus,
              prefixIcon: Icons.person_rounded,
              options: [
                for (final status in _usFilingStatuses)
                  AppSelectOption(value: status, label: status),
              ],
              onChanged: notifier.setFilingStatus,
            ),
          ],
          SizedBox(height: context.rs(20)),
          Row(
            children: [
              Expanded(
                child: _ResultCard(
                  label: 'Tax Owed',
                  value:
                      '${state.country.currency} ${state.taxOwed.toStringAsFixed(2)}',
                  sub: '${state.effectiveRate.toStringAsFixed(1)}% effective',
                  color: palette.danger,
                ),
              ),
              SizedBox(width: context.rs(12)),
              Expanded(
                child: _ResultCard(
                  label: 'After-Tax',
                  value:
                      '${state.country.currency} ${state.afterTaxIncome.toStringAsFixed(2)}',
                  sub: 'Take-home',
                  color: palette.accent,
                ),
              ),
            ],
          ),
          SizedBox(height: context.rs(8)),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _ResultCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppSurfaceCard(
      color: color.withValues(alpha: 0.08),
      borderColor: color.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: context.rs(11),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.rs(6)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: context.rs(15),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: context.rs(2)),
          Text(
            sub,
            style: TextStyle(
              color: palette.textMuted,
              fontSize: context.rs(11),
            ),
          ),
        ],
      ),
    );
  }
}
