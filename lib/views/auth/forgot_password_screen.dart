import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/utils/theme/buttons.dart';
import 'package:expenser/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).forgotPassword(_emailCtrl.text.trim());
    final error = ref.read(authProvider).errorMessage;
    if (error == null) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: titleColor, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child:
              _sent
                  ? _SuccessView(email: _emailCtrl.text)
                  : _FormView(
                    formKey: _formKey,
                    emailCtrl: _emailCtrl,
                    onSubmit: _submit,
                  ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final VoidCallback onSubmit;

  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight;
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : AppBrand.textSecondaryLight;
    final iconColor =
        isDark ? const Color(0xFF94A3B8) : AppBrand.textSecondaryLight;
    final borderColor = isDark ? AppBrand.borderDark : AppBrand.borderLight;
    final fieldBg = isDark ? AppBrand.surfaceDarkElevated : Colors.white;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Reset Password',
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
            "Enter your email and we'll send reset instructions",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontFamily: 'Inter',
              color: titleColor,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
              filled: true,
              fillColor: fieldBg,
              prefixIcon: Icon(
                Icons.email_outlined,
                color: iconColor,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppBrand.tealPrimary,
                  width: 1.5,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 28),
          CustomisedElevatedButton(
            text: 'Send Reset Link',
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight;
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : AppBrand.textSecondaryLight;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppBrand.tealPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 48,
              color: AppBrand.tealPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Check Your Email',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We sent instructions to $email',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 28),
          CustomisedElevatedButton(
            text: 'Back to Sign In',
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}
