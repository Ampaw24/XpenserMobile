import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Accent-barred title used at the top of the converter bottom sheets.
class SheetTitle extends StatelessWidget {
  const SheetTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Container(
          width: context.rs(4),
          height: context.rs(20),
          decoration: BoxDecoration(
            color: palette.accent,
            borderRadius: BorderRadius.circular(context.rs(2)),
          ),
        ),
        SizedBox(width: context.rs(10)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: context.rs(18),
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
