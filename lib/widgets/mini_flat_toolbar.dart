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

import '../theme/glass_theme.dart';
import '../widgets/glass/glass_container.dart';

/// =============================================================
///  공통: 페이지네이션 트리거 (딜레이 + 최소 변경)
/// =============================================================

Timer? _paginationTimer;

/// 페이지 영향 있는 스타일 변경 후 이 함수만 호출하면 됨.
void schedulePagination(quill.QuillController c) {
  _paginationTimer?.cancel();
  _paginationTimer = Timer(const Duration(milliseconds: 120), () {
    final sel = c.selection;
    // controller.changes 를 확실히 발생시키는 최소 no-op
    c.replaceText(sel.baseOffset, 0, '', sel);
  });
}

/// 필요하면 바로 쓰고 싶을 때 호출 (지연 없이)
void triggerPaginationNow(quill.QuillController c) {
  final sel = c.selection;
  c.replaceText(sel.baseOffset, 0, '', sel);
}

/// =============================================================
///  MiniFlatToolbar
/// =============================================================

class MiniFlatToolbar extends StatelessWidget {
  final quill.QuillController controller;
  final GlassTheme theme;

  const MiniFlatToolbar({
    super.key,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final selectionStyle = controller.getSelectionStyle();
    final attrs = selectionStyle.attributes;

    bool isAttr(quill.Attribute a) => attrs.containsKey(a.key);

    // 기본 Splash 제거한 테마
    final ThemeData noSplash = Theme.of(context).copyWith(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
    );

    /// 공통 버튼 빌더
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
            schedulePagination(controller);
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
              // ----------------------------------------------------
              // 글자 크기 버튼 (행간/페이지에 영향 → 페이지네이션 필요)
              // ----------------------------------------------------
              _FontSizeButton(controller: controller, theme: theme),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 제목(헤더) 순환 — 레이아웃 영향 O
              // ----------------------------------------------------
              btn(
                const Icon(Icons.title),
                () {
                  final h = attrs[quill.Attribute.header.key]?.value as int?;
                  if (h == 1) {
                    controller.formatSelection(quill.Attribute.h2);
                  } else if (h == 2) {
                    controller.formatSelection(quill.Attribute.h3);
                  } else if (h == 3) {
                    controller.formatSelection(quill.Attribute.header);
                  } else {
                    controller.formatSelection(quill.Attribute.h1);
                  }
                },
                affectLayout: true,
                tooltip: '제목(순환)',
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // Bold — 레이아웃 영향 거의 없음
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_bold),
                () => controller.formatSelection(quill.Attribute.bold),
                selected: isAttr(quill.Attribute.bold),
                affectLayout: false,
                tooltip: '굵게',
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 글자색 — 레이아웃 영향 거의 없음 (필요시만 pagination)
              // ----------------------------------------------------
              _ColorButton(
                controller: controller,
                forBackground: false,
                icon: Icons.format_color_text,
                tooltip: '글자 색상',
                onChanged: () {
                  // 색상 변경으로 줄바꿈이 달라지는 경우는 드물어서
                  // 꼭 필요할 때만 유지하고 싶으면 주석처리 가능
                  // schedulePagination(controller);
                },
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 배경색 — 레이아웃 영향 거의 없음
              // ----------------------------------------------------
              _ColorButton(
                controller: controller,
                forBackground: true,
                icon: Icons.format_color_fill,
                tooltip: '하이라이트',
                onChanged: () {
                  // 필요시만
                  // schedulePagination(controller);
                },
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
              // 정렬 순환 — 레이아웃 영향 O
              // ----------------------------------------------------
              _AlignCycleButton(
                controller: controller,
                onChanged: () => schedulePagination(controller),
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // Italic — 영향 거의 없음
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_italic),
                () => controller.formatSelection(quill.Attribute.italic),
                selected: isAttr(quill.Attribute.italic),
                affectLayout: false,
                tooltip: '기울임',
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 밑줄 — 영향 거의 없음
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_underline),
                () => controller.formatSelection(quill.Attribute.underline),
                selected: isAttr(quill.Attribute.underline),
                affectLayout: false,
                tooltip: '밑줄',
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 취소선 — 영향 거의 없음
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_strikethrough),
                () => controller.formatSelection(quill.Attribute.strikeThrough),
                selected: isAttr(quill.Attribute.strikeThrough),
                affectLayout: false,
                tooltip: '취소선',
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 번호 목록 — 레이아웃 영향 O
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_list_numbered),
                () => controller.formatSelection(quill.Attribute.ol),
                selected: isAttr(quill.Attribute.ol),
                affectLayout: true,
                tooltip: '번호 목록',
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 글머리 목록 — 레이아웃 영향 O
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_list_bulleted),
                () => controller.formatSelection(quill.Attribute.ul),
                selected: isAttr(quill.Attribute.ul),
                affectLayout: true,
                tooltip: '글머리 목록',
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 인용문 — 레이아웃 영향 O
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_quote),
                () {
                  final isQuote = attrs.containsKey(
                    quill.Attribute.blockQuote.key,
                  );
                  const bq = quill.Attribute.blockQuote;
                  final remove = quill.Attribute(bq.key, bq.scope, null);
                  controller.formatSelection(isQuote ? remove : bq);
                },
                selected: isAttr(quill.Attribute.blockQuote),
                affectLayout: true,
                tooltip: '인용문',
              ),
              const SizedBox(width: 7),

              // ----------------------------------------------------
              // 서식 초기화 — 레이아웃 영향 O
              // ----------------------------------------------------
              btn(
                const Icon(Icons.format_clear),
                () => _clearFormats(controller),
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
///  글자 크기 버튼 (Overlay + Provider 연동)
/// =============================================================

class _FontSizeButton extends StatefulWidget {
  final quill.QuillController controller;
  final GlassTheme theme;

  const _FontSizeButton({required this.controller, required this.theme});

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
            // 뒷배경 클릭 → 닫기
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
                              // 선택 영역에 size 적용
                              widget.controller.formatSelection(
                                quill.Attribute(
                                  'size',
                                  quill.AttributeScope.inline,
                                  _FontSizeButton._sizes[i],
                                ),
                              );

                              // Provider에 기본 폰트 사이즈 반영
                              final sizePt =
                                  double.tryParse(_FontSizeButton._sizes[i]) ??
                                  16.0;
                              final ws =
                                  context.read<WritingSettingsController>();
                              ws.updateFontSize(sizePt);

                              schedulePagination(widget.controller);
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

                            schedulePagination(widget.controller);
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
///  Color Button (텍스트/배경색 + Provider 연동)
/// =============================================================

class _ColorButton extends StatelessWidget {
  final quill.QuillController controller;
  final bool forBackground;
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onChanged; // 필요시 페이지네이션

  const _ColorButton({
    required this.controller,
    required this.forBackground,
    required this.icon,
    this.tooltip,
    this.onChanged,
  });

  static const _palette = <Color>[
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18, color: Colors.black87),
      tooltip: tooltip,
      onPressed: () async {
        final ws = context.read<WritingSettingsController>();

        final picked = await showModalBottomSheet<Color?>(
          context: context,
          backgroundColor: Colors.white,
          showDragHandle: true,
          builder: (ctx) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final c in _palette)
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx, c),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: forBackground ? c : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: c.withValues(alpha: 0.5)),
                          ),
                          child:
                              forBackground
                                  ? null
                                  : Center(
                                    child: Icon(
                                      Icons.circle,
                                      size: 16,
                                      color: c,
                                    ),
                                  ),
                        ),
                      ),
                    TextButton.icon(
                      onPressed:
                          () => Navigator.pop(ctx, const Color(0x00000000)),
                      icon: const Icon(Icons.block),
                      label: const Text('해제'),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (picked == null) return;

        final bool isTransparent = picked.a == 0;

        String? hex;
        if (!isTransparent) {
          final int r = (picked.r * 255.0).round() & 0xff;
          final int g = (picked.g * 255.0).round() & 0xff;
          final int b = (picked.b * 255.0).round() & 0xff;

          hex =
              '#'
              '${r.toRadixString(16).padLeft(2, "0")}'
              '${g.toRadixString(16).padLeft(2, "0")}'
              '${b.toRadixString(16).padLeft(2, "0")}';
        }

        final baseAttr =
            forBackground ? quill.Attribute.background : quill.Attribute.color;

        controller.formatSelection(
          quill.Attribute(baseAttr.key, baseAttr.scope, hex),
        );

        if (!forBackground) {
          if (isTransparent) {
            ws.resetTextColorToThemeDefault();
          } else {
            ws.updateTextColor(picked);
          }
        }

        onChanged?.call();
      },
    );
  }
}

