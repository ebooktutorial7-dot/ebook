// custom_pdf_preview_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ebook_tutorial_app/pages/book_builder_page.dart'
    show ChapterItem;
import 'package:ebook_tutorial_app/pdf/book_pdf_builder.dart' show buildBookPdf;

import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_container.dart';
import 'package:ebook_tutorial_app/widgets/common/app_toast.dart';

const _primaryBlue = ui.Color.fromARGB(255, 79, 164, 255);

const _loaderColor = ui.Color.fromARGB(255, 150, 194, 224);

// 카드 위 아이콘 컬러 (목차 아이콘과 동일 톤)
const _topIconColor = ui.Color.fromARGB(255, 71, 95, 121);

class CustomPdfPreviewPage extends StatefulWidget {
  const CustomPdfPreviewPage({
    super.key,
    required this.title,
    required this.pdfBytes,
    this.chapters = const [],
    this.reduceTransparency = false,
  });

  final String title;
  final Uint8List pdfBytes;
  final List<ChapterItem> chapters;
  final bool reduceTransparency;

  @override
  State<CustomPdfPreviewPage> createState() => _CustomPdfPreviewPageState();
}

class _CustomPdfPreviewPageState extends State<CustomPdfPreviewPage> {
  PdfDocument? _doc;

  int _page = 1;
  int _pagesCount = 1;

  late Uint8List _currentPdfBytes;

  final Map<int, ui.Image> _cache = <int, ui.Image>{};
  final PageController _pageCtrl = PageController();
  final TransformationController _zoomCtrl = TransformationController();

  static const double _cardTopPadding = 70;
  static const double _controlBottom = 45;

  double _uiScale = 1.0;
  static const double _minUiScale = 1.0;
  static const double _maxUiScale = 4.0;
  static const double _stepUiScale = 0.15;

  int _loadingCount = 0;
  bool get _isLoading => _loadingCount > 0;

  GlassTheme get _glassTheme =>
      GlassTheme.fromFlags(reduceTransparency: widget.reduceTransparency);

  @override
  void initState() {
    super.initState();
    _currentPdfBytes = widget.pdfBytes;
    _openFromBytes(widget.pdfBytes);
  }

