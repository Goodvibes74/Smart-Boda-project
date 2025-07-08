// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_buddy_ver2/theme.dart';

class DeviceRegistrationForm extends StatefulWidget {
  const DeviceRegistrationForm({super.key});

  @override
  DeviceRegistrationFormState createState() => DeviceRegistrationFormState();
}

class DeviceRegistrationFormState extends State<DeviceRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdController = TextEditingController();
  final _usernameController = TextEditingController();
  final _deviceTypeController = TextEditingController();
  final _ipAddressController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _deviceIdController.dispose();
    _usernameController.dispose();
    _deviceTypeController.dispose();
    _ipAddressController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _registerDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseException(
          plugin: 'auth',
          code: 'not-authenticated',
        );
      }

      await FirebaseFirestore.instance.collection('devices').add({
        'deviceId': _deviceIdController.text.trim(),
        'username': _usernameController.text.trim(),
        'deviceType': _deviceTypeController.text.trim(),
        'ipAddress': _ipAddressController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'userId': user.uid,
        'createdAt': Timestamp.now(),
      });

      if (mounted) Navigator.pop(context);
    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to register devices.';
      case 'unavailable':
        return 'Firestore is currently unavailable. Please try again later.';
      case 'not-authenticated':
        return 'Please log in to register a device.';
      default:
        return 'Device registration failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    InputDecoration _inputDecoration(String label) => InputDecoration(
      labelText: label,
      labelStyle: text.bodyLarge?.copyWith(color: cs.onSurface),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: cs.primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: cs.primary.withOpacity(0.5)),
      ),
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _deviceIdController,
            decoration: _inputDecoration('Device ID'),
            validator: (v) => (v?.isEmpty ?? true) ? 'Please enter a device ID' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _usernameController,
            decoration: _inputDecoration('Username'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter a username';
              if (v.length < 3) return 'Username must be at least 3 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _deviceTypeController,
            decoration: _inputDecoration('Device Type'),
            validator: (v) => (v?.isEmpty ?? true) ? 'Please enter a device type' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ipAddressController,
            decoration: _inputDecoration('IP Address'),
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter an IP address';
              final regex = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
              return regex.hasMatch(v) ? null : 'Please enter a valid IP address';
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: _inputDecoration('Location'),
            validator: (v) => (v?.isEmpty ?? true) ? 'Please enter a location' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: _inputDecoration('Description'),
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _errorMessage!,
                style: text.bodyLarge?.copyWith(color: cs.error),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _registerDevice,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Activate device registration', style: text.bodyLarge),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: Text('Cancel', style: text.bodyLarge?.copyWith(color: cs.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
