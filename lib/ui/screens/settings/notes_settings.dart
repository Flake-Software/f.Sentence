import 'package:flutter/material.dart';
import '../../../core/app_settings.dart';

class NotesSettings extends StatefulWidget {
  final AppSettings settings; // Dodajemo ovo
  const NotesSettings({super.key, required this.settings}); // Menjamo konstruktor

  @override
  State<NotesSettings> createState() => _NotesSettingsState();
}

class _NotesSettingsState extends State<NotesSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_note_outlined),
            title: const Text('Default name'),
            subtitle: Text(widget.settings.defaultName),
            onTap: () => _showDefaultNameDialog(),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.folder_open_outlined),
            title: const Text('Save directly to device'),
            subtitle: const Text('When switched on, notes will be visible in file manager.'),
            value: widget.settings.saveToDevice,
            onChanged: (val) => widget.settings.toggleSaveToDevice(val),
          ),
        ],
      ),
    );
  }

  void _showDefaultNameDialog() {
    final controller = TextEditingController(text: widget.settings.defaultName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Note Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter name..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.settings.updateDefaultName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}