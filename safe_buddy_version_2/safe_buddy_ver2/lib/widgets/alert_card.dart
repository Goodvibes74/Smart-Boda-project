import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text('Severity: High', style: TextStyle(color: Colors.white)),
              ],
            ),
            Text('Device No: 000920', style: TextStyle(color: Colors.white70)),
            Text('2024-09-11 14:00', style: TextStyle(color: Colors.white70)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Locate'),
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                ),
                SizedBox(width: 8),
                TextButton(
                  onPressed: () {},
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}