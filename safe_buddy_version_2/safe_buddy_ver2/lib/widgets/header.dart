import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.0, // Standard app bar height
      color: Theme.of(context).colorScheme.background, // Dark background from theme
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Greeting text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Hi, User',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary, // Blue color from theme
                fontSize: 18.0,
              ),
            ),
          ),
          // Search bar
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Hinted search text',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[800], // Dark fill for search bar
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          // Notification icon
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          // User profile avatar
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.black),
          ),
          SizedBox(width: 16.0), // Right margin
        ],
      ),
    );
  }
}