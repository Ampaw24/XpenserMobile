import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/extensions/color_extensions.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_color_picker.dart';
import 'package:expenser/core/utils/widgets/app_field_label.dart';
import 'package:expenser/core/utils/widgets/app_form_layout.dart';
import 'package:expenser/core/utils/widgets/app_icon_picker.dart';
import 'package:expenser/core/utils/widgets/app_identity_preview.dart';
import 'package:expenser/core/utils/widgets/app_option_sheet.dart';
import 'package:expenser/core/utils/widgets/app_primary_button.dart';
import 'package:expenser/core/utils/widgets/app_select_field.dart';
import 'package:expenser/core/utils/widgets/app_text_field.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/account_type.dart';
import 'package:expenser/services/notification/fcm_service.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class AddEditAccountScreen extends ConsumerStatefulWidget {
  final String? accountId;
  const AddEditAccountScreen({super.key, this.accountId});

  @override
  ConsumerState<AddEditAccountScreen> createState() =>
      _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends ConsumerState<AddEditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();

  AccountModel? _existing;
  AccountType _type = AccountType.cash;
  String _colorHex = 'FF4CAF50';
  int _iconCodePoint = Icons.wallet_rounded.codePoint;
  String _currency = 'GHS';
  bool _isLoading = false;

  bool get _isEditing => widget.accountId != null;

  static const _colors = [
    'FF4CAF50',
    'FF2196F3',
    'FFFF9800',
    'FFE91E63',
    'FF9C27B0',
    'FF00BCD4',
    'FF795548',
    'FF607D8B',
  ];

  static const _icons = [
    Icons.wallet_rounded,
    Icons.account_balance_rounded,
    Icons.phone_android_rounded,
    Icons.savings_rounded,
    Icons.credit_card_rounded,
    Icons.attach_money_rounded,
  ];

  static const _currencies = ['GHS', 'USD', 'EUR', 'GBP', 'NGN', 'KES', 'ZAR'];

  static IconData _typeIcon(AccountType type) => switch (type) {
    AccountType.cash => Icons.payments_rounded,
    AccountType.bank => Icons.account_balance_rounded,
    AccountType.mobileMoney => Icons.phone_android_rounded,
    AccountType.savings => Icons.savings_rounded,
  };

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  void _loadExisting() {
    final accounts = ref.read(accountProvider).accounts;
    final account = accounts.firstWhere((a) => a.id == widget.accountId);
    _nameCtrl.text = account.name;
    _balanceCtrl.text = account.initialBalance.toStringAsFixed(2);
    setState(() {
      _existing = account;
      _type = account.type;
      _colorHex = account.colorHex;
      _iconCodePoint = account.iconCodePoint;
      _currency = account.currencyCode;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final name = _nameCtrl.text.trim();
    final balance = double.tryParse(_balanceCtrl.text) ?? 0;
    final existing = _existing;
    final account =
        existing?.copyWith(
          name: name,
          type: _type,
          initialBalance: balance,
          currencyCode: _currency,
          colorHex: _colorHex,
          iconCodePoint: _iconCodePoint,
        ) ??
        AccountModel(
          id: const Uuid().v4(),
          name: name,
          type: _type,
          initialBalance: balance,
          currencyCode: _currency,
          colorHex: _colorHex,
          iconCodePoint: _iconCodePoint,
          createdAt: DateTime.now(),
        );

    try {
      final notifier = ref.read(accountProvider.notifier);
      if (_isEditing) {
        await notifier.updateAccount(account);
      } else {
        await notifier.addAccount(account);
        await ref
            .read(fcmServiceProvider)
            .showLocalNotification(
              title: 'Account Added',
              body: '"${account.name}" has been added to your accounts.',
              type: 'account',
              route: '/shell/accounts',
            );
      }
      if (mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the account. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(_colorHex, fallback: context.palette.accent);
    final fieldGap = SizedBox(height: context.rs(16));
    final sectionGap = SizedBox(height: context.rs(28));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Account' : 'New Account'),
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(AppIcons.arrowLeft, size: context.rs(22)),
          onPressed: () => context.pop(),
        ),
      ),
      body: AppFormLayout(
        formKey: _formKey,
        action: AppPrimaryButton(
          label: _isEditing ? 'Save Changes' : 'Create Account',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
        children: [
          AppIdentityPreview(
            icon: IconData(_iconCodePoint, fontFamily: 'MaterialIcons'),
            color: color,
            name: _nameCtrl,
            placeholder: 'Account name',
            subtitle: '${_type.label} · $_currency',
          ),
          sectionGap,
          AppTextField(
            controller: _nameCtrl,
            label: 'Account name',
            hint: 'e.g. Main wallet',
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator:
                (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Give this account a name'
                        : null,
          ),
          fieldGap,
          AppSelectField<AccountType>(
            label: 'Account type',
            value: _type,
            prefixIcon: _typeIcon(_type),
            options: [
              for (final type in AccountType.values)
                AppSelectOption(
                  value: type,
                  label: type.label,
                  icon: _typeIcon(type),
                ),
            ],
            onChanged: (type) => setState(() => _type = type),
          ),
          fieldGap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: AppTextField(
                  controller: _balanceCtrl,
                  label: 'Opening balance',
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [AppTextField.decimalFormatter],
                ),
              ),
              SizedBox(width: context.rs(12)),
              Expanded(
                flex: 2,
                child: AppSelectField<String>(
                  label: 'Currency',
                  value: _currency,
                  options: [
                    for (final code in _currencies)
                      AppSelectOption(value: code, label: code),
                  ],
                  onChanged: (code) => setState(() => _currency = code),
                ),
              ),
            ],
          ),
          sectionGap,
          const AppFieldLabel('Color'),
          AppColorPicker(
            options: _colors,
            selectedHex: _colorHex,
            onSelected: (hex) => setState(() => _colorHex = hex),
          ),
          SizedBox(height: context.rs(20)),
          const AppFieldLabel('Icon'),
          AppIconPicker(
            options: _icons,
            selectedCodePoint: _iconCodePoint,
            color: color,
            onSelected: (code) => setState(() => _iconCodePoint = code),
          ),
        ],
      ),
    );
  }
}
