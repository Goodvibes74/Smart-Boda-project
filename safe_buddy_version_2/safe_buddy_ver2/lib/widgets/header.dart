// ignore_for_file: unused_import

import 'package:flutter/material.dart' hide SearchBar;
import 'package:safe_buddy_ver2/widgets/search_bar.dart';
import 'package:safe_buddy_ver2/theme.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  /// Displayed greeting name
  final String userName;

  /// Called when the search text changes
  final ValueChanged<String>? onSearchChanged;

  /// Called when search is submitted
  final ValueChanged<String>? onSearchSubmitted;

  /// Called when the notification icon is tapped
  final VoidCallback? onNotificationTap;

  /// Badge count for notifications
  final int notificationCount;

  /// Called when the avatar is tapped
  final VoidCallback? onAvatarTap;

  const HeaderWidget({
    Key? key,
    this.userName = 'User',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.onAvatarTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final cs         = theme.colorScheme;
    final textTheme  = theme.textTheme;

    return Material(
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
                style: textTheme.titleMedium
                    ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
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

              // Notifications with badge
              Tooltip(
                message: 'Notifications',
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications, color: cs.onSurface),
                      onPressed: onNotificationTap,
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: cs.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Center(
                            child: Text(
                              notificationCount > 99 ? '99+' : '$notificationCount',
                              style: textTheme.labelSmall?.copyWith(
                                color: cs.onError,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Avatar
              GestureDetector(
                onTap: onAvatarTap,
                child: Semantics(
                  label: 'User profile',
                  button: true,
                  child: CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Icon(Icons.person, color: cs.onPrimaryContainer),
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
