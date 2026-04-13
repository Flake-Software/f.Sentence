import 'package:flutter/material.dart';

class AboutSettings extends StatelessWidget {
  const AboutSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('About f.Sentence', style: TextStyle(fontWeight: FontWeight.w400)),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Center(
                    child: Text(
                      'f.',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w200,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'f.Sentence',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Version 1.0.0-canary',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoGroup(
            context,
            children: [
              _buildInfoTile(
                context,
                icon: Icons.code_rounded,
                title: 'Open Source',
                subtitle: 'Licensed under GPLv3',
              ),
              _buildDivider(),
              _buildInfoTile(
                context,
                icon: Icons.favorite_border_rounded,
                title: 'Made with Love',
                subtitle: 'by Flake Software',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoGroup(
            context,
            children: [
              _buildInfoTile(
                context,
                icon: Icons.policy_outlined,
                title: 'Privacy Policy',
                subtitle: 'Local-first, no tracking',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGroup(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 0.5, indent: 64, endIndent: 20, color: Colors.grey.withOpacity(0.2));
  }
}