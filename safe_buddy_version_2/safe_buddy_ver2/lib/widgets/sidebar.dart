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

  static const _collapsedWidth = 60.0; // Slimmer collapsed width
  static const _expandedWidth = 200.0; // Adjusted expanded width
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
        color: cs.surface, // Dark background from theme
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

  const _SidebarContent.collapsed({
    Key? key,
    required this.cs,
    required this.custom,
    required this.selectedIndex,
    required this.onItemSelected,
  })  : expanded = false,
        super(key: key);

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0), // Uniform spacing
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          icon: Icon(icon, size: 24, color: isSelected ? cs.primary : cs.onSurface),
          onPressed: () => onItemSelected(index),
          style: IconButton.styleFrom(
            backgroundColor: isSelected ? cs.primary.withOpacity(0.1) : Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  Widget _listItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? cs.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? cs.primary : cs.onSurface),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? cs.primary : cs.onSurface,
          ),
        ),
        onTap: () => onItemSelected(index),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!expanded) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Center(child: _logo(40)),
              const SizedBox(height: 24),
              _iconButton(Icons.dashboard, 0, tooltip: 'Home'),
              _iconButton(Icons.devices, 1, tooltip: 'Devices'),
              _iconButton(Icons.settings, 2, tooltip: 'Settings'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '© Group 7 @ MAKCOCIS 2025',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.6),
                    fontSize: 10,
                  ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Center(child: _logo(40)),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Safe Buddy',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.onSurface),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Your safety is our priority',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.7),
                ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _listItem(Icons.dashboard, 'Home', 0),
              _listItem(Icons.devices, 'Devices', 1),
              _listItem(Icons.settings, 'Settings', 2),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '© Group 7 @ MAKCOCIS 2025',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.6),
                  fontSize: 10,
                ),
          ),
        ),
      ],
    );
  }
}