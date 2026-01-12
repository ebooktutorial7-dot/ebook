// canvas_doc_engine.dart

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Settings to paginate a "document chunk" into multiple pages.
@immutable
class CanvasDocSettings {
  const CanvasDocSettings({
    required this.baseStyle,
    required this.contentWidth,
    required this.contentHeight,
    required this.imageSizes,
    required this.maxImageHeight,
  });

  final TextStyle baseStyle;
  final double contentWidth;
  final double contentHeight;

  /// image src -> original image size (width/height in px).
  final Map<String, Size> imageSizes;

  /// Clamp image draw height.
  final double maxImageHeight;
}

/// Result: one page contains draw commands in order.
class CanvasPagePlan {
  final List<CanvasDrawCommand> commands;
  CanvasPagePlan({required this.commands});
}

sealed class CanvasDrawCommand {
  Future<void> paint({
    required Canvas canvas,
    required Offset origin,
    required Future<ui.Image?> Function(String src, {int? targetWidthPx})
    loadImage,
    required double maxImageHeight,
    required double renderScale,
  });
}

/// Core engine.
class CanvasDocEngine {
  CanvasDocEngine(this.settings);

  final CanvasDocSettings settings;

  final Map<int, double> _sliceHeightCache = <int, double>{};

  static const String _zwsp = '\u200B';
  static const String _urlBreakAfterChars = r'/:?&=#._-~%+@';
  static const int _hardTokenGraphemeThreshold = 28;
  static const int _hardTokenInsertEvery = 8;

