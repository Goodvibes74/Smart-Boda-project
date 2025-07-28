import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart'; // For getting current user ID
import 'device.dart'; // Import the Device model and DeviceService

class DeviceRegistrationForm extends StatefulWidget {
  const DeviceRegistrationForm({Key? key}) : super(key: key);

  @override
  State<DeviceRegistrationForm> createState() => _DeviceRegistrationFormState();
}

class _DeviceRegistrationFormState extends State<DeviceRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  // Removed _simNumber as it will be directly from controller
  bool _loading = false;

  final TextEditingController _simNumberCtrl = TextEditingController();
  final TextEditingController _deviceNameCtrl = TextEditingController(); // New: Device Name
  final TextEditingController _descriptionCtrl = TextEditingController(); // New: Description

  final DeviceService _deviceService = DeviceService(); // Instantiate DeviceService

  @override
  void dispose() {
    _simNumberCtrl.dispose();
    _deviceNameCtrl.dispose(); // Dispose new controllers
    _descriptionCtrl.dispose(); // Dispose new controllers
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save(); // Save form fields if any onSaved callback is used
    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to register a device.')),
        );
      }
      setState(() => _loading = false);
      return;
    }

    final String userId = user.uid;
    final String simNumber = _simNumberCtrl.text.trim();
    final String deviceName = _deviceNameCtrl.text.trim();
    final String description = _descriptionCtrl.text.trim();

    try {
      // Check if a device with this SIM Number (ID) already exists for the current user
      final existingDevice = await _deviceService.getDevice(userId, simNumber);
      if (existingDevice != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A device with this SIM Number (ID) already exists.')),
          );
        }
        setState(() => _loading = false);
        return;
      }

      // Create a new Device object using the Device model
      final newDevice = Device(
        deviceId: simNumber, // SIM Number is the device ID
        name: deviceName,
        description: description,
        ownerId: userId,
        registrationDate: DateTime.now(),
        status: 'active', // Default status for a new device
      );

      // Register the device using DeviceService (Firestore)
      await _deviceService.registerDevice(userId, newDevice);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device registered successfully!')),
      );
      // Clear form fields after successful registration
      _simNumberCtrl.clear();
      _deviceNameCtrl.clear();
      _descriptionCtrl.clear();
      // Optionally pop the form if it's in a dialog
      // Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      print('Error during device registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register device: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  InputDecoration _decorate(String hint, {IconData? icon}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        prefixIcon: icon != null ? Icon(icon) : null, // Add icon support
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _simNumberCtrl,
                decoration: _decorate('SIM Card Number (Device ID)', icon: Icons.sim_card),
                keyboardType: TextInputType.phone, // Suggest phone number keyboard
                validator: (v) {
                  if (v == null || v.isEmpty) return 'SIM Card Number is required';
                  // Basic validation for numbers, adjust regex if international prefixes are needed
                  if (!RegExp(r'^\+?\d{10,15}$').hasMatch(v)) {
                    return 'Enter a valid SIM number (e.g., +2567xxxxxxxx)';
                  }
                  return null;
                },
                // onSaved: (v) => _simNumber = v, // No longer needed as we use controller.text
              ),
              const SizedBox(height: 16), // Spacing between fields
              TextFormField(
                controller: _deviceNameCtrl,
                decoration: _decorate('Device Name', icon: Icons.motorcycle),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Device Name is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: _decorate('Description (Optional)', icon: Icons.description),
                maxLines: 3, // Allow multiple lines for description
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white), // White spinner
                          )
                        : const Text('Register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary, // Use primary color
                      foregroundColor: Theme.of(context).colorScheme.onPrimary, // Text color on primary
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
