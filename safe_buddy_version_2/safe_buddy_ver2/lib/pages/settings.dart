import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: ListView(
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          // Theme & Appearance
          Card(
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme & Appearance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Choose your preferred theme.'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement light theme switch
                        },
                        icon: const Icon(Icons.light_mode),
                        label: const Text('Light'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement dark theme switch
                        },
                        icon: const Icon(Icons.dark_mode),
                        label: const Text('Dark'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Account
          Card(
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Manage your account settings'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      // TODO: Implement change password
                    },
                    child: const Text('Change Password'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Notifications
          Card(
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Configure your notification preferences.'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Email Alerts'),
                      Switch(
                        value: true,
                        onChanged: (v) {},
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SMS Alerts'),
                      Switch(
                        value: false,
                        onChanged: (v) {},
                        activeColor: Colors.redAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // About
          Card(
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Application Version: 1.0.0'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement contact support
                    },
                    child: const Text('Contact Support'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
