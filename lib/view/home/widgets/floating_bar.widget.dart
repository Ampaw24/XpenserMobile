import 'package:expenser/view/home/widgets/floating_baritem.widget.dart';
import 'package:flutter/material.dart';

class FloatingNavigationBar extends StatelessWidget {
  const FloatingNavigationBar({super.key, required this.currentIndex});
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: s.width * 0.05,
        vertical: s.height * 0.02,
      ),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        child: Container(
          height: s.height * 0.086,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.home_rounded,
                label: 'Home',
                size: s,
              ),
              NavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.settings_rounded,
                label: 'Settings',
                size: s,
              ),
              NavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.currency_exchange_rounded,
                label: 'Convert',
                size: s,
              ),
              NavItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.calculate_rounded,
                label: 'Tax',
                size: s,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
