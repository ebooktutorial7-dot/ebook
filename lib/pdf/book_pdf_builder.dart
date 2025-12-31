// pdf/book_pdf_builder.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:characters/characters.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:ebook_tutorial_app/pages/book_builder_page.dart'
    show ChapterItem;

/// =========================
/// 기본 색 (테마 완전 제외)
/// =========================
const PdfColor kTextColor = PdfColor(0.12, 0.12, 0.13);
const PdfColor kHeaderColor = PdfColor(0.08, 0.08, 0.09);
const PdfColor kListMarkerColor = PdfColor(0.35, 0.35, 0.38);
const PdfColor kHighlightColor = PdfColor(1.0, 0.96, 0.55);
const PdfColor kQuoteBorderColor = PdfColor(0.65, 0.65, 0.68);

/// 링크 컬러(고정)
const PdfColor kLinkBlue = PdfColor(0.0, 0.48, 1.0);

/// 코드블록 박스 스타일(1번 장점)
const PdfColor kCodeBg = PdfColor(0.96, 0.96, 0.965);
const PdfColor kCodeBorder = PdfColor(0.86, 0.86, 0.88);

/// =========================
/// TextStyle 비교 (span 병합 최적화)
/// =========================
bool sameTextStyle(pw.TextStyle? a, pw.TextStyle? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;

  return a.font == b.font &&
      a.fontSize == b.fontSize &&
      a.fontWeight == b.fontWeight &&
      a.fontStyle == b.fontStyle &&
      a.letterSpacing == b.letterSpacing &&
      a.wordSpacing == b.wordSpacing &&
      a.height == b.height &&
      a.decoration == b.decoration &&
      a.color == b.color;
}

/// =========================
/// UTF-16 안전 처리 (고아 surrogate -> U+FFFD)
/// =========================
String _sanitizeUtf16(String s) {
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
    } else if (cu >= 0xDC00 && cu <= 0xDFFF) {
      out.write('\uFFFD');
    } else {
      out.writeCharCode(cu);
    }
  }
  return out.toString();
}

/// =========================
/// PDF 엔트리
/// =========================
Future<Uint8List> buildBookPdf({
  required List<ChapterItem> chapters,
  bool showChapterTitle = true,
  bool chapterPerPage = true,
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

  if (chapters.isEmpty) {
    doc.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.only(
          left: 32,
          right: 32,
          top: 40,
          bottom: 16,
        ),
        theme: pw.ThemeData.withFont(base: fontKr, bold: fontKrBold),
        build:
            (_) => [
              pw.Text(
                '(내용 없음)',
                style: pw.TextStyle(
                  font: fontKr,
                  fontFallback: [fontJp],
                  fontSize: 12,
                  height: 1.6,
                  color: kTextColor,
                ),
              ),
            ],
      ),
    );
    return doc.save();
  }

  if (chapterPerPage) {
    for (final chapter in chapters) {
      final widgets = <pw.Widget>[];

      final title = _sanitizeUtf16(chapter.title).trim();
      if (showChapterTitle && title.isNotEmpty) {
        widgets.add(
          pw.Text(
            title,
            style: pw.TextStyle(
              font: fontKrBold,
              fontFallback: [fontJpBold],
              fontSize: 16,
              height: 1.3,
              color: kHeaderColor,
            ),
          ),
        );
        widgets.add(pw.SizedBox(height: 14));
      }

      final body = await _deltaToPdfWidgets(
        delta: chapter.delta,
        fontKr: fontKr,
        fontKrBold: fontKrBold,
        fontJp: fontJp,
        fontJpBold: fontJpBold,
      );

      if (body.isEmpty) {
        widgets.add(
          pw.Text(
            '(내용 없음)',
            style: pw.TextStyle(
              font: fontKr,
              fontFallback: [fontJp],
              fontSize: 12,
              height: 1.6,
              color: kTextColor,
            ),
          ),
        );
      } else {
        widgets.addAll(body);
      }

      doc.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          theme: pw.ThemeData.withFont(base: fontKr, bold: fontKrBold),
          build: (_) => widgets,
        ),
      );
    }
    return doc.save();
  }

  // chapterPerPage == false : 여러 회차를 하나의 흐름으로
  final widgets = <pw.Widget>[];
  for (final chapter in chapters) {
    final title = _sanitizeUtf16(chapter.title).trim();
    if (showChapterTitle && title.isNotEmpty) {
      widgets.add(
        pw.Text(
          title,
          style: pw.TextStyle(
            font: fontKrBold,
            fontFallback: [fontJpBold],
            fontSize: 16,
            height: 1.3,
            color: kHeaderColor,
          ),
        ),
      );
      widgets.add(pw.SizedBox(height: 14));
    }

    final body = await _deltaToPdfWidgets(
      delta: chapter.delta,
      fontKr: fontKr,
      fontKrBold: fontKrBold,
      fontJp: fontJp,
      fontJpBold: fontJpBold,
    );

    if (body.isEmpty) {
      widgets.add(
        pw.Text(
          '(내용 없음)',
          style: pw.TextStyle(
            font: fontKr,
            fontFallback: [fontJp],
            fontSize: 12,
            height: 1.6,
            color: kTextColor,
          ),
        ),
      );
    } else {
      widgets.addAll(body);
    }

    widgets.add(pw.SizedBox(height: 24));
  }

  doc.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      theme: pw.ThemeData.withFont(base: fontKr, bold: fontKrBold),
      build: (_) => widgets,
    ),
  );

  return doc.save();
}

