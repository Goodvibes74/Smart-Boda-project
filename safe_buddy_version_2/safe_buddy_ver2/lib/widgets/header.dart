// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart' hide SearchBar;
import 'package:safe_buddy_ver2/widgets/search_bar.dart';
import 'package:safe_buddy_ver2/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  Future<String> _getUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'User';
      
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
          
      return doc.exists ? (doc.data()?['username'] ?? 'User') : 'User';
    } catch (e) {
      debugPrint('Error fetching username: $e');
      return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: cs.background,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: preferredSize.height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Username with loading state
              FutureBuilder<String>(
                future: _getUsername(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        color: cs.primary,
                        minHeight: 2,
                        backgroundColor: cs.primaryContainer,
                      ),
                    );
                  }
                  
                  final error = snapshot.error;
                  if (error != null) {
                    debugPrint('Username error: $error');
                  }
                  
                  final username = error != null ? 'User' : (snapshot.data ?? 'User');
                  
                  return Tooltip(
                    message: error != null ? 'Error loading name' : 'Hello $username',
                    child: Text(
                      'Hi, $username',
                      style: textTheme.titleMedium?.copyWith(
                        color: error != null ? cs.error : cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),

              const SizedBox(width: 20),

              // Search bar
              Expanded(
                child: SearchBar(
                  onChanged: onSearchChanged,
                  onSubmitted: onSearchSubmitted,
                  hintText: 'Search…',
                ),
              ),

              const SizedBox(width: 16),

              // Profile avatar with auth state listener
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  final error = snapshot.error;
                  
                  if (error != null) {
                    debugPrint('Auth state error: $error');
                  }

                  return PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'logout') {
                        try {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/initial');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logout failed: ${e.toString()}'),
                                backgroundColor: cs.error,
                              ),
                            );
                          }
                        }
                      } else if (value == 'profile') {
                        onAvatarTap?.call();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Row(
                          children: [
                            _buildProfileAvatar(user, cs, 20, error != null),
                            const SizedBox(width: 10),
                            Text(
                              'Profile',
                              style: textTheme.bodyMedium?.copyWith(
                                color: error != null ? cs.error : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 10),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                    icon: _buildProfileAvatar(user, cs, 20, error != null),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(User? user, ColorScheme cs, double radius, bool hasError) {
    if (hasError) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: cs.errorContainer,
        child: Icon(
          Icons.error_outline,
          color: cs.onErrorContainer,
          size: radius,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: user?.photoURL ?? '',
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: cs.primaryContainer,
        child: SizedBox(
          width: radius,
          height: radius,
          child: CircularProgressIndicator(
            color: cs.onPrimaryContainer,
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: cs.primaryContainer,
        child: Icon(
          Icons.person,
          color: cs.onPrimaryContainer,
          size: radius,
        ),
      ),
    );
  }
}