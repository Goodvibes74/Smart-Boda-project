// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:safe_buddy_ver2/theme.dart';

class HoverSidebar extends StatefulWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;

  const HoverSidebar({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
  });

  @override
  State<HoverSidebar> createState() => _HoverSidebarState();
}

class _HoverSidebarState extends State<HoverSidebar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final custom = Theme.of(context).extension<CustomTheme>()!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_)  => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isHovered ? 250 : 60,
        color: cs.surface,
        child: _isHovered
          ? _buildExpanded(cs, custom)
          : _buildCollapsed(cs, custom),
      ),
    );
  }

  Widget _logo({double h = 50}) => SvgPicture.asset(
    'assets/svg/icon.svg',
    height: h*1.2,// Adjust height as needed
    width: h*1.2,
    semanticsLabel: 'SafeBuddy',
    placeholderBuilder: (_) => SizedBox(
      height: h,
      child: const ColoredBox(color: Colors.grey),
    ),
  );

  Widget _navIcon(IconData icon, int index, {
    required ColorScheme cs,
  }) {
    final selected = widget.selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: IconButton(
        icon: Icon(icon, size: 26),
        color: selected ? cs.primary : cs.onSurface,
        onPressed: () => widget.onItemSelected(index),
      ),
    );
  }

  Widget _buildCollapsed(ColorScheme cs, CustomTheme custom) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(child: _logo()),
        const SizedBox(height: 24),
        _navIcon(Icons.home,    0, cs: cs),
        _navIcon(Icons.devices, 1, cs: cs),
        _navIcon(Icons.settings,2, cs: cs),
        const Spacer(),

        // Avatar background from your CustomTheme.sidebarBackground
        

        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Developed by Group 7 @MAKCOTIS 2025',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required int index,
    required ColorScheme cs,
  }) {
    final selected = widget.selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selected
          ? cs.secondary.withOpacity(0.2)
          : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 8),
        leading: Icon(icon, color: cs.onSurface),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => widget.onItemSelected(index),
      ),
    );
  }

  Widget _buildExpanded(ColorScheme cs, CustomTheme custom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(child: _logo()),
        Padding(
          padding: const EdgeInsets.fromLTRB(12,12,0,2),
          child: Text(
            'Safe Buddy',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12,0,0,16),
          child: Text(
            'Your safety is our priority',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: cs.onSurface.withOpacity(.7),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _item(icon: Icons.home,    label: 'Home',    index: 0, cs: cs),
              _item(icon: Icons.devices, label: 'Devices', index: 1, cs: cs),
              _item(icon: Icons.settings,label: 'Settings',index: 2, cs: cs),
            ],
          ),
        ),

        

        Padding(
          padding: const EdgeInsets.fromLTRB(12,0,0,10),
          child: Text(
            'Developed by Group 7 @MAKCOTIS 2025',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(.6),
            ),
          ),
        ),
      ],
    );
  }
}