/// =========================
/// Emoji → PNG (Twemoji)
/// =========================
final Map<String, Uint8List> _emojiCache = {};
final Map<String, Future<Uint8List?>> _emojiInflight = {};

bool _isEmojiCluster(String c) {
  for (final r in c.runes) {
    if (r == 0xFE0F || r == 0x200D) return true; // VS16, ZWJ
    if (r >= 0x1F1E6 && r <= 0x1F1FF) return true; // flags
    if (r >= 0x1F300 && r <= 0x1FAFF) return true;
    if (r >= 0x2600 && r <= 0x27BF) return true;
  }
  return false;
}

String _twemojiFileNameFromCluster(String cluster) {
  final cps = cluster.runes.map((r) => r.toRadixString(16)).toList();
  return cps.join('-').toLowerCase();
}

Future<Uint8List?> _loadEmojiPng(String cluster) {
  final cached = _emojiCache[cluster];
  if (cached != null) return Future.value(cached);

  final inflight = _emojiInflight[cluster];
  if (inflight != null) return inflight;

  final fut = () async {
    try {
      final name = _twemojiFileNameFromCluster(cluster);
      final uri = Uri.parse(
        'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/$name.png',
      );
      final data = await NetworkAssetBundle(uri).load(uri.toString());
      final bytes = data.buffer.asUint8List();
      if (bytes.isNotEmpty) _emojiCache[cluster] = bytes;
      return bytes.isEmpty ? null : bytes;
    } catch (_) {
      return null;
    } finally {
      _emojiInflight.remove(cluster);
    }
  }();

  _emojiInflight[cluster] = fut;
  return fut;
}

/// =========================
/// 이미지 로더 (로컬/네트워크)
/// =========================
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
    }

    final file = File(source);
    if (!file.existsSync()) return null;
    return await file.readAsBytes();
  } catch (_) {
    return null;
  }
}

/// =========================
/// 내부 Piece
/// =========================
class _Piece {
  _Piece({this.text, this.emoji, required this.style, this.link, this.bg});

  final String? text;
  final Uint8List? emoji;
  final pw.TextStyle style;
  final String? link;
  final PdfColor? bg;

  bool get isEmoji => emoji != null;
  bool get hasLink => link != null && link!.trim().isNotEmpty;
}

