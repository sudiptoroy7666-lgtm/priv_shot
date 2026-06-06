import 'package:flutter/material.dart';
import 'package:priv_shot/core/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'About',
            children: [
              _InfoTile(
                icon: Icons.shield,
                title: '100% Offline',
                subtitle: 'No internet permission required',
              ),
              _InfoTile(
                icon: Icons.security,
                title: 'On-Device Processing',
                subtitle: 'All ML processing happens locally',
              ),
              _InfoTile(
                icon: Icons.no_accounts,
                title: 'No Backend',
                subtitle: 'No data ever leaves your device',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'App Info',
            children: [
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Source'),
                subtitle: const Text('Open source privacy tool'),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}