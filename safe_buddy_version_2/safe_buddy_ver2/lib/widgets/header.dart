// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart' hide SearchBar;
import 'package:safe_buddy_ver2/widgets/search_bar.dart';
import 'package:safe_buddy_ver2/theme.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  /// Displayed greeting name
  final String userName;

  /// URL of the user's profile picture
  final String? profilePictureUrl;

  /// Called when the search text changes
  final ValueChanged<String>? onSearchChanged;

  /// Called when search is submitted
  final ValueChanged<String>? onSearchSubmitted;

  const HeaderWidget({
    Key? key,
    this.userName = 'User',
    this.profilePictureUrl,
    this.onSearchChanged,
    this.onSearchSubmitted,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

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
              // Greeting
              Text(
                'Hi, $userName',
                style: textTheme.titleMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
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

              // Avatar with PopupMenuButton
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    Navigator.pushReplacementNamed(context, '/initial');
                  }
                  //  TODO: Handle 'profile' selection if needed
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: profilePictureUrl != null
                              ? NetworkImage(profilePictureUrl!)
                              : null,
                          radius: 20,
                          child: profilePictureUrl == null
                              ? Icon(Icons.person, color: cs.onPrimaryContainer)
                              : null,
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
                child: Semantics(
                  label: 'User profile',
                  button: true,
                  child: CircleAvatar(
                    backgroundImage: profilePictureUrl != null
                        ? NetworkImage(profilePictureUrl!)
                        : null,
                    radius: 20,
                    child: profilePictureUrl == null
                        ? Icon(Icons.person, color: cs.onPrimaryContainer)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}