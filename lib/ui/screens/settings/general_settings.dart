import 'package:flutter/material.dart';
import '../../../core/app_settings.dart';

class GeneralSettings extends StatelessWidget {
  final AppSettings settings;

  const GeneralSettings({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General settings', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Accent color'),
            subtitle: const Text('Change app\'s accent color. '),
            onTap: () {

            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Theme'),
            subtitle: Text(settings.themeLabel),
            onTap: () => _showThemePicker(context),
          ),
          const ListTile(
            leading: Icon(Icons.language_outlined),
            title: Text('Language'),
            subtitle: Text('Serbian (Placeholder)'),
          ),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose theme'),
        children: ['System', 'Light', 'Dark', 'AMOLED'].map((t) {
          return SimpleDialogOption(
            onPressed: () {
              settings.updateTheme(t);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(t, style: const TextStyle(fontSize: 16)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
