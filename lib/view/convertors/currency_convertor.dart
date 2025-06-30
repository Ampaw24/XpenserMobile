// Currency Converter Screen
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
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _result = 0.0;

  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
    'CHF',
    'CNY',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Currency Converter',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                    ),
                    onChanged: (value) => _convertCurrency(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _fromCurrency,
                          decoration: InputDecoration(
                            labelText: 'From',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items:
                              _currencies.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _fromCurrency = value!;
                            });
                            _convertCurrency();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _toCurrency,
                          decoration: InputDecoration(
                            labelText: 'To',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items:
                              _currencies.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _toCurrency = value!;
                            });
                            _convertCurrency();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Result',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_result.toStringAsFixed(2)} $_toCurrency',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _convertCurrency() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    // Mock conversion rates - in a real app, you'd fetch from an API
    const mockRates = {
      'USD': {
        'EUR': 0.85,
        'GBP': 0.73,
        'JPY': 110.0,
        'CAD': 1.25,
        'AUD': 1.35,
        'CHF': 0.92,
        'CNY': 6.45,
      },
      'EUR': {
        'USD': 1.18,
        'GBP': 0.86,
        'JPY': 129.0,
        'CAD': 1.47,
        'AUD': 1.59,
        'CHF': 1.08,
        'CNY': 7.60,
      },
      // Add more rates as needed
    };

    if (_fromCurrency == _toCurrency) {
      setState(() {
        _result = amount;
      });
    } else {
      final rate = mockRates[_fromCurrency]?[_toCurrency] ?? 1.0;
      setState(() {
        _result = amount * rate;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
