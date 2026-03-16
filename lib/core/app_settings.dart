import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  final SharedPreferences prefs;

  AppSettings(this.prefs);


  String get themeLabel => prefs.getString('theme_label') ?? 'System';
  bool get isAmoled => prefs.getBool('amoled_mode') ?? false;

  ThemeMode get themeMode {
    switch (themeLabel) {
      case 'Light': return ThemeMode.light;
      case 'Dark': return ThemeMode.dark;
      case 'AMOLED': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  void updateTheme(String label) async {
    await prefs.setString('theme_label', label);
    await prefs.setBool('amoled_mode', label == 'AMOLED');
    notifyListeners(); 
  }


  String get defaultName => prefs.getString('default_name') ?? 'Nova beleška';
  bool get saveToDevice => prefs.getBool('save_to_device') ?? false;

  void updateDefaultName(String name) async {
    await prefs.setString('default_name', name);
    notifyListeners();
  }

  void toggleSaveToDevice(bool value) async {
    await prefs.setBool('save_to_device', value);
    notifyListeners();
  }
}
