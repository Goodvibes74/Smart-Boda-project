// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:safe_buddy_ver2/theme.dart';
import 'header.dart';
import 'sidebar.dart';
import 'pages/dashboard.dart';
import 'pages/device_management.dart';
import 'pages/settings.dart';

class BaseLayout extends StatefulWidget {
  final Widget child;
  const BaseLayout({super.key, required this.child});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const DeviceManagerPage(),
    const SettingsPage(),
  ];

  void _onSidebarItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final custom = Theme.of(context).extension<CustomTheme>()!;

    return Scaffold(
      // Use the theme's scaffoldBackgroundColor
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          HoverSidebar(
            onItemSelected: _onSidebarItemTapped,
            selectedIndex: _selectedIndex,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HeaderWidget(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
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
