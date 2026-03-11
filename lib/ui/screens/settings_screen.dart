import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _saveOnDevice = false;
  String _defaultName = "New note";

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  void _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _saveOnDevice = _prefs.getBool('save_on_device') ?? false;
      _defaultName = _prefs.getString('default_name') ?? "New note";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: ListView(
        children: [
          _sectionHeader('General'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Accent colour'),
            subtitle: const Text('Dynamic or custom colors'),
            onTap: () => _showColorPicker(),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            subtitle: const Text('AMOLED, Dark, Light'),
            onTap: () => _showThemePicker(),
          ),
          const ListTile(
            leading: Icon(Icons.language_outlined),
            title: Text('Language'),
            subtitle: Text('English (System default)'),
          ),

          const Divider(indent: 16, endIndent: 16),
          _sectionHeader('Home screen'),
          ListTile(
            leading: const Icon(Icons.swipe_outlined),
            title: const Text('Swipe gestures'),
            subtitle: const Text('Configure list actions'),
            onTap: () {
              // Ovde ćemo dodati Dismissible logiku kasnije
            },
          ),

          const Divider(indent: 16, endIndent: 16),
          _sectionHeader('Notes'),
          ListTile(
            leading: const Icon(Icons.edit_note_outlined),
            title: const Text('Default name for new notes'),
            subtitle: Text(_defaultName),
            onTap: () => _showDefaultNameDialog(),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.sd_storage_outlined),
            title: const Text('Save notes on device'),
            subtitle: const Text('Export automatically to local storage'),
            value: _saveOnDevice,
            onChanged: (bool value) async {
              setState(() => _saveOnDevice = value);
              await _prefs.setBool('save_on_device', value);
            },
          ),

          const Divider(indent: 16, endIndent: 16),
          _sectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined), // Popravljeno malo 'i'
            title: const Text('Dependencies'),
            onTap: () => _showDependencies(),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('License'),
            subtitle: const Text("Click this to open GNU's website"),
            onTap: () => _launchURL('https://www.gnu.org/licenses/gpl-3.0.html'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Accent colour", style: TextStyle(fontWeight: FontWeight.w300)),
        content: const Text("Material You dynamic coloring is active."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
        ],
      ),
    );
  }

  void _showThemePicker() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Theme", style: TextStyle(fontWeight: FontWeight.w300)),
        children: ['System default', 'Light', 'Dark', 'AMOLED'].map((theme) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(theme),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showDefaultNameDialog() {
    final controller = TextEditingController(text: _defaultName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Default Note Name", style: TextStyle(fontWeight: FontWeight.w300)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter default name"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                setState(() => _defaultName = controller.text);
                await _prefs.setString('default_name', controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDependencies() {
    showAboutDialog(
      context: context,
      applicationName: "f.Sentence",
      applicationVersion: "1.0.1",
      children: const [
        Text("Built with Flutter and passion for FOSS.\n"),
        Text("• Fleather / Parchment"),
        Text("• Hive / Hive Flutter"),
        Text("• Dynamic Color"),
        Text("• Easy Localization"),
        Text("• Shared Preferences"),
        Text("• Animations"),
      ],
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open: $url")),
        );
      }
    }
  }
}
