import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesSettings extends StatefulWidget {
  const NotesSettings({super.key});

  @override
  State<NotesSettings> createState() => _NotesSettingsState();
}

class _NotesSettingsState extends State<NotesSettings> {
  bool _saveToDevice = false;
  String _defaultName = 'New note';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Default name'),
            subtitle: Text(_defaultName),
            onTap: () {}, // Dodaj dijalog ovde
          ),
          SwitchListTile(
            title: const Text('Save directly to device'),
            subtitle: const Text('When switched on, notes will be visible in file manager.'),
            value: _saveToDevice,
            onChanged: (val) => setState(() => _saveToDevice = val),
          ),
        ],
      ),
    );
  }
}