  // -----------------------------
  // Public
  // -----------------------------
  Future<List<CanvasPagePlan>> paginateDelta(
    List<Map<String, dynamic>> deltaJson,
  ) async {
    _sliceHeightCache.clear();

    final blocks = _DeltaParser().parse(deltaJson);
    final pages = <CanvasPagePlan>[];

    var current = CanvasPagePlan(commands: []);
    double y = 0;

    int orderedCounter = 0;
    bool inOrderedList = false;

    void newPage() {
      pages.add(current);
      current = CanvasPagePlan(commands: []);
      y = 0;
    }

    for (final b in blocks) {
      // NOTE: delta chunks are already split by page_break outside
      // (DeltaPageBreakSplitter in book_builder_page.dart), but we keep support anyway.

      if (b is _TitleBlock) {
        final titleStyle = settings.baseStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.2,
        );

        final tp = TextPainter(
          text: TextSpan(text: b.text, style: titleStyle),
          textDirection: TextDirection.ltr,
          textWidthBasis: TextWidthBasis.parent,
        )..layout(maxWidth: settings.contentWidth);

        final titleH = tp.height;
        const gapAfter = 10.0;
        final blockH = titleH + gapAfter;

        if (y + blockH > settings.contentHeight && y > 0) newPage();

        current.commands.add(
          CanvasTitleDrawCommand(y: y, text: b.text, style: titleStyle),
        );

        y += blockH;
        continue;
      }

      if (b is _PageBreakBlock) {
        if (current.commands.isNotEmpty) {
          newPage();
        } else {
          y = 0;
        }
        inOrderedList = false;
        orderedCounter = 0;
        continue;
      }

      if (b is _ChapterTitleBlock) {
        final titleStyle = settings.baseStyle.copyWith(
          fontSize: 16.5,
          fontWeight: FontWeight.w800,
          height: 1.25,
        );

        final tp = TextPainter(
          text: TextSpan(text: b.text, style: titleStyle),
          textDirection: TextDirection.ltr,
          textWidthBasis: TextWidthBasis.parent,
        )..layout(maxWidth: settings.contentWidth);

        final h = tp.height + 12;
        if (y + h > settings.contentHeight && y > 0) newPage();

        current.commands.add(
          CanvasTitleDrawCommand(y: y, text: b.text, style: titleStyle),
        );
        y += h;
        continue;
      }

      // ---------------- HR ----------------
      if (b is _HrBlock) {
        inOrderedList = false;
        orderedCounter = 0;

        const double padV = 2.0;
        const double solidBoxH = 7.0;
        const double dashedBoxH = 7.0;
        final double boxH = b.solid ? solidBoxH : dashedBoxH;
        final double blockH = padV + boxH + padV;
        final double lineYInsideBox = boxH / 2.0;

        if (y + blockH > settings.contentHeight && y > 0) newPage();

        current.commands.add(
          CanvasHrDrawCommand(
            y: y + padV + lineYInsideBox,
            solid: b.solid,
            width: settings.contentWidth,
          ),
        );

        y += blockH;
        continue;
      }

      // ---------------- IMAGE ----------------
      if (b is _ImageBlock) {
        inOrderedList = false;
        orderedCounter = 0;

        double reservedH = math.min(settings.contentHeight * 0.45, 320.0);

        final sz = settings.imageSizes[b.src];
        if (sz != null && sz.width > 0 && sz.height > 0) {
          final scale = settings.contentWidth / sz.width;
          double drawH = sz.height * scale;
          if (drawH > settings.maxImageHeight) drawH = settings.maxImageHeight;
          reservedH = drawH;
        }

        if (y + reservedH > settings.contentHeight && y > 0) newPage();

        current.commands.add(
          CanvasImageDrawCommand(
            y: y,
            src: b.src,
            width: settings.contentWidth,
          ),
        );

        y += reservedH + 10;
        continue;
      }

      // ---------------- PARAGRAPH ----------------
      if (b is _ParagraphBlock) {
        String? markerText;

        if (b.style.listType == ListType.ordered) {
          final isEmpty = _isEmptyParagraphBlock(b);

          if (!inOrderedList) {
            inOrderedList = true;
            orderedCounter = 0;
          }
          if (!isEmpty) {
            orderedCounter += 1;
            markerText = '$orderedCounter.';
          }
        } else if (b.style.listType == ListType.bullet) {
          inOrderedList = false;
          orderedCounter = 0;

          final isEmpty = _isEmptyParagraphBlock(b);
          markerText = isEmpty ? null : '•';
        } else {
          inOrderedList = false;
          orderedCounter = 0;
        }

        final pad = BlockPadding.of(b.style);
        final innerW = math.max(
          0.0,
          settings.contentWidth - pad.left - pad.right,
        );
        final paraStyle = _BlockTextStyle.of(settings.baseStyle, b.style);

        final slices = _buildSlicesFromBlock(b).toList(growable: true);

        int cursor = 0;
        bool isContinuation = false;

        while (cursor < slices.length) {
          final decoTop = pad.topDecoration;
          final decoBottom = pad.bottomDecoration;

          final available =
              settings.contentHeight - y - decoTop - decoBottom - 0.5;

          if (available <= 8) {
            newPage();
            continue;
          }

          final pageSlices = <LineSlice>[];
          double usedH = 0;

          while (cursor < slices.length) {
            final s = slices[cursor];
            final h = _measureSliceHeight(s, paraStyle, innerW);

            if (pageSlices.isNotEmpty && usedH + h > available) break;
            if (pageSlices.isEmpty && h > available) break;

            pageSlices.add(s);
            usedH += h;
            cursor++;
          }

          if (pageSlices.isEmpty && y > 0) {
            newPage();
            continue;
          }

          if (pageSlices.isEmpty && cursor < slices.length) {
            // Single giant line: split by line metrics
            final s = slices[cursor];

            final tp = _buildTextPainterForRuns(s.runs, paraStyle, s.align);
            tp.layout(maxWidth: innerW);

            final canUse =
                (settings.contentHeight - decoTop - decoBottom - 0.5);
            int cut = _cutOffsetByLineMetrics(tp, canUse, innerW);
            if (cut <= 0) cut = 1;

            final flatText = s.runs.map((e) => e.text).join();
            cut = _snapCutToNiceBoundary(flatText, cut, lookBack: 32);
            if (cut <= 0) cut = 1;

            final split = _RunSplitter.split(s.runs, cut);
            final headRuns = split.$1;
            final tailRuns = _trimLeadingWhitespaceRuns(split.$2);

            current.commands.add(
              CanvasParagraphDrawCommand(
                y: y,
                lines: [LineSlice(runs: headRuns, align: s.align)],
                baseStyle: paraStyle,
                blockStyle: b.style,
                width: innerW,
                padding: pad,
                markerText: isContinuation ? null : markerText,
                isListContinuation: isContinuation,
              ),
            );
            newPage();

            if (tailRuns.isNotEmpty) {
              slices[cursor] = LineSlice(runs: tailRuns, align: s.align);
              markerText = null;
              isContinuation = true;
              continue;
            } else {
              cursor++;
              markerText = null;
              isContinuation = true;
              continue;
            }
          }

          current.commands.add(
            CanvasParagraphDrawCommand(
              y: y,
              lines: pageSlices,
              baseStyle: paraStyle,
              blockStyle: b.style,
              width: innerW,
              padding: pad,
              markerText: isContinuation ? null : markerText,
              isListContinuation: isContinuation,
            ),
          );

          y += decoTop + usedH + decoBottom;

          if (cursor < slices.length) {
            newPage();
            markerText = null;
            isContinuation = true;
          }
        }

        y += _BlockSpacing.of(b.style);
        continue;
      }
    }

    if (current.commands.isNotEmpty || pages.isEmpty) {
      pages.add(current);
    }

