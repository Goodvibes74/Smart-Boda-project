// Import Flutter material design package for UI components.
import 'package:flutter/material.dart';

// Import Firebase Authentication for getting the current user ID.
import 'package:firebase_auth/firebase_auth.dart';
// Import the Device model and DeviceService for device management.
import 'device.dart';

/// A StatefulWidget for registering new devices.
/// It provides a form for users to input device details like SIM number, name, and description.
class DeviceRegistrationForm extends StatefulWidget {
  /// Constructor for DeviceRegistrationForm.
  const DeviceRegistrationForm({Key? key}) : super(key: key);

  @override
  State<DeviceRegistrationForm> createState() => _DeviceRegistrationFormState();
}

/// The State class for [DeviceRegistrationForm].
class _DeviceRegistrationFormState extends State<DeviceRegistrationForm> {
  /// A GlobalKey to uniquely identify the Form widget and enable validation.
  final _formKey = GlobalKey<FormState>();

  /// A boolean flag to indicate if a registration process is currently in progress.
  bool _loading = false;

  /// Text editing controllers for the form fields.
  final TextEditingController _simNumberCtrl = TextEditingController();
  final TextEditingController _deviceNameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  final DeviceService _deviceService = DeviceService(); // Instantiate DeviceService

  @override
  void dispose() {
    _simNumberCtrl.dispose();
    _deviceNameCtrl.dispose(); // Dispose new controllers
    _descriptionCtrl.dispose();
    super.dispose();
  }

  /// Handles the form submission logic.
  /// Validates the form, retrieves user and device data, and registers the device.
  Future<void> _submit() async {
    // Validate all form fields. If validation fails, stop the submission.
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save(); // Save form fields (if any `onSaved` callbacks were used)
    setState(() => _loading = true);

    // Get the currently logged-in Firebase user.
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

    // Extract data from text controllers.
    final String userId = user.uid;
    final String simNumber = _simNumberCtrl.text.trim();
    final String deviceName = _deviceNameCtrl.text.trim();
    final String description = _descriptionCtrl.text.trim();

    try {
      // Check if a device with the entered SIM Number (which serves as deviceId)
      // already exists for the current user to prevent duplicates.
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

      // Create a new Device object with the collected data.
      final newDevice = Device(
        deviceId: simNumber, // SIM Number is the device ID
        name: deviceName,
        description: description,
        ownerId: userId,
        registrationDate: DateTime.now(),
        status: 'active', // Default status for a new device
      );

      // Register the device in Firestore using the DeviceService.
      await _deviceService.registerDevice(userId, newDevice);

      if (!mounted) return;

      // Show a success message and clear the form.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device registered successfully!')),
      );
      _simNumberCtrl.clear();
      _deviceNameCtrl.clear();
      _descriptionCtrl.clear();
      // If this form is part of a dialog, you might want to close it here.
      // Optionally pop the form if it's in a dialog
      // Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      print('Error during device registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register device: ${e.toString()}')),
      );
    } finally {
      // Ensure loading state is reset regardless of success or failure.
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// Helper function to create consistent InputDecoration for text form fields.
  /// Takes a hint text and an optional icon.
  InputDecoration _decorate(String hint, {IconData? icon}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Adjust padding
        prefixIcon: icon != null ? Icon(icon) : null, // Add icon support
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        // Constrain the width of the form for better readability on larger screens.
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              // Text field for SIM Card Number (Device ID).
              TextFormField(
                controller: _simNumberCtrl,
                decoration: _decorate('SIM Card Number (Device ID)', icon: Icons.sim_card),
                keyboardType: TextInputType.phone, // Suggest phone number keyboard for input.
                validator: (v) {
                  if (v == null || v.isEmpty) return 'SIM Card Number is required';
                  // Basic validation for numbers (10-15 digits, optional leading +).
                  if (!RegExp(r'^\+?\d{10,15}$').hasMatch(v)) {
                    return 'Enter a valid SIM number (e.g., +2567xxxxxxxx)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Text field for Device Name.
              TextFormField(
                controller: _deviceNameCtrl,
                decoration: _decorate('Device Name', icon: Icons.motorcycle),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Device Name is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Text field for Description (optional).
              TextFormField(
                controller: _descriptionCtrl,
                decoration: _decorate('Description (Optional)', icon: Icons.description),
                maxLines: 3, // Allow multiple lines for description
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button.
                  TextButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  // Register button.
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            // Show a loading spinner when _loading is true.
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
