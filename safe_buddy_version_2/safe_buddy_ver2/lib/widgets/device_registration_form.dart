// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

class DeviceRegistrationForm extends StatefulWidget {
  const DeviceRegistrationForm({Key? key}) : super(key: key);

  @override
  State<DeviceRegistrationForm> createState() => _DeviceRegistrationFormState();
}

class _DeviceRegistrationFormState extends State<DeviceRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameCtrl = TextEditingController();
  final _deviceIdCtrl   = TextEditingController();
  final _typeCtrl       = TextEditingController();
  final _locationCtrl   = TextEditingController();
  final _ipCtrl         = TextEditingController();
  final _descCtrl       = TextEditingController();
  bool _activate = false;
  bool _loading  = false;

  @override
  void dispose() {
    for (final c in [
      _deviceNameCtrl,
      _deviceIdCtrl,
      _typeCtrl,
      _locationCtrl,
      _ipCtrl,
      _descCtrl
    ]) {
      c.dispose();
    }
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
            children: [
              // row 1: name & id
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _deviceNameCtrl,
                      decoration: _decorate('Device Name'),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _deviceIdCtrl,
                      decoration: _decorate('Device ID'),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // row 2: type full width
              TextFormField(
                controller: _typeCtrl,
                decoration: _decorate('Device Type'),
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),

              const SizedBox(height: 12),

              // row 3: location & IP
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationCtrl,
                      decoration: _decorate('Location (e.g. Kampala, Uganda)'),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _ipCtrl,
                      decoration: _decorate('IP Address (Optional)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // row 4: description
              TextFormField(
                controller: _descCtrl,
                decoration: _decorate('Description (Optional)'),
                maxLines: 3,
              ),

              const SizedBox(height: 12),

              // activate checkbox
              CheckboxListTile(
                value: _activate,
                onChanged: (v) => setState(() => _activate = v ?? false),
                title: const Text('Activate device upon registration'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),

              // buttons
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
                        : const Text('Add Device'),
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
