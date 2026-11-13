import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_motion.dart';
import 'package:expenser/views/shell/widgets/nav_tab_item.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.leadingTabs,
    required this.centerTab,
    required this.trailingTabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavTabItem> leadingTabs;
  final NavTabItem centerTab;
  final List<NavTabItem> trailingTabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    void select(int index) {
      HapticFeedback.selectionClick();
      onTap(index);
    }

    Widget tab(NavTabItem item) => Expanded(
      child: _NavTab(
        item: item,
        isActive: item.branchIndex == currentIndex,
        onTap: () => select(item.branchIndex),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.surface,
        border: Border(
          top: BorderSide(color: context.palette.border, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: context.rs(16),
            offset: Offset(0, -context.rs(2)),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: context.contentGutter - context.rs(12),
          right: context.contentGutter - context.rs(12),
          top: context.rs(8),
          bottom: bottomInset > 0 ? bottomInset : context.rs(10),
        ),
        child: SizedBox(
          height: context.rs(62),
          child: Row(
            children: [
              ...leadingTabs.map(tab),
              Expanded(
                child: _CenterButton(
                  item: centerTab,
                  isActive: centerTab.branchIndex == currentIndex,
                  onTap: () => select(centerTab.branchIndex),
                ),
              ),
              ...trailingTabs.map(tab),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
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
    final activeColor = isDark ? AppBrand.mintAccent : AppBrand.spruceDark;
    final inactiveColor =
        isDark
            ? AppBrand.textSecondaryDark.withValues(alpha: 0.6)
            : AppBrand.textMutedLight;
    final color = isActive ? activeColor : inactiveColor;
    final duration = AppMotion.of(context, AppMotion.medium);

    return Semantics(
      button: true,
      selected: isActive,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: context.rs(32),
        highlightShape: BoxShape.rectangle,
        containedInkWell: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: duration,
              curve: AppMotion.enter,
              width: context.rs(isActive ? 56 : 32),
              height: context.rs(30),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: isActive ? 0.14 : 0),
                borderRadius: BorderRadius.circular(context.rs(15)),
              ),
              child: Center(
                child: AnimatedScale(
                  scale: isActive ? 1.08 : 1,
                  duration: duration,
                  curve: AppMotion.bounce,
                  child: HugeIcon(
                    icon: item.icon,
                    color: color,
                    size: context.rs(22),
                  ),
                ),
              ),
            ),
            SizedBox(height: context.rs(4)),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedDefaultTextStyle(
                duration: duration,
                curve: AppMotion.standard,
                style: TextStyle(
                  fontSize: context.rs(11),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
                child: Text(item.label, maxLines: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterButton extends StatefulWidget {
  const _CenterButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final NavTabItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_CenterButton> createState() => _CenterButtonState();
}

class _CenterButtonState extends State<_CenterButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AppBrand.tealPrimary : AppBrand.spruceDark;
    final ringColor =
        widget.isActive
            ? AppBrand.mintAccent.withValues(alpha: 0.45)
            : fill.withValues(alpha: 0.12);
    final diameter = context.rs(54);
    final duration = AppMotion.of(context, AppMotion.medium);
    final scale = _pressed ? 0.9 : (widget.isActive ? 1.04 : 1.0);

    return Center(
      child: Semantics(
        button: true,
        selected: widget.isActive,
        label: widget.item.label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          child: AnimatedScale(
            scale: scale,
            duration: AppMotion.of(context, AppMotion.fast),
            curve: _pressed ? AppMotion.standard : AppMotion.bounce,
            child: AnimatedContainer(
              duration: duration,
              curve: AppMotion.enter,
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: context.rs(4)),
                boxShadow: [
                  BoxShadow(
                    color: fill.withValues(
                      alpha: (isDark ? 0.45 : 0.28) * (_pressed ? 0.6 : 1),
                    ),
                    blurRadius: context.rs(_pressed ? 8 : 14),
                    offset: Offset(0, context.rs(_pressed ? 2 : 5)),
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: widget.item.icon,
                  color: Colors.white,
                  size: context.rs(24),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
