import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Standard text input: caption above, filled borderless field below.
/// Visual style comes from the app's `InputDecorationTheme`.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofillHints,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
  });

  /// Numeric input limited to two decimal places.
  static final decimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d{0,2}'),
  );

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final field = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofillHints,
      obscureText: obscureText,
      autofocus: autofocus,
      enabled: enabled,
      minLines: minLines,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      style: TextStyle(fontSize: context.rs(15), color: palette.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            prefixIcon == null ? null : Icon(prefixIcon, size: context.rs(20)),
        suffixIcon: suffixIcon,
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [AppFieldLabel(label!), field],
    );
  }
}
