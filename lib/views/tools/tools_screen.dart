import 'dart:ui';
import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/views/converters/currency_converter_screen.dart';
import 'package:expenser/views/converters/tax_calculator_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    final toolItems = [
      _ToolItem(
        title: 'Currency Converter',
        description: 'Convert between 20+ currencies with real-time rates',
        icon: Icons.currency_exchange_rounded,
        color: const Color(0xFF26C6DA),
        onTap: () => _showConverter(context),
      ),
      _ToolItem(
        title: 'Tax Calculator',
        description: 'Calculate income tax for USA, UK, Canada, Ghana, and Nigeria',
        icon: Icons.calculate_rounded,
        color: const Color(0xFFAB47BC),
        onTap: () => _showTaxCalc(context),
      ),
      _ToolItem(
        title: 'Savings Goals',
        description: 'Track and plan your future savings targets',
        icon: Icons.savings_rounded,
        color: const Color(0xFFFF7043),
        onTap: () => context.push('/savings'),
      ),
      _ToolItem(
        title: 'Budget Planner',
        description: 'Create and manage category-wise monthly budgets',
        icon: Icons.pie_chart_rounded,
        color: const Color(0xFF66BB6A),
        onTap: () => context.push('/budgets/create'),
      ),
      _ToolItem(
        title: 'Accounts & Cards',
        description: 'Manage your payment accounts, banks, and wallets',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFFFFCA28),
        onTap: () => context.go('/shell/accounts'),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: sh * 0.024),
              Text(
                'Financial Tools',
                style: GoogleFonts.montserrat(
                  fontSize: sw * 0.058,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Utilities to help you manage your wealth',
                style: GoogleFonts.inter(
                  fontSize: sw * 0.032,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
              SizedBox(height: sh * 0.024),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: sh * 0.12),
                  itemCount: toolItems.length,
                  itemBuilder: (context, index) {
                    final item = toolItems[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: sh * 0.014),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(sw * 0.045),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: InkWell(
                            onTap: item.onTap,
                            borderRadius: BorderRadius.circular(sw * 0.045),
                            child: Container(
                              padding: EdgeInsets.all(sw * 0.045),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(sw * 0.045),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: sw * 0.11,
                                    height: sw * 0.11,
                                    decoration: BoxDecoration(
                                      color: item.color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(sw * 0.030),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      color: item.color,
                                      size: sw * 0.052,
                                    ),
                                  ),
                                  SizedBox(width: sw * 0.040),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: GoogleFonts.inter(
                                            fontSize: sw * 0.038,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: sh * 0.003),
                                        Text(
                                          item.description,
                                          style: GoogleFonts.inter(
                                            fontSize: sw * 0.028,
                                            color: Colors.white.withValues(alpha: 0.40),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: sw * 0.036,
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConverter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CurrencyConverterScreen(),
    );
  }

  void _showTaxCalc(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const TaxCalculatorScreen(),
    );
  }
}

class _ToolItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
