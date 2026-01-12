// custom_leading.dart
// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show Attribute;

// Quill 내부 타입 (경고는 ignore_for_file로 무시)
import 'package:flutter_quill/src/document/nodes/node.dart';
import 'package:flutter_quill/src/editor/raw_editor/builders/leading_block_builder.dart';

/// ✅ 해결 2: 색을 "직접" 주입하는 버전
///
/// - themeTextColor == null  → 기본 블랙 마커
/// - themeTextColor != null  → 테마 글자색 마커
///
/// 사용 예 (ChapterWritePage):
///   final Color? markerColor =
///       (settings.themeId == 'default') ? null : _textColorFromSettings(settings);
///   customLeadingBlockBuilder: buildCustomLeadingWithColor(markerColor),
Widget? Function(Node, LeadingConfig) buildCustomLeadingWithColor(
  Color? themeTextColor,
) {
  return (Node node, LeadingConfig cfg) {
    final attr = cfg.attribute;

    final isUl = attr == Attribute.ul;
    final isOl = attr == Attribute.ol;
    final isCheck = attr == Attribute.checked || attr == Attribute.unchecked;

    // ✅ 체크박스는 기본 렌더링에 맡김
    if (isCheck) return null;
    if (!isUl && !isOl) return null;

    // ✅ 마커 색: 기본 블랙 or 테마 글자색
    final Color markerColor = themeTextColor ?? Colors.black;

    final width = cfg.width ?? 36.0;
    final padRight = cfg.padding ?? 6.0;

    // ✅ “본문 크기에 따라 자연스럽게”
    final baseFont = _resolveBaseFontSize(cfg);

    // 인덴트 레벨(있으면 살짝 줄임)
    final indentLevel = (cfg.attrs[Attribute.indent.key]?.value as int?) ?? 0;

    // ✅ UL: 텍스트 '•'
    if (isUl) {
      final ulFont = _shrinkByIndent(
        baseFont * 0.95,
        indentLevel,
      ).clamp(12.0, 20.0);

      return SizedBox(
        width: width,
        child: Padding(
          padding: EdgeInsets.only(right: padRight),
          child: Align(
            alignment: Alignment.topCenter,
            child: _TextMarker(
              text: '•',
              color: markerColor,
              fontSize: ulFont,
              fontWeight: FontWeight.w800,
              topNudge: _nudgeForMarker(baseFont),
            ),
          ),
        ),
      );
    }

    // ✅ OL: "1." (원형 없음)
    final label = _resolveOrderedLabel(cfg);
    final marker = '$label.';

    final olFont = _shrinkByIndent(
      baseFont * 0.80,
      indentLevel,
    ).clamp(11.0, 18.0);

    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.only(right: padRight),
        child: Align(
          alignment: Alignment.topCenter,
          child: _TextMarker(
            text: marker,
            color: markerColor,
            fontSize: olFont,
            fontWeight: FontWeight.w800,
            topNudge: _nudgeForMarker(baseFont) + 1.0,
          ),
        ),
      ),
    );
  };
}

/// ✅ 현재 줄 폰트 크기 추정
double _resolveBaseFontSize(LeadingConfig cfg) {
  final fs = cfg.style?.fontSize;
  if (fs != null && fs > 0) return fs;

  final ls = cfg.lineSize;
  if (ls != null && ls > 0) {
    // lineSize는 줄 높이 성격이라 폰트로 쓰면 과대가 될 수 있어 보정
    return (ls / 1.35).clamp(12.0, 22.0);
  }

  return 15.0;
}

/// ✅ 인덴트 깊어질수록 살짝 축소(자연스러움)
double _shrinkByIndent(double v, int indent) {
  final factor = (1.0 - indent * 0.07).clamp(0.75, 1.0);
  return v * factor;
}

/// ✅ 폰트 크기에 따른 미세 위치 보정
double _nudgeForMarker(double baseFont) {
  if (baseFont >= 20) return 2.0;
  if (baseFont >= 17) return 1.5;
  return 1.0;
}

/// ✅ 안전: getIndexNumberByIndent 대응
String _resolveOrderedLabel(LeadingConfig cfg) {
  final dynamic v = cfg.getIndexNumberByIndent;

  if (v is String && v.trim().isNotEmpty) {
    return v.trim();
  }

  if (v is String Function()) {
    final r = v();
    if (r.trim().isNotEmpty) return r.trim();
  } else if (v is Function) {
    try {
      final r = v();
      if (r is String && r.trim().isNotEmpty) return r.trim();
    } catch (_) {
      // ignore
    }
  }

  return '${cfg.index ?? 1}';
}

/// 간단 텍스트 마커(• / 1.)
class _TextMarker extends StatelessWidget {
  const _TextMarker({
    required this.text,
    required this.color,
    required this.fontSize,
    required this.fontWeight,
    this.topNudge = 0,
  });

  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double topNudge;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, topNudge),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.0,
        ),
      ),
    );
  }
}
