import 'package:flutter/material.dart';
import '../../../core/app_settings.dart';

class GeneralSettings extends StatefulWidget {
  final AppSettings settings;
  const GeneralSettings({super.key, required this.settings});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('General', style: TextStyle(fontWeight: FontWeight.w400)),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSettingsGroup(
            context,
            title: "Appearance",
            children: [
              _buildModernSwitchTile(
                context,
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                value: widget.settings.isDarkMode,
                onChanged: (val) => setState(() {
                  widget.settings.isDarkMode = val;
                  // TODO: Implement save
                }),
              ),
              _buildDivider(),
              _buildModernActionTile(
                context,
                icon: Icons.palette_outlined,
                title: 'Accent Color',
                subtitle: 'Customize app highlights',
                onTap: () {
                  // TODO: Color picker
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsGroup(
            context,
            title: "Localization",
            children: [
              _buildModernActionTile(
                context,
                icon: Icons.translate_rounded,
                title: 'Language',
                subtitle: 'English (US)',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildModernSwitchTile(BuildContext context, {required IconData icon, required String title, required bool value, required Function(bool) onChanged}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildModernActionTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 0.5, indent: 64, endIndent: 20, color: Colors.grey.withOpacity(0.2));
  }
}