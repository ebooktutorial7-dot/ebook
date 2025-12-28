// pdf/book_pdf_builder.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show NetworkAssetBundle, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:ebook_tutorial_app/pages/book_builder_page.dart'
    show ChapterItem;

String _sanitizeUtf16(String s) {
  // ✅
  bool hasSurrogate = false;
  for (final cu in s.codeUnits) {
    if (cu >= 0xD800 && cu <= 0xDFFF) {
      hasSurrogate = true;
      break;
    }
  }
  if (!hasSurrogate) return s;

  final out = StringBuffer();
  final units = s.codeUnits;
  for (int i = 0; i < units.length; i++) {
    final cu = units[i];
    if (cu >= 0xD800 && cu <= 0xDBFF) {
      if (i + 1 < units.length) {
        final cu2 = units[i + 1];
        if (cu2 >= 0xDC00 && cu2 <= 0xDFFF) {
          out.writeCharCode(cu);
          out.writeCharCode(cu2);
          i++;
          continue;
        }
      }
      out.write('\uFFFD');
      continue;
    }
    if (cu >= 0xDC00 && cu <= 0xDFFF) {
      out.write('\uFFFD');
      continue;
    }
    out.writeCharCode(cu);
  }
  return out.toString();
}

Future<Uint8List> buildBookPdf({
  required List<ChapterItem> chapters,
  bool showChapterTitle = true,
  bool chapterPerPage = true, // ✅ 항상 회차별 분리(기본값 true)
}) async {
  final fontKr = pw.Font.ttf(
    await rootBundle.load('lib/assets/fonts/NotoSansKR-Regular.ttf'),
  );
  final fontKrBold = pw.Font.ttf(
    await rootBundle.load('lib/assets/fonts/NotoSansKR-Bold.ttf'),
  );

  final fontJp = pw.Font.ttf(
    await rootBundle.load('lib/assets/fonts/NotoSansJP-Regular.ttf'),
  );
  final fontJpBold = pw.Font.ttf(
    await rootBundle.load('lib/assets/fonts/NotoSansJP-Bold.ttf'),
  );

  final doc = pw.Document();

  // ✅ 회차마다 페이지 분리
  if (chapterPerPage) {
    if (chapters.isEmpty) {
      doc.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          theme: pw.ThemeData.withFont(base: fontKr, bold: fontKrBold),
          build:
              (_) => [
                pw.Text(
                  '(내용 없음)',
                  style: pw.TextStyle(font: fontKr, fontFallback: [fontJp]),
                ),
              ],
        ),
      );
      return doc.save();
    }

    for (final chapter in chapters) {
      final pageWidgets = <pw.Widget>[];

      final title = _sanitizeUtf16(chapter.title).trim(); // ✅
      if (showChapterTitle && title.isNotEmpty) {
        pageWidgets.add(
          pw.Text(
            title,
            style: pw.TextStyle(
              font: fontKrBold,
              fontSize: 16,
              height: 1.3,
              fontFallback: [fontJpBold],
            ),
          ),
        );
        pageWidgets.add(pw.SizedBox(height: 12));
      }

      final bodyWidgets = await _deltaToPdfWidgets(
        delta: chapter.delta,
        fontKr: fontKr,
        fontKrBold: fontKrBold,
        fontJp: fontJp,
        fontJpBold: fontJpBold,
      );

      if (bodyWidgets.isEmpty) {
        pageWidgets.add(
          pw.Text(
            '(내용 없음)',
            style: pw.TextStyle(font: fontKr, fontFallback: [fontJp]),
          ),
        );
      } else {
        pageWidgets.addAll(bodyWidgets);
      }

      doc.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          theme: pw.ThemeData.withFont(base: fontKr, bold: fontKrBold),
          build: (_) => pageWidgets,
        ),
      );
    }

    return doc.save();
  }

  // ✅ (예외 옵션) 여러 회차를 하나의 흐름으로
  final widgets = <pw.Widget>[];

  for (final chapter in chapters) {
    final title = _sanitizeUtf16(chapter.title).trim(); // ✅

    if (showChapterTitle && title.isNotEmpty) {
      widgets.add(
        pw.Text(
          title,
          style: pw.TextStyle(
            font: fontKrBold,
            fontSize: 16,
            height: 1.3,
            fontFallback: [fontJpBold],
          ),
        ),
      );
      widgets.add(pw.SizedBox(height: 12));
    }

    final bodyWidgets = await _deltaToPdfWidgets(
      delta: chapter.delta,
      fontKr: fontKr,
      fontKrBold: fontKrBold,
      fontJp: fontJp,
      fontJpBold: fontJpBold,
    );

    if (bodyWidgets.isEmpty) {
      widgets.add(
        pw.Text(
          '(내용 없음)',
          style: pw.TextStyle(font: fontKr, fontFallback: [fontJp]),
        ),
      );
    } else {
      widgets.addAll(bodyWidgets);
    }

    widgets.add(pw.SizedBox(height: 28));
  }

  doc.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      theme: pw.ThemeData.withFont(base: fontKr, bold: fontKrBold),
      build: (_) {
        if (widgets.isEmpty) {
          return [
            pw.Text(
              '(내용 없음)',
              style: pw.TextStyle(font: fontKr, fontFallback: [fontJp]),
            ),
          ];
        }
        return widgets;
      },
    ),
  );

  return doc.save();
}

