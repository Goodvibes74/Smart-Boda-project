// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

class DeviceRegistrationForm extends StatefulWidget {
  const DeviceRegistrationForm({Key? key}) : super(key: key);

  @override
  State<DeviceRegistrationForm> createState() => _DeviceRegistrationFormState();
}

class _DeviceRegistrationFormState extends State<DeviceRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  String? _deviceId;
  String? _simNumber;
  bool _loading = false;

  // Add controllers for the text fields
  final TextEditingController _deviceIdCtrl = TextEditingController();
  final TextEditingController _simNumberCtrl = TextEditingController();

  @override
  void dispose() {
    _deviceIdCtrl.dispose();
    _simNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // TODO: your registration logic
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.of(context).pop();
  }

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
    final cs   = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _deviceIdCtrl,
                decoration: _decorate('Device ID'),
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                onSaved: (v) => _deviceId = v,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _simNumberCtrl,
                decoration: _decorate('SIM Card Number'),
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                onSaved: (v) => _simNumber = v,
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
                            height: 16, width: 16,
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
