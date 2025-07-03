import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Check if user is authenticated
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          setState(() {
            _errorMessage = 'Please log in to register a device';
            _isLoading = false;
          });
          return;
        }

        // Register device in Firestore
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

        // Navigate back or to success screen
        if (mounted) {
          Navigator.pop(context);
        }
      } on FirebaseException catch (e) {
        setState(() {
          _errorMessage = _getErrorMessage(e.code);
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to register devices.';
      case 'unavailable':
        return 'Firestore is currently unavailable. Please try again later.';
      default:
        return 'Device registration failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _deviceIdController,
            decoration: const InputDecoration(
              labelText: 'Device ID',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a device ID';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              if (value.length < 3) {
                return 'Username must be at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _deviceTypeController,
            decoration: const InputDecoration(
              labelText: 'Device Type',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a device type';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ipAddressController,
            decoration: const InputDecoration(
              labelText: 'IP Address',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an IP address';
              }
              if (!RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$').hasMatch(value)) {
                return 'Please enter a valid IP address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a location';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
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
                    : const Text('Activate device registration'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}