/// =============================================================
///  정렬 순환 버튼
/// =============================================================

class _AlignCycleButton extends StatelessWidget {
  final quill.QuillController controller;
  final VoidCallback? onChanged;

  const _AlignCycleButton({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final attrs = controller.getSelectionStyle().attributes;
    String? align = attrs[quill.Attribute.align.key]?.value as String?;

    Icon icon = const Icon(Icons.format_align_left);
    if (align == 'center') {
      icon = const Icon(Icons.format_align_center);
    } else if (align == 'right') {
      icon = const Icon(Icons.format_align_right);
    }

    return IconButton(
      icon: icon,
      onPressed: () {
        final cur =
            controller
                    .getSelectionStyle()
                    .attributes[quill.Attribute.align.key]
                    ?.value
                as String?;
        if (cur == null) {
          controller.formatSelection(quill.Attribute.centerAlignment);
        } else if (cur == 'center') {
          controller.formatSelection(quill.Attribute.rightAlignment);
        } else {
          const alignAttr = quill.Attribute.align;
          controller.formatSelection(
            quill.Attribute(alignAttr.key, alignAttr.scope, null),
          );
        }

        onChanged?.call();
      },
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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

  if (m.containsKey('script')) {
    toUnset.add(
      const quill.Attribute('script', quill.AttributeScope.inline, null),
    );
  }

  for (final a in toUnset) {
    c.formatSelection(a);
  }

  schedulePagination(c);
}

/// =============================================================
///  이미지 + HR 삽입 공통 코드
/// =============================================================

Future<ui.Image> _loadUiImage(File file) async {
  final bytes = await file.readAsBytes();
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(bytes, completer.complete);
  return completer.future;
}

/// HR 공통 삽입
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

  schedulePagination(c);
}

void _insertSolidHrNextLine(quill.QuillController c) =>
    _insertEmbedNextLine(c, embedKey: 'hr_solid');

void _insertDashedHrNextLine(quill.QuillController c) =>
    _insertEmbedNextLine(c, embedKey: 'hr');

/// 이미지 삽입
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
  } catch (_) {
    // 해상도 체크 실패해도 그냥 진행
  }

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

  schedulePagination(c);
}

/// =============================================================
///  이미지 선택 팝업
/// =============================================================

enum _ImageMenuAction { camera, gallery, cancel }

Future<void> _showImageMenu(
  BuildContext context,
  quill.QuillController c,
) async {
  final overlay = Overlay.maybeOf(context);
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

  final _ImageMenuAction? result = await showMenu<_ImageMenuAction>(
    context: context,
    position: position,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color.fromARGB(255, 171, 193, 217)),
    ),
    items: const [
      PopupMenuItem(
        value: _ImageMenuAction.camera,
        child: Center(
          child: Text(
            '카메라로 촬영',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      PopupMenuItem(
        value: _ImageMenuAction.gallery,
        child: Center(
          child: Text(
            '앨범에서 선택',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      PopupMenuItem(
        value: _ImageMenuAction.cancel,
        child: Center(
          child: Text(
            '취소',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 34, 78, 140),
            ),
          ),
        ),
      ),
    ],
  );

  if (result == null || result == _ImageMenuAction.cancel) return;

  final ImageSource source =
      result == _ImageMenuAction.camera
          ? ImageSource.camera
          : ImageSource.gallery;

  await _insertImageFromSource(c, source);
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
