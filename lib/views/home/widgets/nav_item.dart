import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/viewmodels/navigation_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class NavItem extends ConsumerWidget {
  const NavItem({
    super.key,
    required this.index,
    required this.icon,
    required this.label,
    required this.currentIndex,
    this.onTap,
    required this.size,
  });

  final int index;
  final IconData icon;
  final String label;
  final int currentIndex;
  final VoidCallback? onTap;
  final Size? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (currentIndex != index) {
            ref.read(navigationProvider.notifier).state = index;
            onTap?.call();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.ACCENT.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.ACCENT : Colors.grey[600],
                  size: isSelected ? 26 : 24,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected ? AppColors.PRIMARY : Colors.grey[600],
                ),
                child: Text(label, style: GoogleFonts.inter()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