/// =========================
/// Delta → PDF (합본 버전)
/// - 블록 속성은 원칙적으로 '\n'에서 확정(2번 장점)
/// - 하지만 insert 문자열 안에 여러 줄이 섞여 들어오는 경우 split('\n')로 커버(1번 장점)
/// - code-block은 여러 줄을 버퍼링해서 박스 형태로 렌더(1번 장점)
/// - 고정 컬러/하이라이트/줄 단위 정렬 보정(2번 장점)
/// =========================
Future<List<pw.Widget>> _deltaToPdfWidgets({
  required List<Map<String, dynamic>> delta,
  required pw.Font fontKr,
  required pw.Font fontKrBold,
  required pw.Font fontJp,
  required pw.Font fontJpBold,
}) async {
  final out = <pw.Widget>[];
  final linePieces = <_Piece>[];

  // ordered 리스트 번호(들여쓰기 레벨별)
  final orderedCounterByIndent = <int, int>{};

  // code-block 여러 줄 누적
  final codeLinesBuf = <List<_Piece>>[];

  // 현재 블록 속성(align/list/header/blockquote/indent/code-block)
  Map<String, dynamic>? currentBlockAttrs;

  bool hasBlockKeys(Map<String, dynamic> a) =>
      a.containsKey('align') ||
      a.containsKey('list') ||
      a.containsKey('header') ||
      a.containsKey('blockquote') ||
      a.containsKey('indent') ||
      a.containsKey('code-block');

  pw.TextAlign parseAlign(Map<String, dynamic>? a) {
    final v = a?['align'];
    switch (v) {
      case 'center':
        return pw.TextAlign.center;
      case 'right':
      case 'end': // ✅ 추가
        return pw.TextAlign.right;
      case 'justify':
        return pw.TextAlign.justify;
      case 'left':
      case 'start': // ✅ 추가
      default:
        return pw.TextAlign.left;
    }
  }

  int parseIndent(Map<String, dynamic>? a) {
    final v = a?['indent'];
    if (v is int) return v.clamp(0, 10);
    if (v is num) return v.toInt().clamp(0, 10);
    return 0;
  }

  PdfColor? parseHexColor(dynamic v) {
    if (v is! String) return null;
    final s = v.trim().toLowerCase();
    if (s == 'yellow') return kHighlightColor;
    if (!s.startsWith('#') || s.length != 7) return null;

    final r = int.parse(s.substring(1, 3), radix: 16);
    final g = int.parse(s.substring(3, 5), radix: 16);
    final b = int.parse(s.substring(5, 7), radix: 16);
    return PdfColor(r / 255.0, g / 255.0, b / 255.0);
  }

  pw.TextStyle inlineStyle(Map<String, dynamic>? a) {
    final isBold = a?['bold'] == true;
    final isItalic = a?['italic'] == true;
    final isUnderline = a?['underline'] == true;
    final isStrike = a?['strike'] == true;
    final isCode = a?['code'] == true;

    final decors = <pw.TextDecoration>[];
    if (isUnderline) decors.add(pw.TextDecoration.underline);
    if (isStrike) decors.add(pw.TextDecoration.lineThrough);

    // ✅ 텍스트 색: attrs color가 있으면 반영, 없으면 kTextColor 고정
    final fg = parseHexColor(a?['color']) ?? kTextColor;

    // inline code는 크기만 살짝 다르게
    final baseSize = isCode ? 11.0 : 12.0;

    return pw.TextStyle(
      font: isBold ? fontKrBold : fontKr,
      fontFallback: [isBold ? fontJpBold : fontJp],
      fontSize: baseSize,
      height: 1.6,
      color: fg,
      fontStyle: isItalic ? pw.FontStyle.italic : pw.FontStyle.normal,
      decoration:
          decors.isEmpty
              ? pw.TextDecoration.none
              : pw.TextDecoration.combine(decors),
    );
  }

  pw.TextStyle headerStyle(int level) {
    final size = switch (level) {
      1 => 18.0,
      2 => 16.0,
      3 => 14.0,
      _ => 13.0,
    };
    return pw.TextStyle(
      font: fontKrBold,
      fontFallback: [fontJpBold],
      fontSize: size,
      height: 1.35,
      color: kHeaderColor,
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

  pw.Widget highlightWrap(PdfColor bg, pw.Widget child) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 1.5, vertical: 0.8),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(2.0),
      ),
      child: child,
    );
  }

  pw.Widget buildCheckBoxMarker({required bool checked}) {
    return pw.Container(
      width: 12.5,
      height: 12.5,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: kListMarkerColor, width: 0.9),
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
                    color: kHeaderColor,
                  ),
                ),
              )
              : null,
    );
  }

  pw.Widget buildMarker({required String listType, required int indentLevel}) {
    if (listType == 'ordered') {
      orderedCounterByIndent.removeWhere((k, _) => k > indentLevel);
      final next = (orderedCounterByIndent[indentLevel] ?? 0) + 1;
      orderedCounterByIndent[indentLevel] = next;

      return pw.Text(
        '$next.',
        style: pw.TextStyle(
          font: fontKrBold,
          fontFallback: [fontJpBold],
          fontSize: 12,
          height: 1.6,
          color: kListMarkerColor,
        ),
      );
    }

    if (listType == 'checked') {
      return buildCheckBoxMarker(checked: true);
    }
    if (listType == 'unchecked') {
      return buildCheckBoxMarker(checked: false);
    }

    final bullet = indentLevel <= 0 ? '•' : (indentLevel == 1 ? '◦' : '▪');
    return pw.Text(
      bullet,
      style: pw.TextStyle(
        font: fontKrBold,
        fontFallback: [fontJpBold],
        fontSize: 12,
        height: 1.6,
        color: kListMarkerColor,
      ),
    );
  }

  // RichText inline spans (텍스트/이모지/링크/하이라이트)
  List<pw.InlineSpan> piecesToSpans(
    List<_Piece> pieces, {
    required pw.TextStyle baseStyle,
    required bool
    forceCodeStyle, // code-block이면 true (링크/하이라이트를 허용해도 되지만, 스타일은 code base)
  }) {
    final spans = <pw.InlineSpan>[];

    StringBuffer? buf;
    pw.TextStyle? bufStyle;
    String? bufLink;
    PdfColor? bufBg;

    void flushBuf() {
      if (buf == null) return;
      final txt = buf!.toString();
      if (txt.isNotEmpty) {
        final mergedStyle = (bufStyle ?? baseStyle);

        final hasLink = bufLink != null && bufLink!.trim().isNotEmpty;

        pw.Widget w = pw.Text(
          txt,
          style: mergedStyle.copyWith(
            // 링크면 파란색 + underline
            color: hasLink ? kLinkBlue : (mergedStyle.color ?? kTextColor),
            decoration:
                hasLink ? pw.TextDecoration.underline : mergedStyle.decoration,
          ),
        );

        if (bufBg != null) w = highlightWrap(bufBg!, w);
        if (hasLink) {
          w = pw.UrlLink(destination: bufLink!.trim(), child: w);
        }

        spans.add(pw.WidgetSpan(child: w));
      }

      buf = null;
      bufStyle = null;
      bufLink = null;
      bufBg = null;
    }

    for (final p in pieces) {
      final link = p.hasLink ? p.link!.trim() : null;
      final bg = p.bg;

      final base = forceCodeStyle ? baseStyle : baseStyle;
      final style = base.merge(p.style);

      if (p.isEmoji) {
        flushBuf();

        final fs = (style.fontSize ?? 12.0);
        final size = fs * 1.15;

        pw.Widget w = pw.Image(
          pw.MemoryImage(p.emoji!),
          width: size,
          height: size,
          fit: pw.BoxFit.contain,
        );

        if (bg != null) w = highlightWrap(bg, w);
        if (link != null && link.isNotEmpty) {
          w = pw.UrlLink(destination: link, child: w);
        }

        spans.add(pw.WidgetSpan(child: w));
        continue;
      }

      final t = p.text ?? '';
      if (t.isEmpty) continue;

      final sameRun =
          buf != null &&
          bufLink == link &&
          bufBg == bg &&
          sameTextStyle(bufStyle, style);

      if (!sameRun) {
        flushBuf();
        buf = StringBuffer()..write(t);
        bufStyle = style;
        bufLink = link;
        bufBg = bg;
      } else {
        buf!.write(t);
      }
    }

    flushBuf();
    return spans;
  }

  pw.Widget buildInlineLine({
    required List<_Piece> pieces,
    required pw.TextAlign align,
    required pw.TextStyle baseStyle,
    required bool forceCodeStyle,
  }) {
    final spans = piecesToSpans(
      pieces,
      baseStyle: baseStyle,
      forceCodeStyle: forceCodeStyle,
    );
    return pw.RichText(
      textAlign: align,
      text: pw.TextSpan(style: baseStyle, children: spans),
    );
  }

  pw.Widget buildLine({
    required List<_Piece> pieces,
    required Map<String, dynamic>? attrs,
  }) {
    final align = parseAlign(attrs);
    final indentLevel = parseIndent(attrs);
    final listType = attrs?['list'] as String?;
    final isQuote = attrs?['blockquote'] == true;
    final isCodeBlock = attrs?['code-block'] == true;

    final headerRaw = attrs?['header'];
    int headerLevel = 0;
    if (headerRaw is int) headerLevel = headerRaw;
    if (headerRaw is num) headerLevel = headerRaw.toInt();

    final baseStyle =
        isCodeBlock
            ? codeTextStyle()
            : (headerLevel > 0
                ? headerStyle(headerLevel)
                : pw.TextStyle(
                  font: fontKr,
                  fontFallback: [fontJp],
                  fontSize: 12,
                  height: 1.6,
                  color: kTextColor,
                ));

    // ✅ 텍스트는 “자기 영역”에서 align만으로 정렬 (PNG와 동일)
    pw.Widget text = pw.Container(
      width: double.infinity,
      child: buildInlineLine(
        pieces: pieces,
        align: align,
        baseStyle: baseStyle,
        forceCodeStyle: isCodeBlock,
      ),
    );

    // indent 적용 (줄 전체)
    final leftPad = indentLevel * 14.0;

    // ✅ 리스트면: 마커는 고정 위치, 텍스트는 마커폭 만큼 밀고 정렬
    if (listType != null) {
      final marker = buildMarker(listType: listType, indentLevel: indentLevel);
      final markerBoxWidth = (listType == 'ordered') ? 22.0 : 18.0;

      // 마커가 첫 줄과 대충 맞게 보이도록 아주 약간만 내림(필요 시 1~3 조절)
      const double markerTop = 1.5;

      text = pw.Stack(
        children: [
          // 1) 텍스트 영역 (마커폭만큼 왼쪽 패딩)
          pw.Padding(
            padding: pw.EdgeInsets.only(left: leftPad + markerBoxWidth),
            child: text,
          ),

          // 2) 마커 (고정 위치)
          pw.Positioned(
            left: leftPad,
            top: markerTop,
            child: pw.Container(width: markerBoxWidth, child: marker),
          ),
        ],
      );

      // quote는 아래에서 공통으로 감싸니까 여기서는 return 하지 않음
    } else {
      // 리스트 아니면 기존처럼 leftPad만 적용
      text = pw.Padding(
        padding: pw.EdgeInsets.only(left: leftPad),
        child: text,
      );
    }

    // blockquote (전체 줄을 감싸기)
    if (isQuote) {
      text = pw.Container(
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            left: pw.BorderSide(width: 2.0, color: kQuoteBorderColor),
          ),
        ),
        padding: const pw.EdgeInsets.only(left: 10.0),
        child: text,
      );
    }

    // justify는 width infinity 유지가 중요
    if (align == pw.TextAlign.justify) {
      return pw.Container(width: double.infinity, child: text);
    }

    return pw.Container(width: double.infinity, child: text);
  }

  void flushCodeBlockIfAny() {
    if (codeLinesBuf.isEmpty) return;

    final codeWidgets = <pw.Widget>[
      for (final line in codeLinesBuf)
        buildInlineLine(
          pieces: line,
          align: pw.TextAlign.left,
          baseStyle: codeTextStyle(),
          forceCodeStyle: true,
        ),
    ];

    out.add(
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: pw.BoxDecoration(
          color: kCodeBg,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: kCodeBorder, width: 0.8),
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
    final isCodeBlock = blockAttrs?['code-block'] == true;

    if (isCodeBlock) {
      // code-block은 버퍼에 누적
      if (linePieces.isEmpty) {
        // 빈 code line도 줄 유지 (원하면 제거 가능)
        codeLinesBuf.add(const <_Piece>[]);
      } else {
        codeLinesBuf.add(List<_Piece>.from(linePieces));
      }
      linePieces.clear();
      return;
    }

    // code-block이 끝나는 순간 박스 출력
    flushCodeBlockIfAny();

    // 빈 줄도 간격 유지
    if (linePieces.isEmpty) {
      out.add(pw.SizedBox(height: 10));
      return;
    }

    out.add(
      buildLine(pieces: List<_Piece>.from(linePieces), attrs: blockAttrs),
    );
    out.add(pw.SizedBox(height: 6));
    linePieces.clear();
  }

  Future<void> absorbTextPart(
    String textPart,
    Map<String, dynamic>? attrs,
  ) async {
    if (textPart.isEmpty) return;

    final bg = parseHexColor(attrs?['background']);
    final style = inlineStyle(attrs);
    final String? link =
        (attrs?['link'] is String) ? attrs!['link'] as String : null;

    final text = _sanitizeUtf16(textPart);

    for (final c in text.characters) {
      if (_isEmojiCluster(c)) {
        final e = await _loadEmojiPng(c);
        linePieces.add(
          _Piece(
            text: e == null ? c : null,
            emoji: e,
            style: style,
            link: link,
            bg: bg,
          ),
        );
      } else {
        linePieces.add(_Piece(text: c, style: style, link: link, bg: bg));
      }
    }
  }

  // ========= 메인 루프 =========
  for (final op in delta) {
    final insert = op['insert'];
    final attrs = (op['attributes'] as Map?)?.cast<String, dynamic>();

    if (insert is String && insert == '\n') {
      // 블록 속성은 개행에서 확정
      if (attrs != null && attrs.isNotEmpty && hasBlockKeys(attrs)) {
        currentBlockAttrs = attrs;
      } else {
        // ✅ 왼쪽 정렬(= align 제거) 같은 “속성 없음” 케이스면 이전 값 유지하지 말고 초기화
        currentBlockAttrs = null;
      }

      flushLine(currentBlockAttrs);
      continue;
    }

    // (B) 문자열 insert: 1번 방식으로 split('\n') 커버
    if (insert is String) {
      final parts = _sanitizeUtf16(insert).split('\n');

      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];

        // 텍스트 누적
        await absorbTextPart(part, attrs);

        if (i != parts.length - 1) {
          if (attrs != null && attrs.isNotEmpty && hasBlockKeys(attrs)) {
            currentBlockAttrs = attrs;
          } else {
            // ✅ 여기서도 동일하게 초기화
            currentBlockAttrs = null;
          }

          flushLine(currentBlockAttrs);
        }
      }
      continue;
    }

    // (C) 이미지 insert
    if (insert is Map && insert.containsKey('image')) {
      // code-block 끝 처리
      flushCodeBlockIfAny();

      if (linePieces.isNotEmpty) {
        flushLine(currentBlockAttrs);
      }

      final source = _normalizeImageSource(insert['image']);
      if (source == null || source.isEmpty) continue;

      final bytes = await _loadImageBytes(source);
      if (bytes == null || bytes.isEmpty) continue;

      out.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 12),
          child: pw.Align(
            alignment: () {
              final a = currentBlockAttrs?['align'];
              if (a == 'center') return pw.Alignment.center;
              if (a == 'right' || a == 'end') return pw.Alignment.centerRight;
              return pw.Alignment.centerLeft;
            }(),
            child: pw.Container(
              constraints: const pw.BoxConstraints(maxWidth: 420),
              child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
            ),
          ),
        ),
      );
      continue;
    }
  }

  // 마지막 줄 처리
  if (linePieces.isNotEmpty) {
    flushLine(currentBlockAttrs);
  }
  flushCodeBlockIfAny();

  return out;
}
