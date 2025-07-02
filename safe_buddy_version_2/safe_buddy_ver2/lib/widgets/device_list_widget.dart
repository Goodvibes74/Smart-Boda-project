import 'package:flutter/material.dart';
import 'device_card_widget.dart';

class DeviceListWidget extends StatelessWidget {
  const DeviceListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with your device data
    final devices = ['Device 1', 'Device 2'];

    return ListView(
      children: devices.map((name) => DeviceCardWidget(name: name)).toList(),
    );
  }
}