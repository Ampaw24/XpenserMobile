import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Live preview header for forms that create a named, colored item
/// (accounts, savings goals). Rebuilds only when [name] changes.
class AppIdentityPreview extends StatelessWidget {
  const AppIdentityPreview({
    super.key,
    required this.icon,
    required this.color,
    required this.name,
    required this.placeholder,
    this.subtitle,
  });

  final IconData icon;
  final Color color;
  final ValueListenable<TextEditingValue> name;
  final String placeholder;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tileSize = context.rs(72);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: tileSize,
          height: tileSize,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(context.rs(24)),
          ),
          child: Icon(icon, size: context.rs(34), color: color),
        ),
        SizedBox(height: context.rs(12)),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: name,
          builder: (context, value, _) {
            final text = value.text.trim();
            return Text(
              text.isEmpty ? placeholder : text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.rs(20),
                fontWeight: FontWeight.w700,
                color: text.isEmpty ? palette.textMuted : palette.textPrimary,
              ),
            );
          },
        ),
        if (subtitle != null) ...[
          SizedBox(height: context.rs(4)),
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
    );
  }
}
