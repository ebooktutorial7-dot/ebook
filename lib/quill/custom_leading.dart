// custom_leading.dart
// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show Attribute;

import 'package:flutter_quill/src/document/nodes/node.dart';
import 'package:flutter_quill/src/editor/raw_editor/builders/leading_block_builder.dart';

Widget? Function(Node, LeadingConfig) buildCustomLeadingWithColor(
  Color? themeTextColor,
) {
  return (Node node, LeadingConfig cfg) {
    final attr = cfg.attribute;

    final isUl = attr == Attribute.ul;
    final isOl = attr == Attribute.ol;
    final isCheck = attr == Attribute.checked || attr == Attribute.unchecked;

    if (isCheck) return null;
    if (!isUl && !isOl) return null;

    final Color markerColor = themeTextColor ?? Colors.black;

    final width = cfg.width ?? 36.0;
    final padRight = cfg.padding ?? 6.0;
    final baseFont = _resolveBaseFontSize(cfg);
    final indentLevel = (cfg.attrs[Attribute.indent.key]?.value as int?) ?? 0;

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

double _resolveBaseFontSize(LeadingConfig cfg) {
  final fs = cfg.style?.fontSize;
  if (fs != null && fs > 0) return fs;

  final ls = cfg.lineSize;
  if (ls != null && ls > 0) {
    return (ls / 1.35).clamp(12.0, 22.0);
  }

  return 15.0;
}

double _shrinkByIndent(double v, int indent) {
  final factor = (1.0 - indent * 0.07).clamp(0.75, 1.0);
  return v * factor;
}

double _nudgeForMarker(double baseFont) {
  if (baseFont >= 20) return 2.0;
  if (baseFont >= 17) return 1.5;
  return 1.0;
}

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
