import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  String _currentTheme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Accent color'),
            subtitle: const Text('Change app\'s accent color.'),
            onTap: () {}, // Kasnije dodajemo popup
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_currentTheme),
            onTap: () => _showThemePicker(),
          ),
          const ListTile(
            title: Text('Language'),
            subtitle: Text('Serbian (Placeholder)'),
          ),
        ],
      ),
    );
  }

  void _showThemePicker() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose theme'),
        children: ['System', 'Light', 'Dark', 'AMOLED'].map((t) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() => _currentTheme = t);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(t),
            ),
          );
        }).toList(),
      ),
    );
  }
}
