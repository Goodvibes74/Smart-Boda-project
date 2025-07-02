import 'package:flutter/material.dart';
import 'package:safe_buddy_ver2/widgets/sidebar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Dashboard(),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HoverSidebar(),
        Expanded(
          child: Center(
            child: Text(
              'Dashboard Content Here',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}