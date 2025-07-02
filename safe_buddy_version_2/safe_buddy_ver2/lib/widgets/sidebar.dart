import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HoverSidebar extends StatefulWidget {
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
        duration: Duration(milliseconds: 300),
        width: _isHovered ? 250 : 60,
        color: Theme.of(context).colorScheme.surface, // Use theme color
        child: _isHovered
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  SvgPicture.asset(
                    'assets/Logo.svg', // Corrected path
                    height: 50,
                    width: 50,
                    placeholderBuilder: (context) => Container(
                      height: 50,
                      width: 50,
                      color: Colors.grey,
                    ), // Fallback for loading
                  ),
                  Text('Safe Buddy', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                  Text('Your safety is our priority', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                  SizedBox(height: 20),
                  ListTile(
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(Icons.home, color: Colors.white),
                    ),
                    title: Text('Home', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(Icons.devices, color: Colors.white),
                    ),
                    title: Text('Devices', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(Icons.settings, color: Colors.white),
                    ),
                    title: Text('Settings', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                    onTap: () {},
                  ),
                  Spacer(),
                  CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person)),
                ],
              )
            : Center(
                child: SvgPicture.asset(
                  'assets/Logo.svg', // Consistent SVG usage
                  height: 40,
                  width: 40,
                  placeholderBuilder: (context) => Container(
                    height: 40,
                    width: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
      ),
    );
  }
}