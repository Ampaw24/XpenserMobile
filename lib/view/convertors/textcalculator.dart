// Tax Calculator Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaxCalculatorScreen extends ConsumerStatefulWidget {
  const TaxCalculatorScreen({super.key});

  @override
  ConsumerState<TaxCalculatorScreen> createState() =>
      _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends ConsumerState<TaxCalculatorScreen> {
  final TextEditingController _incomeController = TextEditingController();
  String _filingStatus = 'Single';
  double _taxOwed = 0.0;
  double _afterTaxIncome = 0.0;

  final List<String> _filingStatuses = [
    'Single',
    'Married Filing Jointly',
    'Married Filing Separately',
    'Head of Household',
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
              'Tax Calculator',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
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
                        controller: _incomeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Annual Income',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.attach_money_rounded),
                        ),
                        onChanged: (value) => _calculateTax(),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _filingStatus,
                        decoration: InputDecoration(
                          labelText: 'Filing Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person_rounded),
                        ),
                        items:
                            _filingStatuses.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _filingStatus = value!;
                          });
                          _calculateTax();
                        },
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Tax Owed',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${_taxOwed.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'After-Tax Income',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${_afterTaxIncome.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateTax() {
    final income = double.tryParse(_incomeController.text) ?? 0.0;

    // Simplified tax calculation (US tax brackets for 2023)
    double tax = 0.0;

    if (_filingStatus == 'Single') {
      if (income <= 11000) {
        tax = income * 0.10;
      } else if (income <= 44725) {
        tax = 1100 + (income - 11000) * 0.12;
      } else if (income <= 95375) {
        tax = 5147 + (income - 44725) * 0.22;
      } else if (income <= 182050) {
        tax = 16290 + (income - 95375) * 0.24;
      } else if (income <= 231250) {
        tax = 37104 + (income - 182050) * 0.32;
      } else if (income <= 578125) {
        tax = 52832 + (income - 231250) * 0.35;
      } else {
        tax = 174238 + (income - 578125) * 0.37;
      }
    } else {
      // Simplified calculation for other filing statuses
      tax = income * 0.20; // Flat 20% for simplicity
    }

    setState(() {
      _taxOwed = tax;
      _afterTaxIncome = income - tax;
    });
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }
}
