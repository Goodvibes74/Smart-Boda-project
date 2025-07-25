import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeviceRegistrationForm extends StatefulWidget {
  const DeviceRegistrationForm({Key? key}) : super(key: key);

  @override
  State<DeviceRegistrationForm> createState() => _DeviceRegistrationFormState();
}

class _DeviceRegistrationFormState extends State<DeviceRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  String? _simNumber; // This will hold the saved SIM number from the form
  bool _loading = false;

  // Controllers for the text fields
  final TextEditingController _simNumberCtrl = TextEditingController();

  @override
  void dispose() {
    _simNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate the form fields. If validation fails, stop the submission process.
    if (!_formKey.currentState!.validate()) return;

    // Save the form data to the _simNumber variable.
    _formKey.currentState!.save();
    // Set loading state to true to show a progress indicator and disable buttons.
    setState(() => _loading = true);

    try {
      // Your Firebase Realtime Database API key. Keep this secure in a real application.
      const String firebaseApiKey = 'AIzaSyAkY6qkVOfuXhns81HwTICd41ts-LnBQ0Q';
      
      // Get the SIM number from the text field.
      final String simNumber = _simNumberCtrl.text;

      // Construct the Firebase Realtime Database URL.
      // We are targeting a specific path based on the SIM number.
      // Using `.json` suffix is standard for Firebase REST API.
      final String url =
          'https://safe-buddy-141a4-default-rtdb.firebaseio.com/$simNumber/.json?auth=$firebaseApiKey';

      // Using http.put to set or replace data at the specific path.
      // The body is now an empty JSON object as requested.
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
        }),
      );

      // Check if the widget is still mounted before performing UI operations.
      if (!mounted) return;

      // Check the HTTP response status code. 200 OK indicates success.
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device registered successfully')),
        );
        // Pop the current screen after successful registration.
        Navigator.of(context).pop();
      } else {
        // Log the full response body for debugging failed requests.
        print('Failed to register device. Status Code: ${response.statusCode}, Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register device: ${response.statusCode}. Details: ${response.body}')),
        );
      }
    } catch (e) {
      // Catch any network or other errors during the process.
      if (!mounted) return;
      print('Error during device registration: $e'); // Log the error for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      // Ensure loading state is reset to false, regardless of success or failure.
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Helper function to create consistent InputDecoration for text fields.
  InputDecoration _decorate(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                decoration: _decorate('SIM Card Number'),
                // Validator for the SIM card number field.
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  // Regex to ensure the SIM number is 10-15 digits.
                  if (!RegExp(r'^\d{10,15}$').hasMatch(v)) {
                    return 'Enter a valid SIM number (10-15 digits)';
                  }
                  return null;
                },
                // Save the validated SIM number to the _simNumber variable.
                onSaved: (v) => _simNumber = v,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button: pops the screen. Disabled when loading.
                  TextButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  // Register button: triggers the _submit function. Disabled when loading.
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            // Show a CircularProgressIndicator when loading.
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Register'),
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
