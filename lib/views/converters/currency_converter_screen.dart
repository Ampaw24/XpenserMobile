import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_option_sheet.dart';
import 'package:expenser/core/utils/widgets/app_select_field.dart';
import 'package:expenser/core/utils/widgets/app_text_field.dart';
import 'package:expenser/viewmodels/currency_viewmodel.dart';
import 'package:expenser/viewmodels/exchange_rates_viewmodel.dart';
import 'package:expenser/core/utils/widgets/sheet_title.dart';
import 'package:expenser/views/converters/widgets/conversion_result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrencyConverterScreen extends ConsumerStatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  ConsumerState<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState
    extends ConsumerState<CurrencyConverterScreen> {
  final _amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(exchangeRatesProvider.notifier).ensureFresh(),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currencyProvider);
    final notifier = ref.read(currencyProvider.notifier);
    final rates = ref.watch(exchangeRatesProvider);
    final ratesNotifier = ref.read(exchangeRatesProvider.notifier);
    final palette = context.palette;
    final currencies = CurrencyNotifier.supportedBy(rates.rates);

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
          const SheetTitle('Currency Converter'),
          SizedBox(height: context.rs(20)),
          AppTextField(
            controller: _amountCtrl,
            label: 'Amount',
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [AppTextField.decimalFormatter],
            onChanged: (v) => notifier.setAmount(double.tryParse(v) ?? 0.0),
          ),
          SizedBox(height: context.rs(16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _CurrencySelect(
                  label: 'From',
                  currencies: currencies,
                  value: state.fromCurrency,
                  onChanged: notifier.setFromCurrency,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.rs(8),
                  0,
                  context.rs(8),
                  context.rs(4),
                ),
                child: IconButton(
                  onPressed: notifier.swapCurrencies,
                  tooltip: 'Swap currencies',
                  style: IconButton.styleFrom(
                    backgroundColor: palette.accent.withValues(alpha: 0.12),
                    foregroundColor: palette.accent,
                    shape: const CircleBorder(),
                  ),
                  icon: Icon(AppIcons.transfer, size: context.rs(20)),
                ),
              ),
              Expanded(
                child: _CurrencySelect(
                  label: 'To',
                  currencies: currencies,
                  value: state.toCurrency,
                  onChanged: notifier.setToCurrency,
                ),
              ),
            ],
          ),
          SizedBox(height: context.rs(20)),
          ConversionResultCard(
            conversion: state,
            rates: rates,
            onRefresh: ratesNotifier.refresh,
            onRetry: ratesNotifier.retry,
          ),
          SizedBox(height: context.rs(8)),
        ],
      ),
    );
  }
}

class _CurrencySelect extends StatelessWidget {
  final String label;
  final List<String> currencies;
  final String value;
  final ValueChanged<String> onChanged;

  const _CurrencySelect({
    required this.label,
    required this.currencies,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppSelectField<String>(
      label: label,
      sheetTitle: 'Convert $label',
      value: value,
      options: [
        for (final code in currencies)
          AppSelectOption(value: code, label: code),
      ],
      onChanged: onChanged,
    );
  }
}
