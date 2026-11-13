import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final titleColor = context.palette.textPrimary;
    final linkColor = context.palette.textSecondary;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: context.rs(16),
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: linkColor,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(horizontal: context.rs(6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See all',
                  style: TextStyle(
                    fontSize: context.rs(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: context.rs(4)),
                HugeIcon(
                  icon: AppIcons.arrowForward,
                  color: linkColor,
                  size: context.rs(15),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
