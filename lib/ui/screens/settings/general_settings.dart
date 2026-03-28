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
      Colors.blue, Colors.purple, Colors.green, Colors.orange, 
      Colors.red, Colors.teal, Colors.indigo, const Color(0xFF212121),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Select color'),
        content: SizedBox(
          width: double.maxFinite,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: colors.map((color) {
              final isSelected = widget.settings.accentColor.value == color.value;
              return GestureDetector(
                onTap: () {
                  widget.settings.updateAccentColor(color);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: 20,
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Choose theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['System', 'Light', 'Dark', 'AMOLED'].map((t) {
            return RadioListTile<String>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(t),
              value: t,
              groupValue: widget.settings.themeLabel,
              onChanged: (String? value) {
                if (value != null) {
                  widget.settings.updateTheme(value);
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