import 'package:flutter/material.dart';

/// Full-width primary button; styling comes from the app's ElevatedButtonTheme.
class CustomisedElevatedButton extends StatelessWidget {
  const CustomisedElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(text));
  }
}
