import 'package:flutter/material.dart';
import 'header.dart';
import 'sidebar.dart';

class BaseLayout extends StatefulWidget {
  final Widget child;
  const BaseLayout({super.key, required this.child});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(
      child: Text('Home Page', style: TextStyle(color: Colors.white)),
    ),
    const Center(
      child: Text('Devices Page', style: TextStyle(color: Colors.white)),
    ),
    const Center(
      child: Text('Settings Page', style: TextStyle(color: Colors.white)),
    ),
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
