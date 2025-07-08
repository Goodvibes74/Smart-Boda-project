import 'package:flutter/material.dart';
import 'header.dart';
import 'sidebar.dart';
import 'dashboard.dart';
import 'device_management.dart';
import 'settings.dart';

class BaseLayout extends StatefulWidget {
  const BaseLayout({super.key}); // ✅ Removed `child`

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    DeviceManagerPage(),
    SettingsPage(),
  ];

  void _onSidebarItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
