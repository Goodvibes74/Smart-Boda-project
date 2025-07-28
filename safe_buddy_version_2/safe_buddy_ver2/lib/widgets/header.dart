// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:safe_buddy_ver2/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_image_provider.dart';
import 'avatar_uploader.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onAvatarTap;

  const HeaderWidget({
    Key? key,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onAvatarTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final photoUrl = context.watch<ProfileImageProvider>().imageUrl;
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
              Text(
                'Hi, ${user.displayName ?? 'User'}',
                style: text.titleMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/initial');
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
                  const PopupMenuDivider(),
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