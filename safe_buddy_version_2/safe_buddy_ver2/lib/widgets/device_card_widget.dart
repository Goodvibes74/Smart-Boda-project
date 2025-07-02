import 'package:flutter/material.dart';

class DeviceCardWidget extends StatelessWidget {
  final String name;
  const DeviceCardWidget({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        trailing: Icon(Icons.arrow_forward),
      ),
    );
  }
}