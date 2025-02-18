import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: CinemapsTheme.deepSpaceBlack,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text(
              'Notifications',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notification settings
              },
              activeColor: CinemapsTheme.hotPink,
            ),
          ),
          ListTile(
            title: const Text(
              'Location Services',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement location settings
              },
              activeColor: CinemapsTheme.hotPink,
            ),
          ),
          ListTile(
            title: const Text(
              'Dark Mode',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement theme settings
              },
              activeColor: CinemapsTheme.hotPink,
            ),
          ),
          ListTile(
            title: const Text(
              'Privacy',
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
            onTap: () {
              // TODO: Navigate to privacy settings
            },
          ),
          ListTile(
            title: const Text(
              'About',
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
            onTap: () {
              // TODO: Show about dialog
            },
          ),
        ],
      ),
    );
  }
}
