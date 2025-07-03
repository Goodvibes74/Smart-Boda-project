import 'package:flutter/material.dart';
import 'package:safe_buddy_ver2/widgets/search_bar.dart' as custom; // Import your SearchBar widget

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.0, // Standard app bar height
      color: Theme.of(
        context,
      ).colorScheme.surface, // Dark background from theme
      child: Row(
        children: [
          // Greeting text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Hi, User',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.primary, // Blue color from theme
                fontSize: 18.0,
              ),
            ),
          ),
          const SizedBox(width: 20.0),
          Expanded(
            child: custom.SearchBar(), // Use the custom SearchBar widget
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