    return pages.isEmpty ? [CanvasPagePlan(commands: [])] : pages;
  }

  // -----------------------------
  // Soft wrap / measure utils (ported)
  // -----------------------------
  bool _isWhitespaceChar(String ch) => RegExp(r'\s').hasMatch(ch);

  String _stripZwsp(String s) => s.replaceAll(_zwsp, '');

  bool _looksLikeUrl(String token) {
    final t = token.toLowerCase();
    return t.startsWith('http://') ||
        t.startsWith('https://') ||
        t.startsWith('www.') ||
        t.contains('://');
  }

  String _softWrapToken(String token) {
    token = _stripZwsp(token);
    if (token.isEmpty) return token;

    final chars = token.characters;
    final gCount = chars.length;

    if (_looksLikeUrl(token)) {
      final out = StringBuffer();
      for (final g in chars) {
        out.write(g);
        if (g.length == 1 && _urlBreakAfterChars.contains(g)) {
          out.write(_zwsp);
        }
      }
      return out.toString();
    }

    if (gCount >= _hardTokenGraphemeThreshold) {
      final out = StringBuffer();
      int i = 0;
      for (final g in chars) {
        out.write(g);
        i++;
        if (i % _hardTokenInsertEvery == 0) out.write(_zwsp);
      }
      return out.toString();
    }

    return token;
  }

  List<Run> _softWrapRuns(List<Run> runs) {
    final out = <Run>[];

    for (final r in runs) {
      final raw = _stripZwsp(r.text);

      if (raw.length < _hardTokenGraphemeThreshold) {
        out.add(r.text == raw ? r : Run(text: raw, inline: r.inline));
        continue;
      }

      final buf = StringBuffer();
      final sb = StringBuffer();

      void flushToken() {
        if (sb.isEmpty) return;
        final token = sb.toString();
        sb.clear();
        buf.write(_softWrapToken(token));
      }

      for (final g in raw.characters) {
        if (_isWhitespaceChar(g)) {
          flushToken();
          buf.write(g);
        } else {
          sb.write(g);
        }
      }
      flushToken();

      final cooked = buf.toString();
      out.add(cooked == r.text ? r : Run(text: cooked, inline: r.inline));
    }

    return out;
  }

  int _sliceMeasureKey(LineSlice s, TextStyle baseStyle, double innerW) {
    int h = Object.hash(
      baseStyle.fontSize,
      baseStyle.height,
      baseStyle.letterSpacing,
      baseStyle.fontFamily,
      baseStyle.fontWeight,
      s.align,
      (innerW * 10).round(),
    );

    for (final r in s.runs) {
      h = Object.hash(
        h,
        r.text,
        r.inline.bold,
        r.inline.italic,
        r.inline.underline,
        r.inline.strike,
        r.inline.color?.toARGB32(),
        r.inline.background?.toARGB32(),
        r.inline.sizePt,
      );
    }
    return h;
  }

  TextPainter _buildTextPainterForRuns(
    List<Run> runs,
    TextStyle base,
    TextAlign align,
  ) {
    final spans = <InlineSpan>[
      for (final r in runs)
        TextSpan(text: _sanitizeUtf16(r.text), style: r.inline.applyTo(base)),
    ];

    return TextPainter(
      text: TextSpan(children: spans),
      textAlign: align,
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.parent,
    );
  }

  double _measureSliceHeight(LineSlice s, TextStyle baseStyle, double innerW) {
    final key = _sliceMeasureKey(s, baseStyle, innerW);
    final cached = _sliceHeightCache[key];
    if (cached != null) return cached;

    final tp = _buildTextPainterForRuns(s.runs, baseStyle, s.align);
    tp.layout(maxWidth: innerW);

    double h = tp.height;

    if (h <= 0.1) {
      final fs = baseStyle.fontSize ?? 14.0;
      final lh = (baseStyle.height ?? 1.0);
      h = (fs * lh);
    }

    _sliceHeightCache[key] = h;
    return h;
  }

  List<LineSlice> _buildSlicesFromBlock(_ParagraphBlock b) {
    final out = <LineSlice>[];
    for (final line in b.lines) {
      final cookedRuns = _softWrapRuns(line.runs);
      out.add(LineSlice(runs: cookedRuns, align: line.style.align));
    }
    return out;
  }

  bool _isEmptyParagraphBlock(_ParagraphBlock b) {
    final buf = StringBuffer();
    for (final line in b.lines) {
      for (final r in line.runs) {
        buf.write(r.text);
      }
      buf.write('\n');
    }
    final s = buf.toString().replaceAll('\n', '').trim();
    return s.isEmpty;
  }

  int _cutOffsetByLineMetrics(
    TextPainter tp,
    double available,
    double maxWidth,
  ) {
    final lines = tp.computeLineMetrics();
    if (lines.isEmpty) return 0;

    double used = 0;
    int lastFullLine = -1;

    for (int i = 0; i < lines.length; i++) {
      final lm = lines[i];
      final next = used + lm.height;
      if (next <= available) {
        used = next;
        lastFullLine = i;
      } else {
        break;
      }
    }

    if (lastFullLine < 0) return 0;

    final lm = lines[lastFullLine];
    final descent = (lm.descent.isFinite && lm.descent > 0) ? lm.descent : 2.0;

    final safeY = (used - descent - 1.0).clamp(0.0, available);
    final safeX = math.max(0.0, maxWidth - 4);

    final pos = tp.getPositionForOffset(Offset(safeX, safeY));
    return pos.offset;
  }

  int _snapCutToNiceBoundary(String text, int cutOffset, {int lookBack = 48}) {
    if (cutOffset <= 0) return 0;
    if (text.isEmpty) return cutOffset;
    if (cutOffset > text.length) cutOffset = text.length;

    bool isWhitespace(String ch) => RegExp(r'\s').hasMatch(ch) || ch == _zwsp;

    bool isPunct(String ch) {
      const punct = '.,!?;:…·。！？、)]}’”"\'—–-';
      return punct.contains(ch);
    }

    final start = math.max(0, cutOffset - lookBack);
    for (int i = cutOffset - 1; i >= start; i--) {
      final ch = text[i];
      if (isWhitespace(ch)) return i;
      if (isPunct(ch)) return i + 1;
    }
    return cutOffset;
  }

  List<Run> _trimLeadingWhitespaceRuns(List<Run> runs) {
    final out = <Run>[];
    bool trimming = true;

    for (final r in runs) {
      if (!trimming) {
        out.add(r);
        continue;
      }

      final s = r.text;
      final trimmed = s.replaceFirst(RegExp(r'^[\s\u200B]+'), '');

      if (trimmed.isEmpty) continue;

      out.add(Run(text: trimmed, inline: r.inline));
      trimming = false;
    }

    return out;
  }
}

