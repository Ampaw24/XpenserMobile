import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/account_type.dart';
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
  final _balanceCtrl = TextEditingController(text: '0');

  AccountType _type = AccountType.cash;
  String _colorHex = 'FF4CAF50';
  int _iconCodePoint = Icons.wallet_rounded.codePoint;
  String _currency = 'GHS';
  bool _isLoading = false;

  bool get _isEditing => widget.accountId != null;

  static const _colors = [
    'FF4CAF50', 'FF2196F3', 'FFFF9800', 'FFE91E63',
    'FF9C27B0', 'FF00BCD4', 'FF795548', 'FF607D8B',
  ];

  static const _icons = [
    Icons.wallet_rounded, Icons.account_balance_rounded,
    Icons.phone_android_rounded, Icons.savings_rounded,
    Icons.credit_card_rounded, Icons.attach_money_rounded,
  ];

  static const _currencies = ['GHS', 'USD', 'EUR', 'GBP', 'NGN', 'KES', 'ZAR'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  void _loadExisting() {
    final accounts = ref.read(accountProvider).accounts;
    final account =
        accounts.firstWhere((a) => a.id == widget.accountId);
    _nameCtrl.text = account.name;
    _balanceCtrl.text = account.initialBalance.toStringAsFixed(2);
    setState(() {
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final account = AccountModel(
      id: _isEditing ? widget.accountId! : const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      type: _type,
      initialBalance: double.tryParse(_balanceCtrl.text) ?? 0,
      currencyCode: _currency,
      colorHex: _colorHex,
      iconCodePoint: _iconCodePoint,
      createdAt: DateTime.now(),
    );
    final notifier = ref.read(accountProvider.notifier);
    if (_isEditing) {
      await notifier.updateAccount(account);
    } else {
      await notifier.addAccount(account);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Account' : 'New Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Account Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.PRIMARY),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AccountType>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: 'Account Type',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: AccountType.values
                    .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                            t.name[0].toUpperCase() + t.name.substring(1))))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _balanceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Initial Balance',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.PRIMARY),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _currency,
                      decoration: InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _currencies
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _currency = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Color',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.grey)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: _colors.map((hex) {
                  final color = Color(int.parse(hex, radix: 16));
                  return GestureDetector(
                    onTap: () => setState(() => _colorHex = hex),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _colorHex == hex
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Icon',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.grey)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: _icons.map((icon) {
                  final isSelected = icon.codePoint == _iconCodePoint;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _iconCodePoint = icon.codePoint),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.PRIMARY.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: AppColors.PRIMARY)
                            : null,
                      ),
                      child: Icon(icon,
                          color: isSelected
                              ? AppColors.PRIMARY
                              : Colors.grey[600]),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.PRIMARY,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'Update Account' : 'Create Account',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
