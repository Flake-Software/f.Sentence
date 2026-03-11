import 'package:flutter/material.dart';
import 'settings/general_settings.dart';
import 'settings/notes_settings.dart';
import 'settings/dependencies_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: ListView(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.tune_outlined,
            title: 'General',
            subtitle: 'Accent colors • Theme • Language',
            destination: const GeneralSettings(),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.edit_note_outlined,
            title: 'Notes settings',
            subtitle: 'Default note names • Data saving',
            destination: const NotesSettings(),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'About app',
            subtitle: 'Version • Dependencies • License',
            destination: const DependenciesScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget destination,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }
}
