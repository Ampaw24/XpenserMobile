import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_field_label.dart';
import 'package:flutter/material.dart';

/// Read-only field that opens a picker on tap (date, sheet, etc.).
/// Shares the exact fill and shape of [AppTextField] via the input theme.
class AppTapField extends StatelessWidget {
  const AppTapField({
    super.key,
    required this.value,
    required this.onTap,
    this.label,
    this.placeholder,
    this.prefixIcon,
    this.leading,
    this.trailingIcon = AppIcons.arrowDown,
    this.errorText,
  });

  /// Displayed value; when null, [placeholder] is shown instead.
  final String? value;
  final VoidCallback onTap;
  final String? label;
  final String? placeholder;
  final IconData? prefixIcon;

  /// Custom leading widget (e.g. a colored swatch); overrides [prefixIcon].
  final Widget? leading;
  final IconData trailingIcon;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(context.rs(16));
    final iconSize = context.rs(20);

    final field = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: InputDecorator(
          isEmpty: value == null,
          decoration: InputDecoration(
            hintText: placeholder,
            errorText: errorText,
            prefixIcon:
                leading ??
                (prefixIcon == null ? null : Icon(prefixIcon, size: iconSize)),
            suffixIcon: Icon(trailingIcon, size: context.rs(18)),
          ),
          child: Text(
            value ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: context.rs(15),
              color: palette.textPrimary,
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: label,
      value: value,
      child:
          label == null
              ? field
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [AppFieldLabel(label!), field],
              ),
    );
  }
}
