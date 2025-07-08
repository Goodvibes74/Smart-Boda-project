// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  /// Called on every change in the text field.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (e.g. presses “search” on keyboard).
  final ValueChanged<String>? onSubmitted;

  /// Placeholder text.
  final String hintText;

  /// Whether this field should request focus automatically.
  final bool autofocus;

  const SearchBar({
    Key? key,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Search…',
    this.autofocus = false,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()
      ..addListener(() {
        final hasText = _controller.text.isNotEmpty;
        if (hasText != _hasText) {
          setState(() => _hasText = hasText);
        }
        widget.onChanged?.call(_controller.text);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    // Listener will fire onChanged again with empty string.
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: BorderSide(color: cs.primary.withOpacity(0.5)),
    );

    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmitted,
      cursorColor: cs.primary,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.5)),
        filled: true,
        fillColor: cs.surface,
        prefixIcon: Icon(Icons.search, color: cs.onSurface.withOpacity(0.7)),
        suffixIcon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _hasText
              ? IconButton(
                  key: const ValueKey('clear_btn'),
                  icon: Icon(Icons.clear, color: cs.onSurface.withOpacity(0.7)),
                  onPressed: _clear,
                  tooltip: 'Clear search',
                )
              : const SizedBox.shrink(),
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: cs.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
