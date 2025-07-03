import 'package:flutter/material.dart';

class DeviceRegistrationForm extends StatefulWidget {
  @override
  _DeviceRegistrationFormState createState() => _DeviceRegistrationFormState();
}

class _DeviceRegistrationFormState extends State<DeviceRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  String _deviceId = '';
  String _username = '';
  String _deviceType = '';
  String _ipAddress = '';
  String _location = '';
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Device ID',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a device ID';
              }
              return null;
            },
            onSaved: (value) {
              _deviceId = value!;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              return null;
            },
            onSaved: (value) {
              _username = value!;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Device Type',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a device type';
              }
              return null;
            },
            onSaved: (value) {
              _deviceType = value!;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'IP Address',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an IP address';
              }
              return null;
            },
            onSaved: (value) {
              _ipAddress = value!;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a location';
              }
              return null;
            },
            onSaved: (value) {
              _location = value!;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) {
              _description = value ?? '';
            },
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Add device registration logic here
                  }
                },
                child: Text('Activate device registration'),
              ),
              SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  // Add cancel logic here
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}