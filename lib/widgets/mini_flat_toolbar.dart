// mini
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dart_quill_delta/dart_quill_delta.dart' as dq;
import 'package:ebook_tutorial_app/controllers/writing_settings_controller.dart';
import 'package:ebook_tutorial_app/models/writing_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../theme/glass_theme.dart';
import '../widgets/glass/glass_container.dart';

String _aarrggbbFromColor(Color c) {
  final a = ((c.a) * 255.0).round().clamp(0, 255);
  final r = ((c.r) * 255.0).round().clamp(0, 255);
  final g = ((c.g) * 255.0).round().clamp(0, 255);
  final b = ((c.b) * 255.0).round().clamp(0, 255);

  String h(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();
  return '#${h(a)}${h(r)}${h(g)}${h(b)}';
}

bool _hasAttr(quill.QuillController c, quill.Attribute a) {
  return c.getSelectionStyle().attributes.containsKey(a.key);
}

bool _clearedRecently = false;

const String kBgAlphaKey = 'bgAlpha';

void toggleInlineAttr(
  quill.QuillController c,
  quill.Attribute attr, {
  Object? enableValue,
}) {
  final attrs = c.getSelectionStyle().attributes;
  final key = attr.key;
  final scope = attr.scope;
  final has = attrs.containsKey(key);

  if (has) {
    c.formatSelection(quill.Attribute(key, scope, null));
  } else {
    final v = enableValue ?? attr.value ?? true;
    c.formatSelection(quill.Attribute(key, scope, v));
  }
}

void _toggleExclusiveInline(
  quill.QuillController c, {
  required quill.Attribute mine,
  required quill.Attribute other,
}) {
  final attrs = c.getSelectionStyle().attributes;

  final mineOn = attrs.containsKey(mine.key);
  final otherOn = attrs.containsKey(other.key);

  if (mineOn) {
    c.formatSelection(quill.Attribute(mine.key, mine.scope, null));
  } else {
    if (otherOn) {
      c.formatSelection(quill.Attribute(other.key, other.scope, null));
    }
    c.formatSelection(mine);
  }
}

void toggleBlockAttr(quill.QuillController c, quill.Attribute attr) {
  final attrs = c.getSelectionStyle().attributes;
  final key = attr.key;
  final scope = attr.scope;
  final has = attrs.containsKey(key);

  if (has) {
    c.formatSelection(quill.Attribute(key, scope, null));
  } else {
    c.formatSelection(attr);
  }
}

void cycleAlign(quill.QuillController c) {
  final cur =
      c.getSelectionStyle().attributes[quill.Attribute.align.key]?.value
          as String?;

  if (cur == null) {
    c.formatSelection(quill.Attribute.centerAlignment);
  } else if (cur == 'center') {
    c.formatSelection(quill.Attribute.rightAlignment);
  } else {
    const a = quill.Attribute.align;
    c.formatSelection(quill.Attribute(a.key, a.scope, null));
  }
}

void setExclusiveList(quill.QuillController c, {required bool ordered}) {
  final other = ordered ? quill.Attribute.ul : quill.Attribute.ol;
  c.formatSelection(quill.Attribute(other.key, other.scope, null));
  final mine = ordered ? quill.Attribute.ol : quill.Attribute.ul;
  toggleBlockAttr(c, mine);
}

void cycleHeader(quill.QuillController c, {required bool clearedRecently}) {
  const size = quill.Attribute.size;
  c.formatSelection(quill.Attribute(size.key, size.scope, null));
  if (clearedRecently) {
    c.formatSelection(
      const quill.Attribute('color', quill.AttributeScope.inline, '#000000'),
    );
  }
  final cur =
      c.getSelectionStyle().attributes[quill.Attribute.header.key]?.value
          as int?;

  if (cur == null) {
    c.formatSelection(quill.Attribute.h1);
  } else if (cur == 1) {
    c.formatSelection(quill.Attribute.h2);
  } else if (cur == 2) {
    c.formatSelection(quill.Attribute.h3);
  } else {
    const a = quill.Attribute.header;
    c.formatSelection(quill.Attribute(a.key, a.scope, null));
  }
}

Timer? _layoutRefreshTimer;

void scheduleLayoutRefresh(VoidCallback? onChanged) {
  _layoutRefreshTimer?.cancel();
  _layoutRefreshTimer = Timer(const Duration(milliseconds: 120), () {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChanged?.call();
    });
  });
}

