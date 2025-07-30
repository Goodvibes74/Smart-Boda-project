// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:safe_buddy_ver2/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_image_provider.dart';
import 'avatar_uploader.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  // Callbacks for search functionality
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  // Callback for avatar tap
  final VoidCallback? onAvatarTap;

  // Constructor for HeaderWidget
  const HeaderWidget({
    Key? key,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onAvatarTap,
  }) : super(key: key);

  @override
  // Defines the preferred height of the header
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    // Get the current authenticated user
    final user = FirebaseAuth.instance.currentUser;
    // If no user is logged in, return an empty widget
    if (user == null) return const SizedBox.shrink();

    // Watch for changes in the user's profile image URL
    final photoUrl = context.watch<ProfileImageProvider>().imageUrl;
    // Get the current color scheme and text theme from the ThemeData
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: cs.background,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: preferredSize.height,
          child: Row(
            children: [
              // Display a greeting with the user's display name
              Text(
                'Hi, ${user.displayName ?? 'User'}',
                style: text.titleMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Spacer to push the avatar to the right
              const Spacer(),
              // Popup menu for user actions (profile, logout)
              PopupMenuButton<String>(
                onSelected: (value) {
                  // Handle logout action
                  if (value == 'logout') {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/initial');
                    // Handle profile action
                  } else if (value == 'profile') {
                    if (onAvatarTap != null) onAvatarTap!();
                  }
                },
                icon: AvatarUploader(
                  radius: 20,
                  allowUpload: false,
                  onTap: onAvatarTap,
                ),
                itemBuilder: (_) => [
                  // Profile menu item
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        AvatarUploader(
                          radius: 20,
                          allowUpload: false,
                          onTap: () {},
                        ),
                        const SizedBox(width: 10),
                        Text('Profile', style: text.bodyMedium),
                      ],
                    ),
                  ),
                  // Divider between menu items
                  const PopupMenuDivider(),
                  // Logout menu item
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: cs.error),
                        const SizedBox(width: 10),
                        Text('Logout', style: text.bodyMedium),
                      ],
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
}