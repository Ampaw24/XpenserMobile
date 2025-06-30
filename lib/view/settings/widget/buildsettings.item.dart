import 'package:flutter/material.dart';

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    // Responsive sizing
    final horizontalPadding = _getHorizontalPadding(screenWidth);
    final verticalPadding = _getVerticalPadding(screenHeight);
    final iconSize = _getIconSize(screenWidth);
    final titleFontSize = _getTitleFontSize(screenWidth);
    final subtitleFontSize = _getSubtitleFontSize(screenWidth);
    final borderRadius = _getBorderRadius(screenWidth);
    final iconPadding = _getIconPadding(screenWidth);
    final spacing = _getSpacing(screenWidth);
    final bottomMargin = _getBottomMargin(screenHeight);

    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: Material(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: isLargeScreen ? 12 : (isTablet ? 10 : 8),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.blue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(iconPadding),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? Colors.blue[600],
                    size: iconSize,
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: isTablet ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey[600],
                        ),
                        maxLines: isTablet ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: _getArrowIconSize(screenWidth),
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Responsive sizing methods
  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth > 900) return 24.0;
    if (screenWidth > 600) return 20.0;
    return 16.0;
  }

  double _getVerticalPadding(double screenHeight) {
    if (screenHeight > 800) return 20.0;
    if (screenHeight > 600) return 16.0;
    return 14.0;
  }

  double _getIconSize(double screenWidth) {
    if (screenWidth > 900) return 28.0;
    if (screenWidth > 600) return 26.0;
    return 22.0;
  }

  double _getTitleFontSize(double screenWidth) {
    if (screenWidth > 900) return 18.0;
    if (screenWidth > 600) return 17.0;
    return 16.0;
  }

  double _getSubtitleFontSize(double screenWidth) {
    if (screenWidth > 900) return 15.0;
    if (screenWidth > 600) return 14.0;
    return 13.0;
  }

  double _getBorderRadius(double screenWidth) {
    if (screenWidth > 900) return 20.0;
    if (screenWidth > 600) return 18.0;
    return 16.0;
  }

  double _getIconPadding(double screenWidth) {
    if (screenWidth > 900) return 14.0;
    if (screenWidth > 600) return 12.0;
    return 10.0;
  }

  double _getSpacing(double screenWidth) {
    if (screenWidth > 900) return 20.0;
    if (screenWidth > 600) return 18.0;
    return 16.0;
  }

  double _getBottomMargin(double screenHeight) {
    if (screenHeight > 800) return 16.0;
    if (screenHeight > 600) return 14.0;
    return 12.0;
  }

  double _getArrowIconSize(double screenWidth) {
    if (screenWidth > 900) return 20.0;
    if (screenWidth > 600) return 18.0;
    return 16.0;
  }
}

// Example usage in your Settings Screen
class ExampleSettingsScreen extends StatelessWidget {
  const ExampleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 600 ? 32 : 20,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontSize: MediaQuery.of(context).size.width > 600 ? 36 : 32,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  SettingItem(
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    subtitle: 'Manage your account and personal information',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile tapped')),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                    subtitle: 'Manage app notifications and alerts',
                    iconColor: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications tapped')),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.security_rounded,
                    title: 'Security & Privacy',
                    subtitle: 'Manage your privacy and security settings',
                    iconColor: Colors.green,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Security tapped')),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.palette_rounded,
                    title: 'Appearance',
                    subtitle:
                        'Customize theme, colors, and display preferences',
                    iconColor: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Appearance tapped')),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.language_rounded,
                    title: 'Language & Region',
                    subtitle: 'Change app language and regional settings',
                    iconColor: Colors.teal,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Language tapped')),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.storage_rounded,
                    title: 'Storage & Data',
                    subtitle: 'Manage app data usage and storage preferences',
                    iconColor: Colors.indigo,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Storage tapped')),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.help_rounded,
                    title: 'Help & Support',
                    subtitle:
                        'Get help, report issues, and contact support team',
                    iconColor: Colors.red,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help tapped')),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.info_rounded,
                    title: 'About',
                    subtitle:
                        'App version, terms of service, and legal information',
                    iconColor: Colors.grey,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('About'),
                              content: const Text(
                                'Flutter Settings App v1.0.0',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
