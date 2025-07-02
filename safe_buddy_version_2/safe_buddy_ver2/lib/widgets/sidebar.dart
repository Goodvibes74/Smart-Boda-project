import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[900],
      child: Column(
        children: [
          SizedBox(height: 20),
          Image.asset('assets/safe_buddy_logo.png', height: 50), // Replace with your logo asset
          Text('Safe Buddy', style: TextStyle(color: Colors.white, fontSize: 20)),
          Text('Your safety is our priority', style: TextStyle(color: Colors.white70)),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.home, color: Colors.white),
            title: Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.devices, color: Colors.white),
            title: Text('Devices', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.white),
            title: Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          Spacer(),
          CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person)),
        ],
      ),
    );
  }
}