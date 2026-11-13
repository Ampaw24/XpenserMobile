import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/widgets/app_text_field.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
import 'package:expenser/core/utils/theme/buttons.dart';
import 'package:expenser/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authProvider.notifier)
        .register(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
    if (mounted) {
      final error = ref.read(authProvider).errorMessage;
      if (error == null) context.go('/shell/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight;
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : AppBrand.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: titleColor, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: BrandWatermarkBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              0,
              24,
              BrandWatermarkBackground.reservedHeight(context),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Start managing your finances today',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _nameCtrl,
                          label: 'Full name',
                          hint: 'John Doe',
                          prefixIcon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Name is required'
                                      : null,
                        ),
                        SizedBox(height: context.rs(16)),
                        AppTextField(
                          controller: _emailCtrl,
                          label: 'Email',
                          hint: 'you@example.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        SizedBox(height: context.rs(16)),
                        AppTextField(
                          controller: _passwordCtrl,
                          label: 'Password',
                          hint: 'Min 6 characters',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onFieldSubmitted: (_) => _submit(),
                          suffixIcon: IconButton(
                            tooltip:
                                _obscure ? 'Show password' : 'Hide password',
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: context.rs(20),
                            ),
                            onPressed:
                                () => setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            if (v.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  if (auth.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      auth.errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFFE11D48),
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  auth.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomisedElevatedButton(
                        text: 'Create Account',
                        onPressed: _submit,
                      ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: subtitleColor,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppBrand.tealPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
