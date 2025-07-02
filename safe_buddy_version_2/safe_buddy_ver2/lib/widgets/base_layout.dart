import 'package:flutter/material.dart';
import 'header.dart'; // Import the HeaderWidget
import 'sidebar.dart'; // Import the HoverSidebar

class BaseLayout extends StatelessWidget {
  final Widget child;

  const BaseLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.0),
        child: HeaderWidget(),
      ),
      body: Row(
        children: [
          HoverSidebar(), // The hover-expandable sidebar
          Expanded(child: child), // The main content area
        ],
      ),
    );
  }
}