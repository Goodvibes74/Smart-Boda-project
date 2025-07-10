// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateAccountForm extends StatefulWidget {
  const CreateAccountForm({super.key});

  @override
  CreateAccountFormState createState() => CreateAccountFormState();
}

class CreateAccountFormState extends State<CreateAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController        = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final creds = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      await creds.user?.updateDisplayName(_usernameController.text.trim());
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _getErrorMessage(e.code));
    } catch (_) {
      setState(() => _errorMessage = 'An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'Account creation failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    InputDecoration _inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: text.bodyLarge?.copyWith(color: cs.onSurface),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: cs.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.primary.withOpacity(0.5)),
        ),
        filled: true,
        fillColor: cs.surface,
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Username
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

          // Email
          TextFormField(
            controller: _emailController,
            decoration: _inputDecoration('Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter an email';
              final rx = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              return rx.hasMatch(v) ? null : 'Please enter a valid email';
            },
          ),
          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            decoration: _inputDecoration('Password'),
            obscureText: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter a password';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm
          TextFormField(
            controller: _confirmPasswordController,
            decoration: _inputDecoration('Confirm Password'),
            obscureText: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _errorMessage!,
                style: text.bodyLarge?.copyWith(color: cs.error),
              ),
            ),

          // Create button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
              onPressed: _isLoading ? null : _createAccount,
              child: _isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Create Account', style: text.bodyLarge),
            ),
          ),

          // Switch to login
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pushNamed(context, '/login'),
            child: Text(
              'Already have an account? Login',
              style: text.bodyLarge?.copyWith(color: cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}
