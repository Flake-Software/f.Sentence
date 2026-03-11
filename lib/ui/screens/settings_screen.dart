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
  String _defaultName = "new_note";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _saveOnDevice = _prefs.getBool('save_on_device') ?? false;
      _defaultName = _prefs.getString('default_name') ?? "new_note";
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
          _buildSectionTitle('General'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Accent colour'),
            onTap: () => _showColorPicker(),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            onTap: () => _showThemePicker(),
          ),
          const ListTile(
            leading: Icon(Icons.language_outlined),
            title: Text('Language'),
            subtitle: Text('Placeholder (Coming soon)'),
          ),

          const Divider(),
          _buildSectionTitle('Home screen'),
          ListTile(
            leading: const Icon(Icons.swipe_outlined),
            title: const Text('Swipe gestures'),
            subtitle: const Text('Configure list actions'),
            onTap: () {}, // Implementacija kasnije
          ),

          const Divider(),
          _buildSectionTitle('Notes'),
          ListTile(
            leading: const Icon(Icons.edit_note_outlined),
            title: const Text('Default name for new notes'),
            subtitle: Text(_defaultName),
            onTap: () => _showDefaultNameDialog(),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.sd_storage_outlined),
            title: const Text('Save notes on device'),
            value: _saveOnDevice,
            onChanged: (val) {
              setState(() => _saveOnDevice = val);
              _prefs.setBool('save_on_device', val);
            },
          ),

          const Divider(),
          _buildSectionTitle('About'),
          ListTile(
            leading: const Icon(Icons.Inventory_2_outlined),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  // DIJALOZI (Popunjavaš ih prema tvom ukusu)
  void _showColorPicker() { /* Popup sa listom boja */ }
  void _showThemePicker() { /* Popup: System, Light, Dark, AMOLED */ }

  void _showDefaultNameDialog() {
    TextEditingController controller = TextEditingController(text: _defaultName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Default Note Name", style: TextStyle(fontWeight: FontWeight.w300)),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Enter name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() => _defaultName = controller.text);
              _prefs.setString('default_name', controller.text);
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
      children: [
        const Text("• Fleather / Parchment\n• Hive\n• Dynamic Color\n• Easy Localization\n• Shared Preferences\n• Google Fonts"),
      ],
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
