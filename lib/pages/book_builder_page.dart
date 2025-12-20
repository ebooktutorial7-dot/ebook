// book_builder_page.dart

import 'dart:io'; // File 사용
import 'dart:ui' as ui;

import 'dart:typed_data';
import 'package:pdf/pdf.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:printing/printing.dart';

import 'package:super_editor/super_editor.dart';

import 'package:dart_quill_delta/dart_quill_delta.dart' as dq;

import 'dart:ui';
import 'dart:math' as math; // ⭐ 밤하늘 별 랜덤 배치
import 'dart:convert'; // 회차 저장/복원
import 'dart:async'; // StreamSubscription
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:intl/intl.dart';
import 'package:ebook_tutorial_app/utils/platform_accessibility.dart';
import 'package:ebook_tutorial_app/pages/chapter_write_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ebook_tutorial_app/pages/custom_pdf_preview_page.dart';

import 'package:ebook_tutorial_app/pdf/book_pdf_builder.dart';

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

// 기준이 되는 큰 표지 카드 값
const double kCoverBaseRadius = 13.0; // 기준 너비에서의 radius
const double kCoverBaseWidth = 150.0; // 기준으로 잡을 표지 가로 너비(대략)

// 너비에 따라 시각적으로 동일한 곡률을 유지하는 radius 계산
double scaledCoverRadius(double width) {
  if (width <= 0) return kCoverBaseRadius;

  final ratio = width / kCoverBaseWidth; // 너비 비율
  return kCoverBaseRadius * ratio; // radius도 같은 비율로 스케일링
}

class PdfPreviewPage extends StatelessWidget {
  const PdfPreviewPage({
    super.key,
    required this.title,
    required this.buildBytes,
  });

  final String title;

  /// PdfPreview가 필요할 때마다 PDF bytes를 만들어서 돌려주는 콜백
  final Future<Uint8List> Function(PdfPageFormat format) buildBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: buildBytes,
        allowPrinting: false, // 원하면 true
        allowSharing: true, // 원하면 false
        canChangeOrientation: true,
        canChangePageFormat: true,
      ),
    );
  }
}

class TextRun {
  final String text;
  final TextStyle style;
  final bool isEmbed;

  TextRun(this.text, this.style, {this.isEmbed = false});
}

List<TextRun> deltaToRuns(dq.Delta delta, WritingSettings settings) {
  final runs = <TextRun>[];

  for (final op in delta.toList()) {
    final data = op.data;
    final attrs = op.attributes ?? {};

    // ----------------------------
    // 1) embed
    // ----------------------------
    if (data is! String) {
      final embedStyle = TextStyle(
        fontSize: settings.fontSize,
        height: settings.lineHeight,
      );
      runs.add(TextRun("\uFFFC", embedStyle, isEmbed: true));
      continue;
    }

    String text = data;
    if (text.isEmpty) continue;

    // ----------------------------
    // 2) 텍스트 스타일 계산
    // ----------------------------
    double fontSize = settings.fontSize;
    FontWeight? weight;
    FontStyle? italic;
    double height = settings.lineHeight;

    if (attrs['size'] != null) {
      fontSize = (attrs['size'] as num).toDouble();
    }
    if (attrs['bold'] == true) weight = FontWeight.bold;
    if (attrs['italic'] == true) italic = FontStyle.italic;

    // Header는 Quill 기준 line height 크게 반영
    if (attrs['header'] != null) {
      final header = attrs['header'] as int;
      if (header == 1) fontSize = settings.fontSize * 1.60;
      if (header == 2) fontSize = settings.fontSize * 1.35;
      if (header == 3) fontSize = settings.fontSize * 1.20;
    }

    runs.add(
      TextRun(
        text,
        TextStyle(
          fontSize: fontSize,
          height: height,
          fontWeight: weight,
          fontStyle: italic,
          letterSpacing: settings.letterSpacing,
          fontFamily:
              settings.fontFamily == 'system'
                  ? null
                  : settings.fontFamily == 'inter'
                  ? 'Inter'
                  : 'Apple SD 산돌고딕 Neo',
        ),
      ),
    );
  }

  return runs;
}

class StyledPaginationEngine {
  List<PageSlice> paginate({
    required dq.Delta delta,
    required WritingSettings settings,
    required double pageWidth,
    required double pageHeight,
  }) {
    final runs = deltaToRuns(delta, settings);

    final pages = <PageSlice>[];
    final painter = TextPainter(
      textDirection: ui.TextDirection.ltr,
      maxLines: null,
    );

    double usedHeight = 0;
    int globalOffset = 0;
    int pageStart = 0;

    for (final run in runs) {
      // embed
      if (run.isEmbed) {
        const embedHeight = 40.0;
        if (usedHeight + embedHeight > pageHeight) {
          pages.add(PageSlice(pageStart, globalOffset));
          pageStart = globalOffset;
          usedHeight = 0;
        }
        usedHeight += embedHeight;
        globalOffset += 1;
        continue;
      }

      // 일반 텍스트
      painter.text = TextSpan(text: run.text, style: run.style);
      painter.layout(maxWidth: pageWidth);
      final runHeight = painter.size.height;

      if (usedHeight + runHeight > pageHeight) {
        pages.add(PageSlice(pageStart, globalOffset));
        pageStart = globalOffset;
        usedHeight = 0;
      }

      usedHeight += runHeight;
      globalOffset += run.text.length;
    }

    pages.add(PageSlice(pageStart, globalOffset));
    return pages;
  }
}

class PageSlice {
  final int startOffset; // 문서 전체 plain text 기준 시작 인덱스
  final int endOffset; // [startOffset, endOffset) 구간

  const PageSlice(this.startOffset, this.endOffset);
}

// ✨ 책 미리보기
extension WritingSettingsPreviewExt on WritingSettings {
  double get fontSize {
    return 16.0;
  }

  Color get textColor {
    switch (themeId) {
      case 'dark':
      case 'darkGreen':
      case 'space':
        return Colors.white.withValues(alpha: 0.96);
      case 'lightSky':
        return const Color(0xFF1E293B);
      default:
        return const Color(0xFF222222);
    }
  }
}

