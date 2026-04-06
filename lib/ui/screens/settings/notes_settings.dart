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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Notes', style: TextStyle(fontWeight: FontWeight.w400)),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListenableBuilder(
        listenable: widget.settings,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildSettingsGroup(
                context,
                title: "Defaults",
                children: [
                  _buildModernActionTile(
                    context,
                    icon: Icons.title_rounded,
                    title: 'Default Name',
                    subtitle: widget.settings.defaultName,
                    onTap: () => _showEditNameDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSettingsGroup(
                context,
                title: "Editor Preferences",
                children: [
                  _buildModernSwitchTile(
                    context,
                    icon: Icons.spellcheck_rounded,
                    title: 'Auto-correct',
                    value: true,
                    onChanged: (val) {},
                  ),
                  _buildDivider(),
                  _buildModernSwitchTile(
                    context,
                    icon: Icons.format_list_bulleted_rounded,
                    title: 'Markdown Toolbar',
                    value: true,
                    onChanged: (val) {},
                  ),
                ],
              ),
            ],
          );
        }
      ),
    );
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: widget.settings.defaultName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Note Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              widget.settings.updateDefaultName(controller.text);
              Navigator.pop(context);
            }, 
            child: const Text('Save')
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
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildModernActionTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 20),
      child: Divider(height: 1, thickness: 0.5, color: Colors.grey.withOpacity(0.2)),
    );
  }
}