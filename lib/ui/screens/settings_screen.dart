// This code is released under GNU General Public License v3.0. For more information on license, visit https://www.gnu.org/licenses/gpl-3.0.en.html

import 'package:flutter/material.dart';
import '../../core/app_settings.dart';
import 'settings/general_settings.dart';
import 'settings/notes_settings.dart';
import 'settings/about_settings.dart';

class SettingsScreen extends StatelessWidget {
  final AppSettings settings;

  const SettingsScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
        ),
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Prva grupa: Osnovna podešavanja aplikacije
          _buildSettingsGroup(
            context,
            children: [
              _buildModernTile(
                context,
                icon: Icons.settings_outlined,
                iconColor: Colors.blueAccent,
                title: 'General',
                subtitle: 'Theme, accent color, and language',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GeneralSettings(settings: settings),
                  ),
                ),
              ),
              _buildDivider(),
              _buildModernTile(
                context,
                icon: Icons.edit_note_rounded,
                iconColor: Colors.green.shade600,
                title: 'Notes',
                subtitle: 'Default names and editor preferences',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotesSettings(settings: settings),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Druga grupa: Informacije
          _buildSettingsGroup(
            context,
            children: [
              _buildModernTile(
                context,
                icon: Icons.info_outline_rounded,
                iconColor: Colors.orange.shade700,
                title: 'About f.Sentence',
                subtitle: 'Mission, version and info',
                isLast: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutSettings(),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          Center(
            child: Text(
              'f.Sentence v0.8.7-beta',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(28), // Ultra zaobljeno kao Android 16
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 16),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Colors.grey.withOpacity(0.2),
      ),
    );
  }

  Widget _buildModernTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: onTap,
    );
  }
}