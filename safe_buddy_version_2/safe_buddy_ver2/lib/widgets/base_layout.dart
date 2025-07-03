import 'package:flutter/material.dart';
import 'header.dart'; // Import the HeaderWidget
import 'sidebar.dart'; // Import the HoverSidebar

class BaseLayout extends StatelessWidget {
  final Widget child;

  const BaseLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          HoverSidebar(), // The hover-expandable sidebar
          Column(
            children: [
              HeaderWidget(), // The header widget
              Expanded(
                child:
                    child, // The main content area, now correctly placed below the header
              ),
            ],
          ),
        ],
      ),
    );
  }
}