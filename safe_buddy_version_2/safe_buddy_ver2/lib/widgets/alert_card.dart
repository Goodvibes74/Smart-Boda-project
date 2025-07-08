// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // if narrow, use Wrap for buttons; else Row
            final isNarrow = constraints.maxWidth < 300;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: cs.error),
                    const SizedBox(width: 8),
                    Text(
                      'Severity: High',
                      style: TextStyle(color: cs.error),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Device No: 000920',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 4),
                Text(
                  '2024-09-11 14:00',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 16),
                isNarrow
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: _buildButtons(cs),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: _buildButtons(cs),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildButtons(ColorScheme cs) => [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
          ),
          child: const Text('Locate'),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'Cancel',
            style: TextStyle(color: cs.onSurface),
          ),
        ),
      ];
}
