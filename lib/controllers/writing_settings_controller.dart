// writing_settings_controller.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ebook_tutorial_app/models/writing_settings.dart';

/// 문서별 / 글로벌 글쓰기 설정 컨트롤러
///
/// - documentId == null  → 글로벌 설정 ('writing_prefs_global')
/// - documentId != null → 해당 문서 전용 설정 ('writing_prefs_$documentId')
class WritingSettingsController extends ChangeNotifier {
  WritingSettings _settings = WritingSettings.defaults();
  WritingSettings get settings => _settings;

  /// 문서 ID가 있으면 문서별, 없으면 글로벌 설정
  final String? documentId;

  WritingSettingsController({this.documentId});

  String get _prefsKey => 'writing_prefs_${documentId ?? 'global'}';

  /// SharedPreferences 에서 설정 로드
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _settings = WritingSettings.fromJson(map);
      notifyListeners();
    } catch (_) {
      // 파싱 실패 시 기본값 유지
    }
  }

  /// 현재 설정 SharedPreferences 에 저장
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_settings.toJson()));
  }

  // ===================== 업데이트 메서드들 =====================

  /// 테마 변경 (light / dark / darkGreen 등)
  Future<void> updateTheme(String id) async {
    // 테마별 기본 텍스트 색 정리
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

  /// 폰트 패밀리 변경
  Future<void> updateFontFamily(String id) async {
    _settings = _settings.copyWith(fontFamily: id);
    await _persist();
    notifyListeners();
  }

  /// 줄 간격 변경
  Future<void> updateLineHeight(double v) async {
    _settings = _settings.copyWith(lineHeight: v);
    await _persist();
    notifyListeners();
  }

  /// 글자 간격 변경
  Future<void> updateLetterSpacing(double v) async {
    _settings = _settings.copyWith(letterSpacing: v);
    await _persist();
    notifyListeners();
  }

  /// 좌우 여백 변경
  Future<void> updateHorizontalMargin(double v) async {
    _settings = _settings.copyWith(horizontalMargin: v);
    await _persist();
    notifyListeners();
  }

  /// 기본 글자 크기 변경 (페이지네이션 / 프리뷰 공통으로 사용)
  Future<void> updateFontSize(double v) async {
    _settings = _settings.copyWith(fontSize: v);
    await _persist();
    notifyListeners();
  }

  /// 텍스트 색상 변경 (유저가 팔레트에서 고른 색)
  Future<void> updateTextColor(Color c) async {
    _settings = _settings.copyWith(textColor: c);
    await _persist();
    notifyListeners();
  }

  /// 텍스트 색상 → 현재 테마의 기본 색으로 되돌리기
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
