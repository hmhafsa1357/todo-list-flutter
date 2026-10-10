import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App preferences: theme mode and which tab opens first.
class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _defaultFilter = 'Today';

  ThemeMode get themeMode => _themeMode;
  String get defaultFilter => _defaultFilter;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode');
    _themeMode = ThemeMode.values.firstWhere(
          (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
    _defaultFilter = prefs.getString('defaultFilter') ?? 'Today';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  Future<void> setDefaultFilter(String filter) async {
    _defaultFilter = filter;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultFilter', filter);
  }
}