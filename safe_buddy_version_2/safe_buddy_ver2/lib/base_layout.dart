import 'package:flutter/material.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;

  const BaseLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safe Buddy')),
      body: child,
    );
  }
}
