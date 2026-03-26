import 'package:flutter/material.dart';
import '../../../core/app_settings.dart';
import 'about_settings.dart';

class GeneralSettings extends StatefulWidget {
  final AppSettings settings;

  const GeneralSettings({super.key, required this.settings});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Accent color'),
            subtitle: const Text('Change the app\'s primary color'),
            trailing: CircleAvatar(
              backgroundColor: widget.settings.accentColor,
              radius: 12,
            ),
            onTap: () => _showColorPicker(context),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Theme'),
            subtitle: Text(widget.settings.themeLabel),
            onTap: () => _showThemePicker(context),
          ),
          const ListTile(
            leading: Icon(Icons.language_outlined),
            title: Text('Language'),
            subtitle: Text('English'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About f.Sentence'),
            subtitle: const Text('Mission, version and info'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutSettings()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final List<Color> colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      const Color(0xFF212121), // Sophisticated dark slate
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select color'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                widget.settings.updateAccentColor(color);
                setState(() {});
                Navigator.pop(context);
              },
              child: CircleAvatar(
                backgroundColor: color,
                radius: 24,
                child: widget.settings.accentColor == color 
                    ? const Icon(Icons.check, color: Colors.white) 
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['System', 'Light', 'Dark', 'AMOLED'].map((t) {
            return RadioListTile<String>(
              title: Text(t),
              value: t,
              groupValue: widget.settings.themeLabel,
              onChanged: (String? value) {
                if (value != null) {
                  widget.settings.updateTheme(value);
                  setState(() {});
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
