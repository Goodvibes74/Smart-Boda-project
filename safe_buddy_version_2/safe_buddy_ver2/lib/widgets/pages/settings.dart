// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:safe_buddy_ver2/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: ListView(
        children: [
          // Page Title
          Text(
            'Settings',
            style: text.titleLarge?.copyWith(color: cs.onSurface, fontSize: 32),
          ),
          const SizedBox(height: 24),

          // Theme & Appearance
          Card(
            color: cs.surface,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme & Appearance',
                    style: text.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your preferred theme.',
                    style: text.bodyLarge?.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          /* TODO: light mode */
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cs.primary),
                          foregroundColor: cs.onSurface,
                        ),
                        icon: Icon(Icons.light_mode, color: cs.primary),
                        label: Text('Light', style: text.bodyLarge),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          /* TODO: dark mode */
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cs.primary),
                          foregroundColor: cs.onSurface,
                        ),
                        icon: Icon(Icons.dark_mode, color: cs.primary),
                        label: Text('Dark', style: text.bodyLarge),
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
            color: cs.surface,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: text.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your account settings',
                    style: text.bodyLarge?.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      /* TODO: change password */
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cs.primary),
                      foregroundColor: cs.onSurface,
                    ),
                    child: Text('Change Password', style: text.bodyLarge),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notifications
          Card(
            color: cs.surface,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: text.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure your notification preferences.',
                    style: text.bodyLarge?.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Email Alerts',
                        style: text.bodyLarge?.copyWith(color: cs.onSurface),
                      ),
                      Switch(
                        value: true,
                        onChanged: (_) {},
                        activeColor: cs.primary,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SMS Alerts',
                        style: text.bodyLarge?.copyWith(color: cs.onSurface),
                      ),
                      Switch(
                        value: false,
                        onChanged: (_) {},
                        activeColor: cs.error,
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
            color: cs.surface,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: text.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Application Version: 1.0.0',
                    style: text.bodyLarge?.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      /* TODO: contact support */
                    },
                    style: TextButton.styleFrom(foregroundColor: cs.primary),
                    child: Text('Contact Support', style: text.bodyLarge),
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
