import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and broadcasts the user's theme mode choice (light/dark/system).
/// A ChangeNotifier is the standard, minimal-dependency way to do this in
/// Flutter without pulling in a state management package — MaterialApp
/// listens to it directly via AnimatedBuilder in main.dart.
class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      switch (saved) {
        case 'light':
          _mode = ThemeMode.light;
          break;
        case 'dark':
          _mode = ThemeMode.dark;
          break;
        default:
          _mode = ThemeMode.system;
      }
      notifyListeners();
    } catch (_) {
      // If preferences fail to load, default to system brightness rather
      // than blocking app startup.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode.name);
    } catch (_) {
      // Non-fatal: the toggle still works for this session even if it
      // can't be persisted.
    }
  }

  /// Toggles between light and dark explicitly (skips "system") since a
  /// simple on/off switch in the UI is clearer than a three-way cycle for
  /// most users, while setMode(ThemeMode.system) remains available if a
  /// settings screen wants to offer it later.
  Future<void> toggle() async {
    await setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}

final themeController = ThemeController();
