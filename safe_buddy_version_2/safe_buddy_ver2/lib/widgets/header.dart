// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart' hide SearchBar;
import 'package:safe_buddy_ver2/widgets/search_bar.dart';
import 'package:safe_buddy_ver2/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  /// Called when the search text changes
  final ValueChanged<String>? onSearchChanged;

  /// Called when search is submitted
  final ValueChanged<String>? onSearchSubmitted;

  /// Called when the avatar is tapped
  final VoidCallback? onAvatarTap;

  const HeaderWidget({
    Key? key,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onAvatarTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  // Fetch username from Firestore
  Future<String> _getUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'User'; // Fallback if no user is logged in
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.exists ? (doc.data()?['username'] ?? 'User') : 'User';
    } catch (e) {
      print('Error fetching username: $e'); // Log error for debugging
      return 'User'; // Fallback on error
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final user = FirebaseAuth.instance.currentUser;

    return Material(
      color: cs.background,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: preferredSize.height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Greeting with dynamic username
              FutureBuilder<String>(
                future: _getUsername(),
                builder: (context, snapshot) {
                  final username = snapshot.connectionState == ConnectionState.waiting
                      ? 'Loading...'
                      : (snapshot.data ?? 'User');
                  return Text(
                    'Hi, $username',
                    style: textTheme.titleMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),

              const SizedBox(width: 20),

              // Search
              Expanded(
                child: SearchBar(
                  onChanged: onSearchChanged,
                  onSubmitted: onSearchSubmitted,
                  hintText: 'Search…',
                ),
              ),

              const SizedBox(width: 16),

              // Avatar with Popup Menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/initial');
                  } else if (value == 'profile') {
                    // Optionally handle profile navigation
                    if (onAvatarTap != null) onAvatarTap!();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          backgroundColor: cs.primaryContainer,
                          child: user?.photoURL == null
                              ? Icon(Icons.person, color: cs.onPrimaryContainer)
                              : null,
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        Text('Profile', style: textTheme.bodyMedium),
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
                        Text('Logout', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
                icon: CircleAvatar(
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  backgroundColor: cs.primaryContainer,
                  child: user?.photoURL == null
                      ? Icon(Icons.person, color: cs.onPrimaryContainer)
                      : null,
                  radius: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}