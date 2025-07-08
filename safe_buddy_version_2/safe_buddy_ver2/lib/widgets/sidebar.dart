// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:safe_buddy_ver2/theme.dart';

class HoverSidebar extends StatefulWidget {
  final ValueChanged<int> onItemSelected;
  final int selectedIndex;

  const HoverSidebar({
    Key? key,
    required this.onItemSelected,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  _HoverSidebarState createState() => _HoverSidebarState();
}

class _HoverSidebarState extends State<HoverSidebar> {
  bool _isHovered = false;

  static const _collapsedWidth = 60.0;
  static const _expandedWidth = 250.0;
  static const _animationDuration = Duration(milliseconds: 200);
  static const _animationCurve = Curves.easeInOut;

  void _onHover(bool hovering) => setState(() => _isHovered = hovering);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final custom = theme.extension<CustomTheme>()!;
    final isExpanded = _isHovered;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: _animationCurve,
        width: isExpanded ? _expandedWidth : _collapsedWidth,
        color: cs.surface,
        child: AnimatedSwitcher(
          duration: _animationDuration,
          switchInCurve: _animationCurve,
          switchOutCurve: _animationCurve,
          child: isExpanded
              ? _SidebarContent.expanded(
                  key: const ValueKey('expanded'),
                  cs: cs,
                  custom: custom,
                  selectedIndex: widget.selectedIndex,
                  onItemSelected: widget.onItemSelected,
                )
              : _SidebarContent.collapsed(
                  key: const ValueKey('collapsed'),
                  cs: cs,
                  custom: custom,
                  selectedIndex: widget.selectedIndex,
                  onItemSelected: widget.onItemSelected,
                ),
        ),
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final ColorScheme cs;
  final CustomTheme custom;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool expanded;

  /// Collapsed constructor
  const _SidebarContent.collapsed({
    Key? key,
    required this.cs,
    required this.custom,
    required this.selectedIndex,
    required this.onItemSelected,
  })  : expanded = false,
        super(key: key);

  /// Expanded constructor
  const _SidebarContent.expanded({
    Key? key,
    required this.cs,
    required this.custom,
    required this.selectedIndex,
    required this.onItemSelected,
  })  : expanded = true,
        super(key: key);

  Widget _logo(double size) => SvgPicture.asset(
        'assets/svg/icon.svg',
        width: size,
        height: size,
        semanticsLabel: 'SafeBuddy logo',
        placeholderBuilder: (_) => SizedBox(
          width: size,
          height: size,
          child: const ColoredBox(color: Colors.grey),
        ),
      );

  Widget _iconButton(IconData icon, int index, {String? tooltip}) {
    final isSelected = selectedIndex == index;
    final iconColor = isSelected ? cs.primary : cs.onSurface;
    final btn = IconButton(
      icon: Icon(icon, size: 26),
      color: iconColor,
      onPressed: () => onItemSelected(index),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: tooltip != null ? Tooltip(message: tooltip, child: btn) : btn,
    );
  }

  Widget _listItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? cs.secondary.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: cs.onSurface),
        title: Text(
          label,
          style: TextStyle(
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => onItemSelected(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!expanded) {
      return Column(
        children: [
          const SizedBox(height: 20),
          _logo(40),
          const SizedBox(height: 24),
          _iconButton(Icons.home, 0, tooltip: 'Home'),
          _iconButton(Icons.devices, 1, tooltip: 'Devices'),
          _iconButton(Icons.settings, 2, tooltip: 'Settings'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '© Group 7 @ MAKCOTIS 2025',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurface.withOpacity(0.6)),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(child: _logo(50)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Safe Buddy',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
          child: Text(
            'Your safety is our priority',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: cs.onSurface.withOpacity(0.7)),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _listItem(Icons.home, 'Home', 0),
              _listItem(Icons.devices, 'Devices', 1),
              _listItem(Icons.settings, 'Settings', 2),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Text(
            '© Group 7 @ MAKCOTIS 2025',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: cs.onSurface.withOpacity(0.6)),
          ),
        ),
      ],
    );
  }
}
