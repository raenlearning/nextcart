import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _prefKey = 'theme_mode';

  ThemeCubit() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefKey);
    switch (value) {
      case 'dark':
        emit(ThemeMode.dark);
      case 'light':
        emit(ThemeMode.light);
      default:
        emit(ThemeMode.system);
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefKey,
      switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        _ => 'system',
      },
    );
  }

  bool get isDark => state == ThemeMode.dark;

  void toggle() =>
      setMode(isDark ? ThemeMode.light : ThemeMode.dark);
}
