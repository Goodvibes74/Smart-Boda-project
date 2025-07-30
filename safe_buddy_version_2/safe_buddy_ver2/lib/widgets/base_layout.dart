// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:safe_buddy_ver2/theme.dart'; // Import custom theme extensions.
import 'header.dart'; // Import the HeaderWidget for the top bar.
import 'sidebar.dart'; // Import the HoverSidebar for navigation.
import 'pages/dashboard.dart'; // Import the DashboardPage.
import 'pages/device_management.dart'; // Import the DeviceManagementPage.
import 'pages/settings.dart'; // Import the SettingsPage.

/// A StatefulWidget that provides the base layout for the application.
/// It includes a sidebar for navigation, a header, and a main content area
/// that switches between different pages based on sidebar selection.
class BaseLayout extends StatefulWidget {
  /// The child widget to be displayed within the base layout.
  /// This is typically the initial page or content.
  final Widget child;

  /// Constructor for BaseLayout.
  const BaseLayout({super.key, required this.child});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

/// The State class for [BaseLayout].
class _BaseLayoutState extends State<BaseLayout> {
  /// The currently selected index for the sidebar, determining which page is displayed.
  int _selectedIndex = 0;

  /// A list of pages that can be displayed in the main content area.
  final List<Widget> _pages = [
    const DashboardPage(),
    const DeviceManagementPage(),
    const SettingsPage(),
  ];

  /// Callback function for when a sidebar item is tapped.
  /// Updates the [_selectedIndex] and triggers a UI rebuild.
  ///
  /// [index]: The index of the tapped sidebar item.
  void _onSidebarItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Get the color scheme and custom theme extensions from the current theme.
    final cs = Theme.of(context).colorScheme;
    final custom = Theme.of(context).extension<CustomTheme>()!;

    return Scaffold(
      // Use the theme's scaffoldBackgroundColor
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          HoverSidebar(
            onItemSelected: _onSidebarItemTapped, // Pass the callback for item selection.
            selectedIndex: _selectedIndex, // Pass the currently selected index.
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The header widget displayed at the top of the main content area.
                const HeaderWidget(),
                Expanded(
                  // AnimatedSwitcher provides a smooth transition when switching between pages.
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    // Display the page corresponding to the currently selected index.
                    child: _pages[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
