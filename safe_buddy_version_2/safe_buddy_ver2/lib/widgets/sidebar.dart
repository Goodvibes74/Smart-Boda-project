import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HoverSidebar extends StatefulWidget {
  const HoverSidebar({super.key});

  @override
  _HoverSidebarState createState() => _HoverSidebarState();
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
        color: Theme.of(context).colorScheme.surface,
        child: _isHovered
            ? _buildExpandedSidebar(context)
            : _buildCollapsedSidebar(),
      ),
    );
  }

  Widget _buildLogo({double height = 50, double width = 50}) {
    return SvgPicture.asset(
      'assets/svg/Logo.svg',
      height: height,
      width: width,
      semanticsLabel: 'Safe Buddy Logo',
      placeholderBuilder: (context) => SizedBox(
        height: height,
        width: width,
        child: const DecoratedBox(
          decoration: BoxDecoration(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Tooltip(
        message: label,
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  Widget _buildExpandedSidebar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildLogo(),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
          child: Text(
            'Safe Buddy',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            'Your safety is our priority',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildSidebarItem(icon: Icons.home, label: 'Home', onTap: () {}),
              _buildSidebarItem(
                icon: Icons.devices,
                label: 'Devices',
                onTap: () {},
              ),
              _buildSidebarItem(
                icon: Icons.settings,
                label: 'Settings',
                onTap: () {},
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedSidebar() {
    return Center(child: _buildLogo(height: 40, width: 40));
  }
}