/// =======================================================
/// Draw commands
/// =======================================================

class CanvasTitleDrawCommand extends CanvasDrawCommand {
  CanvasTitleDrawCommand({
    required this.y,
    required this.text,
    required this.style,
  });
  final double y;
  final String text;
  final TextStyle style;

  @override
  Future<void> paint({
    required Canvas canvas,
    required Offset origin,
    required Future<ui.Image?> Function(String src, {int? targetWidthPx})
    loadImage,
    required double maxImageHeight,
    required double renderScale,
  }) async {
    final tp = TextPainter(
      text: TextSpan(text: _sanitizeUtf16(text), style: style),
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.parent,
    )..layout();
    tp.paint(canvas, Offset(origin.dx, origin.dy + y));
  }
}

class CanvasParagraphDrawCommand extends CanvasDrawCommand {
  CanvasParagraphDrawCommand({
    required this.y,
    required this.lines,
    required this.baseStyle,
    required this.blockStyle,
    required this.width,
    required this.padding,
    this.markerText,
    this.isListContinuation = false,
  });

  final double y;
  final List<LineSlice> lines;
  final TextStyle baseStyle;
  final BlockStyle blockStyle;
  final double width;
  final BlockPadding padding;
  final String? markerText;
  final bool isListContinuation;

  List<_PreparedLine>? _prepared;
  double? _totalHCache;
  double? _firstVisibleFontSizeCache;

  void _prepareIfNeeded() {
    if (_prepared != null) return;

    final prepared = <_PreparedLine>[];
    double totalH = 0;

    for (final line in lines) {
      final span = TextSpan(
        children: [
          for (final r in line.runs)
            TextSpan(
              text: _sanitizeUtf16(r.text),
              style: r.inline.applyTo(baseStyle),
            ),
        ],
      );

      final tp = TextPainter(
        text: span,
        textAlign: line.align,
        textDirection: TextDirection.ltr,
        textWidthBasis: TextWidthBasis.parent,
      )..layout(maxWidth: width);

      double h = tp.height;
      final visible = line.runs.any(
        (r) => r.text.replaceAll('\n', '').trim().isNotEmpty,
      );

      if (h <= 0.1) {
        final fs = baseStyle.fontSize ?? 14.0;
        final lh = (baseStyle.height ?? 1.0);
        h = fs * lh;
      }

      prepared.add(
        _PreparedLine(tp: tp, height: h, visible: visible, align: line.align),
      );
      totalH += h;
    }

    _prepared = prepared;
    _totalHCache = totalH;
    _firstVisibleFontSizeCache = _computeFirstVisibleFontSize();
  }

  double _computeFirstVisibleFontSize() {
    for (final line in lines) {
      for (final r in line.runs) {
        final trimmed = r.text.replaceAll('\n', '').trim();
        if (trimmed.isEmpty) continue;

        final fs = r.inline.applyTo(baseStyle).fontSize;
        if (fs != null && fs.isFinite && fs > 0) return fs;
      }
    }
    return baseStyle.fontSize ?? 14.0;
  }

  double _markerFontSizeForBlock({
    required double textFontSize,
    required BlockStyle blockStyle,
  }) {
    double scale = 0.95;
    if (blockStyle.header >= 1) scale = 0.80;
    if (blockStyle.codeBlock) scale = 0.92;
    return (textFontSize * scale).clamp(10.0, 42.0);
  }

