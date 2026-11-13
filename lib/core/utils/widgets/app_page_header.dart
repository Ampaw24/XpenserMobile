import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Large title row used at the top of every bottom-nav tab screen.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.contentGutter,
        context.rs(12),
        context.contentGutter,
        context.rs(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.rs(24),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: palette.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: context.rs(2)),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.rs(13),
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
