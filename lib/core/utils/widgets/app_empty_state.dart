import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Centered icon + title + message shown when a list has no data.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;

  /// Optional call-to-action (e.g. a FilledButton).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.rs(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(context.rs(18)),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: context.rs(32), color: palette.accent),
            ),
            SizedBox(height: context.rs(16)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.rs(16),
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
            if (message != null) ...[
              SizedBox(height: context.rs(6)),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.rs(13),
                  color: palette.textSecondary,
                ),
              ),
            ],
            if (action != null) ...[SizedBox(height: context.rs(20)), action!],
          ],
        ),
      ),
    );
  }
}
