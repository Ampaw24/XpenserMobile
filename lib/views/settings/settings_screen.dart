import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_option_sheet.dart';
import 'package:expenser/core/utils/widgets/app_page_header.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/core/utils/widgets/user_avatar.dart';
import 'package:expenser/viewmodels/auth_viewmodel.dart';
import 'package:expenser/viewmodels/consolidated_balance_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:expenser/views/converters/currency_converter_screen.dart';
import 'package:expenser/views/converters/tax_calculator_screen.dart';
import 'package:expenser/views/settings/widgets/setting_item.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final settings = ref.watch(settingsProvider);
    final balance = ref.watch(consolidatedBalanceProvider);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userEmail = firebaseUser?.email ?? '';
    final isVerified = firebaseUser?.emailVerified ?? false;

    return Scaffold(
      body: BrandWatermarkBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(title: 'Profile'),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.contentGutter,
                    0,
                    context.contentGutter,
                    context.rs(24),
                  ),
                  children: [
                    _ProfileCard(
                      name: settings.userName,
                      photoUrl: settings.userAvatarPath,
                      email: userEmail,
                      isVerified: isVerified,
                      currency: balance.currency,
                      balance: balance.total,
                      isEstimate: balance.isEstimate || balance.isPartial,
                    ),
                    SizedBox(height: context.rs(20)),
                    const _SectionLabel('Preferences'),
                    SettingItem(
                      icon: Icons.dark_mode_rounded,
                      title: 'Dark Mode',
                      subtitle:
                          settings.isDarkMode
                              ? 'Dark theme on'
                              : 'Light theme on',
                      onTap:
                          () =>
                              ref
                                  .read(settingsProvider.notifier)
                                  .toggleDarkMode(),
                      trailing: Switch(
                        value: settings.isDarkMode,
                        onChanged:
                            (_) =>
                                ref
                                    .read(settingsProvider.notifier)
                                    .toggleDarkMode(),
                      ),
                    ),
                    SettingItem(
                      icon: Icons.currency_exchange_rounded,
                      title: 'Currency',
                      subtitle: settings.preferredCurrency,
                      onTap: () => _showCurrencyPicker(context, ref),
                    ),
                    const _SectionLabel('Tools'),
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
                    const _SectionLabel('Account'),
                    SettingItem(
                      icon: Icons.notifications_rounded,
                      title: 'Notifications',
                      subtitle:
                          settings.notificationsEnabled
                              ? 'Enabled'
                              : 'Disabled',
                      onTap:
                          () =>
                              ref
                                  .read(settingsProvider.notifier)
                                  .toggleNotifications(),
                    ),
                    SettingItem(
                      icon: Icons.help_rounded,
                      title: 'Help & Support',
                      subtitle: 'Get help and contact us',
                      onTap: () {},
                    ),
                    SizedBox(height: context.rs(8)),
                    SettingItem(
                      icon: Icons.logout_rounded,
                      iconColor: palette.danger,
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
      ),
    );
  }

  Future<void> _showCurrencyPicker(BuildContext context, WidgetRef ref) async {
    const currencies = ['GHS', 'USD', 'EUR', 'GBP', 'NGN', 'KES', 'ZAR', 'JPY'];
    final picked = await showAppOptionSheet<String>(
      context,
      title: 'Select currency',
      selected: ref.read(settingsProvider).preferredCurrency,
      options: [
        for (final code in currencies)
          AppSelectOption(value: code, label: code),
      ],
    );
    if (picked != null) ref.read(settingsProvider.notifier).setCurrency(picked);
  }

  void _showConverter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CurrencyConverterScreen(),
    );
  }

  void _showTaxCalc(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TaxCalculatorScreen(),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final palette = dialogContext.palette;
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: palette.textSecondary,
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(authProvider.notifier).logout();
                });
              },
              style: TextButton.styleFrom(foregroundColor: palette.danger),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.photoUrl,
    required this.email,
    required this.isVerified,
    required this.currency,
    required this.balance,
    required this.isEstimate,
  });

  final String name;
  final String? photoUrl;
  final String email;
  final bool isVerified;
  final String currency;
  final double balance;
  final bool isEstimate;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppSurfaceCard(
      color: palette.hero,
      borderColor: palette.hero,
      padding: EdgeInsets.all(context.rs(18)),
      child: Row(
        children: [
          UserAvatar(name: name, photoUrl: photoUrl, diameter: context.rs(56)),
          SizedBox(width: context.rs(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'User',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.onHero,
                    fontWeight: FontWeight.w700,
                    fontSize: context.rs(16),
                  ),
                ),
                SizedBox(height: context.rs(4)),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        email,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.onHeroMuted,
                          fontSize: context.rs(12),
                        ),
                      ),
                    ),
                    SizedBox(width: context.rs(6)),
                    _VerificationBadge(isVerified: isVerified),
                  ],
                ),
                SizedBox(height: context.rs(8)),
                Text(
                  '${isEstimate ? '≈ ' : ''}${NumberFormat.currency(symbol: '$currency ', decimalDigits: 2).format(balance)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.onHero,
                    fontWeight: FontWeight.w600,
                    fontSize: context.rs(15),
                  ),
                ),
                SizedBox(height: context.rs(2)),
                Text(
                  '$currency · Total Balance',
                  style: TextStyle(
                    color: palette.onHeroMuted,
                    fontSize: context.rs(11),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = isVerified ? palette.onHeroSuccess : palette.onHeroWarning;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(7),
        vertical: context.rs(2),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(context.rs(20)),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.warning_amber_rounded,
            size: context.rs(11),
            color: color,
          ),
          SizedBox(width: context.rs(3)),
          Text(
            isVerified ? 'Verified' : 'Unverified',
            style: TextStyle(
              fontSize: context.rs(10.5),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      top: context.rs(6),
      bottom: context.rs(8),
      left: context.rs(4),
    ),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: context.rs(11.5),
        color: context.palette.textSecondary,
        letterSpacing: 0.8,
      ),
    ),
  );
}
