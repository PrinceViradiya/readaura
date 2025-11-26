import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central place to manage and persist theme state for the whole app.
class AppTheme {
  AppTheme._();

  static const _prefKey = 'isDarkMode';
  static SharedPreferences? _prefs;

  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1E3A8A),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E3A8A),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7DD3FC),
      brightness: Brightness.dark,
    ),
    cardColor: const Color(0xFF1E1E1E),
    useMaterial3: true,
  );

  /// Must be called before runApp so we restore persisted theme preference.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final storedValue = _prefs?.getBool(_prefKey) ?? false;
    mode.value = storedValue ? ThemeMode.dark : ThemeMode.light;
  }

  /// Switch between light/dark mode and persist the preference locally.
  static Future<void> setDark(bool isDark) async {
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    await _prefs?.setBool(_prefKey, isDark);
  }
}