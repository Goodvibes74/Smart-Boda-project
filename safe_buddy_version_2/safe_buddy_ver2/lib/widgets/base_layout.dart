import 'package:flutter/material.dart';
import 'header.dart';
import 'sidebar.dart';
import 'dashboard.dart'; // Import your actual page
import 'device_management.dart'; // Import your actual page
import 'settings.dart'; // Import your actual page

class BaseLayout extends StatefulWidget {
  final Widget child;
  const BaseLayout({super.key, required this.child});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(), // Updated to use the actual dashboard page
    DeviceManagerPage(), // Updated to use the actual device manager page
    SettingsPage(), // Updated to use the actual settings page
  ];

  void _onSidebarItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme; // Use theme color scheme

    return Scaffold(
      backgroundColor: colorScheme.surface, // Use themed background
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
                const Divider(height: 0),
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
