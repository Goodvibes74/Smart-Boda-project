// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Main AuthPage widget
class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;

  void _toggleForm() => setState(() => _isLogin = !_isLogin);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final maxCardWidth = 400.0;

    return Scaffold(
      backgroundColor: cs.background,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxCardWidth),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/svg/icon.svg',
                      height: 100,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Safe Buddy',
                      style: text.headlineMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Admin Login' : 'Create Account',
                      style: text.titleMedium?.copyWith(
                        decoration: TextDecoration.underline,
                        color: cs.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isLogin ? const LoginForm() : const SignUpForm(),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _toggleForm,
                      child: Text(
                        _isLogin
                            ? 'Don’t have an account? Sign up'
                            : 'Already have an account? Log in',
                        style: text.bodyMedium?.copyWith(
                          color: cs.primary.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// LoginForm widget
class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  final _usernameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usernameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 200));

    String email;
    final input = _usernameOrEmailController.text.trim();

    try {
      if (input.contains('@')) {
        email = input;
      } else {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: input)
            .limit(1)
            .get();
        if (snap.docs.isEmpty) {
          setState(() => _error = 'Username not found.');
          return;
        }
        email = snap.docs.first['email'];
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome back!')),
        );
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapAuthError(e.code));
    } catch (_) {
      setState(() => _error = 'Unexpected error.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Auth failed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameOrEmailController,
            focusNode: _usernameFocus,
            decoration: InputDecoration(
              labelText: 'Username or Email',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: cs.surfaceVariant,
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            onChanged: (v) => setState(() => _error = null),
            // semanticsLabel: 'Username or Email',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: cs.surfaceVariant,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            onChanged: (v) => setState(() => _error = null),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: txt.bodySmall?.copyWith(color: cs.error)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }
}

// SignUpForm widget
class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _usernameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usernameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: _usernameController.text.trim())
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        setState(() => _error = 'Username taken.');
        return;
      }

      final creds = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(creds.user!.uid)
          .set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
      }).catchError((e) {
        setState(() => _error = 'Failed to save user data.');
        throw e;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Welcome!')),
        );
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapError(e.code));
    } catch (_) {
      setState(() => _error = 'Unexpected error.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email already registered.';
      case 'weak-password':
        return 'Password too weak.';
      default:
        return 'Signup failed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            focusNode: _usernameFocus,
            decoration: InputDecoration(
              labelText: 'Username',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: cs.surfaceVariant,
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            onChanged: (v) => setState(() => _error = null),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: cs.surfaceVariant,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              return emailRegex.hasMatch(v) ? null : 'Invalid email';
            },
            onChanged: (v) => setState(() => _error = null),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: cs.surfaceVariant,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
            onChanged: (v) => setState(() => _error = null),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: cs.surfaceVariant,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            validator: (v) => v != _passwordController.text ? 'Doesn’t match' : null,
            onChanged: (v) => setState(() => _error = null),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: txt.bodySmall?.copyWith(color: cs.error)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _createAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create Account'),
            ),
          ),
        ],
      ),
    );
  }
}