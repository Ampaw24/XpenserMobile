import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/viewmodels/auth_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/converters/currency_converter_screen.dart';
import 'package:expenser/views/converters/tax_calculator_screen.dart';
import 'package:expenser/views/settings/widgets/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final settings = ref.watch(settingsProvider);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(sw * 0.06, sh * 0.024, sw * 0.06, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: GoogleFonts.montserrat(
                fontSize: sw * 0.058,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: sh * 0.022),
            // Profile card
            Container(
              padding: EdgeInsets.all(sw * 0.048),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.PRIMARY, AppColors.ACCENT],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(sw * 0.050),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ACCENT.withValues(alpha: 0.30),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: sw * 0.070,
                    backgroundColor: Colors.white.withValues(alpha: 0.20),
                    child: Text(
                      settings.userName.isNotEmpty
                          ? settings.userName[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: sw * 0.055,
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.040),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.userName.isNotEmpty
                              ? settings.userName
                              : 'User',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: sw * 0.042,
                          ),
                        ),
                        SizedBox(height: sh * 0.004),
                        Text(
                          settings.preferredCurrency,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.70),
                            fontSize: sw * 0.032,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sh * 0.024),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: sh * 0.14),
                children: [
                  // Dark mode toggle
                  GestureDetector(
                    onTap: () =>
                        ref.read(settingsProvider.notifier).toggleDarkMode(),
                    child: Container(
                      margin: EdgeInsets.only(bottom: sh * 0.012),
                      padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.042, vertical: sh * 0.014),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(sw * 0.042),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(sw * 0.022),
                            decoration: BoxDecoration(
                              color: AppColors.ACCENT.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(sw * 0.024),
                            ),
                            child: Icon(Icons.dark_mode_rounded,
                                color: AppColors.ACCENT, size: sw * 0.052),
                          ),
                          SizedBox(width: sw * 0.036),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dark Mode',
                                  style: GoogleFonts.inter(
                                    fontSize: sw * 0.038,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: sh * 0.002),
                                Text(
                                  settings.isDarkMode
                                      ? 'Dark theme on'
                                      : 'Light theme on',
                                  style: GoogleFonts.inter(
                                    fontSize: sw * 0.030,
                                    color:
                                        Colors.white.withValues(alpha: 0.45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: settings.isDarkMode,
                            activeThumbColor: AppColors.ACCENT,
                            activeTrackColor:
                                AppColors.ACCENT.withValues(alpha: 0.35),
                            inactiveThumbColor:
                                Colors.white.withValues(alpha: 0.40),
                            inactiveTrackColor:
                                Colors.white.withValues(alpha: 0.12),
                            onChanged: (_) => ref
                                .read(settingsProvider.notifier)
                                .toggleDarkMode(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SettingItem(
                    icon: Icons.currency_exchange_rounded,
                    title: 'Currency',
                    subtitle: settings.preferredCurrency,
                    onTap: () => _showCurrencyPicker(context, ref),
                  ),
                  _SectionLabel('Tools', sw, sh),
                  SettingItem(
                    icon: Icons.currency_exchange_rounded,
                    title: 'Currency Converter',
                    subtitle: 'Convert between currencies',
                    onTap: () => _showConverter(context),
                  ),
                  SettingItem(
                    icon: Icons.calculate_rounded,
                    title: 'Tax Calculator',
                    subtitle: 'Calculate your tax',
                    onTap: () => _showTaxCalc(context),
                  ),
                  SettingItem(
                    icon: Icons.savings_rounded,
                    title: 'Savings Goals',
                    subtitle: 'Track your savings goals',
                    onTap: () => context.push('/savings'),
                  ),
                  _SectionLabel('Account', sw, sh),
                  SettingItem(
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                    subtitle: settings.notificationsEnabled
                        ? 'Enabled'
                        : 'Disabled',
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .toggleNotifications(),
                  ),
                  SettingItem(
                    icon: Icons.help_rounded,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact us',
                    onTap: () {},
                  ),
                  SizedBox(height: sh * 0.004),
                  SettingItem(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFFF5252),
                    title: 'Sign Out',
                    subtitle: 'Log out of your account',
                    onTap: () => _confirmLogout(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    const currencies = [
      'GHS', 'USD', 'EUR', 'GBP', 'NGN', 'KES', 'ZAR', 'JPY'
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final sw = MediaQuery.of(ctx).size.width;
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(sw * 0.060),
          children: [
            Text(
              'Select Currency',
              style: GoogleFonts.montserrat(
                fontSize: sw * 0.046,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ...currencies.map((c) => ListTile(
                  title: Text(c,
                      style: GoogleFonts.inter(
                          color: Colors.white, fontSize: sw * 0.038)),
                  onTap: () {
                    ref.read(settingsProvider.notifier).setCurrency(c);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        );
      },
    );
  }

  void _showConverter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const CurrencyConverterScreen(),
    );
  }

  void _showTaxCalc(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const TaxCalculatorScreen(),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2035),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.montserrat(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.60)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.inter(
                  color: const Color(0xFFFF5252),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final double sw, sh;
  const _SectionLabel(this.text, this.sw, this.sh);

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: sh * 0.010, top: sh * 0.006),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: sw * 0.028,
            color: Colors.white.withValues(alpha: 0.35),
            letterSpacing: 1.2,
          ),
        ),
      );
}