  @override
  Future<void> paint({
    required Canvas canvas,
    required Offset origin,
    required Future<ui.Image?> Function(String src, {int? targetWidthPx})
    loadImage,
    required double maxImageHeight,
    required double renderScale,
  }) async {
    _prepareIfNeeded();
    final prepared = _prepared!;
    final totalH = _totalHCache ?? 0.0;

    final isList = blockStyle.listType != ListType.none;

    final y0 = origin.dy + y + padding.topDecoration;
    final contentW = width + padding.left + padding.right;

    // decoration rect
    final paraRect = Rect.fromLTWH(
      origin.dx,
      origin.dy + y,
      contentW,
      padding.topDecoration + totalH + padding.bottomDecoration,
    );
    padding.paintDecoration(canvas, paraRect);

    // list marker
    if (isList && !isListContinuation) {
      final marker =
          blockStyle.listType == ListType.bullet ? '•' : (markerText ?? '');
      if (marker.isNotEmpty) {
        final markerX = origin.dx + padding.listMarkerX;
        final baseFs =
            _firstVisibleFontSizeCache ?? (baseStyle.fontSize ?? 14.0);
        final markerFs = _markerFontSizeForBlock(
          textFontSize: baseFs,
          blockStyle: blockStyle,
        );

        double lineTop = y0;
        int firstVisibleIdx = -1;
        for (int i = 0; i < prepared.length; i++) {
          if (prepared[i].visible) {
            firstVisibleIdx = i;
            break;
          }
          lineTop += prepared[i].height;
        }

        if (firstVisibleIdx != -1) {
          final markerY = lineTop + (markerFs * 0.12).clamp(1.0, 4.0);

          final markerStyle = baseStyle.copyWith(
            fontSize: markerFs,
            fontWeight: FontWeight.w700,
            height: 1.0,
          );

          final mtp = TextPainter(
            text: TextSpan(text: marker, style: markerStyle),
            textDirection: TextDirection.ltr,
            textWidthBasis: TextWidthBasis.parent,
          )..layout(maxWidth: math.max(12.0, padding.left));

          mtp.paint(canvas, Offset(markerX, markerY));
        }
      }
    }

    // text lines
    double dy = y0;
    final xBase = origin.dx + padding.left;

    for (int i = 0; i < prepared.length; i++) {
      final tp = prepared[i].tp;
      final align = prepared[i].align;

      double x = xBase;
      if (align == TextAlign.center) {
        x = xBase + (width - tp.width) / 2;
      } else if (align == TextAlign.right || align == TextAlign.end) {
        x = xBase + (width - tp.width);
      }

      if (!x.isFinite) x = xBase;
      tp.paint(canvas, Offset(x, dy));
      dy += prepared[i].height;
    }
  }
}

class CanvasHrDrawCommand extends CanvasDrawCommand {
  CanvasHrDrawCommand({
    required this.y,
    required this.solid,
    required this.width,
  });
  final double y;
  final bool solid;
  final double width;

  @override
  Future<void> paint({
    required Canvas canvas,
    required Offset origin,
    required Future<ui.Image?> Function(String src, {int? targetWidthPx})
    loadImage,
    required double maxImageHeight,
    required double renderScale,
  }) async {
    final paint =
        Paint()
          ..color = const Color.fromARGB(255, 129, 147, 182)
          ..strokeWidth = solid ? 0.5 : 0.35
          ..style = PaintingStyle.stroke;

    final start = Offset(origin.dx, origin.dy + y);
    final end = Offset(origin.dx + width, origin.dy + y);

    if (solid) {
      canvas.drawLine(start, end, paint);
    } else {
      const dashW = 4.0;
      const dashS = 3.0;
      double x = start.dx;
      while (x < end.dx) {
        final x2 = math.min(x + dashW, end.dx);
        canvas.drawLine(Offset(x, start.dy), Offset(x2, start.dy), paint);
        x += dashW + dashS;
      }
    }
  }
}

class CanvasImageDrawCommand extends CanvasDrawCommand {
  CanvasImageDrawCommand({
    required this.y,
    required this.src,
    required this.width,
  });
  final double y;
  final String src;
  final double width;

  @override
  Future<void> paint({
    required Canvas canvas,
    required Offset origin,
    required Future<ui.Image?> Function(String src, {int? targetWidthPx})
    loadImage,
    required double maxImageHeight,
    required double renderScale,
  }) async {
    final int targetPx = (width * renderScale).round().clamp(64, 4096);
    final ui.Image? img = await loadImage(src, targetWidthPx: targetPx);
    if (img == null) return;

    final double iw = img.width.toDouble();
    final double ih = img.height.toDouble();

    double drawW = width;
    double drawH = ih * (width / iw);

    if (drawH > maxImageHeight) {
      final double s = maxImageHeight / drawH;
      drawH = maxImageHeight;
      drawW = drawW * s;
    }

    final double dx = origin.dx + (width - drawW) / 2;
    final double dy = origin.dy + y;

    final Rect dst = Rect.fromLTWH(dx, dy, drawW, drawH);
    final Rect srcRect = Rect.fromLTWH(0, 0, iw, ih);

    final paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImageRect(img, srcRect, dst, paint);
  }
}

