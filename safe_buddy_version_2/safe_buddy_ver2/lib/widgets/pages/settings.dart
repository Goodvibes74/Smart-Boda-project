import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_buddy_ver2/widgets/avatar_uploader.dart';
import '../../providers/theme_provider.dart';
import '../change_password_form.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _buildThemeCard(
    ColorScheme cs,
    TextTheme text,
    double width,
    BuildContext context,
  ) {
    return SizedBox(
      width: width,
      child: Card(
        color: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
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
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context
                          .read<ThemeProvider>()
                          .setThemeMode(ThemeMode.light),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cs.primary),
                        foregroundColor: cs.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(Icons.light_mode, color: cs.primary),
                      label: Text('Light', style: text.bodyLarge),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context
                          .read<ThemeProvider>()
                          .setThemeMode(ThemeMode.dark),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cs.primary),
                        foregroundColor: cs.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(Icons.dark_mode, color: cs.primary),
                      label: Text('Dark', style: text.bodyLarge),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(
    ColorScheme cs,
    TextTheme text,
    double width,
    BuildContext context,
  ) {
    return SizedBox(
      width: width,
      child: Card(
        color: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
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
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => Center(
                      child: SizedBox(width: 400, child: ChangePasswordForm()),
                    ),
                  );
                },
                icon: Icon(Icons.edit, color: cs.primary),
                label: Text(
                  'Change Password & Username',
                  style: text.bodyLarge,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/auth');
                },
                icon: Icon(Icons.logout, color: cs.error),
                label: Text(
                  'Log Out',
                  style: text.bodyLarge?.copyWith(color: cs.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureCard(
    ColorScheme cs,
    TextTheme text,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Card(
        color: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Profile Picture',
                style: text.titleMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: AvatarUploader(
                  radius: 60,
                  allowUpload: true, // Explicitly set to true for clarity
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard(ColorScheme cs, TextTheme text, double width) {
    return SizedBox(
      width: width,
      child: Card(
        color: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
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
                'Version 1.0.0',
                style: text.bodyLarge?.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Developed by Group 7 @ MAKCOCIS',
                style: text.bodyLarge?.copyWith(color: cs.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        final cardWidth = isWide
            ? constraints.maxWidth * 0.45
            : constraints.maxWidth * 0.9;

        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: ListView(
            children: [
              Text(
                'Settings',
                style: text.titleLarge?.copyWith(
                  color: cs.onSurface,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildThemeCard(cs, text, cardWidth, context),
                              const SizedBox(height: 16),
                              _buildAccountCard(cs, text, cardWidth, context),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              _buildProfilePictureCard(cs, text, cardWidth),
                              const SizedBox(height: 16),
                              _buildAboutCard(cs, text, cardWidth),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildThemeCard(cs, text, cardWidth, context),
                        const SizedBox(height: 16),
                        _buildAccountCard(cs, text, cardWidth, context),
                        const SizedBox(height: 16),
                        _buildProfilePictureCard(cs, text, cardWidth),
                        const SizedBox(height: 16),
                        _buildAboutCard(cs, text, cardWidth),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }
}
