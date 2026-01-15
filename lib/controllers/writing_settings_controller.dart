// writing_settings_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebook_tutorial_app/models/writing_settings.dart';

class WritingSettingsController extends ChangeNotifier {
  WritingSettings _settings = WritingSettings.defaults();
  WritingSettings get settings => _settings;

  final String? documentId;

  WritingSettingsController({this.documentId});

  String get _prefsKey => 'writing_prefs_${documentId ?? 'global'}';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _settings = WritingSettings.fromJson(map);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_settings.toJson()));
  }

  // ===================== 업데이트 메서드들 =====================

  Future<void> updateTheme(String id) async {
    final Color defaultColor;
    switch (id) {
      case 'dark':
      case 'darkGreen':
      case 'space':
        defaultColor = Colors.white.withValues(alpha: 0.96);
        break;
      case 'lightSky':
        defaultColor = const Color(0xFF1E293B);
        break;
      default:
        defaultColor = const Color(0xFF222222);
    }

    _settings = _settings.copyWith(themeId: id, textColor: defaultColor);
    await _persist();
    notifyListeners();
  }

  Future<void> updateFontFamily(String id) async {
    _settings = _settings.copyWith(fontFamily: id);
    await _persist();
    notifyListeners();
  }

  Future<void> updateLineHeight(double v) async {
    _settings = _settings.copyWith(lineHeight: v);
    await _persist();
    notifyListeners();
  }

  Future<void> updateLetterSpacing(double v) async {
    _settings = _settings.copyWith(letterSpacing: v);
    await _persist();
    notifyListeners();
  }

  Future<void> updateHorizontalMargin(double v) async {
    _settings = _settings.copyWith(horizontalMargin: v);
    await _persist();
    notifyListeners();
  }

  Future<void> updateFontSize(double v) async {
    _settings = _settings.copyWith(fontSize: v);
    await _persist();
    notifyListeners();
  }

  Future<void> updateTextColor(Color c) async {
    _settings = _settings.copyWith(textColor: c);
    await _persist();
    notifyListeners();
  }

  Future<void> resetTextColorToThemeDefault() async {
    final Color defaultColor;
    switch (_settings.themeId) {
      case 'dark':
      case 'darkGreen':
      case 'space':
        defaultColor = Colors.white.withValues(alpha: 0.96);
        break;
      case 'lightSky':
        defaultColor = const Color(0xFF1E293B);
        break;
      default:
        defaultColor = const Color(0xFF222222);
    }

    _settings = _settings.copyWith(textColor: defaultColor);
    await _persist();
    notifyListeners();
  }
}