/// =======================================================
/// Delta -> blocks
/// =======================================================

class _DeltaParser {
  List<_Block> parse(List<Map<String, dynamic>> deltaJson) {
    final lines = <_Line>[];
    final currentRuns = <Run>[];

    void flushLine(Map<String, dynamic>? newlineAttrs) {
      final block = BlockStyle.fromDeltaAttrs(newlineAttrs ?? const {});
      lines.add(_Line(runs: List<Run>.from(currentRuns), style: block));
      currentRuns.clear();
    }

    for (final op in deltaJson) {
      final insert = op['insert'];
      final attrs =
          (op['attributes'] is Map)
              ? Map<String, dynamic>.from(op['attributes'] as Map)
              : <String, dynamic>{};

      if (insert is String) {
        final parts = insert.split('\n');

        for (int i = 0; i < parts.length; i++) {
          final text = parts[i];

          if (text.isNotEmpty) {
            currentRuns.add(
              Run(text: text, inline: InlineStyle.fromDeltaAttrs(attrs)),
            );
          }

          if (i != parts.length - 1) {
            flushLine(attrs);
          }
        }
        continue;
      }

      if (insert is Map) {
        // both pageBreak (ppng.dart) and page_break (your splitter usage) support
        if (insert['pageBreak'] == true || insert['page_break'] == true) {
          if (currentRuns.isNotEmpty) flushLine(const {});
          lines.add(_Line.pageBreak());
          continue;
        }

        if (insert.containsKey('image')) {
          final src = insert['image'];
          if (src is String && src.isNotEmpty) {
            if (currentRuns.isNotEmpty) flushLine(const {});
            lines.add(_Line.image(src));
          }
          continue;
        }

        if (insert.containsKey('hr_solid')) {
          if (currentRuns.isNotEmpty) flushLine(const {});
          lines.add(_Line.hr(solid: true));
          continue;
        }

        if (insert.containsKey('hr')) {
          if (currentRuns.isNotEmpty) flushLine(const {});
          lines.add(_Line.hr(solid: false));
          continue;
        }

        if (insert.containsKey('chapterTitle')) {
          final v = insert['chapterTitle'];
          if (v is String && v.trim().isNotEmpty) {
            if (currentRuns.isNotEmpty) flushLine(const {});
            lines.add(_Line.chapterTitle(v.trim()));
          }
          continue;
        }

        if (insert.containsKey('title')) {
          final v = insert['title'];
          if (v is String && v.trim().isNotEmpty) {
            if (currentRuns.isNotEmpty) flushLine(const {});
            lines.add(_Line.title(v.trim()));
          }
          continue;
        }
      }
    }

    if (currentRuns.isNotEmpty) flushLine(const {});

    final blocks = <_Block>[];
    _ParagraphBlock? current;

    for (final l in lines) {
      if (l.kind == _LineKind.pageBreak) {
        current = null;
        blocks.add(_PageBreakBlock());
        continue;
      }

      if (l.kind == _LineKind.image) {
        current = null;
        blocks.add(_ImageBlock(l.imageSource!));
        continue;
      }

      if (l.kind == _LineKind.hr) {
        current = null;
        blocks.add(_HrBlock(solid: l.hrSolid ?? false));
        continue;
      }

      if (l.kind == _LineKind.chapterTitle) {
        current = null;
        blocks.add(_ChapterTitleBlock(l.chapterTitle!));
        continue;
      }

      if (l.kind == _LineKind.title) {
        current = null;
        blocks.add(_TitleBlock(l.title!));
        continue;
      }

      final isListLine = l.style.listType != ListType.none;

      if (isListLine) {
        current = _ParagraphBlock(style: l.style);
        current.addLine(l);
        blocks.add(current);
        continue;
      }

      if (current == null || current.style != l.style) {
        current = _ParagraphBlock(style: l.style);
        blocks.add(current);
      }
      current.addLine(l);
    }

    if (blocks.isEmpty) blocks.add(_ParagraphBlock(style: const BlockStyle()));
    return blocks;
  }
}

enum _LineKind { text, image, hr, pageBreak, chapterTitle, title }

class LineSlice {
  final List<Run> runs;
  final TextAlign align;
  const LineSlice({required this.runs, required this.align});
}

class _Line {
  final _LineKind kind;
  final List<Run> runs;
  final BlockStyle style;

  final String? imageSource;
  final bool? hrSolid;
  final String? chapterTitle;
  final String? title;

  _Line({required this.runs, required this.style})
    : kind = _LineKind.text,
      imageSource = null,
      hrSolid = null,
      chapterTitle = null,
      title = null;

  _Line.image(this.imageSource)
    : kind = _LineKind.image,
      runs = const [],
      style = const BlockStyle(),
      hrSolid = null,
      chapterTitle = null,
      title = null;

  _Line.hr({required bool solid})
    : kind = _LineKind.hr,
      runs = const [],
      style = const BlockStyle(),
      imageSource = null,
      hrSolid = solid,
      chapterTitle = null,
      title = null;