  @override
  void didUpdateWidget(covariant CustomPdfPreviewPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pdfBytes != widget.pdfBytes) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _currentPdfBytes = widget.pdfBytes;
        _openFromBytes(widget.pdfBytes);
      });
    }
  }

  @override
  void dispose() {
    _zoomCtrl.dispose();
    _pageCtrl.dispose();
    _disposeDocAndCache(disposeImages: true);
    super.dispose();
  }

  void _incLoading() {
    if (!mounted) return;
    setState(() => _loadingCount++);
  }

  void _decLoading() {
    if (!mounted) return;
    setState(() {
      _loadingCount = (_loadingCount - 1).clamp(0, 1 << 30);
    });
  }

  void _disposeDocAndCache({required bool disposeImages}) {
    _doc?.dispose();
    _doc = null;

    if (disposeImages) {
      for (final img in _cache.values) {
        img.dispose();
      }
    }
    _cache.clear();
  }

  void _jumpToFirstSafely() {
    if (_pageCtrl.hasClients) {
      _pageCtrl.jumpToPage(0);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
    });
  }

  Future<void> _openFromBytes(Uint8List bytes) async {
    _incLoading();

    final oldImages = List<ui.Image>.from(_cache.values);
    _cache.clear();

    _doc?.dispose();
    _doc = null;

    try {
      final doc = await PdfDocument.openData(bytes);
      if (!mounted) return;

      setState(() {
        _doc = doc;
        _pagesCount = doc.pageCount;
        _page = 1;
      });

      _jumpToFirstSafely();
      _resetZoom();
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, 'PDF 열기 실패: $e');
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final img in oldImages) {
          img.dispose();
        }
      });
      _decLoading();
    }
  }

  Future<ui.Image> _renderPageImage(int pageNumber) async {
    final cached = _cache[pageNumber];
    if (cached != null) return cached;

    final doc = _doc;
    if (doc == null) {
      final recorder = ui.PictureRecorder();
      final picture = recorder.endRecording();
      return picture.toImage(1, 1);
    }

    final page = await doc.getPage(pageNumber);

    const scale = 3.0;
    final pageImage = await page.render(
      width: (page.width * scale).round(),
      height: (page.height * scale).round(),
      backgroundFill: true,
    );

    final img = await pageImage.createImageIfNotAvailable();
    _cache[pageNumber] = img;
    return img;
  }

  void _applyScale(double newScale) {
    newScale = newScale.clamp(_minUiScale, _maxUiScale);

    final current = _zoomCtrl.value.getMaxScaleOnAxis();
    if (current == 0) return;

    final factor = newScale / current;
    _zoomCtrl.value = _zoomCtrl.value.scaledByDouble(factor, factor, 1.0, 1.0);
    _uiScale = newScale;
  }

  void _zoomIn() => _applyScale(_uiScale + _stepUiScale);
  void _zoomOut() => _applyScale(_uiScale - _stepUiScale);

  void _resetZoom() {
    _zoomCtrl.value = Matrix4.identity();
    _uiScale = 1.0;
  }

  void _goFirst() {
    if (_pagesCount <= 1) return;
    _pageCtrl.animateToPage(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _goLast() {
    if (_pagesCount <= 1) return;
    _pageCtrl.animateToPage(
      _pagesCount - 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _goPrev() {
    final p = (_page - 1).clamp(1, _pagesCount);
    _pageCtrl.animateToPage(
      p - 1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _goNext() {
    final p = (_page + 1).clamp(1, _pagesCount);
    _pageCtrl.animateToPage(
      p - 1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> _openChapterPickerSameDesign() async {
    if (widget.chapters.isEmpty) {
      AppToast.show(context, '목차가 없습니다');
      return;
    }

    final tmpSelected = <int>{};
    var useAll = true;

    final picked = await showDialog<_ChapterPickResult>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void applyAndClose() {
              if (!useAll && tmpSelected.isEmpty) {
                AppToast.show(context, '회차를 선택해 주세요');
                return;
              }
              Navigator.pop(
                context,
                _ChapterPickResult(useAll: useAll, selected: tmpSelected),
              );
            }

            return Material(
              type: MaterialType.transparency,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: GlassContainer(
                    theme: _glassTheme,
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
                            'PDF 미리보기',
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
                                    onTap:
                                        () =>
                                            setModalState(() => useAll = true),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            useAll
                                                ? Colors.white
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
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
                                        () =>
                                            setModalState(() => useAll = false),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            !useAll
                                                ? Colors.white
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
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
                                itemCount: widget.chapters.length,
                                itemBuilder: (context, i) {
                                  final c = widget.chapters[i];
                                  final checked = tmpSelected.contains(i);

                                  return CheckboxListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    value: checked,
                                    activeColor: _primaryBlue,
                                    checkColor: Colors.white,
                                    title: Text(
                                      c.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13.5),
                                    ),
                                    onChanged: (v) {
                                      setModalState(() {
                                        if (v == true) {
                                          tmpSelected.add(i);
                                        } else {
                                          tmpSelected.remove(i);
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
                                    style: TextStyle(color: Color(0xFF1F3A56)),
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
                                  child: const Text('미리보기'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (picked == null) return;

    final List<ChapterItem> targetChapters =
        picked.useAll
            ? widget.chapters
            : picked.selected
                .map((i) => widget.chapters[i])
                .toList(growable: false);

    await _rebuildPreviewPdf(targetChapters);
  }

  Future<void> _rebuildPreviewPdf(List<ChapterItem> chapters) async {
    if (chapters.isEmpty) {
      AppToast.show(context, '선택된 회차가 없습니다');
      return;
    }

    _incLoading();
    try {
      final bytes = await buildBookPdf(
        chapters: chapters,
        showChapterTitle: true,
      );
      if (!mounted) return;

      _currentPdfBytes = bytes;

      _resetZoom();
      await _openFromBytes(bytes);

      if (!mounted) return;
      _jumpToFirstSafely();
      setState(() => _page = 1);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, 'PDF 생성 실패: $e');
    } finally {
      _decLoading();
    }
  }

  String _safeFileName(String name) {
    final trimmed = name.trim().isEmpty ? 'document' : name.trim();
    final sanitized = trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return sanitized.length > 80 ? sanitized.substring(0, 80) : sanitized;
  }

  Future<File> _writePdfToTempFile({required String fileNameBase}) async {
    final dir = await getTemporaryDirectory();
    final fileName = '${_safeFileName(fileNameBase)}.pdf';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(_currentPdfBytes, flush: true);
    return file;
  }

  Future<File> _writePdfToDocuments({required String fileNameBase}) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${_safeFileName(fileNameBase)}.pdf';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(_currentPdfBytes, flush: true);
    return file;
  }

  Future<void> _onDownloadTap() async {
    if (_isLoading) return;

    _incLoading();
    try {
      final file = await _writePdfToDocuments(fileNameBase: widget.title);
      if (!mounted) return;
      AppToast.show(context, '앱에 저장 완료: ${p.basename(file.path)}');
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, '저장 실패: $e');
    } finally {
      _decLoading();
    }
  }

  Future<void> _onShareTap() async {
    if (_isLoading) return;

    _incLoading();
    try {
      final file = await _writePdfToTempFile(fileNameBase: widget.title);
      if (!mounted) return;

      final box = context.findRenderObject() as RenderBox?;
      final origin =
          box == null ? null : (box.localToGlobal(Offset.zero) & box.size);

      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType: 'application/pdf',
            name: p.basename(file.path),
          ),
        ],
        text: widget.title,
        sharePositionOrigin: origin,
      );
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, '공유 실패: $e');
    } finally {
      _decLoading();
    }
  }

  Widget _tightIconButton({
    required VoidCallback? onPressed,
    required IconData icon,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 26),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _pill({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const ui.Color.fromARGB(
          136,
          135,
          181,
          211,
        ).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: child,
      ),
    );
  }

  Widget _loadingOverlay() {
    if (!_isLoading) return const SizedBox.shrink();

    return const Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: Center(
          child: CupertinoActivityIndicator(radius: 16, color: _loaderColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _pagesCount,
            onPageChanged: (index) {
              _resetZoom();
              setState(() => _page = index + 1);
            },
            itemBuilder: (context, index) {
              final doc = _doc;
              if (doc == null) return const SizedBox.shrink();

              final pageNumber = index + 1;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final maxCardWidth = constraints.maxWidth * 0.95;
                  final maxCardHeight = constraints.maxHeight * 0.90;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: _cardTopPadding),
                      child: FutureBuilder<ui.Image>(
                        future: _renderPageImage(pageNumber),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return SizedBox(
                              width: maxCardWidth,
                              height: maxCardHeight,
                            );
                          }

                          final img = snap.data!;
                          final imgRatio = img.width / img.height;

                          final cardHeight =
                              (maxCardWidth / imgRatio > maxCardHeight)
                                  ? maxCardHeight
                                  : (maxCardWidth / imgRatio);

                          return ClipRect(
                            child: InteractiveViewer(
                              transformationController: _zoomCtrl,
                              panEnabled: true,
                              scaleEnabled: false,
                              minScale: _minUiScale,
                              maxScale: _maxUiScale,
                              child: SizedBox(
                                width: maxCardWidth,
                                height: cardHeight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const ui.Color.fromARGB(
                                        255,
                                        138,
                                        176,
                                        201,
                                      ),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: RawImage(
                                    image: img,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // ===== 카드 위 아이콘: 좌/우 분리 =====

          // 왼쪽: 목차
          Positioned(
            left: 10,
            top: _cardTopPadding - 55,
            child: IconButton(
              onPressed:
                  (_isLoading || widget.chapters.isEmpty)
                      ? null
                      : _openChapterPickerSameDesign,
              icon: const Icon(
                Icons.format_list_numbered,
                color: _topIconColor,
                size: 25,
              ),
            ),
          ),

          // 오른쪽: 다운로드 + 공유
          Positioned(
            right: 10,
            top: _cardTopPadding - 55,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _isLoading ? null : _onDownloadTap,
                  icon: const Icon(
                    Icons.file_download_outlined,
                    color: _topIconColor,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 2),
                IconButton(
                  onPressed: _isLoading ? null : _onShareTap,
                  icon: const Icon(
                    Icons.ios_share,
                    color: _topIconColor,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),

          // ===== 하단 통합 컨트롤 바 =====
          Positioned(
            left: 12,
            right: 12,
            bottom: _controlBottom,
            child: SafeArea(
              child: _pill(
                child: Row(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _tightIconButton(
                          onPressed: _zoomOut,
                          icon: Icons.zoom_out,
                        ),
                        _tightIconButton(
                          onPressed: _zoomIn,
                          icon: Icons.zoom_in,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_page / $_pagesCount',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 11),
                        _tightIconButton(
                          onPressed: _page <= 1 ? null : _goFirst,
                          icon: Icons.keyboard_double_arrow_left,
                        ),
                        _tightIconButton(
                          onPressed: _page <= 1 ? null : _goPrev,
                          icon: Icons.chevron_left,
                        ),
                        _tightIconButton(
                          onPressed: _page >= _pagesCount ? null : _goNext,
                          icon: Icons.chevron_right,
                        ),
                        _tightIconButton(
                          onPressed: _page >= _pagesCount ? null : _goLast,
                          icon: Icons.keyboard_double_arrow_right,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          _loadingOverlay(),
        ],
      ),
    );
  }
}

class _ChapterPickResult {
  const _ChapterPickResult({required this.useAll, required this.selected});
  final bool useAll;
  final Set<int> selected;
}
