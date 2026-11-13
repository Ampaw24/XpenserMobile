import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/views/shell/widgets/nav_tab_item.dart';
import 'package:flutter/material.dart';
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
    final bottom = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navBg = isDark ? AppBrand.surfaceDark : Colors.white;
    final borderColor = isDark ? AppBrand.borderDark : AppBrand.borderLight;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sw * 0.04,
        0,
        sw * 0.04,
        bottom > 0 ? bottom + 6 : 16,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: navBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            return _NavItem(
              item: tabs[i],
              isActive: i == currentIndex,
              onTap: () => onTap(i),
            );
          }),
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
  });

  final NavTabItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppBrand.mintAccent : AppBrand.tealPrimary;
    final inactiveColor = isDark ? const Color(0xFF64748B) : AppBrand.textSecondaryLight;
    final activeBg = isDark
        ? AppBrand.mintAccent.withValues(alpha: 0.15)
        : AppBrand.tealPrimary.withValues(alpha: 0.10);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isActive ? activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: HugeIcon(
                icon: item.icon,
                color: isActive ? activeColor : inactiveColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
