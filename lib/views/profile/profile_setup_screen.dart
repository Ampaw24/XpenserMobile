import 'package:expenser/core/constants/countries.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_form_layout.dart';
import 'package:expenser/core/utils/widgets/app_primary_button.dart';
import 'package:expenser/core/utils/widgets/app_tap_field.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/auth_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/profile/widgets/locale_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks for country and currency after sign-in. The router keeps signed-in
/// users here until both are set.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  Country? _country;
  String? _currency;
  bool _checkingProfile = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final deviceCountry = countryByCode(
      WidgetsBinding.instance.platformDispatcher.locale.countryCode,
    );
    _country = deviceCountry;
    _currency = deviceCountry?.currencyCode;
    _restoreSavedProfile();
  }

  /// A restored session may already have these on the server (e.g. set on
  /// another device); if so the router moves on by itself.
  Future<void> _restoreSavedProfile() async {
    try {
      await ref.read(settingsProvider.notifier).restoreProfileLocale();
    } catch (error) {
      debugPrint('Profile locale restore failed: $error');
    }
    if (mounted) setState(() => _checkingProfile = false);
  }

  Future<void> _pickCountry() async {
    final picked = await pickCountry(context, selected: _country?.code);
    if (picked == null || !mounted) return;
    setState(() {
      _country = picked;
      _currency = picked.currencyCode;
    });
  }

  Future<void> _pickCurrency() async {
    final code = await pickCurrency(context, selected: _currency);
    if (code != null && mounted) setState(() => _currency = code);
  }

  Future<void> _submit() async {
    final country = _country;
    final currency = _currency;
    if (_isSaving || country == null || currency == null) return;
    setState(() => _isSaving = true);
    try {
      await ref
          .read(settingsProvider.notifier)
          .completeProfile(countryCode: country.code, currencyCode: currency);
    } catch (error) {
      debugPrint('Profile setup failed: $error');
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your details. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (_checkingProfile) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Accounts exist only for users who were already using the app.
    final isExistingUser = ref.watch(accountProvider).accounts.isNotEmpty;
    final userName = ref.watch(settingsProvider.select((s) => s.userName));
    final gap = SizedBox(height: context.rs(16));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Your Country'),
        actions: [
          TextButton(
            onPressed:
                _isSaving
                    ? null
                    : () => ref.read(authProvider.notifier).logout(),
            child: const Text('Sign Out'),
          ),
        ],
      ),
      body: AppFormLayout(
        action: AppPrimaryButton(
          label: 'Continue',
          isLoading: _isSaving,
          onPressed: _country == null || _currency == null ? null : _submit,
        ),
        children: [
          if (isExistingUser) ...[
            _WarningBanner(
              text:
                  'Your account is missing your country and currency. '
                  'Add them to keep using Xpenser.',
            ),
            SizedBox(height: context.rs(20)),
          ],
          Text(
            userName.isEmpty ? 'Where are you based?' : 'Welcome, $userName',
            style: TextStyle(
              fontSize: context.rs(22),
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
          SizedBox(height: context.rs(6)),
          Text(
            'Your currency is used for new accounts, budgets and savings '
            'goals. You can change it later in Settings.',
            style: TextStyle(
              fontSize: context.rs(14),
              color: palette.textSecondary,
            ),
          ),
          SizedBox(height: context.rs(24)),
          AppTapField(
            label: 'Country',
            value: _country?.name,
            placeholder: 'Choose your country',
            prefixIcon: Icons.public_rounded,
            onTap: _pickCountry,
          ),
          gap,
          AppTapField(
            label: 'Currency',
            value: _currency,
            placeholder: 'Choose your currency',
            prefixIcon: Icons.payments_rounded,
            onTap: _pickCurrency,
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: EdgeInsets.all(context.rs(14)),
      decoration: BoxDecoration(
        color: palette.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.rs(14)),
        border: Border.all(color: palette.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: palette.warning,
            size: context.rs(20),
          ),
          SizedBox(width: context.rs(10)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: context.rs(13),
                color: palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
