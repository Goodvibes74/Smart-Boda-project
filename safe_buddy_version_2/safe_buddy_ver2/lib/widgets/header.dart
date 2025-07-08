// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:safe_buddy_ver2/theme.dart';
import 'package:safe_buddy_ver2/widgets/search_bar.dart' as custom_search_bar;

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      height: 64,
      color: cs.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Hi, User',
            style: text.titleMedium?.copyWith(color: cs.primary),
          ),
          const SizedBox(width: 20),
          const Expanded(child: custom_search_bar.SearchBar()),
          IconButton(
            icon: Icon(Icons.notifications, color: cs.onSurface),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.person, color: cs.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
