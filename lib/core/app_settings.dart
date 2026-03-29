// This code is released under GNU General Public License v3.0. For more imformation on license, visit https://www.gnu.org/licenses/gpl-3.0.en.html

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppSettings extends ChangeNotifier {
  late Box _settingsBox;
  
  Color _accentColor = Colors.blue;
  String _themeLabel = 'System';
  String _defaultName = 'New note';

  AppSettings() {
    _settingsBox = Hive.box('settings_box');
    _loadSettings();
  }

  void _loadSettings() {
    final int? colorValue = _settingsBox.get('accentColor');
    if (colorValue != null) {
      _accentColor = Color(colorValue);
    }
    _themeLabel = _settingsBox.get('themeLabel', defaultValue: 'System');
    _defaultName = _settingsBox.get('defaultName', defaultValue: 'New note');
    notifyListeners();
  }

  Color get accentColor => _accentColor;
  String get themeLabel => _themeLabel;
  String get defaultName => _defaultName;

  // Dodajemo ovo da main.dart ne puca i da AMOLED radi
  bool get isAmoled => _themeLabel == 'AMOLED';

  void updateAccentColor(Color color) {
    _accentColor = color;
    _settingsBox.put('accentColor', color.value);
    notifyListeners();
  }

  void updateTheme(String theme) {
    _themeLabel = theme;
    _settingsBox.put('themeLabel', theme);
    notifyListeners();
  }

  void updateDefaultName(String name) {
    _defaultName = name;
    _settingsBox.put('defaultName', name);
    notifyListeners();
  }

  ThemeMode get themeMode {
    switch (_themeLabel) {
      case 'Light': return ThemeMode.light;
      case 'Dark': return ThemeMode.dark;
      case 'AMOLED': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }
}