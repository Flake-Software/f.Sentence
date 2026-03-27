import 'package:flutter/material.dart';
import '../../core/app_settings.dart';
import 'settings/general_settings.dart';
import 'settings/notes_settings.dart';

class SettingsScreen extends StatelessWidget {
  final AppSettings settings;

  const SettingsScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Čist AppBar bez Rail-a, baš kao na tvojim sistemskim podešavanjima
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          
          // Ova stavka te šalje u general_settings.dart
          _buildSettingsTile(
            context,
            icon: Icons.settings_outlined,
            iconColor: Colors.blue,
            title: 'General',
            subtitle: 'Theme, accent color, and language',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GeneralSettings(settings: settings),
              ),
            ),
          ),
          
          // Ova stavka te šalje u notes_settings.dart
          _buildSettingsTile(
            context,
            icon: Icons.edit_note_rounded,
            iconColor: Colors.green,
            title: 'Notes',
            subtitle: 'Default names and editor preferences',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotesSettings(settings: settings),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Divider(thickness: 0.5),
          ),
          
          // Za ostale stavke (Help, Advanced) možeš dodati nove fajlove kasnije
          _buildSettingsTile(
            context,
            icon: Icons.help_outline_rounded,
            iconColor: Colors.purple,
            title: 'Help & Feedback',
            subtitle: 'FAQs and contact support',
            onTap: () {
              // Placeholder
            },
          ),
        ],
      ),
    );
  }

  // Pomoćni widget da ne kucaš isti kod sto puta
  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      onTap: onTap,
    );
  }
}