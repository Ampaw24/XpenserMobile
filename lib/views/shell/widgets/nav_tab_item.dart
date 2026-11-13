import 'package:flutter/material.dart';

class NavTabItem {
  const NavTabItem({
    required this.icon,
    required this.label,
    required this.branchIndex,
  });

  final IconData icon;
  final String label;

  /// Index of the [StatefulShellBranch] this tab opens.
  final int branchIndex;
}
