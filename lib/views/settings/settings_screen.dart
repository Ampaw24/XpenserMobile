import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/viewmodels/auth_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/converters/currency_converter_screen.dart';
import 'package:expenser/views/converters/tax_calculator_screen.dart';
import 'package:expenser/views/settings/widgets/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Settings',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Profile card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.PRIMARY, AppColors.ACCENT],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      settings.userName.isNotEmpty
                          ? settings.userName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.userName.isNotEmpty
                              ? settings.userName
                              : 'User',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text(
                          settings.preferredCurrency,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // Dark mode toggle
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Dark Mode',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          settings.isDarkMode ? 'Dark theme on' : 'Light theme on',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12)),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.PRIMARY.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.dark_mode_rounded,
                            color: AppColors.PRIMARY, size: 20),
                      ),
                      value: settings.isDarkMode,
                      activeThumbColor: AppColors.PRIMARY,
                      activeTrackColor: AppColors.PRIMARY.withValues(alpha: 0.4),
                      onChanged: (_) =>
                          ref.read(settingsProvider.notifier).toggleDarkMode(),
                    ),
                  ),
                  // Currency preference
                  SettingItem(
                    icon: Icons.currency_exchange_rounded,
                    title: 'Currency',
                    subtitle: settings.preferredCurrency,
                    onTap: () => _showCurrencyPicker(context, ref),
                  ),
                  // Tools section
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Tools',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.grey,
                            letterSpacing: 0.5)),
                  ),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Account',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.grey,
                            letterSpacing: 0.5)),
                  ),
                  SettingItem(
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                    subtitle: settings.notificationsEnabled ? 'Enabled' : 'Disabled',
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
                  const SizedBox(height: 8),
                  SettingItem(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: 'Log out of your account',
                    iconColor: Colors.red,
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
    const currencies = ['GHS', 'USD', 'EUR', 'GBP', 'NGN', 'KES', 'ZAR', 'JPY'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Select Currency',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...currencies.map((c) => ListTile(
                title: Text(c),
                onTap: () {
                  ref.read(settingsProvider.notifier).setCurrency(c);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  void _showConverter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const CurrencyConverterScreen(),
    );
  }

  void _showTaxCalc(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const TaxCalculatorScreen(),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
