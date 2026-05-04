// book_builder_page.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:ebook_tutorial_app/widgets/pdf/pdf_chapter_picker_dialog.dart';
import 'package:ebook_tutorial_app/pdf/book_pdf_builder.dart' show buildBookPdf;

import 'package:dart_quill_delta/dart_quill_delta.dart' as dq;
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ebook_tutorial_app/models/genre.dart';
import 'package:ebook_tutorial_app/utils/platform_accessibility.dart';
import 'package:ebook_tutorial_app/pages/chapter/chapter_write_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebook_tutorial_app/pages/pdf_preview_page.dart';
import 'package:ebook_tutorial_app/pdf/book_pdf_builder.dart';
import 'package:ebook_tutorial_app/pages/canvas_doc_engine.dart';
import 'package:provider/provider.dart';
import 'package:ebook_tutorial_app/controllers/writing_settings_controller.dart';
import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_container.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_action_button.dart';
import 'package:ebook_tutorial_app/widgets/common/app_toast.dart';
import 'package:ebook_tutorial_app/models/writing_settings.dart';
import 'package:ebook_tutorial_app/widgets/card_design.dart'
    show MemoSquareCard;

enum ChapterSort { oldestFirst, newestFirst }

const double kCoverBaseRadius = 13.0;
const double kCoverBaseWidth = 150.0;

final Color kDialogBarrierColor = const Color(
  0xFF0F2238,
).withValues(alpha: 0.13);

double scaledCoverRadius(double width) {
  if (width <= 0) return kCoverBaseRadius;
  final ratio = width / kCoverBaseWidth;
  return kCoverBaseRadius * ratio;
}

String? resolveFontFamily(String key) {
  switch (key) {
    case 'batang':
      return 'Apple SD 산돌고딕 Neo';
    case 'inter':
      return 'Inter';
    case 'system':
    default:
      return 'Inter';
  }
}

class FrostedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool enableGlass;
  final double blurSigma;
  final Color? backgroundColor;
  final BoxConstraints? constraints;
  final bool showBorder;
  final Color? borderColor;
  const FrostedContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    required this.enableGlass,
    this.blurSigma = 16,
    this.backgroundColor,
    this.constraints,
    this.showBorder = true,
    this.borderColor,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        backgroundColor ??
        (isDark
            ? Colors.white.withValues(alpha: enableGlass ? 0.06 : 0.10)
            : Colors.white.withValues(alpha: enableGlass ? 0.70 : 0.90));
    final silver = (borderColor ?? const ui.Color.fromARGB(255, 147, 162, 181))
        .withValues(alpha: 0.65);
    final content = Container(
      constraints: constraints,
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder ? Border.all(color: silver, width: 1) : null,
      ),
      child: child,
    );
    if (!enableGlass) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );
  }
}

class ChapterItem {
  final String title;
  final int index;
  final String? coverPath;
  final String? episodeTitle;
  final List<Map<String, dynamic>> delta;

  final int? sizeBytes;
  final int? charCount;
  final DateTime? updatedAt;
  final bool pinned;
  const ChapterItem({
    required this.title,
    required this.index,
    this.coverPath,
    this.episodeTitle,
    required this.delta,
    this.sizeBytes,
    this.charCount,
    this.updatedAt,
    this.pinned = false,
  });
  ChapterItem copyWith({
    String? title,
    String? coverPath,
    String? episodeTitle,
    List<Map<String, dynamic>>? delta,
    int? sizeBytes,
    int? charCount,
    DateTime? updatedAt,
    bool? pinned,
  }) {
    return ChapterItem(
      title: title ?? this.title,
      index: index,
      coverPath: coverPath ?? this.coverPath,
      episodeTitle: episodeTitle ?? this.episodeTitle,
      delta: delta ?? this.delta,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      charCount: charCount ?? this.charCount,
      updatedAt: updatedAt ?? this.updatedAt,
      pinned: pinned ?? this.pinned,
    );
  }
}

class BookBuilderPage extends StatefulWidget {
  final Genre genre;
  final String? episodeTitle;
  final String initialTitle;
  final List<Map<String, dynamic>> initialDeltaJson;
  final List<Map<String, dynamic>> initialDrawingJson;
  final int pageIndex;
  final String initialPenName;
  final String? documentId;
  final int? initialOpenChapterIndex;
  final bool initialAutoAddChapter;

  const BookBuilderPage({
    required this.genre,
    super.key,
    this.episodeTitle,
    required this.initialTitle,
    required this.initialDeltaJson,
    required this.initialDrawingJson,
    required this.pageIndex,
    this.initialPenName = '',
    this.documentId,
    this.initialOpenChapterIndex,
    this.initialAutoAddChapter = false,
  });

  @override
  State<BookBuilderPage> createState() => _BookBuilderPageState();
}

class _PdfPopupItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double fontSize;

  const _PdfPopupItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.fontSize = 14.5,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1F3A56)),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F3A56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewPageTarget {
  final int chapterIndex;
  final int localPage;

  const _PreviewPageTarget({
    required this.chapterIndex,
    required this.localPage,
  });
}

