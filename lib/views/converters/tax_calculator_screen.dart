import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/viewmodels/tax_viewmodel.dart';
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

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.PRIMARY,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Tax Calculator',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          // Country selector chips
          Wrap(
            spacing: 8,
            children: TaxCountry.values.map((c) {
              final selected = c == state.country;
              return ChoiceChip(
                label: Text(c.label),
                selected: selected,
                selectedColor: AppColors.PRIMARY.withValues(alpha: 0.15),
                side: BorderSide(
                    color: selected ? AppColors.PRIMARY : Colors.grey.shade300),
                labelStyle: TextStyle(
                  color: selected ? AppColors.PRIMARY : Colors.grey[700],
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                onSelected: (_) => notifier.setCountry(c),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _incomeCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Annual Income (${state.country.currency})',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.PRIMARY),
              ),
              prefixIcon: const Icon(Icons.attach_money_rounded),
            ),
            onChanged: (v) => notifier.calculate(double.tryParse(v) ?? 0.0),
          ),
          if (state.country == TaxCountry.usa) ...[
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Filing Status',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person_rounded),
              ),
              child: DropdownButton<String>(
                value: state.filingStatus,
                isExpanded: true,
                underline: const SizedBox(),
                items: _usFilingStatuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) notifier.setFilingStatus(v);
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ResultCard(
                  label: 'Tax Owed',
                  value:
                      '${state.country.currency} ${state.taxOwed.toStringAsFixed(2)}',
                  sub: '${state.effectiveRate.toStringAsFixed(1)}% effective',
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultCard(
                  label: 'After-Tax',
                  value:
                      '${state.country.currency} ${state.afterTaxIncome.toStringAsFixed(2)}',
                  sub: 'Take-home',
                  color: AppColors.PRIMARY,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(sub,
              style:
                  TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }
}
