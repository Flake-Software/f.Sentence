import 'package:flutter/material.dart';
import '../../../core/app_settings.dart';

class GeneralSettings extends StatefulWidget {
  final AppSettings settings;
  const GeneralSettings({super.key, required this.settings});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  // Mapa za povezivanje Flutter boja sa imenima na srpskom/bosanskom
  final Map<Color, String> _colorNames = {
    Colors.blue: 'Blue',
    Colors.red: 'Red',
    Colors.green: 'Green',
    Colors.orange: 'Orange',
    Colors.purple: 'Purple',
    Colors.pink: 'Pink',
    Colors.teal: 'Turqouise',
    Colors.amber: 'Amber',
    Colors.deepPurple: 'Dark Purple',
    Colors.indigo: 'Indigo',
  };

  // Funkcija koja pronalazi ime boje
  String _getColorName(Color color) {
    for (var entry in _colorNames.entries) {
      if (entry.key.value == color.value) return entry.value;
    }
    return "Custom";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('General', style: TextStyle(fontWeight: FontWeight.w400)),
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
                title: "Appearance",
                children: [
                  _buildModernActionTile(
                    context,
                    icon: Icons.brightness_6_outlined,
                    title: 'Theme',
                    subtitle: widget.settings.themeLabel,
                    onTap: () => _showThemeDialog(),
                  ),
                  _buildDivider(),
                  _buildModernActionTile(
                    context,
                    icon: Icons.palette_outlined,
                    title: 'Accent Color',
                    subtitle: _getColorName(widget.settings.accentColor),
                    // Indikator trenutne boje sa desne strane
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: widget.settings.accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onTap: () => _showColorPicker(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSettingsGroup(
                context,
                title: "Localization",
                children: [
                  _buildModernActionTile(
                    context,
                    icon: Icons.translate_rounded,
                    title: 'Language',
                    subtitle: 'English (US)',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Accent Color'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: _colorNames.keys.map((color) {
              final isSelected = widget.settings.accentColor.value == color.value;
              return InkWell(
                onTap: () {
                  widget.settings.updateAccentColor(color);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3)
                        : null,
                  ),
                  child: isSelected 
                      ? const Icon(Icons.check, color: Colors.white, size: 20) 
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['System', 'Light', 'Dark', 'AMOLED'].map((t) {
            return RadioListTile<String>(
              title: Text(t),
              value: t,
              groupValue: widget.settings.themeLabel,
              activeColor: widget.settings.accentColor,
              onChanged: (val) {
                if (val != null) widget.settings.updateTheme(val);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
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

  Widget _buildModernActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
      trailing: trailing,
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