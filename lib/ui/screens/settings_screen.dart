import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Dodaj u pubspec ako nemaš za linkove

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
          _sectionHeader(context, 'General'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Accent colour'),
            subtitle: const Text('System dynamic or custom'),
            onTap: () => _showColorPicker(context),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Theme'),
            onTap: () => _showThemePicker(context),
          ),
          const ListTile(
            leading: Icon(Icons.translate),
            title: Text('Language'),
            subtitle: Text('English (Placeholder)'),
          ),
          
          const Divider(),
          _sectionHeader(context, 'Home screen'),
          SwitchListTile(
            secondary: const Icon(Icons.swipe_outlined),
            title: const Text('Swipe gestures'),
            subtitle: const Text('Swipe to delete or archive notes'),
            value: true,
            onChanged: (val) {},
          ),

          const Divider(),
          _sectionHeader(context, 'Notes'),
          ListTile(
            leading: const Icon(Icons.edit_note_outlined),
            title: const Text('Default name for new notes'),
            subtitle: const Text('New note'),
            onTap: () => _showNameInputDialog(context),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.sd_storage_outlined),
            title: const Text('Save notes on device'),
            subtitle: const Text('Export as files automatically'),
            value: false,
            onChanged: (val) {},
          ),

          const Divider(),
          _sectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.code_outlined),
            title: const Text('Dependencies'),
            onTap: () => _showDependencies(context),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('License'),
            subtitle: const Text('Click this to open GNU\'s website'),
            onTap: () => _launchURL('https://www.gnu.org/licenses/gpl-3.0.html'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accent colour', style: TextStyle(fontWeight: FontWeight.w300)),
        content: const Text('Dynamic Color (Material You) is enabled by default.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.w300)),
        children: ['System default', 'Light', 'Dark', 'AMOLED (Pitch Black)'].map((t) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(t)),
          );
        }).toList(),
      ),
    );
  }

  void _showNameInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default name', style: TextStyle(fontWeight: FontWeight.w300)),
        content: const TextField(decoration: InputDecoration(hintText: "New note")),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Save'))],
      ),
    );
  }

  void _showDependencies(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Project Dependencies', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
          SizedBox(height: 10),
          Text('• Fleather (Editor)\n• Hive (Storage)\n• Dynamic Color\n• Easy Localization\n• Google Fonts\n• Animations\n• Permission Handler'),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    debugPrint("Opening: $url");
  }
}