/// ----------------------
/// A4 비율 카드 컨테이너
/// ----------------------
class A4Page extends StatelessWidget {
  static const double _sqrt2 = 1.41421356237;
  final EdgeInsetsGeometry margins;
  final Widget child;
  final double borderRadius;

  const A4Page({
    super.key,
    required this.child,
    this.margins = EdgeInsets.zero,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final height = width * _sqrt2;
        return SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(padding: margins, child: child),
          ),
        );
      },
    );
  }
}

/// ----------------------
/// 유리(블러) 컨테이너
/// ----------------------
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
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );
  }
}

/// ----------------------
/// 회차(챕터) 모델
/// ----------------------
class ChapterItem {
  final String title; // 표시용: "책 제목 + n화"
  final int index; // 1부터 증가
  final String? coverPath; // 추후 이미지 선택 시 사용
  final List<Map<String, dynamic>> delta; // 회차 본문 Delta

  // 메타데이터
  final int? sizeBytes; // 파일 크기(바이트)
  final int? charCount; // 글자 수
  final DateTime? updatedAt; // 최근 편집 일시

  final bool pinned;

  const ChapterItem({
    required this.title,
    required this.index,
    this.coverPath,
    required this.delta,
    this.sizeBytes,
    this.charCount,
    this.updatedAt,
    this.pinned = false,
  });

  ChapterItem copyWith({
    String? title,
    String? coverPath,
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
      delta: delta ?? this.delta,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      charCount: charCount ?? this.charCount,
      updatedAt: updatedAt ?? this.updatedAt,
      pinned: pinned ?? this.pinned,
    );
  }
}

/// ----------------------
/// 메인 페이지
/// ----------------------
class BookBuilderPage extends StatefulWidget {
  final String initialTitle;
  final List<Map<String, dynamic>> initialDeltaJson;
  final List<Map<String, dynamic>> initialDrawingJson;
  final int pageIndex;
  final String initialPenName;
  final String? documentId;

  const BookBuilderPage({
    super.key,
    required this.initialTitle,
    required this.initialDeltaJson,
    required this.initialDrawingJson,
    required this.pageIndex,
    this.initialPenName = '',
    this.documentId,
  });

  @override
  State<BookBuilderPage> createState() => _BookBuilderPageState();
}

