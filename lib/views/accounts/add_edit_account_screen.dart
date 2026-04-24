import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/account_type.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final account = accounts.firstWhere((a) => a.id == widget.accountId);
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

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.50)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.ACCENT, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          _isEditing ? 'Edit Account' : 'New Account',
          style: GoogleFonts.montserrat(
            fontSize: sw * 0.046,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
                sw * 0.06, sh * 0.010, sw * 0.06, sh * 0.06),
            children: [
              TextFormField(
                controller: _nameCtrl,
                style: GoogleFonts.inter(
                    color: Colors.white, fontSize: sw * 0.038),
                cursorColor: AppColors.ACCENT,
                decoration: _inputDeco('Account Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name required' : null,
              ),
              SizedBox(height: sh * 0.026),
              _AnimatedDropdown<AccountType>(
                label: 'Account Type',
                value: _type,
                options: AccountType.values.toList(),
                labelOf: (t) => t.name[0].toUpperCase() + t.name.substring(1),
                onChanged: (v) => setState(() => _type = v),
                sw: sw,
                sh: sh,
              ),
              SizedBox(height: sh * 0.022),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _balanceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: GoogleFonts.inter(
                          color: Colors.white, fontSize: sw * 0.038),
                      cursorColor: AppColors.ACCENT,
                      decoration: _inputDeco('Initial Balance'),
                    ),
                  ),
                  SizedBox(width: sw * 0.030),
                  Expanded(
                    child: _AnimatedDropdown<String>(
                      label: 'Currency',
                      value: _currency,
                      options: _currencies.toList(),
                      labelOf: (c) => c,
                      onChanged: (v) => setState(() => _currency = v),
                      sw: sw,
                      sh: sh,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.028),
              Text(
                'Color',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: sw * 0.032,
                  color: Colors.white.withValues(alpha: 0.50),
                ),
              ),
              SizedBox(height: sh * 0.012),
              Wrap(
                spacing: sw * 0.030,
                runSpacing: sh * 0.012,
                children: _colors.map((hex) {
                  final color = Color(int.parse(hex, radix: 16));
                  final isSelected = _colorHex == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _colorHex = hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: sw * 0.090,
                      height: sw * 0.090,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : Border.all(
                                color: Colors.white.withValues(alpha: 0.0),
                                width: 3),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: color.withValues(alpha: 0.55),
                                    blurRadius: 10)
                              ]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: sh * 0.024),
              Text(
                'Icon',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: sw * 0.032,
                  color: Colors.white.withValues(alpha: 0.50),
                ),
              ),
              SizedBox(height: sh * 0.012),
              Wrap(
                spacing: sw * 0.030,
                runSpacing: sh * 0.012,
                children: _icons.map((icon) {
                  final isSelected = icon.codePoint == _iconCodePoint;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _iconCodePoint = icon.codePoint),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: sw * 0.120,
                      height: sw * 0.120,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.ACCENT.withValues(alpha: 0.20)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(sw * 0.030),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.ACCENT
                              : Colors.white.withValues(alpha: 0.12),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.ACCENT.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? AppColors.ACCENT
                            : Colors.white.withValues(alpha: 0.40),
                        size: sw * 0.058,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: sh * 0.040),
              _GradientButton(
                label: _isEditing ? 'Update Account' : 'Create Account',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submit,
                sw: sw,
                sh: sh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Custom Dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedDropdown<T> extends StatefulWidget {
  final String label;
  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final double sw;
  final double sh;

  const _AnimatedDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
    required this.sw,
    required this.sh,
  });

  @override
  State<_AnimatedDropdown<T>> createState() => _AnimatedDropdownState<T>();
}

class _AnimatedDropdownState<T> extends State<_AnimatedDropdown<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _arrowTurns;
  late final Animation<double> _fadeAnim;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _arrowTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    final willOpen = !_open;
    setState(() => _open = willOpen);
    if (willOpen) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  void _select(T value) {
    widget.onChanged(value);
    setState(() => _open = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final sw = widget.sw;
    final sh = widget.sh;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label sits above — never floats onto the border
        Padding(
          padding: EdgeInsets.only(left: sw * 0.010),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: sw * 0.030,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.55),
              letterSpacing: 0.3,
            ),
          ),
        ),
        SizedBox(height: sh * 0.007),

        // Trigger field
        GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: sh * 0.068,
            padding: EdgeInsets.symmetric(horizontal: sw * 0.040),
            decoration: BoxDecoration(
              color: _open
                  ? AppColors.ACCENT.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: _open
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    )
                  : BorderRadius.circular(14),
              border: Border.all(
                color: _open
                    ? AppColors.ACCENT
                    : Colors.white.withValues(alpha: 0.12),
                width: _open ? 1.5 : 1.0,
              ),
              boxShadow: _open
                  ? [
                      BoxShadow(
                        color: AppColors.ACCENT.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.labelOf(widget.value),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: sw * 0.036,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                RotationTransition(
                  turns: _arrowTurns,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _open
                        ? AppColors.ACCENT
                        : Colors.white.withValues(alpha: 0.45),
                    size: sw * 0.058,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Inline expanding menu
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          child: _open
              ? FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141929),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      border: Border(
                        left: BorderSide(color: AppColors.ACCENT, width: 1.5),
                        right: BorderSide(color: AppColors.ACCENT, width: 1.5),
                        bottom: BorderSide(color: AppColors.ACCENT, width: 1.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.30),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(13),
                        bottomRight: Radius.circular(13),
                      ),
                      child: Column(
                        children: widget.options.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final option = entry.value;
                          final isSelected = option == widget.value;
                          final isLast = idx == widget.options.length - 1;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (idx == 0)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color:
                                      AppColors.ACCENT.withValues(alpha: 0.20),
                                ),
                              InkWell(
                                onTap: () => _select(option),
                                splashColor:
                                    AppColors.ACCENT.withValues(alpha: 0.12),
                                highlightColor:
                                    AppColors.ACCENT.withValues(alpha: 0.06),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  height: sh * 0.060,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: sw * 0.040),
                                  color: isSelected
                                      ? AppColors.ACCENT
                                          .withValues(alpha: 0.12)
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.labelOf(option),
                                          style: GoogleFonts.inter(
                                            color: isSelected
                                                ? AppColors.ACCENT
                                                : Colors.white
                                                    .withValues(alpha: 0.85),
                                            fontSize: sw * 0.036,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 150),
                                        opacity: isSelected ? 1.0 : 0.0,
                                        child: Icon(
                                          Icons.check_rounded,
                                          color: AppColors.ACCENT,
                                          size: sw * 0.044,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  indent: sw * 0.040,
                                  endIndent: sw * 0.040,
                                  color:
                                      Colors.white.withValues(alpha: 0.06),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient Submit Button
// ─────────────────────────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double sw, sh;
  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: sh * 0.065,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.PRIMARY, AppColors.ACCENT],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(sw * 0.042),
          boxShadow: [
            BoxShadow(
              color: AppColors.ACCENT.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
