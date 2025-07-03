import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isHovered ? 250 : 60,
        color: const Color(0xFF1E1E2C),
        child: _isHovered ? _buildExpanded() : _buildCollapsed(),
      ),
    );
  }

  Widget _logo({double h = 50}) => SvgPicture.asset(
        'assets/svg/Logo.svg',
        height: h,
        semanticsLabel: 'SafeBuddy',
        placeholderBuilder: (_) => SizedBox(
          height: h,
          child: const ColoredBox(color: Colors.grey),
        ),
      );

  Widget _navIcon(IconData icon, int index, {String? tooltip}) {
    final selected = widget.selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: IconButton(
        icon: Icon(icon, size: 26),
        tooltip: tooltip,
        color: selected ? Colors.blueAccent.shade100 : Colors.white,
        onPressed: () => widget.onItemSelected(index),
      ),
    );
  }

  Widget _buildCollapsed() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(child: _logo(h: 50)),
        const SizedBox(height: 24),
        _navIcon(Icons.home, 0, tooltip: 'Home'),
        _navIcon(Icons.devices, 1, tooltip: 'Devices'),
        _navIcon(Icons.settings, 2, tooltip: 'Settings'),
        const Spacer(),
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF1E1E2C)),
          ),
        ),
      ],
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = widget.selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2D2D40) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 8),
        leading: Icon(icon, color: Colors.white),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => widget.onItemSelected(index),
      ),
    );
  }

  Widget _buildExpanded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(child: _logo(h: 50)),
        const Padding(
          padding: EdgeInsets.only(left: 12, top: 12, bottom: 2),
          child: Text('Safe Buddy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 12, bottom: 16),
          child: Text(
            'Your safety is our priority',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _item(icon: Icons.home, label: 'Home', index: 0),
              _item(icon: Icons.devices, label: 'Devices', index: 1),
              _item(icon: Icons.settings, label: 'Settings', index: 2),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(12),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF1E1E2C)),
          ),
        ),
      ],
    );
  }
}