/// ---- 내부 데이터 구조 ----
class _Piece {
  _Piece({required this.text, required this.style, this.link});

  final String text;
  final pw.TextStyle style;
  final String? link;

  bool get hasLink => link != null && link!.trim().isNotEmpty;
}

Future<List<pw.Widget>> _deltaToPdfWidgets({
  required List<Map<String, dynamic>> delta,
  required pw.Font fontKr,
  required pw.Font fontKrBold,
  required pw.Font fontJp,
  required pw.Font fontJpBold,
}) async {
  final out = <pw.Widget>[];

  // iOS 메모 느낌 컬러들(가까운 값)
  const PdfColor codeBg = PdfColor(0.96, 0.96, 0.965);
  const PdfColor codeBorder = PdfColor(0.86, 0.86, 0.88);
  const PdfColor linkBlue = PdfColor(0.0, 0.48, 1.0);
  const PdfColor checkBorder = PdfColor(0.62, 0.62, 0.66);

  // 한 줄 단위 piece 버퍼
  final linePieces = <_Piece>[];

  // ordered 리스트 번호(들여쓰기 레벨별)
  final orderedCounterByIndent = <int, int>{};

  // code-block 연속 줄을 하나의 박스로 묶기 위한 버퍼
  final codeLinesBuf = <List<_Piece>>[];

  pw.TextAlign parseAlign(Map<String, dynamic>? attrs) {
    final v = attrs?['align'];
    switch (v) {
      case 'center':
        return pw.TextAlign.center;
      case 'right':
        return pw.TextAlign.right;
      case 'justify':
        return pw.TextAlign.justify;
      default:
        return pw.TextAlign.left;
    }
  }

  pw.WrapAlignment wrapAlignFromTextAlign(pw.TextAlign align) {
    switch (align) {
      case pw.TextAlign.center:
        return pw.WrapAlignment.center;
      case pw.TextAlign.right:
        return pw.WrapAlignment.end;
      case pw.TextAlign.justify:
        return pw.WrapAlignment.spaceBetween;
      case pw.TextAlign.left:
      default:
        return pw.WrapAlignment.start;
    }
  }

  int parseIndent(Map<String, dynamic>? attrs) {
    final v = attrs?['indent'];
    if (v is int) return v.clamp(0, 10);
    if (v is num) return v.toInt().clamp(0, 10);
    return 0;
  }

  pw.TextStyle inlineStyle(Map<String, dynamic>? attrs) {
    final isBold = attrs?['bold'] == true;
    final isItalic = attrs?['italic'] == true;
    final isUnderline = attrs?['underline'] == true;
    final isStrike = attrs?['strike'] == true;
    final isCode = attrs?['code'] == true;

    final decors = <pw.TextDecoration>[];
    if (isUnderline) decors.add(pw.TextDecoration.underline);
    if (isStrike) decors.add(pw.TextDecoration.lineThrough);

    // 코드 인라인은 iOS 메모처럼 “약간 작고” 회색톤
    final baseSize = isCode ? 11.0 : 12.0;

    return pw.TextStyle(
      font: isBold ? fontKrBold : fontKr,
      fontFallback: [isBold ? fontJpBold : fontJp],
      fontSize: baseSize,
      height: 1.6,
      fontStyle: isItalic ? pw.FontStyle.italic : pw.FontStyle.normal,
      decoration:
          decors.isEmpty
              ? pw.TextDecoration.none
              : pw.TextDecoration.combine(decors),
      // isCode일 때 약간 회색
      color: isCode ? const PdfColor(0.25, 0.25, 0.28) : null,
    );
  }

  pw.TextStyle codeTextStyle() {
    return pw.TextStyle(
      font: fontKr,
      fontFallback: [fontJp],
      fontSize: 10.8,
      height: 1.45,
      color: const PdfColor(0.18, 0.18, 0.20),
    );
  }

  pw.Widget buildInlineLine({
    required List<_Piece> pieces,
    required pw.TextAlign align,
    pw.TextStyle? baseStyle,
  }) {
    final hasLink = pieces.any((p) => p.hasLink);

    if (!hasLink) {
      return pw.RichText(
        textAlign: align,
        text: pw.TextSpan(
          style: baseStyle,
          children: [
            for (final p in pieces) pw.TextSpan(text: p.text, style: p.style),
          ],
        ),
      );
    }

    return pw.Wrap(
      alignment: wrapAlignFromTextAlign(align),
      runSpacing: 0,
      spacing: 0,
      children: [
        for (final p in pieces)
          if (!p.hasLink)
            pw.Text(
              p.text,
              style: (baseStyle ?? const pw.TextStyle()).merge(p.style),
            )
          else
            pw.UrlLink(
              destination: p.link!.trim(),
              child: pw.Text(
                p.text,
                style: (baseStyle ?? const pw.TextStyle()).merge(
                  p.style.copyWith(
                    color: linkBlue,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
            ),
      ],
    );
  }

  pw.Widget checkBoxMarker({required bool checked}) {
    return pw.Container(
      width: 12.5,
      height: 12.5,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: checkBorder, width: 0.9),
        borderRadius: pw.BorderRadius.circular(3.2),
      ),
      child:
          checked
              ? pw.Center(
                child: pw.Text(
                  '✓',
                  style: pw.TextStyle(
                    fontSize: 10.5,
                    font: fontKrBold,
                    fontFallback: [fontJpBold],
                    color: const PdfColor(0.16, 0.16, 0.18),
                  ),
                ),
              )
              : null,
    );
  }

  String bulletForIndent(int indent) {
    if (indent <= 0) return '•';
    if (indent == 1) return '◦';
    return '▪';
  }

  void flushCodeBlockIfAny() {
    if (codeLinesBuf.isEmpty) return;

    final codeWidgets = <pw.Widget>[];
    for (final line in codeLinesBuf) {
      codeWidgets.add(
        buildInlineLine(
          pieces: line,
          align: pw.TextAlign.left,
          baseStyle: codeTextStyle(),
        ),
      );
    }

    out.add(
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: pw.BoxDecoration(
          color: codeBg,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: codeBorder, width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: codeWidgets,
        ),
      ),
    );
    out.add(pw.SizedBox(height: 10));

    codeLinesBuf.clear();
  }

  void flushLine(Map<String, dynamic>? blockAttrs) {
    final listType = blockAttrs?['list'] as String?;
    final headerLevelRaw = blockAttrs?['header'];
    final isBlockQuote = blockAttrs?['blockquote'] == true;
    final isCodeBlock = blockAttrs?['code-block'] == true;
    final align = parseAlign(blockAttrs);
    final indentLevel = parseIndent(blockAttrs);

    if (isCodeBlock) {
      codeLinesBuf.add(List<_Piece>.from(linePieces));
      linePieces.clear();
      return;
    }

    flushCodeBlockIfAny();

    final hasText = linePieces.isNotEmpty;

    if (!hasText &&
        listType == null &&
        !isBlockQuote &&
        headerLevelRaw == null) {
      linePieces.clear();
      out.add(pw.SizedBox(height: 10));
      return;
    }

    pw.TextStyle? headerStyle;
    int headerLevel = 0;
    if (headerLevelRaw is int) headerLevel = headerLevelRaw;
    if (headerLevelRaw is num) headerLevel = headerLevelRaw.toInt();
    if (headerLevel > 0) {
      final size = switch (headerLevel) {
        1 => 18.0,
        2 => 16.0,
        3 => 14.0,
        _ => 13.0,
      };
      headerStyle = pw.TextStyle(
        font: fontKrBold,
        fontFallback: [fontJpBold],
        fontSize: size,
        height: 1.35,
      );
    }

    pw.Widget lineWidget = buildInlineLine(
      pieces: List<_Piece>.from(linePieces),
      align: align,
      baseStyle:
          headerStyle ??
          pw.TextStyle(
            font: fontKr,
            fontFallback: [fontJp],
            fontSize: 12,
            height: 1.6,
          ),
    );

    if (isBlockQuote) {
      lineWidget = pw.Container(
        padding: const pw.EdgeInsets.only(left: 10, top: 6, bottom: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            left: pw.BorderSide(color: PdfColor(0.55, 0.55, 0.55), width: 2),
          ),
        ),
        child: lineWidget,
      );
    }

    final leftPad = indentLevel * 14.0;

    if (listType != null) {
      String? orderedMarker;

      if (listType == 'ordered') {
        orderedCounterByIndent.removeWhere((k, _) => k > indentLevel);
        final next = (orderedCounterByIndent[indentLevel] ?? 0) + 1;
        orderedCounterByIndent[indentLevel] = next;
        orderedMarker = '$next.';
      }

      pw.Widget marker;
      if (listType == 'checked') {
        marker = checkBoxMarker(checked: true);
      } else if (listType == 'unchecked') {
        marker = checkBoxMarker(checked: false);
      } else if (listType == 'ordered') {
        marker = pw.Text(
          orderedMarker ?? '',
          style: pw.TextStyle(
            font: fontKrBold,
            fontFallback: [fontJpBold],
            fontSize: 12,
            height: 1.6,
          ),
        );
      } else {
        marker = pw.Text(
          bulletForIndent(indentLevel),
          style: pw.TextStyle(
            font: fontKrBold,
            fontFallback: [fontJpBold],
            fontSize: 12,
            height: 1.6,
          ),
        );
      }

      final markerBoxWidth = (listType == 'ordered') ? 22.0 : 18.0;

      lineWidget = pw.Padding(
        padding: pw.EdgeInsets.only(left: leftPad),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: markerBoxWidth,
              margin: const pw.EdgeInsets.only(top: 2),
              child: marker,
            ),
            pw.Expanded(child: lineWidget),
          ],
        ),
      );
    } else {
      lineWidget = pw.Padding(
        padding: pw.EdgeInsets.only(left: leftPad),
        child: lineWidget,
      );
    }

    out.add(lineWidget);
    out.add(pw.SizedBox(height: headerStyle != null ? 10 : 6));
    linePieces.clear();
  }

  for (final op in delta) {
    final insert = op['insert'];
    final attrs = (op['attributes'] as Map?)?.cast<String, dynamic>();

    if (insert is String) {
      final parts = _sanitizeUtf16(insert).split('\n');

      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];

        if (part.isNotEmpty) {
          final style = inlineStyle(attrs);
          final link = attrs?['link'];
          final linkStr = link is String ? link : null;

          linePieces.add(_Piece(text: part, style: style, link: linkStr));
        }

        if (i != parts.length - 1) {
          flushLine(attrs);
        }
      }
      continue;
    }

    if (insert is Map) {
      if (insert.containsKey('image')) {
        flushCodeBlockIfAny();

        if (linePieces.isNotEmpty) {
          flushLine(null);
        }

        final dynamic raw = insert['image'];
        final String? source = _normalizeImageSource(raw);
        if (source == null || source.isEmpty) continue;

        final bytes = await _loadImageBytes(source);
        if (bytes == null || bytes.isEmpty) continue;

        out.add(
          pw.Center(
            child: pw.Container(
              constraints: const pw.BoxConstraints(maxWidth: 420),
              child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
            ),
          ),
        );
        out.add(pw.SizedBox(height: 12));
      }
    }
  }

  if (linePieces.isNotEmpty) {
    flushLine(null);
  }
  flushCodeBlockIfAny();

  return out;
}

String? _normalizeImageSource(dynamic raw) {
  if (raw is String) return raw;
  if (raw is Map && raw['source'] is String) return raw['source'] as String;
  return null;
}

Future<Uint8List?> _loadImageBytes(String source) async {
  try {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      final uri = Uri.parse(source);
      final bd = await NetworkAssetBundle(uri).load(uri.toString());
      return bd.buffer.asUint8List();
    } else {
      final f = File(source);
      if (!f.existsSync()) return null;
      return await f.readAsBytes();
    }
  } catch (_) {
    return null;
  }
}