/// =============================================================
///  MiniFlatToolbar
/// =============================================================

class MiniFlatToolbar extends StatelessWidget {
  final quill.QuillController controller;
  final GlassTheme theme;
  final VoidCallback? onLayoutChanged;
  final VoidCallback? onMicTap;
  final bool isListening;

  const MiniFlatToolbar({
    super.key,
    required this.controller,
    required this.theme,
    this.onLayoutChanged,
    this.onMicTap,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData noSplash = Theme.of(context).copyWith(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      colorScheme: Theme.of(
        context,
      ).colorScheme.copyWith(primary: Colors.black),
    );

    Widget btn(
      Widget icon,
      VoidCallback onTap, {
      bool selected = false,
      String? tooltip,
      bool affectLayout = false,
    }) {
      final color = selected ? Colors.black : Colors.black87;
      return IconButton(
        onPressed: () {
          onTap();
          if (affectLayout) {
            scheduleLayoutRefresh(onLayoutChanged);
          }
        },

        icon: IconTheme.merge(
          data: IconThemeData(size: 18, color: color),
          child: icon,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        tooltip: tooltip,
      );
    }

    return Theme(
      data: noSplash,
      child: SizedBox(
        height: 40,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              if (onMicTap != null) ...[
                IconButton(
                  tooltip: isListening ? '음성 입력 중지' : '음성 입력',
                  onPressed: onMicTap,
                  icon: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    size: 18,
                    color: isListening ? Colors.redAccent : Colors.black87,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                const SizedBox(width: 7),

                IconButton(
                  tooltip: '실행 취소',
                  onPressed:
                      controller.hasUndo
                          ? () {
                            controller.undo();
                            onLayoutChanged?.call();
                          }
                          : null,
                  icon: Icon(
                    Icons.undo,
                    size: 18,
                    color: controller.hasUndo ? Colors.black87 : Colors.black26,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                const SizedBox(width: 7),

                IconButton(
                  tooltip: '다시 실행',
                  onPressed:
                      controller.hasRedo
                          ? () {
                            controller.redo();
                            onLayoutChanged?.call();
                          }
                          : null,
                  icon: Icon(
                    Icons.redo,
                    size: 18,
                    color: controller.hasRedo ? Colors.black87 : Colors.black26,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                const SizedBox(width: 7),
              ],

              // ----------------------------------------------------
              // 글자 크기 버튼 (행간/페이지에 영향 → 페이지네이션 필요)
              // ----------------------------------------------------
              _FontSizeButton(
                controller: controller,
                theme: theme,
                onLayoutChanged: onLayoutChanged,
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 제목(헤더) — 레이아웃 영향 O
              // ----------------------------------------------------
              btn(
                const Icon(Icons.title),
                () {
                  cycleHeader(controller, clearedRecently: _clearedRecently);
                  _clearedRecently = false;
                },
                affectLayout: true,
                tooltip: 'H1',
              ),

              const SizedBox(width: 7),

              // ----------------------------------------------------
              // Bold — 레이아웃 영향 거의 없음
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_bold),
                () => toggleInlineAttr(controller, quill.Attribute.bold),
                selected: _hasAttr(controller, quill.Attribute.bold),
                affectLayout: false,
                tooltip: '굵게',
              ),

              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 글자색 — 레이아웃 영향 거의 없음 (필요시만 pagination)
              // ----------------------------------------------------
              _ColorButton(
                controller: controller,
                theme: theme,
                forBackground: false,
                icon: Icons.format_color_text,
                tooltip: '글자 색상',
                onChanged: () {},
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 배경색 — 레이아웃 영향 거의 없음
              // ----------------------------------------------------
              _ColorButton(
                controller: controller,
                theme: theme,
                forBackground: true,
                icon: Icons.format_color_fill,
                tooltip: '하이라이트',
                onChanged: () {},
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 기본(솔리드) HR — 레이아웃 영향 O
              // ----------------------------------------------------
              btn(
                const Icon(Icons.horizontal_rule),
                () => _insertSolidHrNextLine(controller),
                affectLayout: true,
                tooltip: '구분선(기본)',
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 점선 HR — 레이아웃 영향 O
              // ----------------------------------------------------
              btn(
                const Icon(Icons.more_horiz),
                () => _insertDashedHrNextLine(controller),
                affectLayout: true,
                tooltip: '점선 구분선',
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 정렬 — 레이아웃 영향 O
              // ----------------------------------------------------
              Tooltip(
                message: '정렬',
                child: _AlignCycleButton(
                  controller: controller,
                  onChanged: () {
                    onLayoutChanged?.call();
                  },
                ),
              ),

              const SizedBox(width: 7),

              // ----------------------------------------------------
              // Italic — 영향 거의 없음
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_italic),
                () => toggleInlineAttr(controller, quill.Attribute.italic),
                selected: _hasAttr(controller, quill.Attribute.italic),
                affectLayout: false,
                tooltip: '기울임',
              ),

              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 밑줄 — 영향 거의 없음
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_underline),
                () => _toggleExclusiveInline(
                  controller,
                  mine: quill.Attribute.underline,
                  other: quill.Attribute.strikeThrough,
                ),
                selected: _hasAttr(controller, quill.Attribute.underline),
                tooltip: '밑줄',
              ),

              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 취소선
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_strikethrough),
                () => _toggleExclusiveInline(
                  controller,
                  mine: quill.Attribute.strikeThrough,
                  other: quill.Attribute.underline,
                ),
                selected: _hasAttr(controller, quill.Attribute.strikeThrough),
                tooltip: '취소선',
              ),

              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 번호 목록 — 레이아웃 영향 O
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_list_numbered),
                () => setExclusiveList(controller, ordered: true),
                selected: _hasAttr(controller, quill.Attribute.ol),
                affectLayout: true,
                tooltip: '번호 목록',
              ),

              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 글머리 목록 — 레이아웃 영향 O
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_list_bulleted),
                () => setExclusiveList(controller, ordered: false),

                selected: _hasAttr(controller, quill.Attribute.ul),
                affectLayout: true,
                tooltip: '글머리 목록',
              ),

              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 인용문 — 레이아웃 영향 O
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_quote),
                () => toggleBlockAttr(controller, quill.Attribute.blockQuote),
                selected: _hasAttr(controller, quill.Attribute.blockQuote),
                affectLayout: true,
                tooltip: '인용문',
              ),

              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 서식 초기화 — 레이아웃 영향 O
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_clear),
                () {
                  _clearFormats(controller);
                  _clearedRecently = true;
                },
                affectLayout: true,
                tooltip: '서식 초기화',
              ),

              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 이미지 업로드 — 레이아웃 영향 O
              // ----------------------------------------------------
              Builder(
                builder: (buttonContext) {
                  return IconButton(
                    tooltip: '이미지 업로드',
                    onPressed: () => _showImageMenu(buttonContext, controller),
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 18,
                      color: Colors.black87,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =============================================================
///  글자 크기 버튼
/// =============================================================

class _FontSizeButton extends StatefulWidget {
  final quill.QuillController controller;
  final GlassTheme theme;
  final VoidCallback? onLayoutChanged;

  const _FontSizeButton({
    required this.controller,
    required this.theme,
    this.onLayoutChanged,
  });

  static const _sizes = <String>['7', '9', '11', '13', '15', '17', '20', '23'];

  @override
  State<_FontSizeButton> createState() => _FontSizeButtonState();
}

class _FontSizeButtonState extends State<_FontSizeButton> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  static const double kPopupWidth = 160;
  static const double kItemHeight = 42;
  static const double kVGap = 6;
  static const double kYOffset = 6;

  void _open() {
    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (context) {
        final bgColor =
            widget.theme.reduceTransparency
                ? Colors.blueGrey.shade50
                : Colors.white.withValues(alpha: widget.theme.surfaceOpacity);

        final borderColor = Colors.white.withValues(
          alpha: widget.theme.borderOpacity,
        );

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              offset: const Offset(0, kYOffset + 32),
              child: Material(
                color: Colors.transparent,
                child: GlassContainer(
                  theme: widget.theme,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: kPopupWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                            '글자 크기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        for (
                          int i = 0;
                          i < _FontSizeButton._sizes.length;
                          i++
                        ) ...[
                          _LiteListItem(
                            height: kItemHeight,
                            width: kPopupWidth,
                            label: '${_FontSizeButton._sizes[i]} pt',
                            bgColor: bgColor,
                            borderColor: borderColor,
                            onTap: () {
                              widget.controller.formatSelection(
                                quill.Attribute(
                                  'size',
                                  quill.AttributeScope.inline,
                                  _FontSizeButton._sizes[i],
                                ),
                              );

                              final sizePt =
                                  double.tryParse(_FontSizeButton._sizes[i]) ??
                                  16.0;
                              final ws =
                                  context.read<WritingSettingsController>();
                              ws.updateFontSize(sizePt);
                              scheduleLayoutRefresh(widget.onLayoutChanged);
                              _close();
                            },
                          ),
                          if (i != _FontSizeButton._sizes.length - 1)
                            const SizedBox(height: kVGap),
                        ],
                        const SizedBox(height: 8),
                        _LiteListItem(
                          height: kItemHeight,
                          width: kPopupWidth,
                          label: '크기 해제',
                          bgColor: bgColor,
                          borderColor: borderColor,
                          onTap: () {
                            const size = quill.Attribute.size;
                            widget.controller.formatSelection(
                              quill.Attribute(size.key, size.scope, null),
                            );

                            final ws =
                                context.read<WritingSettingsController>();
                            ws.updateFontSize(
                              WritingSettings.defaults().fontSize,
                            );
                            scheduleLayoutRefresh(widget.onLayoutChanged);
                            _close();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay != null) overlay.insert(_entry!);
  }

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: IconButton(
        tooltip: '글자 크기',
        onPressed: _open,
        icon: const Icon(Icons.format_size, size: 18, color: Colors.black87),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }
}

/// =============================================================
///  Color Button
/// =============================================================

class _ColorButton extends StatelessWidget {
  static Color _lastTextColor = const ui.Color.fromARGB(255, 183, 217, 248);
  static Color _lastBgColor = const ui.Color.fromARGB(255, 183, 217, 248);
  final quill.QuillController controller;
  final GlassTheme theme;
  final bool forBackground;
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onChanged;

  const _ColorButton({
    required this.controller,
    required this.theme,
    required this.forBackground,
    required this.icon,
    this.tooltip,
    this.onChanged,
  });

  Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final s = hex.replaceAll('#', '').trim();

    int? v = int.tryParse(s, radix: 16);
    if (v == null) return null;

    if (s.length == 6) {
      return Color(0xFF000000 | v);
    }
    if (s.length == 8) {
      return Color(v);
    }
    return null;
  }

  String _hexFromColor(Color c) {
    final int r = ((c.r) * 255.0).round() & 0xff;
    final int g = ((c.g) * 255.0).round() & 0xff;
    final int b = ((c.b) * 255.0).round() & 0xff;

    return '#'
        '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  Future<_ColorSheetResult> _showPrettyWheelBottomSheet(
    BuildContext context, {
    required String title,
    required GlassTheme theme,
    required Color initial,
    double wheelSize = 190,
  }) async {
    Color current = initial;

    return showModalBottomSheet<_ColorSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final sheetBorder = Colors.white.withValues(alpha: theme.borderOpacity);

        Widget handle() => Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );

        Widget inputCard(StateSetter setState) => Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: current,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12, width: 1),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _hexFromColor(current),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );

        Widget alphaCard(StateSetter setState) {
          final v = (current.a).clamp(0.0, 1.0);

          const double sliderW = 350;
          const double thumbR = 6;

          return Center(
            child: SizedBox(
              width: sliderW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: thumbR),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '투명도',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text('${(v * 100).round()}%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 1.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: thumbR,
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: v,
                      onChanged: (nv) {
                        final a = (nv * 255).round().clamp(0, 255);
                        setState(() => current = current.withAlpha(a));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        Widget wheelCard(StateSetter setState) => Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: SizedBox(
              width: wheelSize,
              height: wheelSize,
              child: ColorWheelPicker(
                color: current,
                onWheel: (_) {},
                onChanged: (c) => setState(() => current = c),
                wheelWidth: 18,
                wheelSquarePadding: 20,
                wheelSquareBorderRadius: 999,
                hasBorder: true,
                borderColor: Colors.black12,
              ),
            ),
          ),
        );

        Widget actions() => Row(
          children: [
            TextButton.icon(
              onPressed:
                  () => Navigator.pop(ctx, const _ColorSheetResult.clear()),
              icon: const Icon(Icons.block),
              label: const Text('해제'),
            ),
            const Spacer(),
            TextButton(
              onPressed:
                  () => Navigator.pop(ctx, const _ColorSheetResult.cancel()),
              child: const Text('취소'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1F3A56),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed:
                  () => Navigator.pop(ctx, _ColorSheetResult.apply(current)),
              child: const Text(
                '적용',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                decoration: BoxDecoration(
                  color: const ui.Color.fromARGB(70, 207, 232, 255),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  border: Border.all(color: sheetBorder, width: 1),
                ),
                child: StatefulBuilder(
                  builder: (ctx, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        handle(),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1F3A56),
                          ),
                        ),
                        const SizedBox(height: 10),
                        inputCard(setState),
                        const SizedBox(height: 10),
                        wheelCard(setState),
                        if (forBackground) ...[
                          const SizedBox(height: 15),
                          alphaCard(setState),
                        ],
                        const SizedBox(height: 15),
                        actions(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    ).then((v) => v ?? const _ColorSheetResult.cancel());
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18, color: Colors.black87),
      tooltip: tooltip,
      onPressed: () async {
        final attrs = controller.getSelectionStyle().attributes;
        final key =
            forBackground
                ? quill.Attribute.background.key
                : quill.Attribute.color.key;

        final curHex = attrs[key]?.value as String?;
        Color? curColor = _colorFromHex(curHex);

        if (forBackground &&
            curHex != null &&
            curHex.startsWith('#') &&
            curHex.length == 9) {
          curColor = _colorFromHex(curHex);
        } else if (forBackground && curColor != null) {
          final dynA = attrs[kBgAlphaKey]?.value;
          int a = 255;
          if (dynA is int) a = dynA.clamp(0, 255);
          if (dynA is num) a = dynA.toInt().clamp(0, 255);
          curColor = curColor.withAlpha(a);
        }

        final fallback =
            forBackground
                ? _ColorButton._lastBgColor
                : _ColorButton._lastTextColor;

        final result = await _showPrettyWheelBottomSheet(
          context,
          title: forBackground ? '배경 색' : '글자 색',
          theme: theme,
          initial: curColor ?? fallback,
          wheelSize: 190,
        );

        final baseAttr =
            forBackground ? quill.Attribute.background : quill.Attribute.color;

        if (result.kind == 0) return;

        if (result.kind == 1) {
          controller.formatSelection(
            quill.Attribute(baseAttr.key, baseAttr.scope, null),
          );

          if (forBackground) {
            controller.formatSelection(
              const quill.Attribute(
                kBgAlphaKey,
                quill.AttributeScope.inline,
                null,
              ),
            );
          }

          onChanged?.call();
          return;
        }

        final picked = result.color!;
        if (forBackground) {
          _ColorButton._lastBgColor = picked;
        } else {
          _ColorButton._lastTextColor = picked;
        }

        if (forBackground) {
          final aarrggbb = _aarrggbbFromColor(picked);

          controller.formatSelection(
            quill.Attribute(
              quill.Attribute.background.key,
              quill.Attribute.background.scope,
              aarrggbb,
            ),
          );

          controller.formatSelection(
            const quill.Attribute(
              kBgAlphaKey,
              quill.AttributeScope.inline,
              null,
            ),
          );
        } else {
          final hex = _hexFromColor(picked);
          controller.formatSelection(
            quill.Attribute(
              quill.Attribute.color.key,
              quill.Attribute.color.scope,
              hex,
            ),
          );
        }

        onChanged?.call();
      },
    );
  }
}

class _ColorSheetResult {
  final int kind;
  final Color? color;

  const _ColorSheetResult._(this.kind, this.color);

  const _ColorSheetResult.cancel() : this._(0, null);
  const _ColorSheetResult.clear() : this._(1, null);
  const _ColorSheetResult.apply(Color c) : this._(2, c);
}

/// =============================================================
///  정렬
/// =============================================================
class _AlignCycleButton extends StatelessWidget {
  final quill.QuillController controller;
  final VoidCallback? onChanged;

  const _AlignCycleButton({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final align =
        controller
                .getSelectionStyle()
                .attributes[quill.Attribute.align.key]
                ?.value
            as String?;

    const double kAlignIconSize = 19;

    Icon icon = const Icon(
      Icons.format_align_left,
      size: kAlignIconSize,
      color: Colors.black87,
    );

    if (align == 'center') {
      icon = const Icon(
        Icons.format_align_center,
        size: kAlignIconSize,
        color: Colors.black87,
      );
    } else if (align == 'right') {
      icon = const Icon(
        Icons.format_align_right,
        size: kAlignIconSize,
        color: Colors.black87,
      );
    }

    return IconButton(
      icon: icon,
      onPressed: () {
        cycleAlign(controller);
        onChanged?.call();
      },
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}

/// =============================================================
///  서식 초기화
/// =============================================================

void _clearFormats(quill.QuillController c) {
  final m = c.getSelectionStyle().attributes;
  final List<quill.Attribute> toUnset = [];

  void unset(quill.Attribute a) {
    toUnset.add(quill.Attribute(a.key, a.scope, null));
  }

  final attrsToCheck = <quill.Attribute>[
    quill.Attribute.bold,
    quill.Attribute.italic,
    quill.Attribute.underline,
    quill.Attribute.strikeThrough,
    quill.Attribute.color,
    quill.Attribute.background,
    quill.Attribute.size,
    quill.Attribute.header,
    quill.Attribute.align,
    quill.Attribute.blockQuote,
    quill.Attribute.codeBlock,
    quill.Attribute.ul,
    quill.Attribute.ol,
  ];

  for (final a in attrsToCheck) {
    if (m.containsKey(a.key)) unset(a);
  }
  if (m.containsKey(kBgAlphaKey)) {
    toUnset.add(
      const quill.Attribute(kBgAlphaKey, quill.AttributeScope.inline, null),
    );
  }
  if (m.containsKey('script')) {
    toUnset.add(
      const quill.Attribute('script', quill.AttributeScope.inline, null),
    );
  }

  for (final a in toUnset) {
    c.formatSelection(a);
  }
}

Future<ui.Image> _loadUiImage(File file) async {
  final bytes = await file.readAsBytes();
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(bytes, completer.complete);
  return completer.future;
}

void _insertEmbedNextLine(quill.QuillController c, {required String embedKey}) {
  final sel = c.selection;
  final cur = sel.isValid ? sel.end : c.document.length;

  final plain = c.document.toPlainText();
  final bool prevIsNewLine =
      (cur > 0 && cur <= plain.length && plain[cur - 1] == '\n');

  if (!prevIsNewLine) {
    c.updateSelection(
      TextSelection.collapsed(offset: cur),
      quill.ChangeSource.local,
    );
    c.replaceText(cur, 0, '\n', TextSelection.collapsed(offset: cur + 1));
  }

  final insertIndex = prevIsNewLine ? cur : cur + 1;

  final delta =
      dq.Delta()
        ..retain(insertIndex)
        ..insert({embedKey: true})
        ..insert('\n');

  c.compose(
    delta,
    const TextSelection.collapsed(offset: 0),
    quill.ChangeSource.local,
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final target = (insertIndex + 2).clamp(0, c.document.length);
    c.updateSelection(
      TextSelection.collapsed(offset: target),
      quill.ChangeSource.local,
    );
  });
}

void _insertSolidHrNextLine(quill.QuillController c) =>
    _insertEmbedNextLine(c, embedKey: 'hr_solid');

void _insertDashedHrNextLine(quill.QuillController c) =>
    _insertEmbedNextLine(c, embedKey: 'hr');

Future<void> _insertImageFromSource(
  quill.QuillController c,
  ImageSource source,
) async {
  final picker = ImagePicker();

  final XFile? picked = await picker.pickImage(
    source: source,
    maxWidth: 2048,
    imageQuality: 85,
  );

  if (picked == null) return;

  final tmpFile = File(picked.path);

  try {
    await _loadUiImage(tmpFile);
  } catch (_) {}

  try {
    final appDocDir = await getApplicationDocumentsDirectory();

    final fileName =
        'img_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';

    final savedPath = p.join(appDocDir.path, fileName);
    final savedFile = await tmpFile.copy(savedPath);

    final imagePath = savedFile.path;

    final selection = c.selection;
    final baseOffset =
        selection.isValid ? selection.baseOffset : c.document.length;
    final length =
        selection.isValid ? selection.extentOffset - selection.baseOffset : 0;

    final embed = quill.BlockEmbed.image(imagePath);

    c.replaceText(
      baseOffset,
      length,
      embed,
      TextSelection.collapsed(offset: baseOffset + 1),
    );
  } catch (e) {
    print('❌ 이미지 처리 오류: $e');
  }
}

/// =============================================================
///  이미지 선택 팝업
/// =============================================================

enum _ImageMenuAction { camera, gallery, cancel }

Future<void> _showImageMenu(
  BuildContext context,
  quill.QuillController c,
) async {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  final renderObject = context.findRenderObject();
  final overlayRenderObject = overlay.context.findRenderObject();

  if (renderObject is! RenderBox || overlayRenderObject is! RenderBox) {
    return;
  }

  final RenderBox buttonBox = renderObject;
  final RenderBox overlayBox = overlayRenderObject;

  final Offset buttonTopLeft = buttonBox.localToGlobal(
    Offset.zero,
    ancestor: overlayBox,
  );
  final Offset buttonBottomRight = buttonBox.localToGlobal(
    buttonBox.size.bottomRight(Offset.zero),
    ancestor: overlayBox,
  );

  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      Offset(buttonTopLeft.dx, buttonBottomRight.dy + 4),
      buttonBottomRight,
    ),
    Offset.zero & overlayBox.size,
  );

  final action = await _showAnchoredImagePopup(
    context: context,
    overlay: overlay,
    position: position,
  );

  if (action == null || action == _ImageMenuAction.cancel) return;

  final ImageSource source =
      action == _ImageMenuAction.camera
          ? ImageSource.camera
          : ImageSource.gallery;

  await _insertImageFromSource(c, source);
}

Future<_ImageMenuAction?> _showAnchoredImagePopup({
  required BuildContext context,
  required OverlayState overlay,
  required RelativeRect position,
}) async {
  final completer = Completer<_ImageMenuAction?>();

  const bg = Colors.white;
  const border = Color(0xFFE6ECF3);
  const ink = Color(0xFF1F3A56);
  const soft = Color(0xFFE9F7FF);

  const double popupW = 160;
  const double itemH = 45;
  const double pad = 12;
  const double gap = 7;

  const double popupH = (pad * 2) + (itemH * 2) + gap;

  const Color kPngDimColor = Color(0xFF0F2238);
  const double kPngDimAlpha = 0.16;

  late OverlayEntry entry;

  void close([_ImageMenuAction? value]) {
    if (!completer.isCompleted) completer.complete(value);
    entry.remove();
  }

  Widget item({
    required String label,
    required _ImageMenuAction value,
    bool isCancel = false,
  }) {
    final Color fill = isCancel ? Colors.white : soft;
    const Color textColor = ink;

    return SizedBox(
      height: itemH,
      width: popupW,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => close(value),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isCancel ? border : const Color(0xFFBFD7EE),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget closeX() {
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => close(_ImageMenuAction.cancel),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          borderRadius: BorderRadius.circular(10),
          child: const Center(child: Icon(Icons.close, size: 18, color: ink)),
        ),
      ),
    );
  }

  entry = OverlayEntry(
    builder: (ctx) {
      final Size overlaySize = MediaQuery.of(ctx).size;

      final double rawLeft = position.left;
      final double rawTop = position.top;

      final double left = rawLeft.clamp(8.0, overlaySize.width - popupW - 8.0);
      final double top = rawTop.clamp(8.0, overlaySize.height - popupH - 8.0);

      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => close(null),
              child: Container(
                color: kPngDimColor.withValues(alpha: kPngDimAlpha),
              ),
            ),
          ),

          Positioned(
            left: left,
            top: top,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: popupW,
                padding: const EdgeInsets.fromLTRB(pad, 8, pad, pad),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [const Spacer(), closeX()]),
                    const SizedBox(height: 6),
                    item(label: '카메라로 촬영', value: _ImageMenuAction.camera),
                    const SizedBox(height: gap),
                    item(label: '앨범에서 선택', value: _ImageMenuAction.gallery),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  overlay.insert(entry);
  return completer.future;
}

/// =============================================================
///  공용 리스트 아이템
/// =============================================================

class _LiteListItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double height;
  final double width;
  final Color bgColor;
  final Color borderColor;

  const _LiteListItem({
    required this.label,
    required this.onTap,
    required this.height,
    required this.width,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
