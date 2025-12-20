// writing_settings.dart

import 'package:flutter/material.dart';

@immutable
class WritingSettings {
  /// 테마 ID: 'light', 'dark', 'darkGreen' 등
  final String themeId;

  /// 폰트 패밀리: 'system' 이면 기본 폰트 사용
  final String fontFamily;

  /// 줄 간격
  final double lineHeight;

  /// 글자 간격
  final double letterSpacing;

  /// 좌우 여백(px)
  final double horizontalMargin;

  /// 기본 글자 크기 (페이지네이션/프리뷰에서 사용)
  final double fontSize;

  /// 기본 텍스트 색 (테마 + 사용자 선택 반영)
  final Color textColor;

  const WritingSettings({
    required this.themeId,
    required this.fontFamily,
    required this.lineHeight,
    required this.letterSpacing,
    required this.horizontalMargin,
    required this.fontSize,
    required this.textColor,
  });

  /// 기본값 (글로벌 / 새 문서 초기값)
  factory WritingSettings.defaults() => const WritingSettings(
    themeId: 'light',
    fontFamily: 'system',
    lineHeight: 1.6,
    letterSpacing: 0.0,
    horizontalMargin: 24.0,
    fontSize: 16.0,
    textColor: Color(0xFF222222),
  );

  WritingSettings copyWith({
    String? themeId,
    String? fontFamily,
    double? lineHeight,
    double? letterSpacing,
    double? horizontalMargin,
    double? fontSize,
    Color? textColor,
  }) {
    return WritingSettings(
      themeId: themeId ?? this.themeId,
      fontFamily: fontFamily ?? this.fontFamily,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      horizontalMargin: horizontalMargin ?? this.horizontalMargin,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeId': themeId,
      'fontFamily': fontFamily,
      'lineHeight': lineHeight,
      'letterSpacing': letterSpacing,
      'horizontalMargin': horizontalMargin,
      'fontSize': fontSize,
      // Color는 int value로 저장
      'textColor': textColor.toARGB32(),
    };
  }

  factory WritingSettings.fromJson(Map<String, dynamic> json) {
    return WritingSettings(
      themeId: json['themeId'] as String? ?? 'light',
      fontFamily: json['fontFamily'] as String? ?? 'system',
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.6,
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 0.0,
      horizontalMargin: (json['horizontalMargin'] as num?)?.toDouble() ?? 24.0,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      textColor: _decodeColor(json['textColor']),
    );
  }

  static Color _decodeColor(dynamic raw) {
    if (raw is int) {
      return Color(raw);
    }
    // 혹시 예전 버전에서 저장된 값이 없으면 테마 기본색으로
    return const Color(0xFF222222);
  }
}
