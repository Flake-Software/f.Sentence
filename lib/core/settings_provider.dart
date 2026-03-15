import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  
  bool _isAmoled = false;
  int _themeMode = 0; // 0: System, 1: Light, 2: Dark
  
  bool get isAmoled => _isAmoled;
  ThemeMode get themeMode => ThemeMode.values[_themeMode];

  SettingsProvider() {
    _loadFromPrefs();
  }

  void _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isAmoled = _prefs.getBool('amoled_mode') ?? false;
    _themeMode = _prefs.getInt('theme_mode') ?? 0;
    notifyListeners(); 
  }

  void toggleAmoled(bool value) async {
    _isAmoled = value;
    await _prefs.setBool('amoled_mode', value);
    notifyListeners();
  }

  void setThemeMode(int index) async {
    _themeMode = index;
    await _prefs.setInt('theme_mode', index);
    notifyListeners();
  }
}