  _Line.pageBreak()
    : kind = _LineKind.pageBreak,
      runs = const [],
      style = const BlockStyle(),
      imageSource = null,
      hrSolid = null,
      chapterTitle = null,
      title = null;

  _Line.chapterTitle(this.chapterTitle)
    : kind = _LineKind.chapterTitle,
      runs = const [],
      style = const BlockStyle(),
      imageSource = null,
      hrSolid = null,
      title = null;

  _Line.title(this.title)
    : kind = _LineKind.title,
      runs = const [],
      style = const BlockStyle(),
      imageSource = null,
      hrSolid = null,
      chapterTitle = null;
}

class Run {
  final String text;
  final InlineStyle inline;
  const Run({required this.text, required this.inline});
}

@immutable
class InlineStyle {
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strike;
  final Color? color;
  final Color? background;
  final double? sizePt;

  const InlineStyle({
    required this.bold,
    required this.italic,
    required this.underline,
    required this.strike,
    required this.color,
    required this.background,
    required this.sizePt,
  });

  static InlineStyle fromDeltaAttrs(Map<String, dynamic> attrs) {
    bool b(String k) => attrs[k] == true;

    Color? parseHex(String? v) {
      if (v == null) return null;
      final s = v.trim();
      if (!s.startsWith('#')) return null;
      final hex = s.substring(1);
      if (hex.length != 6) return null;
      final n = int.tryParse(hex, radix: 16);
      if (n == null) return null;
      return Color(0xFF000000 | n);
    }

    double? parseSize(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return InlineStyle(
      bold: b('bold'),
      italic: b('italic'),
      underline: b('underline'),
      strike: b('strike'),
      color: parseHex(attrs['color'] as String?),
      background: parseHex(attrs['background'] as String?),
      sizePt: parseSize(attrs['size']),
    );
  }

  TextStyle applyTo(TextStyle base) {
    return base.copyWith(
      fontWeight: bold ? FontWeight.w700 : base.fontWeight,
      fontStyle: italic ? FontStyle.italic : base.fontStyle,
      decoration: TextDecoration.combine([
        if (underline) TextDecoration.underline,
        if (strike) TextDecoration.lineThrough,
      ]),
      color: color ?? base.color,
      backgroundColor: background,
      fontSize: sizePt ?? base.fontSize,
    );
  }
}

@immutable
class BlockStyle {
  final int header;
  final TextAlign align;
  final int indent;
  final ListType listType;
  final bool blockQuote;
  final bool codeBlock;

  const BlockStyle({
    this.header = 0,
    this.align = TextAlign.left,
    this.indent = 0,
    this.listType = ListType.none,
    this.blockQuote = false,
    this.codeBlock = false,
  });

