// chapter_write_page.dart

import 'dart:io';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';

import 'package:ebook_tutorial_app/quill/custom_leading.dart';

import 'package:ebook_tutorial_app/controllers/writing_settings_controller.dart';
import 'package:ebook_tutorial_app/widgets/mini_flat_toolbar.dart';
import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/utils/platform_accessibility.dart';
import 'package:ebook_tutorial_app/models/writing_settings.dart';

import 'package:ebook_tutorial_app/pages/png.dart';

class ChapterWritePage extends StatefulWidget {
  final String chapterTitle;
  final List<Map<String, dynamic>> initialDeltaJson;
  final bool enableGlass;
  final String? persistentKey;

  const ChapterWritePage({
    super.key,
    required this.chapterTitle,
    required this.initialDeltaJson,
    required this.enableGlass,
    this.persistentKey,
  });

  @override
  State<ChapterWritePage> createState() => _ChapterWritePageState();
}

class _ChapterWritePageState extends State<ChapterWritePage>
    with WidgetsBindingObserver {
  late quill.QuillController _controller;
  final _titleCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollCtrl = ScrollController();

  bool _reduceTransparencyFlag = false;

  int _pageCount = 1;
  int _currentPage = 1;
  int _pngRevision = 0; // ✅ PNG 강제 리빌드 트리거

  static const double _a4VerticalMargin = 18.0;
  double _a4PageStridePx = 1000;
  double _pngLikeContentHeightPx = 1000; // ✅ 현재 레이아웃 기준 contentHeight

  // ---- Persist/restore state ----
  double? _restoredOffset;
  bool _restoreTried = false;
  Timer? _saveDebounce;

  String get _baseKey =>
      widget.persistentKey ?? 'title_${widget.chapterTitle.hashCode}';
  String get _prefsKeyScroll => 'chapter_write_scroll_$_baseKey';
  String get _prefsKeySelection => 'chapter_write_selection_$_baseKey';
  String get _prefsKeyFocus => 'chapter_write_focus_$_baseKey';

  String? _resolveFontFamily(String key) {
    switch (key) {
      case 'batang':
        return 'Apple SD 산돌고딕 Neo';
      case 'inter':
        return 'inter';
      case 'system':
      default:
        return null; // 시스템 기본
    }
  }

  // ---- UI chrome show/hide ----
  bool _chromeVisible = true;
  static const _tapRevealZone = 56.0;

  bool _toolbarLocked = false;

  DateTime? _lastRevealTap;
  static const _doubleTapWindowMs = 350;

  DateTime? _lastTapAt;
  Offset? _lastTapPos;
  static const _doubleTapWindow = Duration(milliseconds: 280);
  static const _doubleTapMaxDistance = 20.0;

  bool _hadSelection = false;

  static const double _selectionSafeTop = 80.0;
  bool _nudgedForThisSelection = false;

  bool _isFocusWriting = false;

  GlassTheme get _glassTheme => GlassTheme.fromFlags(
    reduceTransparency: _reduceTransparencyFlag || !widget.enableGlass,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final safeInitialDelta = widget.initialDeltaJson
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: true);

    _controller = quill.QuillController(
      document: quill.Document.fromJson(safeInitialDelta),
      selection: const TextSelection.collapsed(offset: 0),
    );

    _titleCtrl.text = widget.chapterTitle;

    _initReduceTransparency();

    _controller.changes.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 스크롤 포지션 기준으로 pageCount 업데이트
        // (contentHeight는 LayoutBuilder에서 항상 최신값 유지)
        _recomputePaginationFromStoredHeight();
      });
      if (mounted) setState(() {});
      _saveSelectionDebounced();

      final sel = _controller.selection;
      if (!sel.isCollapsed) {
        _showAndLockToolbarDebounced();
      }
    });

    _controller.addListener(_onControllerChanged);
    _scrollCtrl.addListener(_handleScroll);
    _focusNode.addListener(_onFocusChanged);

    _loadSavedPosition();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recomputePaginationFromStoredHeight();
      _attemptRestoreScroll();
    });

    _applySystemUi();
    // ✅ 추가: 하드웨어 Enter 감지(빈 리스트면 종료)
    HardwareKeyboard.instance.addHandler(_handleHardwareEnterToExitList);
  }

  Color _backgroundColorFromSettings(WritingSettings s) {
    switch (s.themeId) {
      case 'dark':
        return const Color.fromARGB(255, 0, 0, 0);
      case 'darkGreen':
        return const Color.fromARGB(255, 10, 30, 26);
      case 'space': // 🌌 우주 테마 기본 배경
        return const Color(0xFF05081A);
      case 'lightSky': // 🌤
        return const Color(0xFF1E293B);
      default:
        return Colors.white;
    }
  }

  Color _textColorFromSettings(WritingSettings s) {
    switch (s.themeId) {
      case 'dark':
        return Colors.white.withValues(alpha: 0.92);
      case 'darkGreen':
        return Colors.white.withValues(alpha: 0.92);
      case 'space': // 🌌 우주 테마 텍스트
        return Colors.white.withValues(alpha: 0.96);
      case 'lightSky': // 🌤
        return const Color(0xFF1E293B); // 짙은 남색(가독성용)
      default:
        return Colors.black87;
    }
  }

  Widget _wrapEditorTheme({
    required BuildContext context,
    required Color primaryColor,
    required Widget child,
  }) {
    final base = Theme.of(context);
    final cupertino = CupertinoTheme.of(context);

    return CupertinoTheme(
      data: cupertino.copyWith(
        primaryColor: primaryColor, // ✅ iOS tint(리스트 마커 포함) 고정
      ),
      child: Theme(
        data: base.copyWith(
          primaryColor: primaryColor,
          colorScheme: base.colorScheme.copyWith(
            primary: primaryColor,
            secondary: primaryColor,
          ),

          // ✅ Tooltip
          tooltipTheme: const TooltipThemeData(
            preferBelow: true,
            verticalOffset: 12,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            margin: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Color.fromARGB(213, 158, 217, 246),
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
            waitDuration: Duration(milliseconds: 350),
            showDuration: Duration(milliseconds: 1200),
          ),
        ),
        child: child,
      ),
    );
  }

  Timer? _previewThrottle;

  void _jumpToPagePreview(int page) {
    if (!_scrollCtrl.hasClients) return;

    _previewThrottle?.cancel();
    _previewThrottle = Timer(const Duration(milliseconds: 40), () {
      if (!_scrollCtrl.hasClients) return;
      final pos = _scrollCtrl.position;

      final int clampedPage = page.clamp(1, _pageCount);
      final double desired = _a4PageStridePx * (clampedPage - 1);
      final double target = desired.clamp(0.0, pos.maxScrollExtent);

      _scrollCtrl.jumpTo(target);
    });
  }

  void _recomputePaginationFromStoredHeight() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;

    final contentHeight = _pngLikeContentHeightPx;
    final pages = _calcPageCountLikePng(pos, contentHeight);
    final current = _calcCurrentPageLikePng(pos, pages, contentHeight);

    setState(() {
      _pageCount = pages;
      _currentPage = current;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onControllerChanged);
    _focusNode.removeListener(_onFocusChanged);

    _saveDebounce?.cancel();

    _persistScroll();
    _persistSelection();
    _persistFocus();

    HardwareKeyboard.instance.removeHandler(_handleHardwareEnterToExitList);

    _controller.dispose();
    _titleCtrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _persistScroll();
      _persistSelection();
      _persistFocus();
    }
  }

  Future<void> _initReduceTransparency() async {
    final flag = await PlatformAccessibility.getReduceTransparencyFlag();
    if (!mounted) return;
    setState(() => _reduceTransparencyFlag = flag);
  }

  // ---- Persist ----
  Future<void> _loadSavedPosition() async {
    final prefs = await SharedPreferences.getInstance();
    _restoredOffset = prefs.getDouble(_prefsKeyScroll);
    final sel = prefs.getInt(_prefsKeySelection);
    if (sel != null) {
      final max = _controller.document.toPlainText().length;
      final clamped = sel.clamp(0, max);
      _controller.updateSelection(
        TextSelection.collapsed(offset: clamped),
        quill.ChangeSource.local,
      );
    }
  }

  void _attemptRestoreScroll() {
    if (_restoreTried) return;
    if (!_scrollCtrl.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _attemptRestoreScroll(),
      );
      return;
    }
    if (_restoredOffset == null) {
      _restoreTried = true;
      return;
    }
    final pos = _scrollCtrl.position;
    final target = _restoredOffset!.clamp(0.0, pos.maxScrollExtent);
    _scrollCtrl.jumpTo(target);
    _restoreTried = true;
  }

  void _saveScrollDebounced() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 350), _persistScroll);
  }

  Future<void> _persistScroll() async {
    if (!_scrollCtrl.hasClients) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsKeyScroll, _scrollCtrl.position.pixels);
  }

  void _saveSelectionDebounced() {
    Future<void>.delayed(const Duration(milliseconds: 200), _persistSelection);
  }

  Future<void> _persistSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKeySelection, _controller.selection.baseOffset);
  }

  Future<void> _persistFocus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyFocus, _isFocusWriting);
  }

  void _save() {
    final delta = _controller.document.toDelta().toJson();

    // ✅ 결과도 복사해서 넘기면 다음 페이지에서 add/수정해도 안전
    final safeDeltaJson = List<Map<String, dynamic>>.from(
      delta.map((e) => Map<String, dynamic>.from(e as Map)),
    );

    final result = {'title': _titleCtrl.text.trim(), 'delta': safeDeltaJson};

    Navigator.of(context).pop(result);
  }

  // ---- 선택 시 툴바 노출 ----
  void _showAndLockToolbarDebounced() {
    if (_isFocusWriting) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_controller.selection.isCollapsed) {
        if (!_chromeVisible) {
          _setChromeVisible(true);
        } else {
          setState(() => _chromeVisible = true);
        }
        if (!_toolbarLocked) setState(() => _toolbarLocked = true);
      }
    });
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      if (!_controller.selection.isCollapsed) {
        if (!_chromeVisible) {
          _setChromeVisible(true);
        } else {
          setState(() => _chromeVisible = true);
        }
        if (!_toolbarLocked) setState(() => _toolbarLocked = true);
      }
    });
  }

  void _onControllerChanged() {
    final sel = _controller.selection;
    final bool hasSelection = sel.baseOffset != sel.extentOffset;

    if (hasSelection && !_hadSelection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final stillSelected =
            _controller.selection.baseOffset !=
            _controller.selection.extentOffset;
        if (stillSelected) {
          if (!_isFocusWriting) {
            if (!_chromeVisible) _setChromeVisible(true);
            setState(() => _toolbarLocked = true);
          }
        }
      });

      Future.delayed(const Duration(milliseconds: 180), () {
        if (!mounted) return;
        final stillSelected =
            _controller.selection.baseOffset !=
            _controller.selection.extentOffset;
        if (stillSelected) {
          if (!_isFocusWriting) {
            if (!_chromeVisible) _setChromeVisible(true);
            if (!_toolbarLocked) setState(() => _toolbarLocked = true);
          }
        }
      });
    }

    if (hasSelection) {
      final textLen = _controller.document.toPlainText().length;
      final isSelectAll = sel.baseOffset == 0 && sel.extentOffset == textLen;
      final startsAtTop = sel.baseOffset <= 1;

      if ((isSelectAll || startsAtTop) &&
          !_nudgedForThisSelection &&
          _scrollCtrl.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollCtrl.hasClients) return;
          final current = _scrollCtrl.position.pixels;
          if (current < _selectionSafeTop) {
            final target = _selectionSafeTop.clamp(
              0.0,
              _scrollCtrl.position.maxScrollExtent,
            );
            _scrollCtrl.animateTo(
              target,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
            );
          }
        });
        _nudgedForThisSelection = true;
      }
    } else {
      _nudgedForThisSelection = false;
    }

    _hadSelection = hasSelection;
    _applySystemUi();
  }

  void _setChromeVisible(bool visible) {
    if (_chromeVisible == visible) return;
    setState(() => _chromeVisible = visible);
    _applySystemUi();
  }

  void _revealChrome() => _setChromeVisible(true);

  void _onTapRevealZone() {
    if (_isFocusWriting) return;
    final now = DateTime.now();
    final isDoubleTap =
        _lastRevealTap != null &&
        now.difference(_lastRevealTap!).inMilliseconds < _doubleTapWindowMs;

    if (isDoubleTap) {
      setState(() {
        _toolbarLocked = !_toolbarLocked;
        _chromeVisible = true;
      });
      _applySystemUi();
    } else {
      if (!_toolbarLocked) _revealChrome();
    }
    _lastRevealTap = now;
  }

  bool _handleDoubleTapForToolbar(TapDownDetails details) {
    final now = DateTime.now();
    final pos = details.globalPosition;

    final isTimeClose =
        _lastTapAt != null && now.difference(_lastTapAt!) <= _doubleTapWindow;
    final isSpaceClose =
        _lastTapPos != null &&
        (pos - _lastTapPos!).distance <= _doubleTapMaxDistance;

    _lastTapAt = now;
    _lastTapPos = pos;

    final isDouble = isTimeClose && isSpaceClose;

    if (isDouble) {
      if (_isFocusWriting) {
        _exitFocusWritingMode();
        setState(() => _toolbarLocked = true);
      } else if (_controller.selection.isCollapsed) {
        if (!_chromeVisible) {
          _setChromeVisible(true);
        } else {
          setState(() => _chromeVisible = true);
        }
        if (!_toolbarLocked) setState(() => _toolbarLocked = true);
      }
    }
    return isDouble;
  }

  void _onFocusChanged() => _applySystemUi();

  Future<void> _applySystemUi() async {
    final bool wantImmersive = _isFocusWriting;

    if (wantImmersive) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  // ✅ flutter_quill 11.5.0 호환: HorizontalSpacing/VerticalSpacing는 positional 2개만 받음
  quill.DefaultTextBlockStyle _headerBlockStyle({
    required quill.DefaultTextBlockStyle base,
    required WritingSettings settings,
    required String? fontFamily,

    // 제목 크기/굵기
    required double fontSize,
    required FontWeight fontWeight,

    // 여백/들여쓰기(간접 구현)
    required double vTop,
    required double vBottom,
    required double hMargin, // 좌/우 여백
    required double leftIndent, // 블록 전체 왼쪽으로 더 밀기(=left spacing에 더함)
  }) {
    return quill.DefaultTextBlockStyle(
      base.style.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: settings.lineHeight,
        letterSpacing: settings.letterSpacing,
        fontFamily: fontFamily,
        color: null, // ✅ 테마 색상 상속
        decorationStyle: TextDecorationStyle.solid,
        decorationColor: _textColorFromSettings(settings), // ✅ 헤더에서도 방지
      ),
      // ✅ HorizontalSpacing(left, right)
      quill.HorizontalSpacing(hMargin + leftIndent, hMargin),
      // ✅ VerticalSpacing(top, bottom)
      quill.VerticalSpacing(vTop, vBottom),
      base.lineSpacing,
      base.decoration,
    );
  }

  void _toggleFocusWriting() {
    if (_isFocusWriting) {
      _exitFocusWritingMode();
    } else {
      _enterFocusWritingMode();
    }
    _persistFocus();
  }

  void _enterFocusWritingMode() {
    setState(() {
      _isFocusWriting = true;
      _toolbarLocked = false;
      _chromeVisible = false;
    });
    _focusNode.requestFocus();
    _applySystemUi();
  }

  void _exitFocusWritingMode() {
    setState(() {
      _isFocusWriting = false;
      _chromeVisible = true;
    });
    _applySystemUi();
  }

  double _calcPngLikeContentHeightPx(BoxConstraints constraints) {
    final pageWidth = constraints.maxWidth * 0.95; // ✅ PNG와 동일
    final pageHeight = pageWidth * 297 / 210;
    return pageHeight - (_a4VerticalMargin * 2); // ✅ verticalMargin=18과 일치
  }

  // ✅ PNG처럼 contentHeight로 페이지 수 계산
  int _calcPageCountLikePng(ScrollPosition pos, double contentHeight) {
    final total = pos.maxScrollExtent + pos.viewportDimension;
    return math.max(1, (total / contentHeight).ceil());
  }

  int _calcCurrentPageLikePng(
    ScrollPosition pos,
    int pages,
    double contentHeight,
  ) {
    final window = math.min(pos.viewportDimension, contentHeight);
    final end = pos.pixels + window;
    const eps = 1e-6;
    return (((end - eps) / contentHeight).floor() + 1).clamp(1, pages);
  }

  void _handleScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;

    final contentHeight = _pngLikeContentHeightPx;
    final pages = _calcPageCountLikePng(pos, contentHeight);
    final newCurrentPage = _calcCurrentPageLikePng(pos, pages, contentHeight);

    if (newCurrentPage != _currentPage || pages != _pageCount) {
      setState(() {
        _currentPage = newCurrentPage;
        _pageCount = pages;
      });
    }
    _saveScrollDebounced();
  }

  Future<void> _jumpToPage(int page) async {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    final int clampedPage = page.clamp(1, _pageCount);
    final double desired = _a4PageStridePx * (clampedPage - 1);
    final double target = desired.clamp(0.0, pos.maxScrollExtent);

    await _scrollCtrl.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  int _getCharCount() {
    final plain = _controller.document.toPlainText();
    return plain.replaceAll(RegExp(r'\s+'), '').length;
  }

  // ✅ 빈 리스트 항목에서 Enter 한번 더 누르면 리스트 종료 (메모 앱처럼)
  bool _handleHardwareEnterToExitList(KeyEvent event) {
    if (!_focusNode.hasFocus) return false;

    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.enter) return false;

    if (_isInListAtCursor(_controller) && _isCurrentLineEmpty(_controller)) {
      _exitListLikeMemo(_controller);
      return true; // Enter 기본 동작(새 줄 생성) 막기
    }
    return false;
  }

  bool _isInListAtCursor(quill.QuillController c) {
    final attrs = c.getSelectionStyle().attributes;
    final v = attrs[quill.Attribute.list.key]?.value;
    return v == 'bullet' ||
        v == 'ordered' ||
        v == 'checked' ||
        v == 'unchecked';
  }

  // ✅ queryLine 없이 "현재 줄" 텍스트를 뽑아서 비었는지 확인
  bool _isCurrentLineEmpty(quill.QuillController c) {
    final sel = c.selection;
    if (!sel.isCollapsed) return false;

    final text = c.document.toPlainText();
    if (text.isEmpty) return true;

    int o = sel.baseOffset;
    if (o < 0) o = 0;
    if (o > text.length) o = text.length;

    final before = (o - 1).clamp(0, text.length);
    final startIdx = text.lastIndexOf('\n', before);
    final start = (startIdx == -1) ? 0 : startIdx + 1;
    final endIdx = text.indexOf('\n', o);
    final end = (endIdx == -1) ? text.length : endIdx;

    final line = text.substring(start, end).trim();
    return line.isEmpty;
  }

  void _exitListLikeMemo(quill.QuillController c) {
    // ✅ flutter_quill 11.x : unset 대신 fromKeyValue(key, null)로 해제
    c.formatSelection(
      quill.Attribute.fromKeyValue(quill.Attribute.list.key, null),
    );
    c.formatSelection(
      quill.Attribute.fromKeyValue(quill.Attribute.indent.key, null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isImmersive = _isFocusWriting;

    // Provider 에서 설정 읽기
    final settings = context.watch<WritingSettingsController>().settings;
    final primary = _textColorFromSettings(settings);
    final textColor = primary;

    final bool isSpaceTheme = settings.themeId == 'space';
    final bool isLightSkyTheme = settings.themeId == 'lightSky';
    final Color pageBg = _backgroundColorFromSettings(settings);

    // 🔹 Quill 기본 스타일 가져오기
    final baseStyles = quill.DefaultStyles.getInstance(context);
    final paragraph = baseStyles.paragraph;
    final baseLists = baseStyles.lists;

    final defaultEmbeds = FlutterQuillEmbeds.editorBuilders();
    final safeEmbeds = defaultEmbeds.where((b) => b.key != 'image').toList();

    // 🔹 customStyles
    final fontFamily = _resolveFontFamily(settings.fontFamily);

    // 본문(Paragraph)
    final customParagraph = quill.DefaultTextBlockStyle(
      (paragraph?.style ?? const TextStyle()).copyWith(
        fontSize: 15.0,
        height: settings.lineHeight,
        letterSpacing: settings.letterSpacing,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        color: _textColorFromSettings(settings),
        decorationStyle: TextDecorationStyle.solid,
        decorationColor: textColor,
      ),
      paragraph?.horizontalSpacing ?? baseStyles.paragraph!.horizontalSpacing,
      paragraph?.verticalSpacing ?? baseStyles.paragraph!.verticalSpacing,
      paragraph?.lineSpacing ?? baseStyles.paragraph!.lineSpacing,
      paragraph?.decoration,
    );

    // 리스트(Lists)
    final customLists = (baseLists ?? baseStyles.lists!).copyWith(
      style: (baseLists?.style ?? const TextStyle()).copyWith(
        fontSize: 15.0,
        height: settings.lineHeight,
        letterSpacing: settings.letterSpacing,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        color: _textColorFromSettings(settings),
        decorationStyle: TextDecorationStyle.solid,
        decorationColor: textColor,
      ),
    );

    final customH1 = _headerBlockStyle(
      base: baseStyles.h1!,
      settings: settings,
      fontFamily: fontFamily,
      fontSize: 30,
      fontWeight: FontWeight.w800,
      vTop: 30,
      vBottom: 14,
      hMargin: 0,
      leftIndent: 0,
    );

    final customH2 = _headerBlockStyle(
      base: baseStyles.h2!,
      settings: settings,
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w800,
      vTop: 18,
      vBottom: 10,
      hMargin: 0,
      leftIndent: 6,
    );

    final customH3 = _headerBlockStyle(
      base: baseStyles.h3!,
      settings: settings,
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      vTop: 12,
      vBottom: 8,
      hMargin: 0,
      leftIndent: 10,
    );

    final customStyles = baseStyles.merge(
      quill.DefaultStyles(
        paragraph: customParagraph,
        lists: customLists,
        h1: customH1,
        h2: customH2,
        h3: customH3,
      ),
    );

    // ✅ 테마 래핑은 딱 1번만!
    return _wrapEditorTheme(
      context: context,
      primaryColor: primary, // ✅ iOS tint / list marker 기준
      child: LayoutBuilder(
        builder: (context, constraints) {
          _pngLikeContentHeightPx = _calcPngLikeContentHeightPx(constraints);
          _a4PageStridePx = _pngLikeContentHeightPx;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _recomputePaginationFromStoredHeight();
            _attemptRestoreScroll();
          });

          final bool isKeyboardUp =
              MediaQuery.of(context).viewInsets.bottom > 0;

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              _save();
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              extendBody: true,
              extendBodyBehindAppBar: true,
              resizeToAvoidBottomInset: true,
              appBar:
                  _chromeVisible
                      ? AppBar(
                        toolbarHeight: 52,
                        leadingWidth: 64,
                        leading: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            _persistScroll();
                            _persistSelection();
                            _persistFocus();
                            _save();
                          },
                        ),
                        titleSpacing: 0,
                        title: TextField(
                          controller: _titleCtrl,
                          textAlign: TextAlign.start,
                          textInputAction: TextInputAction.done,
                          maxLines: 1,
                          decoration: const InputDecoration(
                            hintText: '회차 제목 입력',
                            border: InputBorder.none,
                            isCollapsed: true,
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0x8C000000),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                        centerTitle: false,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        actions: [
                          Semantics(
                            label: '집중 글쓰기 모드 토글',
                            button: true,
                            child: IconButton(
                              tooltip:
                                  _isFocusWriting ? '집중 모드 해제' : '집중 글쓰기 모드',
                              onPressed: _toggleFocusWriting,
                              icon: Icon(
                                Icons.fullscreen,
                                color:
                                    _isFocusWriting
                                        ? Colors.blueAccent
                                        : Colors.black87,
                              ),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                          ),
                          Semantics(
                            label: 'PNG 변환',
                            button: true,
                            child: IconButton(
                              tooltip: 'PNG',
                              onPressed: () {
                                final delta =
                                    _controller.document.toDelta().toJson();
                                final deltaJson =
                                    List<Map<String, dynamic>>.from(
                                      delta.map(
                                        (e) =>
                                            Map<String, dynamic>.from(e as Map),
                                      ),
                                    );

                                final ep = _titleCtrl.text.trim();

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => PngPage(
                                          title: ep.isEmpty ? 'PNG 미리보기' : ep,
                                          episodeTitle: ep.isEmpty ? null : ep,
                                          deltaJson: deltaJson,
                                          revision: _pngRevision,
                                          horizontalMargin:
                                              settings.horizontalMargin,
                                          verticalMargin: 18,
                                          baseFontSize: 15,
                                          lineHeight: settings.lineHeight,
                                          letterSpacing: settings.letterSpacing,
                                          fontFamily: _resolveFontFamily(
                                            settings.fontFamily,
                                          ),
                                          pageBackgroundColor:
                                              _backgroundColorFromSettings(
                                                settings,
                                              ),
                                          defaultTextColor:
                                              _textColorFromSettings(settings),
                                          renderScale: 2.8,
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.layers_outlined,
                                size: 22,
                                color: Colors.black87,
                              ),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                          ),
                          IconButton(
                            onPressed: _save,
                            icon: const Icon(
                              Icons.check,
                              color: Colors.black87,
                            ),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                        ],
                      )
                      : null,
              body: SafeArea(
                top: !isImmersive,
                bottom: !isImmersive ? true : isKeyboardUp,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child:
                          isSpaceTheme
                              ? Stack(
                                children: [
                                  const Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color.fromARGB(255, 6, 10, 38),
                                            Color.fromARGB(255, 20, 27, 69),
                                            Color.fromARGB(246, 33, 23, 38),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Positioned.fill(
                                    child: _AnimatedStarField(starCount: 260),
                                  ),
                                  const Positioned.fill(
                                    child: IgnorePointer(
                                      child: _ShootingStarLayer(),
                                    ),
                                  ),
                                  Container(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        settings.horizontalMargin,
                                        (_chromeVisible ? 56 : 0) +
                                            _a4VerticalMargin,
                                        settings.horizontalMargin,
                                        (_chromeVisible ? 64 : 0) +
                                            _a4VerticalMargin,
                                      ),
                                      child: DefaultTextStyle.merge(
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          height: settings.lineHeight,
                                          letterSpacing: settings.letterSpacing,
                                          fontFamily: _resolveFontFamily(
                                            settings.fontFamily,
                                          ),
                                          color: _textColorFromSettings(
                                            settings,
                                          ),
                                        ),

                                        child: quill.QuillEditor(
                                          controller: _controller,
                                          focusNode: _focusNode,
                                          scrollController: _scrollCtrl,
                                          config: quill.QuillEditorConfig(
                                            scrollable: true,
                                            padding: EdgeInsets.zero,
                                            expands: true,
                                            customLeadingBlockBuilder:
                                                buildCustomLeading,
                                            embedBuilders: [
                                              _SafeImageEmbedBuilder(),
                                              _HrSolidEmbedBuilder(),
                                              _HrEmbedBuilder(),
                                              ...safeEmbeds, // 원래 쓰시던 그대로 유지
                                            ],
                                            customStyles: customStyles,
                                            onTapDown: (details, pos) {
                                              final wasDouble =
                                                  _handleDoubleTapForToolbar(
                                                    details,
                                                  );
                                              if (!wasDouble &&
                                                  _toolbarLocked) {
                                                setState(
                                                  () => _toolbarLocked = false,
                                                );
                                              }
                                              return false;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : isLightSkyTheme
                              ? Stack(
                                children: [
                                  const Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color.fromARGB(255, 238, 248, 255),
                                            Color(0xFFBBDEFB),
                                            Color.fromARGB(255, 241, 249, 255),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Positioned.fill(
                                    child: CustomPaint(
                                      painter: _SunRayPainter(),
                                    ),
                                  ),
                                  Container(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        settings.horizontalMargin,
                                        (_chromeVisible ? 56 : 0) +
                                            _a4VerticalMargin,
                                        settings.horizontalMargin,
                                        (_chromeVisible ? 64 : 0) +
                                            _a4VerticalMargin,
                                      ),
                                      child: DefaultTextStyle.merge(
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          height: settings.lineHeight,
                                          letterSpacing: settings.letterSpacing,
                                          fontFamily: _resolveFontFamily(
                                            settings.fontFamily,
                                          ),
                                          color: _textColorFromSettings(
                                            settings,
                                          ),
                                        ),

                                        child: quill.QuillEditor(
                                          controller: _controller,
                                          focusNode: _focusNode,
                                          scrollController: _scrollCtrl,
                                          config: quill.QuillEditorConfig(
                                            scrollable: true,
                                            padding: EdgeInsets.zero,
                                            expands: true,
                                            customLeadingBlockBuilder:
                                                buildCustomLeading,
                                            embedBuilders: [
                                              _SafeImageEmbedBuilder(),
                                              _HrSolidEmbedBuilder(),
                                              _HrEmbedBuilder(),
                                              ...safeEmbeds, // 원래 쓰시던 그대로 유지
                                            ],
                                            customStyles: customStyles,
                                            onTapDown: (details, pos) {
                                              final wasDouble =
                                                  _handleDoubleTapForToolbar(
                                                    details,
                                                  );
                                              if (!wasDouble &&
                                                  _toolbarLocked) {
                                                setState(
                                                  () => _toolbarLocked = false,
                                                );
                                              }
                                              return false;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : Container(
                                color: pageBg,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    settings.horizontalMargin,
                                    (_chromeVisible ? 56 : 0) +
                                        _a4VerticalMargin,
                                    settings.horizontalMargin,
                                    (_chromeVisible ? 64 : 0) +
                                        _a4VerticalMargin,
                                  ),
                                  child: DefaultTextStyle.merge(
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      height: settings.lineHeight,
                                      letterSpacing: settings.letterSpacing,
                                      fontFamily: _resolveFontFamily(
                                        settings.fontFamily,
                                      ),
                                      color: _textColorFromSettings(settings),
                                    ),

                                    child: quill.QuillEditor(
                                      controller: _controller,
                                      focusNode: _focusNode,
                                      scrollController: _scrollCtrl,
                                      config: quill.QuillEditorConfig(
                                        scrollable: true,
                                        padding: EdgeInsets.zero,
                                        expands: true,
                                        customLeadingBlockBuilder:
                                            buildCustomLeading,
                                        embedBuilders: [
                                          _SafeImageEmbedBuilder(),
                                          _HrSolidEmbedBuilder(),
                                          _HrEmbedBuilder(),
                                          ...safeEmbeds, // 원래 쓰시던 그대로 유지
                                        ],
                                        customStyles: customStyles,
                                        onTapDown: (details, pos) {
                                          final wasDouble =
                                              _handleDoubleTapForToolbar(
                                                details,
                                              );
                                          if (!wasDouble && _toolbarLocked) {
                                            setState(
                                              () => _toolbarLocked = false,
                                            );
                                          }
                                          return false;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                    ),

                    if (_chromeVisible)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          color: Colors.white,
                          child: MiniFlatToolbar(
                            controller: _controller,
                            theme: _glassTheme,
                            onLayoutChanged: () {
                              if (!mounted) return;

                              // ✅ PNG 페이지 강제 리빌드 트리거
                              setState(() {
                                _pngRevision++;
                              });

                              // ✅ 페이지바도 즉시 갱신 (postFrame 없이도 보통 충분)
                              _recomputePaginationFromStoredHeight();
                            },
                          ),
                        ),
                      ),

                    if (_chromeVisible)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _PageJumpBar(
                          currentPage: _currentPage,
                          pageCount: _pageCount,
                          charCount: _getCharCount(),
                          onPageChanged: (p) => _jumpToPage(p), // 끝났을 때 animate
                          onPagePreviewChanged:
                              (p) => _jumpToPagePreview(p), // ✅ 드래그 중 jump
                          backgroundColor: Colors.white,
                        ),
                      ),

                    if (!_chromeVisible) ...[
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: _tapRevealZone,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _onTapRevealZone,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: _tapRevealZone,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _onTapRevealZone,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================== 하단 페이지 점프 바 ==================

class _PageJumpBar extends StatefulWidget {
  final int currentPage;
  final int pageCount;
  final int charCount;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onPagePreviewChanged;
  final Color backgroundColor;

  const _PageJumpBar({
    required this.currentPage,
    required this.pageCount,
    required this.charCount,
    required this.onPageChanged,
    this.onPagePreviewChanged,
    required this.backgroundColor,
  });

  @override
  State<_PageJumpBar> createState() => _PageJumpBarState();
}

class _PageJumpBarState extends State<_PageJumpBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final int pageCount = math.max(1, widget.pageCount);
    final double currentDouble =
        ((_dragValue ?? widget.currentPage.toDouble()).clamp(
          1.0,
          pageCount.toDouble(),
        )).toDouble();

    final Color active = Colors.black87.withValues(alpha: 0.72);
    final Color inactive = Colors.black87.withValues(alpha: 0.18);
    final Color thumb = Colors.black87.withValues(alpha: 0.72);
    const Color denom = Color(0xFFB0B0B0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(color: widget.backgroundColor),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              child: LayoutBuilder(
                builder: (context, row) {
                  final double sliderWidth = (row.maxWidth * 0.85) - 36.0;
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(width: 15),
                      SizedBox(
                        width: sliderWidth.clamp(80.0, row.maxWidth),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 0.35,
                            overlayShape: SliderComponentShape.noOverlay,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 4,
                            ),
                            inactiveTrackColor: inactive,
                            activeTrackColor: active,
                            thumbColor: thumb,
                          ),
                          child: Slider(
                            min: 1.0,
                            max: pageCount.toDouble(),
                            divisions: pageCount > 1 ? pageCount - 1 : null,
                            value: currentDouble,
                            onChanged: (v) {
                              final pg = v.round().clamp(1, pageCount);

                              setState(() => _dragValue = v);

                              // ✅ 드래그 중에도 스크롤 이동(미리보기)
                              widget.onPagePreviewChanged?.call(pg);
                            },
                            onChangeEnd: (v) {
                              setState(() => _dragValue = null);
                              widget.onPageChanged(v.round());
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: currentDouble.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                            const TextSpan(
                              text: ' / ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: denom,
                                height: 1.2,
                              ),
                            ),
                            TextSpan(
                              text: pageCount.toString(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: denom,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '글자 : ${widget.charCount}',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Colors.black87.withValues(alpha: 0.55),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== 솔리드 HR(구분선) 임베드 빌더 =====
class _HrSolidEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => 'hr_solid'; // 툴바에서 삽입하는 키와 정확히 일치해야 합니다.

  @override
  Widget build(BuildContext context, quill.EmbedContext embedContext) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        thickness: 0.5,
        height: 17,
        color: Color.fromARGB(255, 129, 147, 182),
      ),
    );
  }
}

class _HrEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => 'hr';

  @override
  Widget build(BuildContext context, quill.EmbedContext embedContext) {
    return const _DashedDivider(
      thickness: 0.5,
      dashWidth: 5,
      dashSpace: 5,
      color: Color.fromARGB(255, 129, 147, 182),
      padding: EdgeInsets.symmetric(vertical: 8),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({
    this.thickness = 0.6,
    this.dashWidth = 5,
    this.dashSpace = 5,
    this.color = const Color.fromARGB(255, 129, 147, 182),
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  final double thickness;
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: 18, // ✅ PNG와 동일
        width: double.infinity,
        child: CustomPaint(
          painter: _DashedLinePainter(
            color: color,
            thickness: thickness,
            dashWidth: dashWidth,
            dashSpace: dashSpace,
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final double thickness;
  final double dashWidth;
  final double dashSpace;
  final Color color;

  const _DashedLinePainter({
    required this.thickness,
    required this.dashWidth,
    required this.dashSpace,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.square;

    const y = 8.0; // ✅ PNG와 동일한 기준선

    double x = 0;
    while (x < size.width) {
      final x2 = math.min(x + dashWidth, size.width);
      canvas.drawLine(Offset(x, y), Offset(x2, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) =>
      old.color != color ||
      old.thickness != thickness ||
      old.dashWidth != dashWidth ||
      old.dashSpace != dashSpace;
}

/// ===== 안전한 이미지 임베드 빌더 =====
class _SafeImageEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => 'image'; // flutter_quill 의 기본 image key와 동일

  @override
  Widget build(BuildContext context, quill.EmbedContext embedContext) {
    final dynamic data = embedContext.node.value.data;

    // flutter_quill 11.x에서 image 데이터는 보통 String (경로 또는 URL)
    String? source;
    if (data is String) {
      source = data;
    } else if (data is Map && data['source'] is String) {
      // 혹시 Map 형태면 이렇게 한 번 더 방어
      source = data['source'] as String;
    }

    if (source == null || source.isEmpty) {
      return const SizedBox.shrink();
    }

    // 1) http/https 이면 네트워크 이미지
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) {
          return const Icon(Icons.broken_image, size: 32, color: Colors.grey);
        },
      );
    }

    // 2) 로컬 파일 경로인 경우
    final file = File(source);

    // 예전에 저장된 /tmp/image_picker_... 처럼 이미 사라진 파일이면 그냥 안 그린다
    if (!file.existsSync()) {
      return const SizedBox.shrink();
    }

    return Image.file(
      file,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) {
        return const Icon(Icons.broken_image, size: 32, color: Colors.grey);
      },
    );
  }
}

// ----------------------
// 🌌 우주 테마용 별 페인터
// ----------------------

class _AnimatedStarField extends StatefulWidget {
  final int starCount;

  const _AnimatedStarField({this.starCount = 230});

  @override
  State<_AnimatedStarField> createState() => _AnimatedStarFieldState();
}

class _AnimatedStarFieldState extends State<_AnimatedStarField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  final math.Random _rnd = math.Random();
  int? _twinkleIndex;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // 반짝이는 데 걸리는 시간
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // 첫 반짝임
    _twinkleIndex = _rnd.nextInt(widget.starCount);
    _controller.forward(from: 0);

    // 5초마다 새로운 별 하나 반짝이게
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || widget.starCount <= 0) return;
      setState(() {
        _twinkleIndex = _rnd.nextInt(widget.starCount);
      });
      _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarFieldPainter(
        starCount: widget.starCount,
        twinkleIndex: _twinkleIndex,
        twinkleProgress: _curve,
      ),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  final int starCount;
  final int? twinkleIndex;
  final Animation<double> twinkleProgress;

  _StarFieldPainter({
    this.starCount = 230,
    required this.twinkleIndex,
    required this.twinkleProgress,
  }) : super(repaint: twinkleProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(12345);
    final basePaint = Paint()..style = PaintingStyle.fill;

    // 0 → 1 → 0으로 가는 부드러운 펄스
    final double t = twinkleProgress.value.clamp(0.0, 1.0);
    final double pulse = math.sin(t * math.pi); // 0~1~0

    for (int i = 0; i < starCount; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final center = Offset(dx, dy);

      // === 기본 별 세팅 ===
      final double baseRadius = rnd.nextDouble() * 0.2 + 0.1;
      final bool bigGlow = rnd.nextBool();
      final double baseGlowRadius = baseRadius * (bigGlow ? 4.0 : 3.0);
      final double baseAlpha = 0.65 + rnd.nextDouble() * 0.3;

      final Color baseColor = const Color.fromARGB(
        255,
        255,
        255,
        255,
      ).withValues(alpha: baseAlpha);

      // 1) 기본 glow
      final RadialGradient baseGlow = RadialGradient(
        colors: [baseColor, baseColor.withValues(alpha: 0.0)],
        stops: const [0.0, 1.0],
      );
      final Rect baseRect = Rect.fromCircle(
        center: center,
        radius: baseGlowRadius,
      );
      final Paint baseGlowPaint =
          Paint()
            ..shader = baseGlow.createShader(baseRect)
            ..blendMode = BlendMode.plus;

      canvas.drawCircle(center, baseGlowRadius, baseGlowPaint);

      // 2) 기본 중심 별
      basePaint.color = baseColor;
      canvas.drawCircle(center, baseRadius, basePaint);

      // === twinkle 대상이면, "같은 별"에만 하이라이트 추가 ===
      if (twinkleIndex != null && i == twinkleIndex) {
        // 밝기/halo를 살짝 더 키운다 (크기 변화는 과하지 않게)
        final double extraAlpha = 0.5 * pulse; // 0 ~ 0.4
        final double extraRadius =
            baseGlowRadius * (1.5 + 0.7 * pulse); // 1.2~1.6배 정도

        final Color highlightColor = const Color.fromARGB(
          255,
          255,
          255,
          255,
        ).withValues(alpha: (baseAlpha + extraAlpha).clamp(0.0, 1.0));

        final RadialGradient highlight = RadialGradient(
          colors: [highlightColor, highlightColor.withValues(alpha: 0.0)],
          stops: const [0.0, 1.0],
        );

        final Rect highlightRect = Rect.fromCircle(
          center: center,
          radius: extraRadius,
        );

        final Paint highlightPaint =
            Paint()
              ..shader = highlight.createShader(highlightRect)
              ..blendMode = BlendMode.plus;

        // base 위에 살짝 더 밝게 덮어 씌우는 느낌
        canvas.drawCircle(center, extraRadius, highlightPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) {
    return oldDelegate.starCount != starCount ||
        oldDelegate.twinkleIndex != twinkleIndex ||
        oldDelegate.twinkleProgress != twinkleProgress;
  }
}

// ----------------------
// 🌠 랜덤 별똥별용 스펙 + 레이어 + 페인터
// ----------------------

class _ShootingStarSpec {
  /// 0~1 비율 기준 시작 위치 (살짝 바깥 허용)
  final double startX;
  final double startY;

  /// 진행 방향 벡터 (정규화 X, 비율 기반)
  final double dx;
  final double dy;

  /// 꼬리 길이 (화면 짧은 변 비율)
  final double length;

  /// 선 두께
  final double thickness;

  const _ShootingStarSpec({
    required this.startX,
    required this.startY,
    required this.dx,
    required this.dy,
    required this.length,
    required this.thickness,
  });
}

class _ShootingStarLayer extends StatefulWidget {
  const _ShootingStarLayer();

  @override
  State<_ShootingStarLayer> createState() => _ShootingStarLayerState();
}

class _ShootingStarLayerState extends State<_ShootingStarLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final math.Random _rnd = math.Random();

  _ShootingStarSpec? _currentStar;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // 별똥별 수명(약 0.9초)
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 애니메이션 끝나면 별 제거 + 예약
        setState(() => _currentStar = null);
        _scheduleNext();
      }
    });

    _scheduleNext(initial: true);
  }

  void _scheduleNext({bool initial = false}) {
    // 10초 ± 4초 정도 랜덤
    const double baseSeconds = 10.0;
    const double jitter = 2.0;
    final double seconds =
        initial ? 1.5 : baseSeconds + (_rnd.nextDouble() * 2 - 1) * jitter;

    Future.delayed(Duration(milliseconds: (seconds * 700).round()), () {
      if (!mounted) return;
      _spawnStar();
    });
  }

  void _spawnStar() {
    setState(() {
      _currentStar = _randomSpec();
    });
    _controller.forward(from: 0.0);
  }

  _ShootingStarSpec _randomSpec() {
    // 화면보다 약간 바깥까지 포함하는 시작 위치 (-0.1 ~ 1.1 비율)
    final double startX = _rnd.nextDouble() * 1.2 - 0.1;
    final double startY = _rnd.nextDouble() * 1.2 - 0.1;

    // 대각선 아래로 흘러가게, 좌/우 방향 랜덤
    final bool toRight = _rnd.nextBool();
    final double angleDeg = 20 + _rnd.nextDouble() * 40; // 20~60도
    final double angleRad = angleDeg * math.pi / 180.0;

    final double dx = (toRight ? 1.0 : -1.0) * math.cos(angleRad);
    final double dy = math.sin(angleRad); // 아래 방향

    // 진짜 얇은 느낌
    final double length = 0.25 + _rnd.nextDouble() * 0.10; // 25~35%
    final double thickness = 0.4 + _rnd.nextDouble() * 0.2; // 0.4~0.6

    return _ShootingStarSpec(
      startX: startX,
      startY: startY,
      dx: dx,
      dy: dy,
      length: length,
      thickness: thickness,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShootingStarPainter(animation: _controller, star: _currentStar),
    );
  }
}

class _ShootingStarPainter extends CustomPainter {
  final Animation<double> animation;
  final _ShootingStarSpec? star;

  _ShootingStarPainter({required this.animation, required this.star})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (star == null) return;

    final double t = animation.value.clamp(0.0, 1.0);

    // 끝으로 갈수록 사라지게
    final double opacity = (1.0 - t) * 0.9;
    if (opacity <= 0) return;

    final Paint paint =
        Paint()
          ..color = const Color.fromARGB(
            255,
            255,
            255,
            255,
          ).withValues(alpha: opacity)
          ..strokeWidth = star!.thickness
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final double baseLengthPx =
        star!.length * math.min(size.width, size.height);

    // 시작점 (비율 → 실제 좌표)
    final Offset start = Offset(
      star!.startX * size.width,
      star!.startY * size.height,
    );

    final Offset dir = Offset(star!.dx, star!.dy).normalize();

    // 머리(head)는 진행 방향으로, 꼬리(tail)는 뒤로
    final Offset head = start + dir * (baseLengthPx * (0.3 + 0.7 * t));
    final Offset tail = head - dir * (baseLengthPx * 0.7);

    canvas.drawLine(tail, head, paint);
  }

  @override
  bool shouldRepaint(covariant _ShootingStarPainter oldDelegate) {
    return oldDelegate.star != star;
  }
}

// Offset 확장 메서드
extension _OffsetNormalize on Offset {
  Offset normalize() {
    final double len = distance;
    if (len == 0) return this;
    return this / len;
  }
}

// ----------------------
// 🌞 한낮 하늘 테마용 태양빛 페인터 (무지개 스펙트럼 추가)
// ----------------------
class _SunRayPainter extends CustomPainter {
  const _SunRayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset sunCenter = Offset(size.width * 0.01, size.height * 0.01);
    final double coreRadius = size.width * 0.11;
    final double haloRadius = size.longestSide * 0.7;
    final Rect fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 🌞 눈부신 코어 핫스팟
    final Paint hotspot =
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
            stops: [0.0, 1.0],
          ).createShader(
            Rect.fromCircle(center: sunCenter, radius: coreRadius * 1.5),
          )
          ..blendMode = BlendMode.plus;
    canvas.drawCircle(sunCenter, coreRadius * 1.6, hotspot);

    // 🌕 태양 코어
    final Paint sunCore =
        Paint()
          ..shader = RadialGradient(
            center: Alignment.topLeft,
            radius: 0.3,
            colors: [
              const Color(0xFFFFFFFF),
              const Color.fromARGB(255, 255, 253, 232).withValues(alpha: 0.95),
              const Color(0x00FFF59D),
            ],
            stops: const [0.0, 0.25, 1.0],
          ).createShader(Rect.fromCircle(center: sunCenter, radius: coreRadius))
          ..blendMode = BlendMode.plus;
    canvas.drawCircle(sunCenter, coreRadius, sunCore);

    // 🌤 주변 퍼짐
    final Paint halo =
        Paint()
          ..shader = RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.5),
              const Color(0xFFFFFFFF).withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: sunCenter, radius: haloRadius))
          ..blendMode = BlendMode.softLight;
    canvas.drawCircle(sunCenter, haloRadius, halo);

    // 🌈 무지개 스펙트럼 얇은 빛줄기
    final List<Color> spectrumColors = [
      const Color(0xFFFF3B3B), // red
      const Color(0xFFFFA500), // orange
      const Color(0xFFFFFF00), // yellow
      const Color(0xFF00FF00), // green
      const Color(0xFF00BFFF), // sky blue
      const Color(0xFF4169E1), // royal blue
      const Color(0xFF9932CC), // violet
    ];

    final math.Random random = math.Random(7); // 시드 고정 → 일관된 패턴
    final int rayCount = 70 + random.nextInt(15); // 25 광선

    for (int i = 0; i < rayCount; i++) {
      final double angle =
          (random.nextDouble() * math.pi / 3) + (math.pi / 6); // 태양에서 우상향 범위
      final double len =
          (haloRadius * 0.4) + random.nextDouble() * (haloRadius * 0.3);
      final double thickness = 0.5 + random.nextDouble() * 0.6;

      // 랜덤 스펙트럼 색
      final Color c = spectrumColors[random.nextInt(spectrumColors.length)]
          .withValues(alpha: 0.28);

      final Paint rayPaint =
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [c.withValues(alpha: 0.7), c.withValues(alpha: 0.0)],
            ).createShader(Rect.fromLTWH(0, 0, len, thickness))
            ..blendMode = BlendMode.screen
            ..strokeWidth = thickness
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      final Offset start = sunCenter;
      final Offset end = Offset(
        sunCenter.dx + math.cos(angle) * len,
        sunCenter.dy + math.sin(angle) * len,
      );

      canvas.drawLine(start, end, rayPaint);
    }

    // 🌤 대각선 햇살
    final Paint diagonal =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.6),
              const Color(0x00FFFFFF),
            ],
            stops: const [0.0, 0.75],
          ).createShader(fullRect)
          ..blendMode = BlendMode.screen;
    canvas.drawRect(fullRect, diagonal);

    // ☀️ 전체 밝기
    final Paint overlay =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.15),
              const Color(0x00FFFFFF),
            ],
          ).createShader(fullRect)
          ..blendMode = BlendMode.softLight;
    canvas.drawRect(fullRect, overlay);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
