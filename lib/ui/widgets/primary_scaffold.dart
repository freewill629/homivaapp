import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrimaryScaffold extends StatelessWidget {
  const PrimaryScaffold({
    required this.title,
    required this.body,
    this.actions,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Homiva'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => context.go('/home'),
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Analytics'),
              onTap: () => context.go('/analytics'),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Alerts'),
              onTap: () => context.go('/alerts'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => context.go('/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => context.go('/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Diagnostics'),
              onTap: () => context.go('/diagnostics'),
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}
