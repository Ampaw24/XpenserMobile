import 'package:expenser/core/constants/branding.dart';
import 'package:flutter/material.dart';

/// Circular profile photo with a brand ring; falls back to initials when the
/// user has no photo or it fails to load (offline, expired URL).
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.diameter,
  });

  final String name;
  final String? photoUrl;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim() ?? '';
    final hasPhoto = Uri.tryParse(url)?.hasScheme ?? false;
    final ringWidth = diameter * 0.05;

    return Container(
      width: diameter,
      height: diameter,
      padding: EdgeInsets.all(ringWidth),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppBrand.mintAccent, AppBrand.tealPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CircleAvatar(
        backgroundColor: AppBrand.spruceDark,
        foregroundImage: hasPhoto ? NetworkImage(url) : null,
        onForegroundImageError: hasPhoto ? (_, __) {} : null,
        child: Text(
          _initials(name),
          style: TextStyle(
            fontFamily: 'Inter',
            color: AppBrand.mintLight,
            fontWeight: FontWeight.w700,
            fontSize: diameter * 0.34,
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }
}
