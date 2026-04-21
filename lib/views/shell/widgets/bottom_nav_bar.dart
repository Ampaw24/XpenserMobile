import 'dart:ui';

import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/views/shell/widgets/nav_tab_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavTabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sw * 0.04,
        0,
        sw * 0.04,
        bottom + sh * 0.015,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(sw * 0.065),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: sh * 0.082,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E21).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(sw * 0.065),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.0,
              ),
            ),
            child: Row(
              children: List.generate(tabs.length, (i) {
                return _NavItem(
                  item: tabs[i],
                  isActive: i == currentIndex,
                  onTap: () => onTap(i),
                  sw: sw,
                  sh: sh,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.sw,
    required this.sh,
  });

  final NavTabItem item;
  final bool isActive;
  final VoidCallback onTap;
  final double sw, sh;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.038,
                vertical: sh * 0.008,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.ACCENT.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(sw * 0.035),
              ),
              child: HugeIcon(
                icon: item.icon,
                color: isActive
                    ? AppColors.ACCENT
                    : Colors.white.withValues(alpha: 0.38),
                size: sw * 0.056,
              ),
            ),
            SizedBox(height: sh * 0.004),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: GoogleFonts.inter(
                fontSize: sw * 0.026,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.ACCENT
                    : Colors.white.withValues(alpha: 0.35),
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