class _BookBuilderPageState extends State<BookBuilderPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _penNameCtrl;
  late List<Map<String, dynamic>> _delta;
  late List<Map<String, dynamic>> _drawings;
  final LayerLink _pdfPreviewLink = LayerLink();
  OverlayEntry? _pdfSubmenuEntry;

  final ValueNotifier<bool> _pdfExportSubmenuOpenVN = ValueNotifier(false);

  OverlayEntry? _cloudSubmenuEntry;
  final GlobalKey _cloudSubmenuKey = GlobalKey();
  double? _measuredCloudSubmenuHeight;
  final ValueNotifier<bool> _cloudSubmenuOpenVN = ValueNotifier(false);
  final LayerLink _cloudLink = LayerLink();

  OverlayEntry? _epubSubmenuEntry;
  final GlobalKey _epubSubmenuKey = GlobalKey();
  double? _measuredEpubSubmenuHeight;
  final ValueNotifier<bool> _epubSubmenuOpenVN = ValueNotifier(false);
  final LayerLink _epubLink = LayerLink();

  final GlobalKey _pdfSubmenuKey = GlobalKey();
  double? _measuredSubmenuHeight;
  final ValueNotifier<bool> _pdfSubmenuOpenVN = ValueNotifier<bool>(false);

  late final TextEditingController _summaryCtrl;
  late final TextEditingController _keywordInputCtrl;
  final List<String> _keywords = [];
  final Map<int, _PreviewPageTarget> _previewPageTargets = {};

  late final TextEditingController _workTypeCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _ageRatingCtrl;
  String? _coverPath;
  String get _coverKey =>
      widget.documentId == null ? '' : 'book_cover_${widget.documentId}';

  String get _metaKey =>
      widget.documentId == null ? '' : 'book_meta_${widget.documentId}';
  late final WritingSettingsController _settingsController;

  List<CanvasPagePlan> _pagePlans = const [];
  int _pageCount = 1;
  final Map<String, ui.Image> _imageCache = <String, ui.Image>{};
  final Map<String, Size> _imageSizeCache = <String, Size>{};

  double _pageWidthPx = 0;
  double _pageHeightPx = 0;
  double? _lastLayoutWidth;

  Timer? _paginateDebounce;
  int _paginateEpoch = 0;

  String? _lastPaginationSignature;
  int _currentIndex = 0;
  bool _isPageView = true;
  bool _glass = true;
  bool _reduceTransparencyFlag = false;

  OverlayEntry? _imageSubmenuEntry;
  final ValueNotifier<bool> _imageSubmenuOpenVN = ValueNotifier(false);

  bool _previewAllChapters = true;
  final Set<int> _selectedChapterIndexes = {};
  GlassTheme get _glassTheme =>
      GlassTheme.fromFlags(reduceTransparency: _reduceTransparencyFlag);
  late final TabController _tabCtrl;

  bool _paginating = false;

  int _loadingCount = 0;

  int _tabIndex = 0;
  final PageController _pageCtrl = PageController();
  final List<GlobalKey> _itemKeys = <GlobalKey>[];
  SharedPreferences? _prefs;

  ChapterSort _sortOrder = ChapterSort.oldestFirst;
  String get _sortKey =>
      widget.documentId == null ? '' : 'book_sort_${widget.documentId}';

  bool _reorderMode = false;

  final List<ChapterItem> _chapters = [];
  String get _titleKey =>
      widget.documentId == null ? '' : 'book_title_${widget.documentId}';
  String get _penKey =>
      widget.documentId == null ? '' : 'book_pen_${widget.documentId}';
  String get _chaptersKey =>
      widget.documentId == null ? '' : 'book_chapters_${widget.documentId}';

  final List<_LocalMemo> _memos = [];
  String get _memoKey =>
      widget.documentId == null ? '' : 'book_memos_${widget.documentId}';

  List<Map<String, dynamic>> _withEpisodeTitleDelta(
    List<Map<String, dynamic>> original, {
    required String episodeTitle,
  }) {
    final title = episodeTitle.trim();
    if (title.isEmpty) return original;

    return <Map<String, dynamic>>[
      {'insert': title},
      {
        'insert': '\n',
        'attributes': {'header': 3},
      },
      {'insert': '\n'},
      ...original,
    ];
  }

  void _disposeImages() {
    for (final img in _imageCache.values) {
      img.dispose();
    }
    _imageCache.clear();
  }

  void _resetPreviewCaches({bool notify = true}) {
    _paginateDebounce?.cancel();
    _paginateEpoch++;
    _paginating = false;
    _pagePlans = const [];

    _imageSizeCache.clear();
    _disposeImages();
    _pageCount = 1;
    _currentIndex = 0;
    _ensureItemKeys();
    if (notify && mounted) setState(() {});
  }

  void _incLoading() {
    _loadingCount += 1;
    if (!mounted) return;
    setState(() {});
  }

  void _decLoading() {
    _loadingCount = (_loadingCount - 1).clamp(0, 1 << 30);
    if (!mounted) return;
    setState(() {});
  }

  void _scheduleRebuild({Duration delay = const Duration(milliseconds: 120)}) {
    _paginateDebounce?.cancel();
    final epoch = _paginateEpoch;
    _paginateDebounce = Timer(delay, () {
      if (!mounted) return;
      unawaited(_rebuildPreviewPlans(epoch));
    });
  }

  Future<void> _rebuildPreviewPlans(int epoch) async {
    if (epoch != _paginateEpoch) return;
    if (_pageWidthPx <= 0 || _pageHeightPx <= 0) return;
    if (_paginating) return;

    final full = dq.Delta.fromJson(_delta);
    final chunks = DeltaPageBreakSplitter.splitByPageBreak(full);

    _paginating = true;
    _incLoading();
    try {
      final s = _settingsController.settings;
      final hm = _effectiveHorizontalMarginPx(s);
      final vm = _effectiveVerticalMarginPx(s);
      final contentW = _pageWidthPx - hm * 2;
      final contentH = _pageHeightPx - vm * 2;
      final maxImageH = contentH * 0.65;

      await _primeImageSizesFromChunks(chunks: chunks, epoch: epoch);

      final docSettings = CanvasDocSettings(
        baseStyle: TextStyle(
          fontSize: s.fontSize,
          height: s.lineHeight,
          letterSpacing: s.letterSpacing,
          fontFamily: resolveFontFamily(s.fontFamily),
          color: s.textColor,
          fontWeight: FontWeight.w400,
        ),
        contentWidth: contentW,
        contentHeight: contentH,
        imageSizes: _imageSizeCache,
        maxImageHeight: maxImageH,
      );

      final engine = CanvasDocEngine(docSettings);

      final allPlans = <CanvasPagePlan>[];
      final pageTargets = <int, _PreviewPageTarget>{};

      int globalPage = 1;

      for (int chapterPos = 0; chapterPos < chunks.length; chapterPos++) {
        if (epoch != _paginateEpoch) return;

        final chunk = chunks[chapterPos];
        final chunkJson = (chunk.toJson() as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(growable: true);

        final plans = await engine.paginateDelta(chunkJson);

        for (int localPage = 0; localPage < plans.length; localPage++) {
          allPlans.add(plans[localPage]);

          if (chapterPos < _chapters.length) {
            pageTargets[globalPage] = _PreviewPageTarget(
              chapterIndex: _chapters[chapterPos].index,
              localPage: localPage + 1,
            );
          }

          globalPage++;
        }
      }

      if (!mounted || epoch != _paginateEpoch) return;

      setState(() {
        _pagePlans =
            allPlans.isEmpty ? [CanvasPagePlan(commands: [])] : allPlans;
        _pageCount = _pagePlans.length.clamp(1, 1 << 30);
        _currentIndex = _currentIndex.clamp(0, _pageCount - 1);

        _previewPageTargets
          ..clear()
          ..addAll(pageTargets);
      });
    } finally {
      if (mounted && epoch == _paginateEpoch) _paginating = false;
      _decLoading();
    }
  }

  Future<void> _primeImageSizesFromChunks({
    required List<dynamic> chunks,
    required int epoch,
  }) async {
    for (final chunk in chunks) {
      if (epoch != _paginateEpoch) return;

      final List<Map<String, dynamic>> chunkJson = (chunk.toJson() as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);

      for (final op in chunkJson) {
        final insert = op['insert'];
        if (insert is Map && insert['image'] is String) {
          final src = insert['image'] as String;
          if (src.isEmpty) continue;
          if (_imageSizeCache.containsKey(src)) continue;

          try {
            if (src.startsWith('http://') || src.startsWith('https://')) {
              continue;
            }

            final f = File(src);
            if (!await f.exists()) continue;

            final bytes = await f.readAsBytes();
            final codec = await ui.instantiateImageCodec(bytes);
            final frame = await codec.getNextFrame();
            final img = frame.image;

            _imageSizeCache[src] = Size(
              img.width.toDouble(),
              img.height.toDouble(),
            );

            img.dispose();
            codec.dispose();
          } catch (_) {}
        }
      }
    }
  }

  Future<ui.Image?> _loadImage(String src, {int? targetWidthPx}) async {
    final cached = _imageCache[src];
    if (cached != null) return cached;
    try {
      Uint8List bytes;
      if (src.startsWith('http://') || src.startsWith('https://')) {
        return null;
      } else {
        final f = File(src);
        if (!await f.exists()) return null;
        bytes = await f.readAsBytes();
      }
      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(bytes, (img) => completer.complete(img));
      final img = await completer.future;
      _imageCache[src] = img;
      return img;
    } catch (_) {
      return null;
    }
  }

  Future<void> _rebuildPagination() async {
    _resetPreviewCaches(notify: false);

    _scheduleRebuild(delay: Duration.zero);
  }

  static const double _kA4W = 595.275590551;
  static const double _kA4H = 841.88976378;

  double _effectiveHorizontalMarginPx(WritingSettings s) {
    if (_pageWidthPx <= 0) return s.horizontalMargin;
    return s.horizontalMargin * (_pageWidthPx / _kA4W);
  }

  double _effectiveVerticalMarginPx(WritingSettings s) {
    if (_pageHeightPx <= 0) return s.verticalMargin;
    return s.verticalMargin * (_pageHeightPx / _kA4H);
  }

  Future<ui.Image?> _renderImageForPage(int pageNumber) async {
    if (_pagePlans.isEmpty) return null;

    final s = _settingsController.settings;
    final hm = _effectiveHorizontalMarginPx(s);
    final vm = _effectiveVerticalMarginPx(s);
    final idx = (pageNumber - 1).clamp(0, _pagePlans.length - 1);

    final plan = _pagePlans[idx];
    const renderScale = 2.2;
    final int outW = (_pageWidthPx * renderScale).round();
    final int outH = (_pageHeightPx * renderScale).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
      Paint()..color = Colors.transparent,
    );

    canvas.scale(renderScale, renderScale);
    final origin = Offset(hm, vm);

    for (final cmd in plan.commands) {
      await cmd.paint(
        canvas: canvas,
        origin: origin,
        loadImage: _loadImage,
        maxImageHeight: (_pageHeightPx - vm * 2) * 0.65,
        renderScale: renderScale,
      );
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(outW, outH);
    picture.dispose();
    return img;
  }

  Future<void> _openEditorFromPreviewPage(int globalPage) async {
    final target = _previewPageTargets[globalPage];
    if (target == null) return;

    final found = _chapters.indexWhere((c) => c.index == target.chapterIndex);
    if (found < 0) return;

    await _openChapterEditor(
      _chapters[found],
      initialOpenPage: target.localPage,
    );
  }

  String _buildPaginationSignature(WritingSettings s) {
    return [
      s.themeId,
      s.fontFamily,
      s.fontSize.toStringAsFixed(2),
      s.lineHeight.toStringAsFixed(2),
      s.letterSpacing.toStringAsFixed(2),
      s.horizontalMargin.toStringAsFixed(2),
      s.verticalMargin.toStringAsFixed(2),
      _pageWidthPx.toStringAsFixed(2),
      _pageHeightPx.toStringAsFixed(2),
    ].join('|');
  }

  void _onSettingsChanged() {
    if (!mounted) return;
    final s = _settingsController.settings;
    final newSig = _buildPaginationSignature(s);
    if (newSig == _lastPaginationSignature) return;
    _lastPaginationSignature = newSig;
    unawaited(_rebuildPagination());
  }

  @override
  void initState() {
    super.initState();

    var safeDelta = widget.initialDeltaJson
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: true);

    final initTitle =
        (_currentIndex >= 0 && _currentIndex < _chapters.length)
            ? _chapters[_currentIndex].title
            : '';

    safeDelta = _withEpisodeTitleDelta(safeDelta, episodeTitle: initTitle);

    _settingsController = context.read<WritingSettingsController>();
    _lastPaginationSignature = _buildPaginationSignature(
      _settingsController.settings,
    );
    _settingsController.addListener(_onSettingsChanged);
    _delta = safeDelta;
    _drawings = List<Map<String, dynamic>>.from(widget.initialDrawingJson);
    _titleCtrl = TextEditingController(text: widget.initialTitle)
      ..addListener(() => _persistTitle(_titleCtrl.text));
    _penNameCtrl = TextEditingController(text: widget.initialPenName)
      ..addListener(() => _persistPenName(_penNameCtrl.text));
    _tabCtrl = TabController(length: 5, vsync: this, initialIndex: 0)
      ..addListener(() {
        if (!_tabCtrl.indexIsChanging) {
          setState(() => _tabIndex = _tabCtrl.index);
        }
      });
    _summaryCtrl = TextEditingController();
    _keywordInputCtrl = TextEditingController();
    _workTypeCtrl = TextEditingController();
    _categoryCtrl = TextEditingController();
    _ageRatingCtrl = TextEditingController();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scheduleRebuild(delay: Duration.zero);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initReduceTransparency();
      _glass = !_reduceTransparencyFlag;
      await _loadPersistedFields();
      await _loadSortPref();
      await _loadPersistedChapters();
      _applyChapterSort();
      await _maybeAutoOpenChapter();
      if (widget.initialAutoAddChapter) {
        _addChapter();
        final newestIndex = _chapters
            .map((c) => c.index)
            .fold<int>(0, (p, e) => e > p ? e : p);
        final found = _chapters.indexWhere((c) => c.index == newestIndex);
        if (found >= 0) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          if (!mounted) return;
          _openChapterEditor(_chapters[found]);
        }
      }
      await _loadPersistedMemos();
      await _loadPersistedMeta();
      await _loadPersistedCover();
      if (!mounted) return;
      setState(() {
        _currentIndex = widget.pageIndex.clamp(0, _pageCount - 1);
      });

      if (!mounted) return;
      _scheduleRebuild(delay: Duration.zero);
    });
  }

  @override
  void dispose() {
    _paginateDebounce?.cancel();
    _disposeImages();
    _hidePdfSubmenu();
    _pdfSubmenuOpenVN.dispose();
    _imageSubmenuOpenVN.dispose();
    _cloudSubmenuOpenVN.dispose();
    _epubSubmenuOpenVN.dispose();
    _settingsController.removeListener(_onSettingsChanged);
    _titleCtrl.dispose();
    _penNameCtrl.dispose();
    _summaryCtrl.dispose();
    _keywordInputCtrl.dispose();
    _workTypeCtrl.dispose();
    _categoryCtrl.dispose();
    _ageRatingCtrl.dispose();
    _pageCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadPersistedFields() async {
    if (widget.documentId == null) return;
    await _ensurePrefs();
    final savedTitle = _prefs!.getString(_titleKey);
    final savedPen = _prefs!.getString(_penKey);
    if (savedTitle?.isNotEmpty == true) _titleCtrl.text = savedTitle!;
    if (savedPen?.isNotEmpty == true) _penNameCtrl.text = savedPen!;
  }

  Future<void> _persistCoverPath(String? path) async {
    if (widget.documentId == null) return;
    await _ensurePrefs();
    if (path == null || path.isEmpty) {
      await _prefs!.remove(_coverKey);
    } else {
      await _prefs!.setString(_coverKey, path);
    }
  }

  Future<void> _loadPersistedCover() async {
    if (widget.documentId == null) return;
    await _ensurePrefs();
    final saved = _prefs!.getString(_coverKey);
    if (!mounted) return;
    setState(() {
      _coverPath = saved;
    });
  }

  Future<void> _persistTitle(String value) async {
    if (widget.documentId == null) return;
    await _ensurePrefs();
    await _prefs!.setString(_titleKey, value);
  }

  Future<void> _persistPenName(String value) async {
    if (widget.documentId == null) return;
    await _ensurePrefs();
    await _prefs!.setString(_penKey, value);
  }

  Future<void> _persistMeta() async {
    if (widget.documentId == null) return;
    await _ensurePrefs();
    final data = {
      'summary': _summaryCtrl.text.trim(),
      'keywords': _keywords,
      'workType': _workTypeCtrl.text.trim(),
      'category': _categoryCtrl.text.trim(),
      'ageRating': _ageRatingCtrl.text.trim(),
    };
    await _prefs!.setString(_metaKey, jsonEncode(data));
  }

  Future<void> _pickChapterCoverImage(ChapterItem chapter) async {
    if (!mounted) return;
    final hasOwnCover =
        chapter.coverPath != null && chapter.coverPath!.isNotEmpty;
    final result = await showCupertinoModalPopup<Object?>(
      context: context,
      builder: (ctx) {
        return CupertinoActionSheet(
          title: Text(
            chapter.title,
            style: const TextStyle(
              color: Color.fromARGB(255, 26, 64, 97),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          message: const Text(
            '이 회차 표지로 사용할 이미지를 선택하세요.',
            style: TextStyle(
              color: Color.fromARGB(221, 111, 131, 176),
              fontSize: 11,
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, ImageSource.camera),
              child: const Text(
                '카메라로 촬영',
                style: TextStyle(
                  color: Color.fromARGB(255, 26, 64, 97),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
              child: const Text(
                '앨범에서 선택',
                style: TextStyle(
                  color: Color.fromARGB(255, 26, 64, 97),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (hasOwnCover)
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(ctx, 'delete'),
                child: const Text(
                  '사진 삭제',

                  style: TextStyle(
                    color: Color.fromARGB(255, 26, 64, 97),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text(
              '취소',
              style: TextStyle(
                color: Color.fromARGB(255, 26, 64, 97),
                fontSize: 15,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        );
      },
    );
    if (!mounted) return;
    if (result == null) return;

    if (result == 'delete') {
      setState(() {
        final idx = _chapters.indexWhere((c) => c.index == chapter.index);
        if (idx >= 0) {
          _chapters[idx] = _chapters[idx].copyWith(coverPath: '');
        }
      });
      await _persistChapters();
      if (!mounted) return;
      AppToast.show(context, '이 회차 표지가 삭제되었습니다');
      return;
    }

    final source = result as ImageSource;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (picked == null) return;
    final tmpFile = File(picked.path);
    final appDocDir = await getApplicationDocumentsDirectory();
    final fileName =
        'chapter_cover_${widget.documentId ?? 'local'}_${chapter.index}_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
    final savedPath = p.join(appDocDir.path, fileName);

    final savedFile = await tmpFile.copy(savedPath);
    if (!mounted) return;
    setState(() {
      final idx = _chapters.indexWhere((c) => c.index == chapter.index);
      if (idx >= 0) {
        _chapters[idx] = _chapters[idx].copyWith(coverPath: savedFile.path);
      }
    });
    await _persistChapters();
    if (!mounted) return;
    AppToast.show(context, '회차 표지가 설정되었습니다');
  }

  void _showCoverPreview() {
    final path = _coverPath;
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (!file.existsSync()) {
      AppToast.show(context, '표지 파일을 찾을 수 없습니다');
      return;
    }
    showDialog(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  maxScale: 3.0,
                  minScale: 0.8,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: ClipRRect(
                      child: Image.file(file, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickCoverImage() async {
    if (!mounted) return;

    final result = await showCupertinoModalPopup<Object?>(
      context: context,
      builder: (ctx) {
        final hasCover = _coverPath != null && _coverPath!.isNotEmpty;
        return CupertinoActionSheet(
          title: const Text(
            '표지 사진 선택',
            style: TextStyle(
              color: Color.fromARGB(255, 26, 64, 97),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          message: const Text(
            '책 표지로 사용할 이미지를 선택하세요.',
            style: TextStyle(
              color: Color.fromARGB(221, 111, 131, 176),
              fontSize: 11,
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, ImageSource.camera),
              child: const Text(
                '카메라로 촬영',
                style: TextStyle(
                  color: Color.fromARGB(255, 26, 64, 97),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
              child: const Text(
                '앨범에서 선택',
                style: TextStyle(
                  color: Color.fromARGB(255, 26, 64, 97),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (hasCover)
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(ctx, 'delete'),
                child: const Text(
                  '사진 삭제',
                  style: TextStyle(
                    color: Color.fromARGB(255, 26, 64, 97),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text(
              '취소',
              style: TextStyle(
                color: Color.fromARGB(255, 26, 64, 97),
                fontSize: 15,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    if (result == null) return;

    if (result == 'delete') {
      setState(() {
        _coverPath = null;
      });
      if (!mounted) return;
      await _persistCoverPath(null);
      if (!mounted) return;
      AppToast.show(context, '표지 사진이 삭제되었습니다');
      return;
    }

    final source = result as ImageSource;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (picked == null) return;
    final tmpFile = File(picked.path);
    final appDocDir = await getApplicationDocumentsDirectory();
    final fileName =
        'cover_${widget.documentId ?? 'local'}_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';

    final savedPath = p.join(appDocDir.path, fileName);
    final savedFile = await tmpFile.copy(savedPath);
    if (!mounted) return;
    setState(() {
      _coverPath = savedFile.path;
    });
    if (!mounted) return;
    await _persistCoverPath(savedFile.path);
    if (!mounted) return;
    AppToast.show(context, '표지 사진이 설정되었습니다');
  }

  Future<void> _loadPersistedMeta() async {
    if (widget.documentId == null) return;
    await _ensurePrefs();
    final raw = _prefs!.getString(_metaKey);
    if (raw == null || raw.isEmpty) return;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    _summaryCtrl.text = (map['summary'] as String?) ?? '';
    _keywords
      ..clear()
      ..addAll(
        (map['keywords'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty),
      );
    _workTypeCtrl.text = (map['workType'] as String?) ?? '';
    _categoryCtrl.text = (map['category'] as String?) ?? '';
    _ageRatingCtrl.text = (map['ageRating'] as String?) ?? '';
    if (mounted) setState(() {});
  }

  void _addKeyword(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return;
    if (_keywords.contains(value)) return;
    setState(() {
      _keywords.add(value);
    });
    _keywordInputCtrl.clear();
    _persistMeta();
  }

  void _removeKeyword(String value) {
    setState(() {
      _keywords.remove(value);
    });
    _persistMeta();
  }

  Future<void> _initReduceTransparency() async {
    final reduce = await PlatformAccessibility.getReduceTransparencyFlag();
    if (!mounted) return;
    setState(() => _reduceTransparencyFlag = reduce);
  }

  void _ensureItemKeys() {
    if (_itemKeys.length == _pageCount) return;
    _itemKeys
      ..clear()
      ..addAll(List.generate(_pageCount, (_) => GlobalKey()));
  }

  Future<void> _loadSortPref() async {
    if (widget.documentId == null) return;
    await _ensurePrefs();
    final v = _prefs!.getString(_sortKey);
    _sortOrder =
        (v == 'new') ? ChapterSort.newestFirst : ChapterSort.oldestFirst;
  }

  Future<void> _persistSortPref() async {
    if (widget.documentId == null) return;
    await _ensurePrefs();
    await _prefs!.setString(
      _sortKey,
      _sortOrder == ChapterSort.newestFirst ? 'new' : 'old',
    );
  }

  void _applyChapterSort() {
    if (_reorderMode) return;
    final pinned = _chapters.where((c) => c.pinned).toList();
    final normal = _chapters.where((c) => !c.pinned).toList();
    if (_sortOrder == ChapterSort.oldestFirst) {
      normal.sort((a, b) => a.index.compareTo(b.index));
    } else {
      normal.sort((a, b) => b.index.compareTo(a.index));
    }
    _chapters
      ..clear()
      ..addAll(pinned)
      ..addAll(normal);
    _refreshPreviewFromChapters();
  }

  Map<String, dynamic> _chapterToJson(ChapterItem c) {
    return {
      'title': c.title,
      'index': c.index,
      'cover': c.coverPath,
      'episodeTitle': c.episodeTitle,
      'delta': c.delta,
      'sizeBytes': c.sizeBytes,
      'charCount': c.charCount,
      'updatedAt': c.updatedAt?.toIso8601String(),
      'pinned': c.pinned,
    };
  }

  void _reindexChapters() {
    for (int i = 0; i < _chapters.length; i++) {
      final cur = _chapters[i];
      _chapters[i] = ChapterItem(
        title: cur.title,
        index: i + 1,
        coverPath: cur.coverPath,
        delta: cur.delta,
        sizeBytes: cur.sizeBytes,
        charCount: cur.charCount,
        updatedAt: cur.updatedAt,
        pinned: cur.pinned,
      );
    }
  }

  Future<void> _persistChapters() async {
    if (widget.documentId == null) return;
    await _ensurePrefs();
    final list = _chapters.map(_chapterToJson).toList();
    await _prefs!.setString(_chaptersKey, jsonEncode(list));
  }

  Future<void> _loadPersistedChapters() async {
    if (widget.documentId == null) return;
    await _ensurePrefs();
    final raw = _prefs!.getString(_chaptersKey);
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    _chapters
      ..clear()
      ..addAll(
        decoded.map((e) {
          final m = e as Map<String, dynamic>;

          final updatedStr = m['updatedAt'] as String?;
          final upAt =
              (updatedStr != null && updatedStr.isNotEmpty)
                  ? DateTime.tryParse(updatedStr)
                  : null;
          return ChapterItem(
            title: m['title'] as String,
            index: (m['index'] as num).toInt(),
            coverPath: m['cover'] as String?,
            episodeTitle: m['episodeTitle'] as String?,
            delta: (m['delta'] as List).cast<Map<String, dynamic>>(),
            sizeBytes: (m['sizeBytes'] as num?)?.toInt(),
            charCount: (m['charCount'] as num?)?.toInt(),
            updatedAt: upAt,
            pinned: (m['pinned'] as bool?) ?? false,
          );
        }),
      );
    if (mounted) {
      setState(() {});
      _refreshPreviewFromChapters();
    }
  }

  bool _didAutoOpenChapter = false;

  Future<void> _maybeAutoOpenChapter() async {
    if (_didAutoOpenChapter) return;

    final idx = widget.initialOpenChapterIndex;
    if (idx == null) return;

    final found = _chapters.indexWhere((c) => c.index == idx);
    if (found < 0) return;

    _didAutoOpenChapter = true;

    if (!mounted) return;
    await _openChapterEditor(_chapters[found]);
  }

  Future<void> _persistMemos() async {
    if (widget.documentId == null) return;
    await _ensurePrefs();
    final list = _memos.map((m) => m.toJson()).toList();
    await _prefs!.setString(_memoKey, jsonEncode(list));
  }

  Future<void> _loadPersistedMemos() async {
    if (widget.documentId == null) return;
    await _ensurePrefs();
    final raw = _prefs!.getString(_memoKey);
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    _memos
      ..clear()
      ..addAll(
        decoded.map(
          (e) => _LocalMemo.fromJson(Map<String, dynamic>.from(e as Map)),
        ),
      );
    _memos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (mounted) setState(() {});
  }

  List<ChapterItem> get _previewTargetChapters {
    if (_chapters.isEmpty) return const [];
    if (_previewAllChapters || _selectedChapterIndexes.isEmpty) {
      return List.unmodifiable(_chapters);
    }
    return _chapters
        .where((c) => _selectedChapterIndexes.contains(c.index))
        .toList();
  }

  void _refreshPreviewFromChapters() {
    final targets = _previewTargetChapters;

    final merged = <Map<String, dynamic>>[];
    for (var i = 0; i < targets.length; i++) {
      merged.addAll(
        _withEpisodeTitleDelta(
          targets[i].delta,
          episodeTitle: targets[i].title,
        ),
      );

      if (i != targets.length - 1) {
        if (merged.isNotEmpty && merged.last['insert'] != '\n') {
          merged.add({'insert': '\n'});
        }
        merged.add({
          'insert': {'page_break': true},
        });
      }
    }

    if (merged.isEmpty) merged.add({'insert': '\n'});

    _delta = merged;
    _rebuildPagination();
  }

  List<Map<String, dynamic>> _buildDeltaForSave() {
    if (_chapters.isEmpty) {
      return List<Map<String, dynamic>>.from(_delta);
    }
    final merged = <Map<String, dynamic>>[];
    for (var i = 0; i < _chapters.length; i++) {
      merged.addAll(_chapters[i].delta);
      if (i != _chapters.length - 1) {
        merged.add({
          'insert': {'page_break': true},
        });
        merged.add({'insert': '\n'});
      }
    }
    return merged;
  }

  List<Map<String, dynamic>> _emptyDelta() => const [
    {'insert': '\n'},
  ];

  String _formatBytes(int? bytes) {
    if (bytes == null || bytes <= 0) return '0B';
    const kb = 1024;
    const mb = 1024 * 1024;
    const gb = 1024 * 1024 * 1024;
    if (bytes < kb) {
      return '${NumberFormat.decimalPattern().format(bytes)}B';
    } else if (bytes < mb) {
      final v = bytes / kb;
      return '${v.toStringAsFixed(1)}KB';
    } else if (bytes < gb) {
      final v = bytes / mb;
      return '${v.toStringAsFixed(1)}MB';
    } else {
      final v = bytes / gb;
      return '${v.toStringAsFixed(2)}GB';
    }
  }

  String _formatYMD(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('yyyy.MM.dd.').format(dt);
  }

  String _formatMemoDate(DateTime dt) {
    final l = dt.toLocal();
    final m = l.month.toString().padLeft(2, '0');
    final d = l.day.toString().padLeft(2, '0');
    return '$m/$d';
  }

  int _countCharsFromDelta(
    List<Map<String, dynamic>> delta, {
    bool includeNewline = false,
  }) {
    var cnt = 0;
    final spaceReg = RegExp(r'\s');
    for (final op in delta) {
      final ins = op['insert'];
      if (ins is String) {
        final cleaned = includeNewline ? ins : ins.replaceAll(spaceReg, '');
        cnt += cleaned.length;
      } else {
        cnt += 1;
      }
    }
    return cnt;
  }

  int _nextChapterIndex() {
    if (_chapters.isEmpty) return 1;
    var maxIdx = 0;
    for (final c in _chapters) {
      if (c.index > maxIdx) maxIdx = c.index;
    }
    return maxIdx + 1;
  }

  TextStyle refinedHintStyle(Color hintColor) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w300,
      letterSpacing: 0.2,
      height: 1.15,
      color: hintColor,
    );
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final saveDelta = _buildDeltaForSave();
    _delta = saveDelta;
    await _persistTitle(_titleCtrl.text.trim());
    await _persistPenName(_penNameCtrl.text.trim());

    await _persistChapters();
    await _persistMeta();
    final data = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'delta': saveDelta,
      'drawings': _drawings,
      'penName': _penNameCtrl.text.trim(),
      'updatedAt': DateTime.now().toIso8601String(),
      'index': _currentIndex,
      'documentId': widget.documentId,
      'chapters': _chapters.map(_chapterToJson).toList(),
      'summary': _summaryCtrl.text.trim(),
      'keywords': _keywords,
      'workType': _workTypeCtrl.text.trim(),
      'category': _categoryCtrl.text.trim(),
      'ageRating': _ageRatingCtrl.text.trim(),
      'coverPath': _coverPath,
    };
    if (!mounted) return;
    navigator.pop(data);
  }

  void _toggleView() {
    setState(() => _isPageView = !_isPageView);
    _ensureItemKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isPageView) {
        if (_pageCtrl.hasClients) {
          _pageCtrl.jumpToPage(_currentIndex);
        }
      } else {
        if (_itemKeys.isNotEmpty &&
            _currentIndex >= 0 &&
            _currentIndex < _itemKeys.length) {
          final ctx = _itemKeys[_currentIndex].currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 1),
              alignment: 0.02,
            );
          }
        }
      }
    });
  }

  void _addChapter() {
    final title =
        (_titleCtrl.text.trim().isEmpty) ? '책 제목' : _titleCtrl.text.trim();
    final next = _nextChapterIndex();
    final label = '$title $next화';
    setState(() {
      _chapters.add(
        ChapterItem(title: label, index: next, delta: _emptyDelta()),
      );
      _applyChapterSort();
    });
    _persistChapters();
  }

  Future<void> _openChapterEditor(ChapterItem c, {int? initialOpenPage}) async {
    final stableKey = 'doc_${widget.documentId ?? 'local'}_chapter_${c.index}';
    final settingsController = context.read<WritingSettingsController>();
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider.value(
              value: settingsController,
              child: ChapterWritePage(
                documentId: widget.documentId ?? 'local',
                chapterTitle: c.title,
                initialDeltaJson: c.delta,
                enableGlass: _glass,
                persistentKey: stableKey,
                genre: widget.genre,
                writingDate: DateTime.now(),
                initialOpenPage: initialOpenPage,
              ),
            ),
      ),
    );
    if (result == null) return;
    final newDelta = (result['delta'] as List).cast<Map<String, dynamic>>();
    final newTitle = result['title'] as String?;
    final computedSize =
        (result['sizeBytes'] as int?) ??
        utf8.encode(jsonEncode(newDelta)).length;
    final computedChars =
        (result['charCount'] as int?) ??
        _countCharsFromDelta(newDelta, includeNewline: false);
    DateTime computedUpdatedAt;
    final rawUpdated = result['updatedAt'];
    if (rawUpdated is String && rawUpdated.isNotEmpty) {
      computedUpdatedAt = DateTime.tryParse(rawUpdated) ?? DateTime.now();
    } else if (rawUpdated is DateTime) {
      computedUpdatedAt = rawUpdated;
    } else {
      computedUpdatedAt = DateTime.now();
    }
    setState(() {
      final idx = _chapters.indexWhere((x) => x.index == c.index);
      if (idx >= 0) {
        _chapters[idx] = _chapters[idx].copyWith(
          title: newTitle?.trim().isNotEmpty == true ? newTitle!.trim() : null,
          delta: newDelta,
          sizeBytes: computedSize,
          charCount: computedChars,
          updatedAt: computedUpdatedAt,
        );
      }
      _applyChapterSort();
    });
    _persistChapters();
    if (!mounted) return;
    AppToast.show(context, '회차 저장 완료');
  }

  void _enterReorderMode() {
    setState(() => _reorderMode = true);
  }

  void _exitReorderMode() {
    setState(() => _reorderMode = false);
    _applyChapterSort();
    _persistChapters();
  }

  void _reorderChapters(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= _chapters.length ||
        newIndex >= _chapters.length) {
      return;
    }
    setState(() {
      final item = _chapters.removeAt(oldIndex);
      _chapters.insert(newIndex, item);
      _reindexChapters();
    });
    _refreshPreviewFromChapters();
    _persistChapters();
  }

  void _confirmDeleteChapter(ChapterItem c) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => CupertinoActionSheet(
            title: const Text('삭제 확인'),
            message: Text('‘${_shortTitle(c.title, max: 24)}’ 회차를 삭제하시겠습니까?'),
            actions: [
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  setState(() {
                    _chapters.removeWhere((x) => x.index == c.index);
                    _reindexChapters();
                  });
                  Navigator.pop(context);
                  _refreshPreviewFromChapters();
                  _persistChapters();
                  AppToast.show(context, '삭제되었습니다');
                },
                child: const Text('삭제'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ),
    );
  }

  String _shortTitle(String title, {int max = 18}) {
    if (title.length <= max) return title;
    return '${title.substring(0, max)}…';
  }

  Future<ShareFormat?> showShareFormatOnlyDialog({
    required BuildContext context,
    Color barrierColor = const Color(0xFF0F2238),
    String dialogTitle = '공유',
    String confirmLabel = '공유',
  }) async {
    ShareFormat format = ShareFormat.pdf;

    final result = await showDialog<ShareFormat>(
      context: context,
      barrierColor: barrierColor.withValues(alpha: 0.21),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget segPill({required List<Widget> children}) {
              return Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const ui.Color.fromARGB(255, 234, 243, 255),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(children: children),
              );
            }

            Widget segItem({
              required String label,
              required bool selected,
              required VoidCallback onTap,
            }) {
              return Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      border:
                          selected
                              ? Border.all(
                                color: const Color(0xFFBFD7EE),
                                width: 1,
                              )
                              : null,
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color:
                            selected
                                ? const Color(0xFF1F3A56)
                                : const ui.Color.fromARGB(255, 144, 164, 185),
                      ),
                    ),
                  ),
                ),
              );
            }

            void confirm() => Navigator.pop(context, format);

            return Material(
              type: MaterialType.transparency,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE6ECF3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          dialogTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 12),
                        segPill(
                          children: [
                            segItem(
                              label: 'PDF',
                              selected: format == ShareFormat.pdf,
                              onTap:
                                  () => setModalState(
                                    () => format = ShareFormat.pdf,
                                  ),
                            ),
                            segItem(
                              label: 'PNG',
                              selected: format == ShareFormat.png,
                              onTap:
                                  () => setModalState(
                                    () => format = ShareFormat.png,
                                  ),
                            ),
                            segItem(
                              label: 'JPG',
                              selected: format == ShareFormat.jpg,
                              onTap:
                                  () => setModalState(
                                    () => format = ShareFormat.jpg,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  overlayColor: Colors.transparent,
                                  splashFactory: NoSplash.splashFactory,
                                ),
                                child: const Text(
                                  '닫기',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F3A56),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: const WidgetStatePropertyAll(
                                    Color(0xFFE9F7FF),
                                  ),
                                  foregroundColor: const WidgetStatePropertyAll(
                                    Color(0xFF1F3A56),
                                  ),
                                  elevation: const WidgetStatePropertyAll(0.0),
                                  shadowColor: const WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),
                                  surfaceTintColor:
                                      const WidgetStatePropertyAll(
                                        Colors.transparent,
                                      ),
                                  overlayColor: const WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  padding: const WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                                onPressed: confirm,
                                child: Text(
                                  confirmLabel,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    return result;
  }

  void _showChapterMoreDialog(ChapterItem c) {
    final theme = _glassTheme;
    showDialog(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: GlassContainer(
              theme: theme,
              borderRadius: 20,
              padding: const EdgeInsets.only(
                top: 16,
                left: 12,
                right: 12,
                bottom: 8,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 310),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '더보기',

                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassActionButton(
                      theme: theme,
                      icon: Icons.swap_vert,
                      label: '회차 이동',
                      onPressed: () {
                        Navigator.pop(context);
                        _enterReorderMode();
                        AppToast.show(context, '이동 모드입니다. 드래그하여 순서를 바꾸세요');
                      },
                    ),
                    const SizedBox(height: 8),
                    GlassActionButton(
                      theme: theme,
                      icon: Icons.ios_share,
                      label: '‘${_shortTitle(c.title)}’ 공유',
                      onPressed: () async {
                        Navigator.pop(context);
                        final bytes = await buildBookPdf(
                          chapters: [c],
                          showChapterTitle: true,
                        );
                        if (!mounted) return;
                        final pagesCount = await pdfPageCountFromBytes(bytes);
                        if (!mounted) return;
                        final format = await showShareFormatOnlyDialog(
                          context: context,
                          dialogTitle: '공유',
                          confirmLabel: '공유',
                        );
                        if (!mounted || format == null) return;

                        final pick = SharePickResult(
                          format: format,
                          rangeMode: ShareRangeMode.all,
                          startPage: 1,
                          endPage: pagesCount,
                        );

                        final box = context.findRenderObject() as RenderBox?;
                        final origin =
                            box == null
                                ? null
                                : (box.localToGlobal(Offset.zero) & box.size);
                        await sharePdfBytesWithPick(
                          title: c.title,
                          pdfBytes: bytes,
                          pick: pick,
                          toast: (msg) => AppToast.show(context, msg),
                          sharePositionOrigin: origin,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    GlassActionButton(
                      theme: theme,
                      icon: Icons.delete_outline,
                      label: '‘${_shortTitle(c.title)}’ 삭제',
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDeleteChapter(c);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '닫기',
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _openMemoEditor({int? index}) async {
    final initial =
        (index != null && index >= 0 && index < _memos.length)
            ? _memos[index].text
            : '';
    final edited = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => _InlineMemoEditor(initialText: initial),
        transitionDuration: const Duration(milliseconds: 120),

        reverseTransitionDuration: const Duration(milliseconds: 120),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    if (edited == null) return;
    final text = edited.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();
    setState(() {
      if (index != null && index >= 0 && index < _memos.length) {
        _memos[index] = _LocalMemo(text, now);
      } else {
        _memos.insert(0, _LocalMemo(text, now));
      }
      _memos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
    await _persistMemos();
  }

  void _confirmDeleteMemo(int index) {
    if (index < 0 || index >= _memos.length) return;
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => CupertinoActionSheet(
            title: const Text('메모 삭제'),
            message: const Text('이 메모를 삭제하시겠습니까?'),
            actions: [
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () async {
                  setState(() {
                    _memos.removeAt(index);
                  });
                  Navigator.pop(context);
                  await _persistMemos();
                  if (!mounted) return;
                  AppToast.show(context, '메모가 삭제되었습니다');
                },
                child: const Text('삭제'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ),
    );
  }

  void _hideCloudSubmenu() {
    _cloudSubmenuOpenVN.value = false;
    _cloudSubmenuEntry?.remove();
    _cloudSubmenuEntry = null;
    _measuredCloudSubmenuHeight = null;
  }

  void _showCloudSubmenu() {
    if (_cloudSubmenuEntry != null) {
      _hideCloudSubmenu();
      return;
    }

    _hideImageSubmenu();
    _hideEpubSubmenu();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _cloudSubmenuOpenVN.value = true;
    _cloudSubmenuEntry = OverlayEntry(
      builder: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_cloudSubmenuEntry == null) return;
          final ctx = _cloudSubmenuKey.currentContext;
          if (ctx == null) return;
          final ro = ctx.findRenderObject();
          if (ro is! RenderBox || !ro.hasSize) return;
          final newH = ro.size.height;
          if (_measuredCloudSubmenuHeight != null &&
              (newH - _measuredCloudSubmenuHeight!).abs() < 0.5) {
            return;
          }
          _measuredCloudSubmenuHeight = newH;
          _cloudSubmenuEntry!.markNeedsBuild();
        });

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideCloudSubmenu,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _cloudLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,
              offset: const Offset(0, 0),
              child: Material(
                color: Colors.transparent,
                child: KeyedSubtree(
                  key: _cloudSubmenuKey,
                  child: FrostedContainer(
                    enableGlass: true,
                    blurSigma: 16,
                    borderRadius: 22,
                    showBorder: false,
                    backgroundColor: Colors.white.withValues(alpha: 0.96),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 170),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: _hideCloudSubmenu,
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Color(0xFF1F3A56),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  '로컬 / 클라우드',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 30),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _PdfPopupItem(
                            icon: Icons.cloud_outlined,
                            label: 'iCloud',
                            onTap: () {},
                          ),
                          const SizedBox(height: 6),
                          _PdfPopupItem(
                            icon: Icons.cloud_outlined,
                            label: 'Google Drive',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_cloudSubmenuEntry!);
  }

  void _hideEpubSubmenu() {
    _epubSubmenuOpenVN.value = false;
    _epubSubmenuEntry?.remove();
    _epubSubmenuEntry = null;
    _measuredEpubSubmenuHeight = null;
  }

  void _showEpubSubmenu() {
    if (_epubSubmenuEntry != null) {
      _hideEpubSubmenu();
      return;
    }

    _hideCloudSubmenu();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _epubSubmenuOpenVN.value = true;
    _epubSubmenuEntry = OverlayEntry(
      builder: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_epubSubmenuEntry == null) return;
          final ctx = _epubSubmenuKey.currentContext;
          if (ctx == null) return;
          final ro = ctx.findRenderObject();
          if (ro is! RenderBox || !ro.hasSize) return;
          final newH = ro.size.height;
          if (_measuredEpubSubmenuHeight != null &&
              (newH - _measuredEpubSubmenuHeight!).abs() < 0.5) {
            return;
          }
          _measuredEpubSubmenuHeight = newH;
          _epubSubmenuEntry!.markNeedsBuild();
        });

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideEpubSubmenu,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _epubLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,
              offset: const Offset(0, 0),
              child: Material(
                color: Colors.transparent,
                child: KeyedSubtree(
                  key: _epubSubmenuKey,
                  child: FrostedContainer(
                    enableGlass: true,
                    blurSigma: 16,
                    borderRadius: 22,
                    showBorder: false,
                    backgroundColor: Colors.white.withValues(alpha: 0.96),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 175),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: _hideEpubSubmenu,
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Color(0xFF1F3A56),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'ePub',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 30),
                            ],
                          ),
                          const SizedBox(height: 10),

                          _PdfPopupItem(
                            icon: Icons.description_outlined,
                            label: 'DOXK : MS Word',
                            onTap: () {},
                          ),
                          const SizedBox(height: 6),
                          _PdfPopupItem(
                            icon: Icons.text_snippet_outlined,
                            label: 'TXT',
                            onTap: () {},
                          ),
                          const SizedBox(height: 6),
                          _PdfPopupItem(
                            icon: Icons.code_outlined,
                            label: 'Markdown',
                            onTap: () {},
                          ),
                          const SizedBox(height: 6),
                          _PdfPopupItem(
                            icon: Icons.archive_outlined,
                            label: 'zip',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_epubSubmenuEntry!);
  }

  void _hidePdfSubmenu() {
    _pdfSubmenuEntry?.remove();
    _pdfSubmenuEntry = null;
    _measuredSubmenuHeight = null;
    _pdfSubmenuOpenVN.value = false;
  }

  static const double _previewPopupWidth = 165;

  void _showPdfSubmenu() {
    if (_pdfSubmenuEntry != null) {
      _hidePdfSubmenu();
      return;
    }

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _pdfSubmenuOpenVN.value = true;
    _pdfSubmenuEntry = OverlayEntry(
      builder: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pdfSubmenuEntry == null) return;
          final ctx = _pdfSubmenuKey.currentContext;
          if (ctx == null) return;
          final ro = ctx.findRenderObject();
          if (ro is! RenderBox || !ro.hasSize) return;
          final newH = ro.size.height;
          if (_measuredSubmenuHeight != null &&
              (newH - _measuredSubmenuHeight!).abs() < 0.5) {
            return;
          }
          _measuredSubmenuHeight = newH;
          _pdfSubmenuEntry!.markNeedsBuild();
        });

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hidePdfSubmenu,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _pdfPreviewLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,
              offset: const Offset(0, -105),
              child: Material(
                color: Colors.transparent,
                child: KeyedSubtree(
                  key: _pdfSubmenuKey,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _imageSubmenuOpenVN,
                    builder: (context, imageOpen, child) {
                      final scale = imageOpen ? 0.96 : 1.0;
                      final sigma = imageOpen ? 6.0 : 0.0;
                      final opacity = imageOpen ? 0.72 : 1.0;
                      return AnimatedScale(
                        scale: scale,
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        child: AnimatedOpacity(
                          opacity: opacity,
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOut,
                          child: ImageFiltered(
                            imageFilter: ui.ImageFilter.blur(
                              sigmaX: sigma,
                              sigmaY: sigma,
                            ),
                            child: child,
                          ),
                        ),
                      );
                    },

                    child: FrostedContainer(
                      enableGlass: true,
                      blurSigma: 16,
                      borderRadius: 22,
                      showBorder: false,
                      backgroundColor: Colors.white.withValues(alpha: 0.96),
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _previewPopupWidth,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: _hidePdfSubmenu,
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Color(0xFF1F3A56),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    'PDF',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 30),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _PdfPopupItem(
                              icon: Icons.menu_book_outlined,
                              label: '전체 회차',
                              fontSize: 15.5,
                              onTap: () async {
                                setState(() {
                                  _previewAllChapters = true;
                                  _selectedChapterIndexes.clear();
                                  _refreshPreviewFromChapters();
                                });

                                _hidePdfSubmenu();
                                final bytes = await buildBookPdf(
                                  chapters: _previewTargetChapters,
                                );
                                if (!mounted) return;
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => CustomPdfPreviewPage(
                                          title: '전체 회차',
                                          pdfBytes: bytes,
                                          chapters: _chapters,
                                          reduceTransparency:
                                              _reduceTransparencyFlag,
                                        ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 6),
                            _PdfPopupItem(
                              icon: Icons.checklist_outlined,
                              label: '선택 회차',
                              fontSize: 15.5,
                              onTap: () async {
                                _hidePdfSubmenu();
                                final allChapters = _chapters;
                                final picked = await showPdfChapterPickerDialog(
                                  context: context,
                                  chapters: allChapters,
                                  glassTheme: GlassTheme.fromFlags(
                                    reduceTransparency: _reduceTransparencyFlag,
                                  ),
                                  barrierColor: Colors.transparent,
                                );
                                if (picked == null) return;
                                final List<ChapterItem> targetChapters =
                                    picked.useAll
                                        ? allChapters
                                        : picked.selected
                                            .map((i) => allChapters[i])
                                            .toList(growable: false);
                                if (targetChapters.isEmpty) {
                                  if (!mounted) return;
                                  AppToast.show(context, '선택된 회차가 없습니다');
                                  return;
                                }
                                try {
                                  final bytes = await buildBookPdf(
                                    chapters: targetChapters,
                                    showChapterTitle: true,
                                  );
                                  if (!mounted) return;
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => CustomPdfPreviewPage(
                                            title: '선택 회차',
                                            pdfBytes: bytes,
                                            chapters: allChapters,
                                            reduceTransparency:
                                                _reduceTransparencyFlag,
                                          ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  AppToast.show(context, 'PDF 생성 실패: $e');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_pdfSubmenuEntry!);
  }

  void _showPreviewChapterSelector() {
    if (_chapters.isEmpty) {
      AppToast.show(context, '먼저 회차를 추가해 주세요');
      return;
    }
    final theme = _glassTheme;
    final tmpSelected = Set<int>.from(_selectedChapterIndexes);
    var useAll = _previewAllChapters;
    showDialog(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void applyAndClose() {
              setState(() {
                _previewAllChapters = useAll;
                _selectedChapterIndexes
                  ..clear()
                  ..addAll(tmpSelected);
                _refreshPreviewFromChapters();
              });
              Navigator.pop(context);
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 24,
              ),
              child: GlassContainer(
                theme: theme,
                borderRadius: 20,
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 10,
                  right: 10,
                  bottom: 10,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 230),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '책 미리보기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7EFF8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setModalState(() => useAll = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        useAll
                                            ? Colors.white
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '모든 회차',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          useAll
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                      color:
                                          useAll
                                              ? const Color(0xFF1F3A56)
                                              : const Color(0xFF607D8B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: GestureDetector(
                                onTap:
                                    () => setModalState(() => useAll = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        !useAll
                                            ? Colors.white
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '선택 회차',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          !useAll
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                      color:
                                          !useAll
                                              ? const Color(0xFF1F3A56)
                                              : const Color(0xFF607D8B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (!useAll)
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: _chapters.length,

                            itemBuilder: (context, i) {
                              final c = _chapters[i];
                              final checked = tmpSelected.contains(c.index);
                              return CheckboxListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                value: checked,
                                title: Text(
                                  c.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13.5),
                                ),
                                activeColor: theme.accentColor,
                                checkColor: Colors.white,
                                onChanged: (v) {
                                  setModalState(() {
                                    if (v == true) {
                                      tmpSelected.add(c.index);
                                    } else {
                                      tmpSelected.remove(c.index);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                '닫기',
                                style: TextStyle(
                                  color: Color(0xFF1F3A56),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const ui.Color.fromARGB(
                                  255,
                                  233,
                                  247,
                                  255,
                                ),
                                foregroundColor: const Color(0xFF1F3A56),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: applyAndClose,
                              child: const Text('적용'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGlobalSettingsTab(Color silver, WritingSettings settings) {
    const labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );
    return Column(
      children: [
        const SizedBox(height: 7),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    const Text('테마', style: labelStyle),
                    const Spacer(),
                    Row(
                      children: [
                        _ThemeDot(
                          themeId: 'light',

                          color: Colors.white,
                          borderColor: const Color.fromARGB(255, 255, 255, 255),
                          isSelected: settings.themeId == 'light',
                          onTap: () {
                            context
                                .read<WritingSettingsController>()
                                .updateTheme('light');
                          },
                        ),
                        const SizedBox(width: 10),
                        _ThemeDot(
                          themeId: 'dark',
                          color: const Color.fromARGB(255, 0, 0, 0),
                          borderColor: Colors.black,
                          isSelected: settings.themeId == 'dark',
                          onTap: () {
                            context
                                .read<WritingSettingsController>()
                                .updateTheme('dark');
                          },
                        ),
                        const SizedBox(width: 10),
                        _ThemeDot(
                          themeId: 'darkGreen',
                          color: const Color.fromARGB(255, 10, 30, 26),
                          borderColor: const Color.fromARGB(255, 10, 30, 26),
                          isSelected: settings.themeId == 'darkGreen',
                          onTap: () {
                            context
                                .read<WritingSettingsController>()
                                .updateTheme('darkGreen');
                          },
                        ),
                        const SizedBox(width: 10),
                        _ThemeDot(
                          themeId: 'space',
                          color: const Color(0xFF05081A),
                          borderColor: const Color(0xFF4C6FFF),
                          isSelected: settings.themeId == 'space',
                          onTap: () {
                            context
                                .read<WritingSettingsController>()
                                .updateTheme('space');
                          },
                        ),
                        const SizedBox(width: 10),

                        _ThemeDot(
                          themeId: 'lightSky',
                          color: const Color(0xFFB3E5FC),
                          borderColor: const Color.fromARGB(255, 123, 213, 255),
                          isSelected: settings.themeId == 'lightSky',
                          onTap: () {
                            context
                                .read<WritingSettingsController>()
                                .updateTheme('lightSky');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _settingsDivider(silver),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    const Text('폰트', style: labelStyle),
                    const Spacer(),
                    Row(
                      children: [
                        _FontChip(
                          label: '기본체',
                          selected: settings.fontFamily == 'system',
                          onTap: () {
                            context
                                .read<WritingSettingsController>()
                                .updateFontFamily('system');
                          },
                        ),
                        const SizedBox(width: 8),
                        _FontChip(
                          label: '바탕체',
                          selected: settings.fontFamily == 'batang',
                          onTap: () {
                            context
                                .read<WritingSettingsController>()
                                .updateFontFamily('batang');
                          },
                        ),
                        const SizedBox(width: 8),
                        _FontChip(
                          label: '고딕체',
                          selected: settings.fontFamily == 'Inter',
                          onTap: () {
                            context
                                .read<WritingSettingsController>()
                                .updateFontFamily('Inter');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _SettingsStepperRow(
                label: '줄 간격',
                valueText: settings.lineHeight.toStringAsFixed(1),
                onMinus: () {
                  final newH = (settings.lineHeight - 0.5).clamp(1.0, 3.0);
                  context.read<WritingSettingsController>().updateLineHeight(
                    newH,
                  );
                },
                onPlus: () {
                  final newH = (settings.lineHeight + 0.5).clamp(1.0, 3.0);
                  context.read<WritingSettingsController>().updateLineHeight(
                    newH,
                  );
                },
              ),
              _settingsDivider(silver),
              _SettingsStepperRow(
                label: '글 간격',
                valueText: settings.letterSpacing.toStringAsFixed(1),
                onMinus: () {
                  final newLs = (settings.letterSpacing - 0.1).clamp(0.0, 1.0);
                  context.read<WritingSettingsController>().updateLetterSpacing(
                    newLs,
                  );
                },
                onPlus: () {
                  final newLs = (settings.letterSpacing + 0.1).clamp(0.0, 1.0);
                  context.read<WritingSettingsController>().updateLetterSpacing(
                    newLs,
                  );
                },
              ),
              _settingsDivider(silver),
              _SettingsStepperRow(
                label: '여백',
                valueText: settings.horizontalMargin.round().toString(),
                onMinus: () {
                  final newM = (settings.horizontalMargin - 5).clamp(0.0, 30.0);
                  context
                      .read<WritingSettingsController>()
                      .updateHorizontalMargin(newM);
                },
                onPlus: () {
                  final newM = (settings.horizontalMargin + 5).clamp(0.0, 30.0);
                  context
                      .read<WritingSettingsController>()
                      .updateHorizontalMargin(newM);
                },
              ),
              const SizedBox(height: 12),
              _MiniReadingPreview(settings: settings),
            ],
          ),
        ),

        const SizedBox(height: 0),
      ],
    );
  }

  Widget _settingsDivider(Color silver) {
    return const SizedBox(height: 5);
  }

  Widget _buildChapterThumbnail(ChapterItem c) {
    final effectivePath =
        (c.coverPath != null && c.coverPath!.isNotEmpty)
            ? c.coverPath!
            : _coverPath;
    return _MiniCoverCard(width: 79, imagePath: effectivePath);
  }

  Widget _chapterRow(ChapterItem c, Color silver) {
    const subColor = Color.fromARGB(221, 83, 129, 159);
    final safeSize = c.sizeBytes ?? utf8.encode(jsonEncode(c.delta)).length;
    final safeChars = c.charCount ?? _countCharsFromDelta(c.delta);
    final safeUpdatedAt = c.updatedAt;
    return Dismissible(
      key: ValueKey('chapter_${c.index}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFD0E8FF).withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.85),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF90CAF9).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.push_pin, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              c.pinned ? '고정 해제' : '회차 고정',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        setState(() {
          final idx = _chapters.indexWhere((x) => x.index == c.index);
          if (idx >= 0) {
            _chapters[idx] = _chapters[idx].copyWith(pinned: !c.pinned);
            _applyChapterSort();
            _persistChapters();
          }
        });
        AppToast.show(context, c.pinned ? '고정 해제됨' : '회차 고정됨');
        return false;
      },
      child: InkWell(
        onTap: () => _openChapterEditor(c),
        onLongPress: () => _showChapterMoreDialog(c),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: FrostedContainer(
          enableGlass: _glass,
          borderRadius: 10,
          padding: const EdgeInsets.fromLTRB(1, 6, 10, 1),
          backgroundColor: Colors.white.withValues(alpha: _glass ? 0.92 : 1.0),
          showBorder: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _pickChapterCoverImage(c),
                child: _buildChapterThumbnail(c),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (c.pinned)
                          const Padding(
                            padding: EdgeInsets.only(right: 5),
                            child: Icon(
                              Icons.star,
                              size: 20,
                              color: Color.fromARGB(255, 255, 224, 132),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            c.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w400,
                              color:
                                  c.pinned
                                      ? const Color(0xFF64B5F6)
                                      : Colors.black87,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_formatBytes(safeSize)} · ${NumberFormat.decimalPattern().format(safeChars)}자 · ${_formatYMD(safeUpdatedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: subColor,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewTab(Color silver, WritingSettings settings) {
    _ensureItemKeys();

    return Column(
      children: [
        Transform.translate(
          offset: const Offset(0, -10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
            child: Theme(
              data: Theme.of(context).copyWith(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 17),
                    child: IconButton(
                      icon: const Icon(
                        Icons.checklist_outlined,
                        size: 20,
                        color: Color.fromARGB(255, 88, 109, 129),
                      ),
                      onPressed: _showPreviewChapterSelector,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 39,
                        minHeight: 39,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _isPageView ? Icons.view_carousel : Icons.view_agenda,
                      color: const Color.fromARGB(255, 88, 109, 129),
                      size: 24,
                    ),
                    onPressed: _toggleView,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        ),

        Transform.translate(
          offset: const Offset(0, -10),
          child: Padding(
            padding: EdgeInsets.zero,
            child: LayoutBuilder(
              builder: (context, c) {
                final parentW = c.maxWidth;
                final cardW = parentW * 0.95;
                final cardH = cardW * 297 / 210;
                final viewportH = cardH / 0.90;

                final prevW = _lastLayoutWidth;
                _lastLayoutWidth = cardW;

                final widthChanged =
                    prevW != null && (cardW - prevW).abs() > 0.5;
                if (widthChanged) {
                  _resetPreviewCaches(notify: false);
                  _pageWidthPx = cardW;
                  _pageHeightPx = cardH;
                  _scheduleRebuild(delay: const Duration(milliseconds: 80));
                } else if (_pageWidthPx <= 0 || _pageHeightPx <= 0) {
                  _pageWidthPx = cardW;
                  _pageHeightPx = cardH;
                  _scheduleRebuild(delay: Duration.zero);
                }

                if (_isPageView) {
                  return SizedBox(
                    width: parentW,
                    height: viewportH,
                    child: PageView.builder(
                      controller: _pageCtrl,
                      itemCount: _pageCount,
                      itemBuilder: (context, index) {
                        return Align(
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              final globalPage = index + 1;
                              await _openEditorFromPreviewPage(globalPage);
                            },
                            child: _buildContentCard(index, settings: settings),
                          ),
                        );
                      },
                    ),
                  );
                }

                return SizedBox(
                  width: parentW,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pageCount,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              final globalPage = index + 1;
                              await _openEditorFromPreviewPage(globalPage);
                            },
                            child: _buildContentCard(index, settings: settings),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildChaptersTab(Color silver) {
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(0, -10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    _reorderMode ? '회차 이동 중' : '전체 ${_chapters.length}회',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Spacer(),
                if (!_reorderMode)
                  _ChapterSortToggle(
                    silver: silver,
                    sortOrder: _sortOrder,
                    onTap: () {
                      setState(() {
                        _sortOrder =
                            (_sortOrder == ChapterSort.oldestFirst)
                                ? ChapterSort.newestFirst
                                : ChapterSort.oldestFirst;
                        _applyChapterSort();
                      });
                      _persistSortPref();
                    },
                  ),
                IconButton(
                  onPressed: _reorderMode ? _exitReorderMode : _addChapter,

                  icon: Icon(
                    _reorderMode ? Icons.check : Icons.add,
                    size: 22,
                    color: Colors.black87,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child:
              _chapters.isEmpty
                  ? const Column(
                    children: [
                      SizedBox(height: 12),
                      Text(
                        '우측 상단의 + 버튼을 눌러 회차를 추가하세요.',
                        style: TextStyle(
                          color: Color.fromARGB(221, 83, 129, 159),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                  )
                  : _reorderMode
                  ? ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _chapters.length,
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        color: Colors.transparent,
                        child: Transform.scale(scale: 1.02, child: child),
                      );
                    },
                    onReorder: _reorderChapters,
                    itemBuilder: (_, i) {
                      final c = _chapters[i];
                      return Container(
                        key: ValueKey('chapter_${c.index}'),
                        margin: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            ReorderableDragStartListener(
                              index: i,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.drag_indicator,
                                  color: silver.withValues(alpha: 1.0),
                                ),
                              ),
                            ),
                            Expanded(child: _chapterRow(c, silver)),
                          ],
                        ),
                      );
                    },
                  )
                  : Column(
                    children: List.generate(
                      _chapters.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _chapterRow(_chapters[i], silver),
                      ),
                    ),
                  ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMemoTab() {
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(0, -10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '책 메모',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _openMemoEditor(),
                  icon: const Icon(Icons.add, size: 22, color: Colors.black87),
                  tooltip: '새 메모',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child:
              _memos.isEmpty
                  ? const Column(
                    children: [
                      SizedBox(height: 12),
                      Text(
                        '이 책과 관련된 메모를 추가해 보세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(221, 83, 129, 159),
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                  )
                  : _buildMemoSections(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMetaTab(Color silver) {
    final labelStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.black.withValues(alpha: 0.78),
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 13),
              FrostedContainer(
                enableGlass: _glass,
                borderRadius: 10,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                backgroundColor: Colors.white.withValues(
                  alpha: _glass ? 0.96 : 1.0,
                ),
                showBorder: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text('작품 소개', style: labelStyle),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _summaryCtrl,
                      maxLines: 50,
                      minLines: 1,
                      onChanged: (_) => _persistMeta(),
                      decoration: const InputDecoration(
                        hintText: '작품의 분위기, 줄거리, 세계관 등을 간단히 소개해 주세요.',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(221, 83, 129, 159),
                          fontSize: 12,
                          height: 1.35,
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      style: const TextStyle(fontSize: 14.5, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FrostedContainer(
                enableGlass: _glass,
                borderRadius: 10,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                backgroundColor: Colors.white.withValues(
                  alpha: _glass ? 0.96 : 1.0,
                ),
                showBorder: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('키워드', style: labelStyle),
                    const SizedBox(height: 4),
                    const Text(
                      '#로맨스 #성장물 #판타지 처럼 자유롭게 추가하세요.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(221, 83, 129, 159),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        for (final k in _keywords)
                          InputChip(
                            label: Text(
                              '#$k',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            onDeleted: () => _removeKeyword(k),
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 13,
                              color: Colors.black54,
                            ),
                            backgroundColor: const Color.fromARGB(
                              101,
                              193,
                              229,
                              247,
                            ),
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.transparent),
                            ),
                          ),
                        if (_keywords.isEmpty)
                          const Text(
                            '아직 등록된 키워드가 없습니다.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(184, 132, 166, 191),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _keywordInputCtrl,
                            textInputAction: TextInputAction.done,
                            onSubmitted: _addKeyword,
                            decoration: const InputDecoration(
                              hintText: '키워드 입력 후 Enter',
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            style: const TextStyle(fontSize: 13.5),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: () => _addKeyword(_keywordInputCtrl.text),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FrostedContainer(
                enableGlass: _glass,
                borderRadius: 10,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                backgroundColor: Colors.white.withValues(
                  alpha: _glass ? 0.96 : 1.0,
                ),
                showBorder: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('상세 정보', style: labelStyle),
                    const SizedBox(height: 8),
                    _MetaTextFieldRow(
                      label: '글 / 원작',
                      controller: _workTypeCtrl,
                      hintText: '글 / 원작 정보를 입력하세요.',
                      onChanged: (_) => _persistMeta(),
                    ),
                    const SizedBox(height: 8),
                    _MetaTextFieldRow(
                      label: '작품 분류',
                      controller: _categoryCtrl,
                      hintText: '작품 분류를 입력하세요.',
                      onChanged: (_) => _persistMeta(),
                    ),
                    const SizedBox(height: 8),
                    _MetaTextFieldRow(
                      label: '연령 등급',
                      controller: _ageRatingCtrl,
                      hintText: '연령 등급을 입력하세요.',
                      onChanged: (_) => _persistMeta(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMemoSections() {
    final Map<String, List<int>> grouped = {};
    for (var i = 0; i < _memos.length; i++) {
      final m = _memos[i];
      final key = _formatMemoDate(m.updatedAt);
      (grouped[key] ??= <int>[]).add(i);
    }
    final nowYear = DateTime.now().year;
    final keys =
        grouped.keys.toList()..sort((a, b) {
          final am = int.parse(a.substring(0, 2));
          final ad = int.parse(a.substring(3, 5));
          final bm = int.parse(b.substring(0, 2));
          final bd = int.parse(b.substring(3, 5));
          final adt = DateTime(nowYear, am, ad);
          final bdt = DateTime(nowYear, bm, bd);
          return bdt.compareTo(adt);
        });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var s = 0; s < keys.length; s++) ...[
          Padding(
            padding: EdgeInsets.only(
              left: 7,
              right: 4,
              bottom: s == 0 ? 10 : 4,
              top: s == 0 ? 0 : 2,
            ),
            child: Text(
              keys[s],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(221, 83, 129, 159),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,

              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.90,
            ),
            itemCount: grouped[keys[s]]!.length,
            itemBuilder: (_, i) {
              final memoIndex = grouped[keys[s]]![i];
              final m = _memos[memoIndex];
              return GestureDetector(
                onTap: () => _openMemoEditor(index: memoIndex),
                onLongPress: () => _confirmDeleteMemo(memoIndex),
                child: MemoSquareCard(
                  text: m.text,
                  onTap: () => _openMemoEditor(index: memoIndex),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildContentCard(int index, {required WritingSettings settings}) {
    final themeId = settings.themeId;
    final bool isSpace = themeId == 'space';
    final bool isLightSky = themeId == 'lightSky';
    Color pageBg;
    switch (themeId) {
      case 'dark':
        pageBg = const Color.fromARGB(255, 0, 0, 0);
        break;
      case 'darkGreen':
        pageBg = const Color.fromARGB(255, 10, 30, 26);
        break;
      case 'space':
        pageBg = const Color(0xFF05081A);
        break;
      case 'lightSky':
        pageBg = const Color(0xFFE3F2FD);
        break;
      default:
        pageBg = Colors.transparent;
    }

    return LayoutBuilder(
      builder: (context, c) {
        final maxCardWidth = c.maxWidth * 0.95;
        final pageHeight = maxCardWidth * 297 / 210;

        final maxCardHeight = c.maxHeight * 0.90;
        final cardHeight =
            pageHeight > maxCardHeight ? maxCardHeight : pageHeight;
        final cardW = maxCardWidth;
        final cardH = cardHeight;
        return Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: cardW,
                height: cardH,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color.fromARGB(255, 138, 176, 201),
                        width: 0.4,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child:
                              (isSpace || isLightSky)
                                  ? DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient:
                                          isSpace
                                              ? const LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color.fromARGB(
                                                    255,
                                                    6,
                                                    10,
                                                    38,
                                                  ),
                                                  Color.fromARGB(
                                                    255,
                                                    20,
                                                    27,
                                                    69,
                                                  ),
                                                  Color.fromARGB(
                                                    246,
                                                    33,
                                                    23,
                                                    38,
                                                  ),
                                                ],
                                              )
                                              : const LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color.fromARGB(
                                                    255,
                                                    241,
                                                    249,
                                                    255,
                                                  ),
                                                  Color.fromARGB(
                                                    255,
                                                    180,
                                                    225,
                                                    255,
                                                  ),

                                                  Color.fromARGB(
                                                    255,
                                                    241,
                                                    249,
                                                    255,
                                                  ),
                                                ],
                                              ),
                                    ),
                                  )
                                  : ColoredBox(color: pageBg),
                        ),
                        if (isSpace) ...[
                          const Positioned.fill(
                            child: _AnimatedStarField(starCount: 260),
                          ),
                          const Positioned.fill(
                            child: IgnorePointer(child: _ShootingStarLayer()),
                          ),
                        ] else if (isLightSky) ...[
                          const Positioned.fill(
                            child: CustomPaint(painter: _SunRayPainter()),
                          ),
                        ],
                        Positioned.fill(
                          child: FutureBuilder<ui.Image?>(
                            future: _renderImageForPage(index + 1),
                            builder: (context, snap) {
                              final img = snap.data;
                              if (img == null) return const SizedBox.expand();

                              return FittedBox(
                                fit: BoxFit.contain,
                                child: SizedBox(
                                  width: img.width.toDouble(),
                                  height: img.height.toDouble(),
                                  child: RawImage(
                                    image: img,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '페이지 ${index + 1} / $_pageCount',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 152, 171, 195),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _hideImageSubmenu() {
    _imageSubmenuOpenVN.value = false;
    _imageSubmenuEntry?.remove();
    _imageSubmenuEntry = null;
  }

  void _showPdfSharePopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'pdf_popup',
      barrierDismissible: true,
      barrierColor: const Color(0xFF0F2238).withValues(alpha: 0.13),

      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 64,
                right: 16,
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _pdfSubmenuOpenVN,
                      _pdfExportSubmenuOpenVN,
                      _imageSubmenuOpenVN,
                      _cloudSubmenuOpenVN,
                      _epubSubmenuOpenVN,
                    ]),
                    builder: (context, _) {
                      final anyOpen =
                          _pdfSubmenuOpenVN.value ||
                          _pdfExportSubmenuOpenVN.value ||
                          _imageSubmenuOpenVN.value ||
                          _cloudSubmenuOpenVN.value ||
                          _epubSubmenuOpenVN.value;

                      final scale = anyOpen ? 0.92 : 1.0;
                      final blur = anyOpen ? 1.0 : 0.0;
                      final opacity = anyOpen ? 0.70 : 1.0;
                      Widget popup = CompositedTransformTarget(
                        link: _pdfPreviewLink,
                        child: FrostedContainer(
                          enableGlass: true,
                          blurSigma: 16,
                          borderRadius: 16,
                          showBorder: false,
                          backgroundColor: Colors.white.withValues(alpha: 0.96),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 10,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _PdfPopupItem(
                                  icon: Icons.picture_as_pdf_outlined,
                                  label: 'PDF',
                                  onTap: _showPdfSubmenu,
                                ),
                                const SizedBox(height: 6),

                                CompositedTransformTarget(
                                  link: _cloudLink,
                                  child: _PdfPopupItem(
                                    icon: Icons.download_outlined,
                                    label: '로컬 / 클라우드',
                                    onTap: _showCloudSubmenu,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                CompositedTransformTarget(
                                  link: _epubLink,
                                  child: _PdfPopupItem(
                                    icon: Icons.auto_stories_outlined,
                                    label: 'ePub 전자책용',
                                    onTap: _showEpubSubmenu,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );

                      popup = ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(
                          sigmaX: blur,
                          sigmaY: blur,
                        ),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 140),
                          opacity: opacity,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 140),
                            scale: scale,
                            child: popup,
                          ),
                        ),
                      );
                      return popup;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final genreText = genreLabel(widget.genre);
    final writingSettings = _settingsController.settings;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor =
        isDark
            ? Colors.white.withValues(alpha: 0.60)
            : Colors.black.withValues(alpha: 0.38);
    const silver = Color.fromARGB(221, 83, 129, 159);
    _ensureItemKeys();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Book Builder Page',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.share_outlined,
                                size: 21,
                                color: Color.fromARGB(255, 107, 148, 181),
                              ),
                              onPressed: () {
                                _showPdfSharePopup(context);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 31,
                                minHeight: 31,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                size: 27,
                                color: Color.fromARGB(255, 107, 148, 181),
                              ),
                              onPressed: _save,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    genreText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ui.Color.fromARGB(255, 118, 156, 183),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: FrostedContainer(
                  enableGlass: _glass,
                  borderRadius: 10,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white.withValues(
                    alpha: _glass ? 0.92 : 1.0,
                  ),
                  showBorder: false,
                  child: _A4PortraitCoverCard(
                    coverPath: _coverPath,
                    onTap: _pickCoverImage,
                    onLongPressPreview: _showCoverPreview,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: FrostedContainer(
                  enableGlass: _glass,
                  borderRadius: 10,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  backgroundColor: Colors.white.withValues(
                    alpha: _glass ? 0.92 : 1.0,
                  ),
                  showBorder: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleCtrl,
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.done,
                        maxLines: 2,
                        minLines: 1,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: _persistTitle,
                        decoration: InputDecoration(
                          hintText: '제목을 입력하세요',
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintStyle: refinedHintStyle(hintColor),
                        ),

                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 7),
                      TextField(
                        controller: _penNameCtrl,
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.done,
                        maxLines: 1,
                        onChanged: _persistPenName,
                        decoration: const InputDecoration(
                          hintText: '필명 작성',
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            height: 1.2,
                            color: Color.fromARGB(139, 156, 176, 201),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          letterSpacing: 0.2,
                          color: Color.fromARGB(221, 83, 129, 159),
                        ),
                      ),
                      const SizedBox(height: 13),
                    ],
                  ),
                ),
              ),
              Container(
                height: 1,
                color: const Color.fromARGB(255, 185, 209, 235),
              ),
              TabBar(
                controller: _tabCtrl,
                isScrollable: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                labelPadding: const EdgeInsets.only(
                  left: 17,
                  right: 17,
                  top: 8,
                  bottom: 1,
                ),
                tabAlignment: TabAlignment.center,
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                indicator: const BoxDecoration(),

                indicatorColor: Colors.transparent,
                dividerColor: Colors.transparent,
                labelColor: const Color.fromARGB(255, 22, 42, 61),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                unselectedLabelColor: const Color.fromARGB(255, 176, 197, 219),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: '책 미리보기'),
                  Tab(text: '회차'),
                  Tab(text: '메모'),
                  Tab(text: '작품 정보'),
                  Tab(text: '전체 설정'),
                ],
                onTap: (i) {
                  _tabCtrl.animateTo(
                    i,
                    duration: Duration.zero,
                    curve: Curves.linear,
                  );
                  setState(() => _tabIndex = i);
                },
              ),
              IndexedStack(
                index: _tabIndex,
                children: [
                  _KeepAlive(child: _buildPreviewTab(silver, writingSettings)),
                  _KeepAlive(child: _buildChaptersTab(silver)),
                  _KeepAlive(child: _buildMemoTab()),
                  _KeepAlive(child: _buildMetaTab(silver)),
                  _KeepAlive(
                    child: _buildGlobalSettingsTab(silver, writingSettings),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

const double kCoverRadius = 13;

class _A4PortraitCoverCard extends StatelessWidget {
  final String? coverPath;
  final VoidCallback onTap;
  final VoidCallback? onLongPressPreview;
  const _A4PortraitCoverCard({
    required this.coverPath,
    required this.onTap,
    this.onLongPressPreview,
  });
  static const double _ratio2to3 = 1.5;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth;

        final cardW = (maxW * 0.88 * 0.45).clamp(0.0, maxW);
        final cardH = cardW * _ratio2to3;
        final cardRadius = scaledCoverRadius(cardW);

        File? coverFile;
        if (coverPath != null && coverPath!.isNotEmpty) {
          final f = File(coverPath!);
          if (f.existsSync()) {
            coverFile = f;
          }
        }

        const placeholder = Center(
          child: Text(
            '+ 표지 사진',
            style: TextStyle(
              fontSize: 15,
              color: Color.fromARGB(255, 171, 193, 217),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
        return SizedBox(
          height: cardH + 15,
          child: Center(
            child: GestureDetector(
              onTap: onTap,
              onLongPress: coverFile != null ? onLongPressPreview : null,
              child: Container(
                width: cardW,
                height: cardH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cardRadius),
                  color:
                      coverFile != null
                          ? Colors.transparent
                          : const Color(0xFFFFFFFF).withValues(alpha: 0.04),
                  border:
                      coverFile != null
                          ? null
                          : Border.all(
                            color: const Color.fromARGB(255, 170, 193, 216),
                            width: 0.5,
                          ),
                ),
                clipBehavior: Clip.hardEdge,
                child:
                    coverFile != null
                        ? Image.file(
                          coverFile,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => placeholder,
                        )
                        : placeholder,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniCoverCard extends StatelessWidget {
  final double width;
  final String? imagePath;
  const _MiniCoverCard({this.width = 79, this.imagePath});
  @override
  Widget build(BuildContext context) {
    final h = width * 1.5;
    final miniRadius = scaledCoverRadius(width);
    final hasImage =
        imagePath != null &&
        imagePath!.isNotEmpty &&
        File(imagePath!).existsSync();
    return Container(
      width: width,
      height: h,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(miniRadius),
        color:
            hasImage
                ? Colors.transparent
                : const Color(0xFFFFFFFF).withValues(alpha: 0.04),

        border:
            hasImage
                ? null
                : Border.all(
                  color: const Color.fromARGB(255, 170, 193, 216),
                  width: 0.5,
                ),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          hasImage
              ? Image.file(File(imagePath!), fit: BoxFit.cover)
              : const Center(
                child: Text(
                  '+ 표지 사진',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color: Color.fromARGB(255, 171, 193, 217),
                  ),
                ),
              ),
    );
  }
}

class DeltaPageBreakSplitter {
  static List<dq.Delta> splitByPageBreak(dq.Delta full) {
    final out = <dq.Delta>[];
    var cur = dq.Delta();
    void pushCurrent() {
      final ops = cur.toList();
      if (ops.isEmpty) {
        cur.insert('\n');
      } else {
        final last = ops.last.data;
        if (last is String && !last.endsWith('\n')) {
          cur.insert('\n');
        } else {
          cur.insert('\n');
        }
      }
      out.add(cur);
      cur = dq.Delta();
    }

    for (final op in full.toList()) {
      final data = op.data;

      final isPageBreak = data is Map && data.containsKey('page_break');
      if (isPageBreak) {
        pushCurrent();
        continue;
      }
      cur.insert(data, op.attributes);
    }

    pushCurrent();
    return out;
  }
}

class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});
  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _ChapterSortToggle extends StatelessWidget {
  final Color silver;
  final ChapterSort sortOrder;
  final VoidCallback onTap;
  const _ChapterSortToggle({
    required this.silver,
    required this.sortOrder,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final oldestFirst = sortOrder == ChapterSort.oldestFirst;
    final label = oldestFirst ? '첫화부터' : '마지막화부터';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '⇅',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: silver.withValues(alpha: 1.0),
                height: 1.0,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,

                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
                color: silver.withValues(alpha: 1.0),
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeDot extends StatelessWidget {
  final String themeId;
  final Color color;
  final Color borderColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeDot({
    required this.themeId,
    required this.color,
    required this.borderColor,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    const silver = Color.fromARGB(255, 185, 209, 235);
    final bool isSpaceTheme = themeId == 'space';
    final bool isLightSkyTheme = themeId == 'lightSky';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 27,
        height: 27,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF6D8CFF) : silver,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ClipOval(
          child: CustomPaint(
            foregroundPainter:
                isSpaceTheme ? const _SpaceDotStarPainter() : null,
            child: Container(
              decoration: BoxDecoration(
                gradient:
                    isSpaceTheme
                        ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF060A26),
                            Color(0xFF18206B),
                            Color(0xFF2C1B4E),
                          ],
                        )
                        : isLightSkyTheme
                        ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(255, 241, 249, 255),
                            Color.fromARGB(255, 180, 225, 255),
                            Color.fromARGB(255, 241, 249, 255),
                          ],
                        )
                        : null,

                color: isSpaceTheme ? null : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpaceDotStarPainter extends CustomPainter {
  const _SpaceDotStarPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    const int starCount = 15;
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < starCount; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final radius = rnd.nextDouble() * 0.5 + 0.3;
      paint.color = Colors.white.withValues(
        alpha: 0.55 + rnd.nextDouble() * 0.4,
      );
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FontChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FontChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.transparent,
          border: Border.all(
            color:
                selected
                    ? const Color.fromARGB(255, 127, 198, 255)
                    : const Color(0xFFBFC6CF).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 117, 148, 188),
          ),
        ),
      ),
    );
  }
}

class _SettingsStepperRow extends StatelessWidget {
  final String label;
  final String valueText;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _SettingsStepperRow({
    required this.label,
    required this.valueText,
    required this.onMinus,
    required this.onPlus,
  });
  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: labelStyle),
          const Spacer(),
          _RoundStepButton(symbol: '−', onTap: onMinus),
          const SizedBox(width: 10),
          Text(
            valueText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          _RoundStepButton(symbol: '+', onTap: onPlus),
        ],
      ),
    );
  }
}

class _RoundStepButton extends StatelessWidget {
  final String symbol;
  final VoidCallback onTap;
  const _RoundStepButton({required this.symbol, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 27,
        height: 27,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black87.withValues(alpha: 0.15),
            width: 0.7,
          ),
        ),
        child: Text(
          symbol,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,

            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _MiniReadingPreview extends StatelessWidget {
  final WritingSettings settings;
  const _MiniReadingPreview({required this.settings});
  @override
  Widget build(BuildContext context) {
    final colors = _mapThemeToColors(settings.themeId);
    final bool isSpace = settings.themeId == 'space';
    final bool isLightSky = settings.themeId == 'lightSky';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 6, top: 3),
          child: Text(
            '예시',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(137, 43, 84, 124),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: (isSpace || isLightSky) ? null : colors.background,
            gradient:
                isSpace
                    ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 6, 10, 38),
                        Color.fromARGB(255, 20, 27, 69),
                        Color.fromARGB(246, 33, 23, 38),
                      ],
                    )
                    : isLightSky
                    ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 241, 249, 255),
                        Color(0xFFBBDEFB),
                        Color(0xFFE3F2FD),
                      ],
                    )
                    : null,

            border:
                (settings.themeId == 'dark' ||
                        settings.themeId == 'darkGreen' ||
                        settings.themeId == 'space' ||
                        settings.themeId == 'lightSky')
                    ? null
                    : Border.all(
                      color: const Color.fromARGB(255, 185, 209, 235),
                      width: 0.5,
                    ),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              (isSpace || isLightSky)
                  ? Stack(
                    children: [
                      if (isSpace) ...[
                        const Positioned.fill(
                          child: _AnimatedStarField(starCount: 110),
                        ),

                        const Positioned.fill(
                          child: IgnorePointer(child: _ShootingStarLayer()),
                        ),
                      ] else ...[
                        const Positioned.fill(
                          child: CustomPaint(painter: _SunRayPainter()),
                        ),
                      ],
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: settings.horizontalMargin / 2,
                          vertical: 0,
                        ),
                        child: _buildPreviewText(colors.text),
                      ),
                    ],
                  )
                  : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: settings.horizontalMargin / 2,
                      vertical: 0,
                    ),
                    child: _buildPreviewText(colors.text),
                  ),
        ),
      ],
    );
  }

  Widget _buildPreviewText(Color textColor) {
    const sample = 'Build Story\n예시 글 입니다\n설정을 바꿔보세요';
    final textStyle = TextStyle(
      fontSize: 15.0,
      height: settings.lineHeight,
      letterSpacing: settings.letterSpacing,
      color: textColor,
      fontFamily: _mapFontFamily(settings.fontFamily),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sample,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: textStyle,
        ),
      ],
    );
  }

  String? _mapFontFamily(String fontKey) {
    switch (fontKey) {
      case 'batang':
        return 'Apple SD 산돌고딕 Neo';
      case 'inter':
        return 'Inter';
      case 'system':
      default:
        return 'Inter';
    }
  }

  _ThemeColors _mapThemeToColors(String id) {
    switch (id) {
      case 'dark':
        return _ThemeColors(
          background: const Color.fromARGB(255, 0, 0, 0),
          text: Colors.white.withValues(alpha: 0.92),
        );
      case 'darkGreen':
        return const _ThemeColors(
          background: Color.fromARGB(255, 10, 30, 26),
          text: Color.fromARGB(255, 255, 255, 255),
        );
      case 'space':
        return const _ThemeColors(
          background: Color(0xFF0B0E2A),
          text: Color(0xFFEAF2FF),
        );
      case 'lightSky':
        return const _ThemeColors(
          background: Color(0xFFE3F2FD),
          text: Color(0xFF1E293B),
        );
      default:
        return const _ThemeColors(
          background: Color.fromARGB(255, 255, 255, 255),
          text: Color.fromARGB(255, 0, 0, 0),
        );
    }
  }
}

class _ThemeColors {
  final Color background;
  final Color text;
  const _ThemeColors({required this.background, required this.text});
}

class _LocalMemo {
  final String text;
  final DateTime updatedAt;
  const _LocalMemo(this.text, this.updatedAt);
  Map<String, dynamic> toJson() => {
    'text': text,
    'updatedAt': updatedAt.toIso8601String(),
  };
  factory _LocalMemo.fromJson(Map<String, dynamic> json) {
    return _LocalMemo(
      (json['text'] as String?) ?? '',
      DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class _InlineMemoEditor extends StatefulWidget {
  final String? initialText;
  const _InlineMemoEditor({this.initialText});
  @override
  State<_InlineMemoEditor> createState() => _InlineMemoEditorState();
}

class _InlineMemoEditorState extends State<_InlineMemoEditor> {
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();
  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialText ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).maybePop(_controller.text);
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: Text(
          widget.initialText == null || widget.initialText!.isEmpty
              ? '새 메모'
              : '메모 편집',
        ),
        leading: const CupertinoNavigationBarBackButton(
          color: Color.fromARGB(255, 52, 96, 143),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _save,
          child: const Text(
            '저장',
            style: TextStyle(color: Color.fromARGB(255, 52, 96, 143)),
          ),
        ),
        border: null,
      ),
      child: SafeArea(
        bottom: true,
        child: CupertinoScrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: CupertinoTextField(
              controller: _controller,
              focusNode: _focus,
              placeholder: '메모를 입력하세요',
              style: const TextStyle(color: Color.fromARGB(255, 52, 96, 143)),
              autofocus: false,
              scrollPadding: EdgeInsets.zero,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const BoxDecoration(),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaTextFieldRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  const _MetaTextFieldRow({
    required this.label,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black.withValues(alpha: 0.78),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color.fromARGB(221, 83, 129, 159),
                fontSize: 12,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
      ],
    );
  }
}

class _AnimatedStarField extends StatefulWidget {
  final int starCount;
  const _AnimatedStarField({this.starCount = 150});
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
      duration: const Duration(milliseconds: 700),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _twinkleIndex = _rnd.nextInt(widget.starCount);
    _controller.forward(from: 0);

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
    this.starCount = 150,
    required this.twinkleIndex,
    required this.twinkleProgress,
  }) : super(repaint: twinkleProgress);
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(12345);
    final basePaint = Paint()..style = PaintingStyle.fill;

    final double t = twinkleProgress.value.clamp(0.0, 1.0);
    final double pulse = math.sin(t * math.pi);
    for (int i = 0; i < starCount; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final center = Offset(dx, dy);

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

      basePaint.color = baseColor;
      canvas.drawCircle(center, baseRadius, basePaint);

      if (twinkleIndex != null && i == twinkleIndex) {
        final double extraAlpha = 0.5 * pulse;
        final double extraRadius = baseGlowRadius * (1.5 + 0.7 * pulse);
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

class _ShootingStarSpec {
  final double startX;
  final double startY;
  final double dx;
  final double dy;
  final double length;

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
      duration: const Duration(milliseconds: 600),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _currentStar = null);
        _scheduleNext();
      }
    });
    _scheduleNext(initial: true);
  }

  void _scheduleNext({bool initial = false}) {
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
    final double startX = _rnd.nextDouble() * 1.2 - 0.1;
    final double startY = _rnd.nextDouble() * 1.2 - 0.1;

    final bool toRight = _rnd.nextBool();
    final double angleDeg = 20 + _rnd.nextDouble() * 40;
    final double angleRad = angleDeg * math.pi / 180.0;
    final double dx = (toRight ? 1.0 : -1.0) * math.cos(angleRad);
    final double dy = math.sin(angleRad);

    final double length = 0.25 + _rnd.nextDouble() * 0.10;
    final double thickness = 0.4 + _rnd.nextDouble() * 0.2;
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
    final Offset start = Offset(
      star!.startX * size.width,
      star!.startY * size.height,
    );
    final Offset dir = Offset(star!.dx, star!.dy).normalize();

    final Offset head = start + dir * (baseLengthPx * (0.3 + 0.7 * t));
    final Offset tail = head - dir * (baseLengthPx * 0.7);
    canvas.drawLine(tail, head, paint);
  }

  @override
  bool shouldRepaint(covariant _ShootingStarPainter oldDelegate) {
    return oldDelegate.star != star;
  }
}

extension _OffsetNormalize on Offset {
  Offset normalize() {
    final double len = distance;
    if (len == 0) return this;
    return this / len;
  }
}

class _SunRayPainter extends CustomPainter {
  const _SunRayPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final Offset sunCenter = Offset(size.width * -0.10, size.height * -0.10);
    final double coreRadius = size.width * 0.11;
    final double haloRadius = size.longestSide * 0.7;
    final Rect fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
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

    final Paint overlay =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.18),
              const Color(0x00FFFFFF),
            ],
          ).createShader(fullRect)
          ..blendMode = BlendMode.softLight;
    canvas.drawRect(fullRect, overlay);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
