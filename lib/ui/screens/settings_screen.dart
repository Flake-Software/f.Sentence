// This code is released under GNU General Public License v3.0. For more imformation on license, visit https://www.gnu.org/licenses/gpl-3.0.en.html


import 'package:flutter/material.dart';
import '../../core/app_settings.dart';
import 'settings/general_settings.dart';
import 'settings/notes_settings.dart';
import 'settings/about_settings.dart'; // Importujemo About

class SettingsScreen extends StatelessWidget {
  final AppSettings settings;

  const SettingsScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          
          // About f.Sentence je sada ovde na glavnom ekranu
          _buildSettingsTile(
            context,
            icon: Icons.info_outline_rounded,
            iconColor: Colors.orange,
            title: 'About f.Sentence',
            subtitle: 'Mission, version and info',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AboutSettings(),
              ),
            ),
          ),
          
          _buildSettingsTile(
            context,
            icon: Icons.help_outline_rounded,
            iconColor: Colors.purple,
            title: 'Help & Feedback',
            subtitle: 'FAQs and contact support',
            onTap: () {
              // TODO: Implement help
            },
          ),
        ],
      ),
    );
  }

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