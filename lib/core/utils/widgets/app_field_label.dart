import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Caption shown above a form control — never on its border.
class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel(this.text, {super.key, this.trailing});

  final String text;

  /// Optional right-aligned widget, e.g. a live value or helper action.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.rs(4),
        right: context.rs(4),
        bottom: context.rs(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: context.rs(13),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: context.palette.textSecondary,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