class _PdfPopupItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PdfPopupItem({
    required this.icon,
    required this.label,
    required this.onTap,
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
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F3A56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookBuilderPageState extends State<BookBuilderPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _penNameCtrl;
  late List<Map<String, dynamic>> _delta;
  late List<Map<String, dynamic>> _drawings;

  late final quill.QuillController _previewCtrl;

  final LayerLink _pdfPreviewLink = LayerLink();
  OverlayEntry? _pdfSubmenuEntry;

  // Export submenu overlay
  OverlayEntry? _pdfExportSubmenuEntry;
  final ValueNotifier<bool> _pdfExportSubmenuOpenVN = ValueNotifier(false);

  // Export submenu anchor link
  final LayerLink _pdfExportLink = LayerLink();

  // ✅ 새 팝업 실측용
  final GlobalKey _pdfSubmenuKey = GlobalKey();
  double? _measuredSubmenuHeight;

  final ValueNotifier<bool> _pdfSubmenuOpenVN = ValueNotifier<bool>(false);

  // 작품 정보 탭 상태
  late final TextEditingController _summaryCtrl;
  late final TextEditingController _keywordInputCtrl;
  final List<String> _keywords = [];

  // 상세 정보 입력용 컨트롤러
  late final TextEditingController _workTypeCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _ageRatingCtrl;

  String? _coverPath; // 책 표지 이미지 경로

  String get _coverKey =>
      widget.documentId == null ? '' : 'book_cover_${widget.documentId}';

  String get _metaKey =>
      widget.documentId == null ? '' : 'book_meta_${widget.documentId}';

  late final PaginationEngine _paginationEngine;

  late final WritingSettingsController _settingsController;

  // ✅ 각 페이지별 Delta (스타일/이미지/헤더 포함)
  List<dq.Delta> _pageDeltas = const [];

  int _pageCount = 1;

  // ✅ 새 코드: 설정 서명용
  String? _lastPaginationSignature;

  int _currentIndex = 0;
  bool _isPageView = true;
  bool _glass = true;

  bool _reduceTransparencyFlag = false;

  // 책 미리보기(카드)에서 사용할 회차 선택 상태
  bool _previewAllChapters = true; // true: 모든 회차, false: 선택 회차만
  final Set<int> _selectedChapterIndexes = {}; // ChapterItem.index

  GlassTheme get _glassTheme =>
      GlassTheme.fromFlags(reduceTransparency: _reduceTransparencyFlag);

  late final TabController _tabCtrl;
  int _tabIndex = 0;

  final PageController _pageCtrl = PageController();
  final List<GlobalKey> _itemKeys = <GlobalKey>[];
  SharedPreferences? _prefs;

  // 정렬 상태 및 키
  ChapterSort _sortOrder = ChapterSort.oldestFirst;

  String get _sortKey =>
      widget.documentId == null ? '' : 'book_sort_${widget.documentId}';

  // 이동 모드
  bool _reorderMode = false;

  // 회차 목록 상태
  final List<ChapterItem> _chapters = [];

  String get _titleKey =>
      widget.documentId == null ? '' : 'book_title_${widget.documentId}';
  String get _penKey =>
      widget.documentId == null ? '' : 'book_pen_${widget.documentId}';
  String get _chaptersKey =>
      widget.documentId == null ? '' : 'book_chapters_${widget.documentId}';

  // 메모 상태 (이 책 전용)
  final List<_LocalMemo> _memos = [];

  String get _memoKey =>
      widget.documentId == null ? '' : 'book_memos_${widget.documentId}';

  void _rebuildPagination() {
    final doc = _previewCtrl.document;
    final fullText = doc.toPlainText();

    if (fullText.trim().isEmpty) {
      setState(() {
        _pageDeltas = [dq.Delta()..insert('\n')];
        _pageCount = 1;
        _currentIndex = 0;
        _ensureItemKeys();
      });
      return;
    }

    final s = context.read<WritingSettingsController>().settings;

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32; // 좌우 16 패딩

    final pageWidth = cardWidth - s.horizontalMargin * 2;
    final pageHeight = cardWidth * A4Page._sqrt2;

    // 0) 전체 Delta 먼저 생성
    final fullDelta = doc.toDelta(); // dq.Delta

    // 1) plainText 기준 start/end 범위 계산
    final slices = _paginationEngine.paginateDelta(
      delta: fullDelta,
      settings: s,
      pageWidth: pageWidth,
      pageHeight: pageHeight,
    );

    // 2) Delta 기반으로 각 페이지 잘라내기
    final pageDeltas = DeltaPaginator.sliceByPageRanges(
      fullDelta: fullDelta,
      pages: slices,
    );

    setState(() {
      _pageDeltas = pageDeltas;
      _pageCount = pageDeltas.length;
      _currentIndex = _currentIndex.clamp(0, _pageCount - 1);
      _ensureItemKeys();
    });
  }

  String _buildPaginationSignature(WritingSettings s) {
    return [
      // 🔹 레이아웃에 영향을 줄 수 있는 순서대로
      s.themeId, // 테마에 따라 다른 폰트/스타일 쓸 수 있으니까 포함
      s.fontFamily, // 폰트 패밀리 변경 시 줄 길이/높이 달라짐

      s.fontSize.toStringAsFixed(2),
      s.lineHeight.toStringAsFixed(2),
      s.letterSpacing.toStringAsFixed(2),
      s.horizontalMargin.toStringAsFixed(2),
    ].join('|'); // 구분자는 아무거나 상관없음
  }

  void _onSettingsChanged() {
    if (!mounted) return;

    final s = _settingsController.settings;
    final newSig = _buildPaginationSignature(s);

    if (newSig == _lastPaginationSignature) return;

    _lastPaginationSignature = newSig;
    _rebuildPagination();
  }

  @override
  void initState() {
    super.initState();

    // 🔹 글 설정 컨트롤러 가져오기 & 리스너 등록
    _settingsController = context.read<WritingSettingsController>();
    _lastPaginationSignature = _buildPaginationSignature(
      _settingsController.settings,
    );
    _settingsController.addListener(_onSettingsChanged);

    // 🔹 페이지네이션 엔진 생성
    _paginationEngine = PaginationEngine();

    _delta = List<Map<String, dynamic>>.from(widget.initialDeltaJson);
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

    // 프리뷰 컨트롤러
    _previewCtrl = quill.QuillController(
      document: quill.Document.fromJson(_delta),
      selection: const TextSelection.collapsed(offset: 0),
    );

    // 🔹 페이지 다시 계산
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _rebuildPagination();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initReduceTransparency();
      _glass = !_reduceTransparencyFlag;

      await _loadPersistedFields();
      await _loadSortPref();
      await _loadPersistedChapters();
      _applyChapterSort();
      await _loadPersistedMemos();
      await _loadPersistedMeta();
      await _loadPersistedCover();

      if (!mounted) return;
      setState(() {
        _currentIndex = widget.pageIndex.clamp(0, _pageCount - 1);
      });
      // 🔹 초기 데이터 로딩이 끝난 뒤 한 번 페이지 계산
      if (mounted) {
        _rebuildPagination();
      }
    });
  }

  @override
  void dispose() {
    _hidePdfSubmenu(); // ⭐ 여기 추가
    _pdfSubmenuOpenVN.dispose();

    _settingsController.removeListener(_onSettingsChanged);

    _previewCtrl.dispose();
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

  // ----------------------
  // SharedPreferences
  // ----------------------
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

  // ----------------------
  // 작품 정보 저장 / 복원
  // ----------------------
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

    // 🔧 회차 표지 삭제 처리 부분만 수정
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

    // 2) 이미지 선택 (기존 코드 동일)
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
      barrierColor: const Color.fromARGB(
        0,
        81,
        93,
        104,
      ).withValues(alpha: 0.85),
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.pop(context), // 아무 데나 탭하면 닫힘
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

    // 1) await 앞이므로 context 사용 OK
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

    // 2) showCupertinoModalPopup 이후 → mounted 체크 필수
    if (!mounted) return;

    // 취소
    if (result == null) return;

    // 3) 삭제 처리
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

    // 4) 이미지 선택
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

  // ----------------------
  // 접근성 / 글래스
  // ----------------------
  Future<void> _initReduceTransparency() async {
    final reduce = await PlatformAccessibility.getReduceTransparencyFlag();
    if (!mounted) return;
    setState(() => _reduceTransparencyFlag = reduce);
  }

  // ----------------------
  // 정렬 / 페이지 키 관리
  // ----------------------
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

  // ----------------------
  // Chapter / Memo 직렬화 유틸
  // ----------------------
  Map<String, dynamic> _chapterToJson(ChapterItem c) {
    return {
      'title': c.title,
      'index': c.index,
      'cover': c.coverPath,
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

  // ----------------------
  // 회차 저장 / 복원
  // ----------------------
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

  // ----------------------
  // 메모 저장 / 복원
  // ----------------------
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

  // ----------------------
  // 프리뷰 / Delta 관련
  // ----------------------
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
    final mergedDelta = <Map<String, dynamic>>[];

    if (targets.isEmpty) {
      mergedDelta.addAll(_delta);
    } else {
      for (var i = 0; i < targets.length; i++) {
        mergedDelta.addAll(targets[i].delta);
        if (i != targets.length - 1) {
          mergedDelta.add({'insert': '\n\n'});
        }
      }
    }

    // 🔹 마지막 op 보정: 항상 개행으로 끝나도록
    if (mergedDelta.isEmpty) {
      mergedDelta.add({'insert': '\n'});
    } else {
      final lastInsert = mergedDelta.last['insert'];

      if (lastInsert is String) {
        // 문자열인데 \n 으로 안 끝나면 개행 하나 더
        if (!lastInsert.endsWith('\n')) {
          mergedDelta.add({'insert': '\n'});
        }
      } else {
        // 이미지, hr 등 String 이 아니면 그냥 개행 하나 추가
        mergedDelta.add({'insert': '\n'});
      }
    }

    final newDoc = quill.Document.fromJson(mergedDelta).toDelta();

    _previewCtrl.replaceText(
      0,
      _previewCtrl.document.length,
      newDoc,
      const TextSelection.collapsed(offset: 0),
    );

    if (mounted) {
      _rebuildPagination();
    }
  }

  // 책 전체 delta를 회차 기준으로 합쳐서 저장용으로 사용
  List<Map<String, dynamic>> _buildDeltaForSave() {
    if (_chapters.isEmpty) {
      return List<Map<String, dynamic>>.from(_delta);
    }

    final merged = <Map<String, dynamic>>[];
    for (var i = 0; i < _chapters.length; i++) {
      merged.addAll(_chapters[i].delta);
      if (i != _chapters.length - 1) {
        merged.add({'insert': '\n\n'});
      }
    }
    return merged;
  }

  List<Map<String, dynamic>> _emptyDelta() => const [
    {'insert': '\n'},
  ];

  // ----------------------
  // 통계 / 포맷 유틸
  // ----------------------
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

  // ----------------------
  // 상단 / 저장
  // ----------------------
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

  // ----------------------
  // 보기 전환
  // ----------------------
  void _toggleView() {
    setState(() => _isPageView = !_isPageView);
    _ensureItemKeys(); //
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

  // ----------------------
  // 회차 추가
  // ----------------------
  void _addChapter() {
    final title =
        (_titleCtrl.text.trim().isEmpty) ? '책 제목' : _titleCtrl.text.trim();
    final next = _nextChapterIndex();
    final label = '$title $next화';

    setState(() {
      _chapters.add(
        ChapterItem(
          title: label,
          index: next,
          delta: _emptyDelta(),
          // ❌ coverPath: _coverPath 넣지 않기!
          // coverPath가 null이어야 "책 표지 fallback" 이 가능해집니다.
        ),
      );
      _applyChapterSort();
    });
    _persistChapters();
  }

  Future<void> _openChapterEditor(ChapterItem c) async {
    final stableKey = 'doc_${widget.documentId ?? 'local'}_chapter_${c.index}';

    final settingsController = context.read<WritingSettingsController>();

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider.value(
              value: settingsController,
              child: ChapterWritePage(
                chapterTitle: c.title,
                initialDeltaJson: c.delta,
                enableGlass: _glass,
                persistentKey: stableKey,
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
            message: Text('‘${c.title}’ 회차를 삭제하시겠습니까?'),
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

  void _showChapterMoreDialog(ChapterItem c) {
    final theme = _glassTheme;

    showDialog(
      context: context,
      barrierColor: Colors.black12,
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
                      icon: Icons.delete_outline,
                      label: '‘${c.title}’ 삭제',
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

  // ----------------------
  // 메모
  // ----------------------
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

  static const double _exportPopupWidth = 165;

  void _hidePdfExportSubmenu() {
    _pdfExportSubmenuEntry?.remove();
    _pdfExportSubmenuEntry = null;
    _pdfExportSubmenuOpenVN.value = false;
  }

  void _showPdfExportSubmenu() {
    // 다른 서브팝업이 열려있으면 닫기
    if (_pdfSubmenuOpenVN.value) {
      _hidePdfSubmenu();
    }

    if (_pdfExportSubmenuEntry != null) {
      _hidePdfExportSubmenu();
      return;
    }

    final overlay = Overlay.of(context);
    _pdfExportSubmenuOpenVN.value = true;

    _pdfExportSubmenuEntry = OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            // 바깥 탭하면 닫기
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hidePdfExportSubmenu,
                child: const SizedBox.expand(),
              ),
            ),

            // 앵커(내보내기 항목) 기준으로 붙는 서브팝업
            CompositedTransformFollower(
              link: _pdfExportLink,
              showWhenUnlinked: false,

              // ✅ 미리보기 서브팝업과 동일하게 앵커 정렬 맞추고 싶으면 아래 두 줄도 동일하게
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,

              // 기존 값 유지(필요하면 미리보기처럼 const Offset(0, -55)로 통일 가능)
              offset: const Offset(0, 0),

              // offset: const Offset(-_exportPopupWidth + 140, 44),
              child: Material(
                color: Colors.transparent,
                child: FrostedContainer(
                  enableGlass: true,
                  blurSigma: 16,
                  borderRadius: 22,
                  showBorder: false,
                  backgroundColor: Colors.white.withValues(alpha: 0.96),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _exportPopupWidth,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ 미리보기 팝업과 동일한 헤더(X + 가운데 타이틀)
                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: _hidePdfExportSubmenu,
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
                                'PDF 내보내기',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 30), // ✅ 미리보기처럼 오른쪽 여백 확보
                          ],
                        ),
                        const SizedBox(height: 10),

                        _PdfPopupItem(
                          icon: Icons.all_inbox_outlined,
                          label: '전체 회차 내보내기',
                          onTap: () async {
                            _hidePdfExportSubmenu();
                            await _exportAllEpisodesAsPdf();
                          },
                        ),
                        const SizedBox(height: 6),
                        _PdfPopupItem(
                          icon: Icons.checklist_outlined,
                          label: '선택 회차 내보내기',
                          onTap: () async {
                            _hidePdfExportSubmenu();
                            await _exportSelectedEpisodesAsPdf();
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

    overlay.insert(_pdfExportSubmenuEntry!);
  }

  void _hidePdfSubmenu() {
    _pdfSubmenuEntry?.remove();
    _pdfSubmenuEntry = null;
    _measuredSubmenuHeight = null;
    _pdfSubmenuOpenVN.value = false;
  }

  Future<void> _exportAllEpisodesAsPdf() async {
    //전체 회차 PDF 생성/저장/공유 로직 연결
  }

  Future<void> _exportSelectedEpisodesAsPdf() async {
    //선택 회차 선택 UI(체크박스/다이얼로그) + PDF 생성/저장/공유 로직 연결
  }

  static const double _previewPopupWidth = 165;

  void _showPdfSubmenu() {
    if (_pdfSubmenuEntry != null) {
      _hidePdfSubmenu();
      return;
    }

    final overlay = Overlay.of(context);
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

              // 버튼 아래 가운데 정렬 기준은 유지
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,

              // ✅ 음수로 주면 위로 올라가서 기존 팝업과 겹침
              // 기존 코드에 dy 계산이 있지만 offset은 const로 고정되어 있었음.
              // 원하시면 아래 offset을 Offset(0, dy)로 바꿔서 "실측값 기반"으로 붙일 수 있습니다.
              offset: const Offset(0, -60),

              // offset: Offset(0, dy),
              child: Material(
                color: Colors.transparent,
                child: KeyedSubtree(
                  key: _pdfSubmenuKey,
                  child: FrostedContainer(
                    // ✅ 화이트 팝업 (blur 느낌 유지)
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
                                  'PDF 미리보기',
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
                            label: '전체 회차 미리보기',
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
                                        title: '전체 회차 미리보기',
                                        pdfBytes: bytes,
                                        chapters: _previewTargetChapters,
                                      ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 6),
                          _PdfPopupItem(
                            icon: Icons.checklist_outlined,
                            label: '선택 회차 미리보기',
                            onTap: () {
                              _hidePdfSubmenu();
                              _showPreviewChapterSelector();
                            },
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

    overlay.insert(_pdfSubmenuEntry!);
  }

  // ----------------------
  // 책 미리보기 회차 선택 (롱탭 팝업과 같은 디자인)
  // ----------------------
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
      barrierColor: Colors.black12,
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
                  constraints: const BoxConstraints(maxWidth: 230), // ← 가로폭
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

                      // ---- 세그먼트 스위치 ----
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

                      // ---- 체크 리스트 ----
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
                                '취소',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GlassActionButton(
                              theme: theme,
                              icon: Icons.check,
                              label: '적용',
                              onPressed: applyAndClose,
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

  // ----------------------
  // 위젯 빌드
  // ----------------------
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
                        // 라이트 테마
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

                        // 다크 테마
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

                        // 다크 그린
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

                        // 🌌 스페이스
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

                        // 🌤 lightSky (밝은 하늘)
                        _ThemeDot(
                          themeId: 'lightSky',
                          color: const Color(0xFFB3E5FC), // fallback 단색
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
                          selected: settings.fontFamily == 'inter',
                          onTap: () {
                            context
                                .read<WritingSettingsController>()
                                .updateFontFamily('inter');
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
                  final newH = (settings.lineHeight - 0.2).clamp(1.0, 3.0);
                  context.read<WritingSettingsController>().updateLineHeight(
                    newH,
                  );
                },
                onPlus: () {
                  final newH = (settings.lineHeight + 0.2).clamp(1.0, 3.0);
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
                  final newLs = (settings.letterSpacing - 0.1).clamp(0.0, 0.7);
                  context.read<WritingSettingsController>().updateLetterSpacing(
                    newLs,
                  );
                },
                onPlus: () {
                  final newLs = (settings.letterSpacing + 0.1).clamp(0.0, 0.7);
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
                  final newM = (settings.horizontalMargin - 2).clamp(2.0, 50.0);
                  context
                      .read<WritingSettingsController>()
                      .updateHorizontalMargin(newM);
                },
                onPlus: () {
                  final newM = (settings.horizontalMargin + 2).clamp(2.0, 50.0);
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
    // 1순위: 회차 개별 표지
    // 2순위: 책 전체 표지(_coverPath)
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
                            padding: EdgeInsets.only(right: 4),
                            child: Text(
                              '📖',
                              style: TextStyle(fontSize: 15, height: 1.3),
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

  // ----------------------
  // 탭별 빌드
  // ----------------------
  Widget _buildPreviewTab(Color silver, WritingSettings settings) {
    _ensureItemKeys(); // 키 개수 맞추기

    return Column(
      children: [
        // 상단 버튼 행
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
                      size: 24, // 필요하면 크기도 조절 가능
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

        // 본문 영역: PageView / ListView 전환
        Transform.translate(
          offset: const Offset(0, -10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LayoutBuilder(
              builder: (_, c) {
                final width = c.maxWidth;
                final height = width * A4Page._sqrt2;
                final cardHeight = height + 36;

                if (_isPageView) {
                  // ① 페이지 뷰
                  return SizedBox(
                    height: cardHeight,
                    child: PageView.builder(
                      controller: _pageCtrl,
                      itemCount: _pageCount,
                      allowImplicitScrolling: true,
                      padEnds: false,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (_, i) {
                        return _buildContentCard(
                          i,
                          key: _itemKeys[i],
                          settings: settings,
                        );
                      },
                    ),
                  );
                } else {
                  // ② 스크롤 리스트 뷰
                  return SizedBox(
                    height: cardHeight,
                    child: ListView.builder(
                      itemCount: _pageCount,
                      itemBuilder: (_, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildContentCard(
                            i,
                            key: _itemKeys[i],
                            settings: settings,
                          ),
                        );
                      },
                    ),
                  );
                }
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
                  ? Column(
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        '우측 상단의 + 버튼을 눌러 회차를 추가하세요.',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.55),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
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

              // 1) 작품 소개
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

              // 2) 키워드
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
                      '#로맨스  #성장물  #판타지 처럼 자유롭게 추가하세요.',
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

              // 3) 상세 정보
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

                    // 글 / 원작
                    _MetaTextFieldRow(
                      label: '글 / 원작',
                      controller: _workTypeCtrl,
                      hintText: '글 / 원작 정보를 입력하세요.',
                      onChanged: (_) => _persistMeta(),
                    ),
                    const SizedBox(height: 8),

                    // 작품 분류
                    _MetaTextFieldRow(
                      label: '작품 분류',
                      controller: _categoryCtrl,
                      hintText: '작품 분류를 입력하세요.',
                      onChanged: (_) => _persistMeta(),
                    ),
                    const SizedBox(height: 8),

                    // 연령 등급
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

  Widget _buildContentCard(
    int index, {
    Key? key,
    required WritingSettings settings,
  }) {
    final themeId = settings.themeId;
    final bool isSpace = themeId == 'space';
    final bool isLightSky = themeId == 'lightSky';

    // ✅ 이 페이지에서 쓸 Delta 하나 선택
    final dq.Delta pageDelta =
        (_pageDeltas.isNotEmpty && index < _pageDeltas.length)
            ? _pageDeltas[index]
            : (dq.Delta()..insert('\n'));

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
        pageBg = Colors.white;
    }

    final bool noBorder =
        themeId == 'dark' ||
        themeId == 'darkGreen' ||
        themeId == 'space' ||
        themeId == 'lightSky';

    final Color? cardBorderColor =
        noBorder ? null : const Color.fromARGB(255, 185, 209, 235);

    final margins = EdgeInsets.fromLTRB(
      settings.horizontalMargin,
      0,
      settings.horizontalMargin,
      0,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FrostedContainer(
          enableGlass: _glass,
          borderRadius: 20,
          padding: EdgeInsets.zero,
          backgroundColor:
              (isSpace || isLightSky) ? Colors.transparent : pageBg,
          showBorder: cardBorderColor != null,
          borderColor: cardBorderColor,
          child:
              (isSpace || isLightSky)
                  ? LayoutBuilder(
                    builder: (_, c) {
                      final width = c.maxWidth;
                      final height = width * A4Page._sqrt2;

                      return SizedBox(
                        width: width,
                        height: height,
                        child: Stack(
                          children: [
                            // 1) 배경 그라데이션
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
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
                              ),
                            ),
                            // 2) space/lightSky 특수 효과
                            if (isSpace) ...[
                              const Positioned.fill(
                                child: _AnimatedStarField(starCount: 260),
                              ),
                              const Positioned.fill(
                                child: IgnorePointer(
                                  child: _ShootingStarLayer(),
                                ),
                              ),
                            ] else ...[
                              const Positioned.fill(
                                child: CustomPaint(painter: _SunRayPainter()),
                              ),
                            ],
                            // 3) Quill 기반 본문 프리뷰
                            // 3) Quill 기반 본문 프리뷰
                            Padding(
                              padding: EdgeInsets.only(
                                left: margins.left,
                                right: margins.right,
                                top: 0, // 🔥 상단 여백 제거
                                bottom: 0, // 🔥 하단 여백 제거
                              ),
                              child: AbsorbPointer(
                                child: _PageQuillView(
                                  delta: pageDelta, // ✅ 여기!
                                  settings: settings,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                  : A4Page(
                    key: key,
                    // ✅ A4Page는 순수 A4 비율만 맞추고,
                    //    실제 텍스트 여백은 여기서 Padding으로만 한 번 줍니다
                    margins: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: settings.horizontalMargin,
                      ),
                      child: AbsorbPointer(
                        child: _PageQuillView(
                          delta: pageDelta,
                          settings: settings,
                        ),
                      ),
                    ),
                  ),
        ),
        Text(
          '페이지 ${index + 1} / $_pageCount',
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 152, 171, 195),
          ),
        ),
      ],
    );
  }

  void _showPdfSharePopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'pdf_popup',
      barrierDismissible: true,
      barrierColor: Colors.black12,
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
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _pdfSubmenuOpenVN,
                    builder: (context, previewOpen, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _pdfExportSubmenuOpenVN,
                        builder: (context, exportOpen, __) {
                          final anyOpen = previewOpen || exportOpen;

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
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.96,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 10,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 140,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _PdfPopupItem(
                                      icon: Icons.picture_as_pdf_outlined,
                                      label: 'PDF 미리보기',
                                      onTap: _showPdfSubmenu,
                                    ),
                                    const SizedBox(height: 6),

                                    // PDF 내보내기 (export submenu anchor)
                                    CompositedTransformTarget(
                                      link: _pdfExportLink,
                                      child: _PdfPopupItem(
                                        icon: Icons.download_outlined,
                                        label: 'PDF 내보내기',
                                        onTap: _showPdfExportSubmenu,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                          // ✅ 기존 blur + opacity + scale 그대로
                          popup = ImageFiltered(
                            imageFilter: ImageFilter.blur(
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
                      );
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
    // 🔹 리스너에서 항상 최신값을 유지하므로 그냥 필드만 사용
    final writingSettings = _settingsController.settings;

    // 4. 여기부터는 그냥 UI용 값들
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
              // 🔻 아래는 기존 코드 그대로 두시면 됩니다
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

              const SizedBox(height: 7),
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

// 공통 상수
const double kCoverRadius = 13;

/// ----------------------
/// 표지 큰 카드(2:3 비율 미리보기)
/// ----------------------
class _A4PortraitCoverCard extends StatelessWidget {
  final String? coverPath;
  final VoidCallback onTap; // 사진 변경
  final VoidCallback? onLongPressPreview; // 길게 탭 시 크게 보기

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

        // 전체 화면 비율에 맞춰 책 카드 가로
        final cardW = (maxW * 0.88 * 0.45).clamp(0.0, maxW);
        final cardH = cardW * _ratio2to3;
        final cardRadius = scaledCoverRadius(cardW);

        // 표지 파일 체크
        File? coverFile;
        if (coverPath != null && coverPath!.isNotEmpty) {
          final f = File(coverPath!);
          if (f.existsSync()) {
            coverFile = f;
          }
        }

        // placeholder 위젯
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
              onTap: onTap, // 탭 = 사진 선택/변경
              onLongPress:
                  coverFile != null
                      ? onLongPressPreview
                      : null, // 표지 있을 때만 길게 탭 동작
              child: Container(
                width: cardW,
                height: cardH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cardRadius),
                  color:
                      coverFile != null
                          ? Colors
                              .transparent // 사진 있으면 배경/테두리 없이 이미지만 보이게
                          : const Color(0xFFFFFFFF).withValues(alpha: 0.04),
                  border:
                      coverFile != null
                          ? null
                          : Border.all(
                            color: const Color.fromARGB(255, 170, 193, 216),
                            width: 0.5,
                          ),
                ),
                clipBehavior: Clip.hardEdge, // radius 적용 위해 추가
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

/// ----------------------
/// 표지 미니 썸네일(+ 텍스트) — 2:3 비율
/// ----------------------
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
      // 이미지 있을 때 border 없음 / 없으면 border 있음
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(miniRadius),
        color:
            hasImage
                ? Colors
                    .transparent // 이미지 있을 때 배경 없이
                : const Color(0xFFFFFFFF).withValues(alpha: 0.04),
        border:
            hasImage
                ? null // ← 테두리 제거!
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

/// ----------------------
/// 한 페이지용 Quill 프리뷰 (페이지별 Delta 사용)
/// ----------------------
class _PageQuillView extends StatefulWidget {
  final dq.Delta delta;
  final WritingSettings settings;

  const _PageQuillView({required this.delta, required this.settings});

  @override
  State<_PageQuillView> createState() => _PageQuillViewState();
}

class _PageQuillViewState extends State<_PageQuillView>
    with AutomaticKeepAliveClientMixin {
  late quill.QuillController _controller;
  final ScrollController _scrollCtrl = ScrollController();
  late final FocusNode _focusNode;

  @override
  bool get wantKeepAlive => true; // 🔹 꼭 구현

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(skipTraversal: true, canRequestFocus: false);
    _controller = quill.QuillController(
      document: quill.Document.fromDelta(widget.delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void didUpdateWidget(covariant _PageQuillView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ DeepCollectionEquality 필요 없이 인스턴스만 비교해도 충분해요.
    if (oldWidget.delta != widget.delta) {
      _controller.dispose();
      _controller = quill.QuillController(
        document: quill.Document.fromDelta(widget.delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final s = widget.settings;

    String? fontFamily;
    switch (s.fontFamily) {
      case 'batang':
        fontFamily = 'Apple SD 산돌고딕 Neo';
        break;
      case 'inter':
        fontFamily = 'inter';
        break;
      default:
        fontFamily = null;
    }

    Color textColor;
    switch (s.themeId) {
      case 'dark':
        textColor = Colors.white.withValues(alpha: 0.92);
        break;
      case 'darkGreen':
        textColor = const Color.fromARGB(255, 255, 255, 255);
        break;
      case 'space':
        textColor = Colors.white.withValues(alpha: 0.96);
        break;
      case 'lightSky':
        textColor = const Color(0xFF1E293B);
        break;
      default:
        textColor = const Color(0xFF222222);
    }
    final baseStyles = quill.DefaultStyles.getInstance(context);

    // ✅ paragraph 가 null 일 수도 있으니, 안전한 기본값을 한 번 만들어 줍니다.
    final quill.DefaultTextBlockStyle baseParagraph =
        baseStyles.paragraph ??
        const quill.DefaultTextBlockStyle(
          TextStyle(),
          quill.HorizontalSpacing.zero,
          quill.VerticalSpacing.zero,
          quill.VerticalSpacing.zero,
          null,
        );

    // 기본 이미지 빌더들 중 image 키는 제거
    final defaultEmbeds = FlutterQuillEmbeds.editorBuilders();
    final safeEmbeds = defaultEmbeds.where((b) => b.key != 'image').toList();

    // 1) 기본 paragraph 스타일 가져와서 커스터마이징
    final customParagraph = baseParagraph.copyWith(
      style: baseParagraph.style.copyWith(
        fontSize: s.fontSize,
        height: s.lineHeight,
        letterSpacing: s.letterSpacing,
        fontFamily: fontFamily,
        color: textColor,
      ),

      // 2) 문단 위/아래 여백 제거
      verticalSpacing: quill.VerticalSpacing.zero,
      // horizontalSpacing / lineSpacing 은 baseParagraph 값 유지
    );

    // 3) 전체 스타일에 paragraph만 덮어쓰기
    final customStyles = baseStyles.merge(
      quill.DefaultStyles(paragraph: customParagraph),
    );

    return RepaintBoundary(
      child: ClipRect(
        child: quill.QuillEditor(
          controller: _controller,
          scrollController: _scrollCtrl,
          focusNode: _focusNode,
          config: quill.QuillEditorConfig(
            enableInteractiveSelection: false,
            showCursor: false,
            autoFocus: false,
            scrollable: false,
            padding: EdgeInsets.zero,
            expands: false,
            scrollPhysics: const ClampingScrollPhysics(),
            embedBuilders: [
              _SafeImageEmbedBuilder(),
              _HrSolidEmbedBuilder(),
              _HrEmbedBuilder(),
              ...safeEmbeds,
            ],
            customStyles: customStyles,
          ),
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
        thickness: 1,
        height: 17,
        color: ui.Color.fromARGB(255, 129, 147, 182),
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
      color: ui.Color.fromARGB(255, 129, 147, 182),
      padding: EdgeInsets.symmetric(vertical: 8),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  final double thickness;
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final EdgeInsetsGeometry padding;

  const _DashedDivider({
    this.thickness = 0.5,
    this.dashWidth = 5,
    this.dashSpace = 5,
    this.color = const Color(0xFFBDBDBD),
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: thickness,
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

class PaginationEngine {
  List<PageSlice> paginateDelta({
    required dq.Delta delta,
    required WritingSettings settings,
    required double pageWidth,
    required double pageHeight,
  }) {
    final painter = TextPainter(
      textDirection: ui.TextDirection.ltr,
      maxLines: null,
    );

    final ops = delta.toList();
    final slices = <PageSlice>[];

    int globalStart = 0;
    double accumulatedHeight = 0;

    final buffer = StringBuffer();
    Map<String, dynamic>? currentAttrs;

    void flushCurrentBuffer() {
      if (buffer.isEmpty) return;

      painter.text = TextSpan(
        text: buffer.toString(),
        style: _buildStyle(settings, currentAttrs),
      );
      painter.layout(maxWidth: pageWidth);

      accumulatedHeight += painter.size.height;
      buffer.clear();
    }

    int cursor = 0;

    for (final op in ops) {
      currentAttrs = op.attributes;

      if (op.data is! String) {
        flushCurrentBuffer();

        const embedHeight = 40.0;

        if (accumulatedHeight + embedHeight > pageHeight) {
          slices.add(PageSlice(globalStart, cursor));
          globalStart = cursor;
          accumulatedHeight = 0;
        }

        accumulatedHeight += embedHeight;
        cursor++;
        continue;
      }

      final text = op.data as String;

      final double effectivePageHeight = pageHeight + settings.fontSize * 0.8;

      for (int i = 0; i < text.length; i++) {
        buffer.write(text[i]);

        painter.text = TextSpan(
          text: buffer.toString(),
          style: _buildStyle(settings, currentAttrs),
        );
        painter.layout(maxWidth: pageWidth);

        if (accumulatedHeight + painter.size.height > effectivePageHeight) {
          buffer.write('\n');

          slices.add(PageSlice(globalStart, cursor + i));
          globalStart = cursor + i;
          accumulatedHeight = 0;
          buffer.clear();
        }
      }

      cursor += text.length;
      flushCurrentBuffer();
    }

    if (globalStart < cursor) {
      slices.add(PageSlice(globalStart, cursor));
    }

    return slices;
  }

  TextStyle _buildStyle(WritingSettings s, Map<String, dynamic>? attrs) {
    double size = s.fontSize;
    FontWeight weight = FontWeight.w400;

    if (attrs != null) {
      if (attrs['bold'] == true) weight = FontWeight.w700;

      // header 우선
      if (attrs['header'] == 1) {
        size = s.fontSize * 2.0;
      } else if (attrs['header'] == 2) {
        size = s.fontSize * 1.6;
      }

      // 🔹 Quill 'size' attribute 반영 (예: "15", 15, "7.5" 등)
      final dynamic szAttr = attrs['size'];
      if (szAttr != null) {
        double? parsed;
        if (szAttr is num) {
          parsed = szAttr.toDouble();
        } else if (szAttr is String) {
          parsed = double.tryParse(szAttr);
        }
        if (parsed != null && parsed > 0) {
          size = parsed;
        }
      }
    }

    return TextStyle(
      fontSize: size,
      height: s.lineHeight,
      letterSpacing: s.letterSpacing,
      fontWeight: weight,
      fontFamily:
          s.fontFamily == 'inter'
              ? 'Inter'
              : s.fontFamily == 'batang'
              ? 'Apple SD 산돌고딕 Neo'
              : null,
    );
  }
}

/// plainText 기준 start/end 에 맞춰 Delta를 잘라주는 유틸
class DeltaPaginator {
  /// [fullDelta] 전체 문서와 [pages] (plainText 기준 start/end) 를 받아
  /// 각 페이지에 해당하는 Delta 리스트를 반환
  static List<dq.Delta> sliceByPageRanges({
    required dq.Delta fullDelta,
    required List<PageSlice> pages,
  }) {
    final result = <dq.Delta>[];
    for (final p in pages) {
      result.add(_sliceDelta(fullDelta, p.startOffset, p.endOffset));
    }
    return result;
  }

  /// [start] ~ [end) 구간만 Delta로 잘라내기
  static dq.Delta _sliceDelta(dq.Delta fullDelta, int start, int end) {
    final out = dq.Delta();
    int cursor = 0;

    for (final op in fullDelta.toList()) {
      final data = op.data;
      final attrs = op.attributes;

      // 이 op가 plainText에서 차지하는 길이
      int opLen;
      final isEmbed = data is! String;
      if (data is String) {
        opLen = data.length;
      } else {
        // image / hr 등 embed는 1글자 취급
        opLen = 1;
      }

      final opStart = cursor;
      final opEnd = cursor + opLen;

      if (opEnd <= start) {
        cursor = opEnd;
        continue;
      }
      if (opStart >= end) break;

      if (isEmbed) {
        // 임베드는 범위와 겹치면 통째로 넣기 (1글자)
        out.insert(data, attrs);
      } else {
        final localStart = (start - opStart).clamp(0, opLen);
        final localEnd = (end - opStart).clamp(0, opLen);
        if (localStart < localEnd) {
          // 🔥 불필요한 cast 제거
          final sub = (data as String?)!.substring(localStart, localEnd);
          out.insert(sub, attrs);
        }
      }

      cursor = opEnd;
    }

    // ----------------------------
    // 🔥 마지막에 newline
    // ----------------------------
    final ops = out.toList();

    // 비어 있으면 newline 하나만
    if (ops.isEmpty) {
      out.insert('\n');
      return out;
    }

    final last = ops.last;
    final lastData = last.data;

    if (lastData is String) {
      if (!lastData.endsWith('\n')) {
        out.insert('\n', last.attributes);
      }
    } else {
      // embed로 끝나면 반드시 newline 추가
      out.insert('\n');
    }

    return out;
  }
}

class _DashedLinePainter extends CustomPainter {
  final double thickness;
  final double dashWidth;
  final double dashSpace;
  final Color color;

  _DashedLinePainter({
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

    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      final x2 = (x + dashWidth).clamp(0, size.width).toDouble();
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
        return const Icon(
          Icons.broken_image,
          size: 32,
          color: ui.Color.fromARGB(255, 95, 124, 139),
        );
      },
    );
  }
}

/// --------------------------------------
/// KeepAlive wrapper (탭 유지용)
/// --------------------------------------
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
  final String themeId; // 🔹 테마 구분용
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
                // 우주 테마는 그라데이션 배경
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
                // 나머지 테마는 단색
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
            '미리보기',
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
            // 배경
            color: (isSpace || isLightSky) ? null : colors.background,

            // 그라데이션
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

            //  화이트 테마일 때만 표시
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
                      // 배경 레이어
                      if (isSpace) ...[
                        // 반짝이는 별
                        const Positioned.fill(
                          child: _AnimatedStarField(starCount: 110),
                        ),
                        // 별똥별 (옵션)
                        const Positioned.fill(
                          child: IgnorePointer(child: _ShootingStarLayer()),
                        ),
                      ] else ...[
                        // lightSky: 햇살
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
        return null;
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
      case 'space': // ⭐
        return const _ThemeColors(
          background: Color(0xFF0B0E2A),
          text: Color(0xFFEAF2FF),
        );
      case 'lightSky': // 🌤
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

/// 이 책 전용 메모 모델
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

/// 인라인 메모 에디터
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

// 상세 정보 입력용 텍스트 필드 행 위젯
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

// ----------------------
// 🌌 우주 테마용 별 페인터
// ----------------------

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
    this.starCount = 150,
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
// 🌞 한낮 하늘 테마용 태양빛 페인터
// ----------------------
class _SunRayPainter extends CustomPainter {
  const _SunRayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset sunCenter = Offset(size.width * -0.10, size.height * -0.10);
    final double coreRadius = size.width * 0.11;
    final double haloRadius = size.longestSide * 0.7;
    final Rect fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 눈부신 핫스팟 (해 주변만)
    final Paint hotspot =
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
            stops: [0.0, 1.0],
          ).createShader(
            Rect.fromCircle(center: sunCenter, radius: coreRadius * 1.5),
          )
          ..blendMode = BlendMode.plus;

    // 🔁 더 이상 전체 rect에 안 깔고, 코어 근처만 그리기
    canvas.drawCircle(sunCenter, coreRadius * 1.6, hotspot);

    // 태양 코어
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

    // 주변 퍼짐
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

    // 대각선 햇살
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

    // 전체 밝기 보정
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
