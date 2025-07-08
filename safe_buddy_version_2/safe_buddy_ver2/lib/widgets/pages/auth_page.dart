// ignore_for_file: deprecated_member_use, unused_local_variable, unused_import

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_buddy_ver2/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/svg/icon.svg',
                  height: 100,
                  color: cs.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Safe Buddy',
                  style: text.titleLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your safety is our priority',
                  style: text.bodyLarge?.copyWith(
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isLogin ? 'Admin Login' : 'Create Account',
                  style: text.titleMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 20),
                _isLogin ? const LoginForm() : const SignUpForm(),
                const SizedBox(height: 20),
                _isLogin
                    ? TextButton(
                        onPressed: () => _resetPassword(context),
                        child: Text(
                          'Forgot PIN?',
                          style: text.bodyLarge?.copyWith(
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                TextButton(
                  onPressed: _toggleForm,
                  child: Text(
                    _isLogin
                        ? 'Don’t have an account?'
                        : 'Already have an account? Login',
                    style: text.bodyLarge?.copyWith(
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword(BuildContext context) async {
    // Integrate your existing _resetPassword logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent.')),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Replace with your existing sign-in logic
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text.trim(), // Adjust based on your auth method
        password: _passwordController.text.trim(),
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/admin_dashboard');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _getErrorMessage(e.code));
    } catch (_) {
      setState(() => _errorMessage = 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this username.';
      case 'wrong-password':
        return 'Incorrect PIN/Password.';
      default:
        return 'Authentication failed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Enter your username',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: cs.onSurface.withOpacity(0.1),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Enter username' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'PIN/Password',
              hintText: 'Enter your PIN/Password',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: cs.onSurface.withOpacity(0.1),
            ),
            obscureText: true,
            validator: (v) => (v == null || v.isEmpty) ? 'Enter PIN/Password' : null,
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: text.bodyLarge?.copyWith(color: cs.error),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _isLoading ? null : _signIn,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Login', style: text.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
      // Replace with your existing sign-up logic
      final creds = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await creds.user?.updateDisplayName(_usernameController.text.trim());
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _getErrorMessage(e.code));
    } catch (_) {
      setState(() => _errorMessage = 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      default:
        return 'Account creation failed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Enter your username',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: cs.onSurface.withOpacity(0.1),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Enter username' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: cs.onSurface.withOpacity(0.1),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || v.isEmpty) ? 'Enter email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: cs.onSurface.withOpacity(0.1),
            ),
            obscureText: true,
            validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Confirm your password',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: cs.onSurface.withOpacity(0.1),
            ),
            obscureText: true,
            validator: (v) => (v != _passwordController.text) ? 'Passwords must match' : null,
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: text.bodyLarge?.copyWith(color: cs.error),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _isLoading ? null : _createAccount,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Create Account', style: text.bodyLarge),
          ),
        ],
      ),
    );
  }
}