import 'package:flutter/material.dart';
import '../services/firestore_service.dart'; // your path

class DeviceMapLive extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  DeviceMapLive({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DeviceData>>(
      stream: _firestoreService.getDeviceDataStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final devices = snapshot.data!;
        return Stack(
          children: [
            // Your GoogleMap widget (e.g., using google_maps_flutter for desktop)
            // or HtmlElementView if on web, with markers generated dynamically:
            // For example, on web, you'd call JS using `js.context.callMethod('updateMarkers', [...])`
            Text('Total devices: ${devices.length}'), // placeholder
          ],
        );
      },
    );
  }
}