  static BlockStyle fromDeltaAttrs(Map<String, dynamic> attrs) {
    int header = 0;
    final h = attrs['header'];
    if (h is num) header = h.toInt();
    if (h is String) header = int.tryParse(h) ?? 0;

    TextAlign align = TextAlign.left;
    final a = attrs['align'];

    if (a == 'center') {
      align = TextAlign.center;
    } else if (a == 'right' || a == 'end') {
      align = TextAlign.right;
    } else if (a == 'justify') {
      align = TextAlign.justify;
    } else if (a == 'left' || a == 'start') {
      align = TextAlign.left;
    }

    int indent = 0;
    final ind = attrs['indent'];
    if (ind is num) indent = ind.toInt();
    if (ind is String) indent = int.tryParse(ind) ?? 0;

    ListType list = ListType.none;
    final l = attrs['list'];
    if (l == 'bullet') list = ListType.bullet;
    if (l == 'ordered') list = ListType.ordered;

    final bq = attrs['blockquote'] == true;
    final code = attrs['code-block'] == true;

    return BlockStyle(
      header: header,
      align: align,
      indent: indent,
      listType: list,
      blockQuote: bq,
      codeBlock: code,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BlockStyle &&
      other.header == header &&
      other.align == align &&
      other.indent == indent &&
      other.listType == listType &&
      other.blockQuote == blockQuote &&
      other.codeBlock == codeBlock;

  @override
  int get hashCode =>
      Object.hash(header, align, indent, listType, blockQuote, codeBlock);
}

enum ListType { none, bullet, ordered }

sealed class _Block {}

class _TitleBlock extends _Block {
  final String text;
  _TitleBlock(this.text);
}

class _ChapterTitleBlock extends _Block {
  final String text;
  _ChapterTitleBlock(this.text);
}

class _ParagraphBlock extends _Block {
  final BlockStyle style;
  final List<_Line> lines = [];
  _ParagraphBlock({required this.style});
  void addLine(_Line l) => lines.add(l);
}

class _ImageBlock extends _Block {
  final String src;
  _ImageBlock(this.src);
}

class _HrBlock extends _Block {
  final bool solid;
  _HrBlock({required this.solid});
}

class _PageBreakBlock extends _Block {
  _PageBreakBlock();
}

/// =======================================================
/// Block padding / style / run splitting
/// =======================================================

class BlockPadding {
  final double left;
  final double right;
  final double topDecoration;
  final double bottomDecoration;

  final bool quote;
  final bool code;
  final ListType list;
  final int indent;

  const BlockPadding({
    required this.left,
    required this.right,
    required this.topDecoration,
    required this.bottomDecoration,
    required this.quote,
    required this.code,
    required this.list,
    required this.indent,
  });

  static BlockPadding of(BlockStyle s) {
    final baseIndent = 14.0 * s.indent;

    double headerLeftIndent = 0;
    if (s.header == 2) headerLeftIndent = 6;
    if (s.header == 3) headerLeftIndent = 10;

    double left = baseIndent + headerLeftIndent;
    double right = 0;

    if (s.listType != ListType.none) left += 22;

    final quote = s.blockQuote;
    final code = s.codeBlock;

    double headerTop = 0, headerBottom = 0;
    if (s.header == 1) {
      headerTop = 24;
      headerBottom = 10;
    }
    if (s.header == 2) {
      headerTop = 14;
      headerBottom = 7;
    }
    if (s.header == 3) {
      headerTop = 10;
      headerBottom = 6;
    }

    double topDeco = headerTop;
    double bottomDeco = headerBottom;

    if (quote || code) {
      topDeco += 8;
      bottomDeco += 8;
    }

    if (quote) {
      left += 16;
      right += 6;
    }

    if (code) {
      left += 12;
      right += 12;
    }

    return BlockPadding(
      left: left,
      right: right,
      topDecoration: topDeco,
      bottomDecoration: bottomDeco,
      quote: quote,
      code: code,
      list: s.listType,
      indent: s.indent,
    );
  }

  double get listMarkerX => (left - 18).clamp(0, 10000);

  void paintDecoration(Canvas canvas, Rect paragraphRect) {
    if (!quote && !code) return;

    if (code) {
      final r = RRect.fromRectAndRadius(
        paragraphRect,
        const Radius.circular(10),
      );
      final paint = Paint()..color = const Color.fromARGB(40, 120, 140, 160);
      canvas.drawRRect(r, paint);
    }

    if (quote) {
      final barPaint =
          Paint()
            ..color = const Color.fromARGB(255, 171, 193, 217)
            ..strokeWidth = 3.0
            ..style = PaintingStyle.stroke;

      final x = paragraphRect.left + 6;
      canvas.drawLine(
        Offset(x, paragraphRect.top + 6),
        Offset(x, paragraphRect.bottom - 6),
        barPaint,
      );
    }
  }
}

class _BlockTextStyle {
  static TextStyle of(TextStyle base, BlockStyle s) {
    double size = base.fontSize ?? 14;
    FontWeight? weight = base.fontWeight;

    if (s.header == 1) {
      size = 30;
      weight = FontWeight.w800;
    }
    if (s.header == 2) {
      size = 22;
      weight = FontWeight.w800;
    }
    if (s.header == 3) {
      size = 18;
      weight = FontWeight.w700;
    }

    final isCode = s.codeBlock;

    return base.copyWith(
      fontSize: size,
      fontWeight: (s.header > 0) ? weight : base.fontWeight,
      fontFamily: isCode ? (base.fontFamily ?? 'monospace') : base.fontFamily,
      fontFamilyFallback:
          isCode
              ? const [
                'SF Mono',
                'Menlo',
                'Courier New',
                'Roboto Mono',
                'monospace',
              ]
              : base.fontFamilyFallback,
      height: base.height,
    );
  }
}

class _BlockSpacing {
  static double of(BlockStyle s) {
    if (s.header > 0) return 0;
    if (s.blockQuote || s.codeBlock) return 6;
    return 4;
  }
}

class _PreparedLine {
  final TextPainter tp;
  final double height;
  final bool visible;
  final TextAlign align;
  const _PreparedLine({
    required this.tp,
    required this.height,
    required this.visible,
    required this.align,
  });
}

class _RunSplitter {
  static (List<Run>, List<Run>) split(List<Run> runs, int cutOffset) {
    if (cutOffset <= 0) return (<Run>[], List<Run>.from(runs));

    int remaining = cutOffset;
    final left = <Run>[];
    final right = <Run>[];

    for (final r in runs) {
      final len = r.text.length;
      if (remaining >= len) {
        left.add(r);
        remaining -= len;
      } else if (remaining <= 0) {
        right.add(r);
      } else {
        final a = r.text.substring(0, remaining);
        final b = r.text.substring(remaining);
        if (a.isNotEmpty) left.add(Run(text: a, inline: r.inline));
        if (b.isNotEmpty) right.add(Run(text: b, inline: r.inline));
        remaining = 0;
      }
    }

    return (left, right);
  }
}

/// =======================================================
/// UTF-16 safe text (same idea as ppng.dart)
/// =======================================================

String _sanitizeUtf16(String s) {
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
