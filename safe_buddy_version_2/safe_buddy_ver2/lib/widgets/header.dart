import 'package:flutter/material.dart';

// Use this widget in your Scaffold's appBar property: appBar: HeaderAppBar(),
class HeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HeaderAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Image.asset('assets/logo.png', height: 40), // Add logo asset
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Safe Buddy', style: TextStyle(fontSize: 20)),
              Text('Your safety, our priority', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
      actions: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('Hi, User', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Hinted search text',
              contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        const SizedBox(width: 10),
        const CircleAvatar(backgroundImage: AssetImage('assets/profile.png')),
        const SizedBox(width: 10),
      ],
    );
  }
}