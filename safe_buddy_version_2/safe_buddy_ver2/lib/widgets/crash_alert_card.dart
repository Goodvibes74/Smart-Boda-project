import 'package:flutter/material.dart';

class CrashAlertCard extends StatelessWidget {
  const CrashAlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
  color: Colors.grey[900],
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 5),
            Text('Severity: High', style: TextStyle(color: Colors.white)),
          ],
        ),
        Text('Device No: 1203 299292', style: TextStyle(color: Colors.white)),
        Text('2024-01-15 14:30', style: TextStyle(color: Colors.white)),
        Text('123 Main Street, Nairobi', style: TextStyle(color: Colors.white)),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {},
              child: Text('Locate'),
            ),
            SizedBox(width: 10),
            ElevatedButton(onPressed: () {}, child: Text('Cancel')),
          ],
        ),
      ],
    ),
  ),
)
    ;
  }
}