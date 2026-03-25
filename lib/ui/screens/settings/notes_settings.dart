import 'package:flutter/material.dart';
import '../../../core/app_settings.dart';

class NotesSettings extends StatefulWidget {
  final AppSettings settings;
  const NotesSettings({super.key, required this.settings});

  @override
  State<NotesSettings> createState() => _NotesSettingsState();
}

class _NotesSettingsState extends State<NotesSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.title),
            title: const Text('Default Note Name'),
            subtitle: Text(widget.settings.defaultName),
            onTap: () => _editDefaultName(),
          ),
          SwitchListTile(
            title: const Text('Auto-save notes'),
            value: true, // Ovo možemo dodati u AppSettings kasnije
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }

  void _editDefaultName() {
    final controller = TextEditingController(text: widget.settings.defaultName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Name'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => widget.settings.updateDefaultName(controller.text.trim()));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}