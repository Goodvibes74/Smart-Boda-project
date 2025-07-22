// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart' hide SearchBar;
import 'package:safe_buddy_ver2/widgets/search_bar.dart';
import 'package:safe_buddy_ver2/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  /// A custom header widget that displays a greeting message, a search bar,
  /// and an avatar icon.
  /// It includes functionality for user profile access and logout.
  final ValueChanged<String>? onSearchChanged;
  /// Callback when the search input changes.
  /// This can be used to filter a list or perform a search.
  final ValueChanged<String>? onSearchSubmitted;
  /// Callback when the avatar icon is tapped.
  /// This can be used to navigate to the user's profile or settings.
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

    final docStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: docStream,
      builder: (context, snapshot) {
        // Loading or error fallback
        final data = snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.data() as Map<String, dynamic>)
            : <String, dynamic>{ 'username': 'User', 'photoURL': null };

        final username = data['username'] as String? ?? 'User';
        final photoUrl = data['photoURL'] as String?;
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
                    'Hi, $username',
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
                    icon: CircleAvatar(
                      radius: 20,
                      backgroundColor: cs.primaryContainer,
                      backgroundImage:
                          photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? Icon(Icons.person, color: cs.onPrimaryContainer)
                          : null,
                    ),
                    itemBuilder: (_) => [
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: cs.primaryContainer,
                              backgroundImage:
                                  photoUrl != null ? NetworkImage(photoUrl) : null,
                              child: photoUrl == null
                                  ? Icon(Icons.person, color: cs.onPrimaryContainer)
                                  : null,
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
      },
    );
  }
}