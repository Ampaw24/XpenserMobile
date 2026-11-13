import 'package:expenser/core/utils/widgets/app_option_sheet.dart';
import 'package:expenser/core/utils/widgets/app_tap_field.dart';
import 'package:flutter/material.dart';

/// Dropdown replacement: a tap field that opens an option bottom sheet.
class AppSelectField<T> extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.label,
    this.sheetTitle,
    this.placeholder = 'Select',
    this.prefixIcon,
  });

  final T? value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T> onChanged;
  final String? label;

  /// Defaults to [label].
  final String? sheetTitle;
  final String placeholder;
  final IconData? prefixIcon;

  Future<void> _open(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final picked = await showAppOptionSheet<T>(
      context,
      title: sheetTitle ?? label ?? placeholder,
      options: options,
      selected: value,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    String? display;
    for (final option in options) {
      if (option.value == value) display = option.label;
    }
    return AppTapField(
      label: label,
      value: display,
      placeholder: placeholder,
      prefixIcon: prefixIcon,
      onTap: () => _open(context),
    );
  }
}
