// Settings Screen
import 'package:expenser/view/settings/widget/buildsettings.item.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  SettingItem(
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    subtitle: 'Manage your account',
                    onTap: () {},
                  ),
                  SettingItem(
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                    subtitle: 'Manage notifications',
                    onTap: () {},
                  ),
                  SettingItem(
                    icon: Icons.security_rounded,
                    title: 'Security',
                    subtitle: 'Privacy and security settings',
                    onTap: () {},
                  ),
                  SettingItem(
                    icon: Icons.palette_rounded,
                    title: 'Appearance',
                    subtitle: 'Theme and display settings',
                    onTap: () {},
                  ),
                  SettingItem(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    subtitle: 'Change app language',
                    onTap: () {},
                  ),
                  SettingItem(
                    icon: Icons.help_rounded,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact us',
                    onTap: () {},
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