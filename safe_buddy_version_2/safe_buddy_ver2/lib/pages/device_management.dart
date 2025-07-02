import 'package:flutter/material.dart';
import '../widgets/device_list_widget.dart';

class DeviceManagerPage extends StatelessWidget {
  const DeviceManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Device Manager')),
      body: DeviceListWidget(),
    );
  }
}