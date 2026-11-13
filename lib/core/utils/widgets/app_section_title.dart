import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Bold group heading inside forms, with an optional inline error hint.
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle(this.text, {super.key, this.trailing});

  final String text;

  /// Inline error hint shown at the end of the row.
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: context.rs(15),
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(fontSize: context.rs(12), color: palette.danger),
          ),
      ],
    );
  }
}
