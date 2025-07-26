// lib/widgets/pages/device_management.dart
// Removed ignore_for_file: deprecated_member_use as modern widgets will be used

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For authentication
import 'package:intl/intl.dart'; // For date formatting
import '../device.dart'; // Import Device model and DeviceService
import '../alert_card.dart'; // Import AlertCard for messages
import '../device_registration_form.dart'; // For the registration form

// Removed global databaseRef and stream as we will use DeviceService (Firestore)

/// A page for managing registered devices.
/// Users can view, update, and delete their devices here.
class DeviceManagementPage extends StatefulWidget {
  const DeviceManagementPage({Key? key}) : super(key: key);

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  final DeviceService _deviceService = DeviceService(); // Instantiate DeviceService
  User? _currentUser;
  bool _showRegistrationForm = false; // State to toggle registration form visibility

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    // Listen for auth state changes to update _currentUser
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  /// Shows a confirmation dialog before deleting a device.
  Future<void> _confirmDeleteDevice(Device device) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${device.name}" (SIM: ${device.deviceId})? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true && _currentUser != null) {
      try {
        await _deviceService.deleteDevice(_currentUser!.uid, device.deviceId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Device "${device.name}" deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete device: $e')),
          );
        }
      }
    }
  }

  /// Shows a dialog to edit device details.
  void _editDevice(Device device) {
    final TextEditingController nameController = TextEditingController(text: device.name);
    final TextEditingController descriptionController = TextEditingController(text: device.description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final cs = Theme.of(context).colorScheme;
        final text = Theme.of(context).textTheme;
        return AlertDialog(
          backgroundColor: cs.surface, // Use theme surface color
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Edit Device: ${device.name}',
            style: text.titleMedium?.copyWith(color: cs.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Device Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_currentUser == null) return;
                final updatedDevice = Device(
                  deviceId: device.deviceId,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  ownerId: device.ownerId,
                  status: device.status, // Keep existing status
                  lastKnownLatitude: device.lastKnownLatitude,
                  lastKnownLongitude: device.lastKnownLongitude,
                  registrationDate: device.registrationDate,
                  lastActive: device.lastActive,
                );
                try {
                  await _deviceService.updateDevice(_currentUser!.uid, updatedDevice);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Device "${updatedDevice.name}" updated successfully!')),
                    );
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update device: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (_currentUser == null) {
      return const Center(
        child: AlertCard(
          title: 'Authentication Required',
          message: 'Please log in to manage your devices.',
          type: AlertType.info,
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Manager',
              style: text.titleLarge?.copyWith(
                color: cs.onSurface,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 24),
            // StreamBuilder now listens to Firestore via DeviceService
            StreamBuilder<List<Device>>(
              stream: _deviceService.getDevicesStream(_currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading devices: ${snapshot.error}'));
                }
                final devices = snapshot.data ?? []; // Get list of Device objects
                final activeDevices = devices.where((d) => d.status == 'active').length;
                final offlineDevices = devices.where((d) => d.status != 'active').length; // Assuming 'active' is the only online status

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _CounterCard(
                          label: 'Active Devices',
                          value: activeDevices,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 16),
                        _CounterCard(
                          label: 'Offline Devices',
                          value: offlineDevices,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your Registered Devices',
                      style: text.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        final crossAxisCount = constraints.maxWidth ~/ 220;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: devices.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount > 1 ? crossAxisCount : 1,
                            childAspectRatio: 1.8,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (_, i) {
                            final device = devices[i]; // Now a Device object
                            return _DeviceCard(
                              device: device, // Pass the full Device object
                              onEdit: () => _editDevice(device),
                              onDelete: () => _confirmDeleteDevice(device),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon( // Changed to ElevatedButton.icon for better UX
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: cs.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          'Register New Device',
                          style: text.titleMedium,
                        ),
                        content: const DeviceRegistrationForm(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add), // Add icon
                  label: const Text('Register New Device'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cs.onSurface.withOpacity(0.3)),
                  ),
                  onPressed: () {
                    // Implement turn off all logic if needed
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Turn Off All not implemented yet.')),
                    );
                  },
                  child: const Text('Turn Off All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A card widget to display individual device details.
class _DeviceCard extends StatelessWidget {
  final Device device; // Now takes a Device object
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DeviceCard({
    required this.device,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Determine status color
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.device_unknown;
    if (device.status == 'active') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (device.status == 'offline') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else {
      statusColor = Colors.orange; // For other statuses like 'inactive'
      statusIcon = Icons.warning;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
      ),
      color: cs.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    device.name, // Display device name
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: cs.secondary),
                      onPressed: onEdit,
                      tooltip: 'Edit Device',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: cs.error),
                      onPressed: onDelete,
                      tooltip: 'Delete Device',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'SIM Number: ${device.deviceId}', // Display SIM Number
              style: text.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.7)),
            ),
            if (device.description.isNotEmpty)
              Text(
                'Description: ${device.description}',
                style: text.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.6)),
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Status: ${device.status.toUpperCase()}',
                  style: text.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (device.lastActive != null)
              Text(
                'Last Active: ${DateFormat.yMMMd().add_jm().format(device.lastActive!)}',
                style: text.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.6)),
              ),
            if (device.lastKnownLatitude != null && device.lastKnownLongitude != null)
              Text(
                'Last Location: ${device.lastKnownLatitude!.toStringAsFixed(4)}, ${device.lastKnownLongitude!.toStringAsFixed(4)}',
                style: text.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.6)),
              ),
          ],
        ),
      ),
    );
  }
}


class _CounterCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _CounterCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Expanded( // Use Expanded to make cards take equal width
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: text.headlineMedium?.copyWith( // Adjusted font size
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: text.bodyMedium?.copyWith(color: color), // Adjusted font size
              ),
            ],
          ),
        ),
      ),
    );
  }
}
