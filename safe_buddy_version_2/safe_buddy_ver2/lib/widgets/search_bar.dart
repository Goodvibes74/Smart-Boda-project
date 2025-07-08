// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      decoration: InputDecoration(
        hintText: 'Hinted search text',
        prefixIcon: Icon(Icons.search, color: colorScheme.onSurface),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(64),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(64),
          borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
      ),
      style: TextStyle(color: colorScheme.onSurface),
    );
  }
}
