import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:flutter/material.dart';

/// Full-width themed primary action; disables itself and shows a spinner
/// while [isLoading] so a submit can't be triggered twice.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child:
          isLoading
              ? SizedBox.square(
                dimension: context.rs(20),
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
              : Text(label),
    );
  }
}
