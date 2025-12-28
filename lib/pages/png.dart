// png.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

enum ShareFormat { pdf, png, jpg }

enum ShareRangeMode { current, all, range }

class SharePickResult {
  const SharePickResult({
    required this.format,
    required this.rangeMode,
    required this.startPage,
    required this.endPage,
  });

  final ShareFormat format;
  final ShareRangeMode rangeMode;

  // 1-based inclusive
  final int startPage;
  final int endPage;
}

Future<SharePickResult?> showShareOptionsDialog({
  required BuildContext context,
  required int currentPage,
  required int pagesCount,
  Color barrierColor = const Color(0xFF0F2238),
  String dialogTitle = '공유',
  String confirmLabel = '공유',
}) async {
  ShareFormat format = ShareFormat.png;
  ShareRangeMode rangeMode = ShareRangeMode.current;

  int start = currentPage;
  int end = currentPage;

  final startCtrl = TextEditingController(text: '$start');
  final endCtrl = TextEditingController(text: '$end');
  final startFocus = FocusNode();
  final endFocus = FocusNode();

  bool rangeInvalid = false;

  int clampPage(int v) => v.clamp(1, pagesCount);

  void normalizeRange() {
    start = clampPage(start);
    end = clampPage(end);
    if (start > end) {
      final t = start;
      start = end;
      end = t;
    }
  }

  void syncCtrls() {
    startCtrl.text = '$start';
    endCtrl.text = '$end';
  }

  bool applyFields({bool commitNormalize = false}) {
    final sRaw = startCtrl.text.trim();
    final eRaw = endCtrl.text.trim();
    if (sRaw.isEmpty || eRaw.isEmpty) {
      rangeInvalid = true;
      return false;
    }

    final s = int.tryParse(sRaw);
    final e = int.tryParse(eRaw);
    if (s == null || e == null) {
      rangeInvalid = true;
      return false;
    }

    if (s < 1 || s > pagesCount || e < 1 || e > pagesCount) {
      rangeInvalid = true;
      return false;
    }

    start = s;
    end = e;
    normalizeRange();
    rangeInvalid = false;

    if (commitNormalize) syncCtrls();
    return true;
  }

  void setPreset(ShareRangeMode m) {
    rangeMode = m;
    rangeInvalid = false;

    if (m == ShareRangeMode.current) {
      start = currentPage;
      end = currentPage;
      syncCtrls();
    } else if (m == ShareRangeMode.all) {
      start = 1;
      end = pagesCount;
      syncCtrls();
    } else {
      // range: 비어있으면 현재값 유지, 없으면 현재페이지
      if (startCtrl.text.trim().isEmpty) startCtrl.text = '$currentPage';
      if (endCtrl.text.trim().isEmpty) endCtrl.text = '$currentPage';
      applyFields(commitNormalize: true);
    }
  }

  bool canConfirm() {
    if (rangeMode != ShareRangeMode.range) return true;
    return !rangeInvalid &&
        startCtrl.text.trim().isNotEmpty &&
        endCtrl.text.trim().isNotEmpty;
  }

  final result = await showDialog<SharePickResult>(
    context: context,
    barrierColor: barrierColor.withValues(alpha: 0.21),
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          void confirm() {
            if (rangeMode == ShareRangeMode.range) {
              final ok = applyFields(commitNormalize: true);
              if (!ok) {
                setModalState(() {});
                return;
              }
            } else {
              // current/all은 이미 값이 맞춰져 있음
              rangeInvalid = false;
              normalizeRange();
              syncCtrls();
            }

            Navigator.pop(
              context,
              SharePickResult(
                format: format,
                rangeMode: rangeMode,
                startPage: start,
                endPage: end,
              ),
            );
          }

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
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
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

          Widget minimalField(
            TextEditingController ctrl,
            FocusNode focus, {
            double width = 56, // ✅ 기본 알약 폭
          }) {
            final border =
                rangeInvalid
                    ? const ui.Color.fromARGB(255, 239, 111, 109)
                    : const Color(0xFFD6E3F0);

            return Container(
              width: width, // ✅ 가로 고정
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: border, width: 0.8),
              ),
              alignment: Alignment.center,
              child: CupertinoTextField(
                controller: ctrl,
                focusNode: focus,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: const BoxDecoration(color: Colors.transparent),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  color: Color(0xFF1F3A56),
                ),
                onChanged:
                    (_) => setModalState(
                      () => applyFields(commitNormalize: false),
                    ),
                onEditingComplete:
                    () =>
                        setModalState(() => applyFields(commitNormalize: true)),
              ),
            );
          }

          final showRange = rangeMode == ShareRangeMode.range;

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

                      // FORMAT (minimal segmented)
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

                      const SizedBox(height: 20),

                      // RANGE (minimal segmented)
                      segPill(
                        children: [
                          segItem(
                            label: '지금',
                            selected: rangeMode == ShareRangeMode.current,
                            onTap:
                                () => setModalState(
                                  () => setPreset(ShareRangeMode.current),
                                ),
                          ),
                          segItem(
                            label: '전체',
                            selected: rangeMode == ShareRangeMode.all,
                            onTap:
                                () => setModalState(
                                  () => setPreset(ShareRangeMode.all),
                                ),
                          ),
                          segItem(
                            label: '직접',
                            selected: rangeMode == ShareRangeMode.range,
                            onTap:
                                () => setModalState(() {
                                  setPreset(ShareRangeMode.range);
                                  startFocus.requestFocus();
                                }),
                          ),
                        ],
                      ),

                      // A안: start/end only when range
                      if (!showRange)
                        const SizedBox(height: 7)
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center, // 가운데 정렬(선택)
                                children: [
                                  minimalField(
                                    startCtrl,
                                    startFocus,
                                    width: 60,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      '~',
                                      style: TextStyle(
                                        color: Color(0xFF9AA7B4),
                                      ),
                                    ),
                                  ),
                                  minimalField(endCtrl, endFocus, width: 60),
                                ],
                              ),

                              const SizedBox(height: 6),
                              Text(
                                rangeInvalid ? '1~$pagesCount' : '$start~$end',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      rangeInvalid
                                          ? const ui.Color.fromARGB(
                                            255,
                                            255,
                                            94,
                                            92,
                                          )
                                          : const Color(0xFF9AA7B4),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                overlayColor:
                                    Colors
                                        .transparent, // ✅ long press / hover 제거
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
                                surfaceTintColor: const WidgetStatePropertyAll(
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

                              onPressed: canConfirm() ? confirm : null,
                              child: const Text(
                                '공유',
                                style: TextStyle(
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

  startCtrl.dispose();
  endCtrl.dispose();
  startFocus.dispose();
  endFocus.dispose();

  return result;
}

const _loaderColor = ui.Color.fromARGB(255, 198, 232, 255);
const _topIconColor = ui.Color.fromARGB(255, 71, 95, 121);

/// =======================================================
/// PNG 미리보기 페이지 (PDF 없이, Quill Delta를 직접 렌더)
/// =======================================================
class PngPage extends StatefulWidget {
  const PngPage({
    super.key,
    required this.title,
    required this.deltaJson,
    required this.revision,
    this.episodeTitle,
    // 스타일/설정(ChapterWritePage settings 그대로 넘기면 됨)
    this.horizontalMargin = 18,
    this.verticalMargin = 18,
    this.baseFontSize = 15,
    this.lineHeight = 1.55,
    this.letterSpacing = 0.0,
    this.fontFamily,
    this.pageBackgroundColor = Colors.white,
    this.defaultTextColor = const Color(0xFF111111),

    // 렌더 품질(저장/공유 품질에 영향)
    this.renderScale = 2.8,
    // 이미지 최대 높이 비율(페이지 내에서 너무 길면 축소)
    this.maxImageHeightRatio = 0.65,
  });

  final String title;

  final String? episodeTitle;

  /// Quill delta json: List<Map<String, dynamic>>
  final List<Map<String, dynamic>> deltaJson;
  final int revision;

  final double horizontalMargin;
  final double verticalMargin;

  final double baseFontSize;
  final double lineHeight;
  final double letterSpacing;
  final String? fontFamily;

  final Color pageBackgroundColor;
  final Color defaultTextColor;

  final double renderScale;
  final double maxImageHeightRatio;

  @override
  State<PngPage> createState() => _PngPageState();
}

class _PngPageState extends State<PngPage> {
  int _page = 1;
  int _pagesCount = 1;

  final PageController _pageCtrl = PageController();
  final TransformationController _zoomCtrl = TransformationController();

  // 이미지 원본 사이즈 캐시 (src -> Size(w,h))
  final Map<String, Size> _imageSizeCache = <String, Size>{};

  static const double _cardTopPadding = 75;
  static const double _controlBottom = 45;

  double _uiScale = 1.0;
  static const double _minUiScale = 1.0;
  static const double _maxUiScale = 4.0;
  static const double _stepUiScale = 0.15;

  int _loadingCount = 0;
  bool get _isLoading => _loadingCount > 0;

  // A4 기준(미리보기 카드 기준 폭에 맞춰 계산)
  double _pageWidthPx = 0;
  double _pageHeightPx = 0;

  double? _lastLayoutWidth;
  int _styleSig = 0;

  int _deltaSig = 0; // delta 내용 해시 시그니처
  bool _paginateScheduled = false; // postFrame 중복 호출 방지

  // settings 연속 변경 폭주 방지: 디바운스 + 취소(epoch)
  Timer? _paginateDebounce;
  int _paginateEpoch = 0;
  bool _paginating = false;

  List<Map<String, dynamic>> _withEpisodeTitleDelta(
    List<Map<String, dynamic>> delta,
  ) {
    final t = (widget.episodeTitle ?? '').trim();
    if (t.isEmpty) return delta;

    String? firstText;
    for (final op in delta) {
      final ins = op['insert'];
      if (ins is String) {
        final s = ins.trim();
        if (s.isNotEmpty) {
          firstText = s;
          break;
        }
      }
    }
    if (firstText == t) return delta;

    return <Map<String, dynamic>>[
      {'insert': t},
      {
        'insert': '\n',
        'attributes': {
          'header': 3, // 원하는 크기에 맞게 1/2/3 선택
        },
      },
      {'insert': '\n'}, // 제목-본문 간격(원하면 1개만)
      ...delta,
    ];
  }

  int _calcStyleSig(PngPage w) {
    return Object.hash(
      w.revision,
      w.horizontalMargin,
      w.verticalMargin,
      w.baseFontSize,
      w.lineHeight,
      w.letterSpacing,
      w.fontFamily,
      w.maxImageHeightRatio,
      w.renderScale,

      w.pageBackgroundColor.toARGB32(),
      w.defaultTextColor.toARGB32(),

      (w.episodeTitle ?? '').trim(),
    );
  }

  int _calcDeltaSig(List<Map<String, dynamic>> delta) {
    int h = 0x345678;
    for (final op in delta) {
      final ins = op['insert'];
      if (ins is String) {
        h = Object.hash(h, 1, ins);
      } else if (ins is Map) {
        if (ins.containsKey('image')) {
          h = Object.hash(h, 2, ins['image']);
        } else if (ins.containsKey('hr_solid')) {
          h = Object.hash(h, 3);
        } else if (ins.containsKey('hr')) {
          h = Object.hash(h, 4);
        } else {
          h = Object.hash(h, 5, ins.length);
        }
      } else {
        h = Object.hash(h, 6, ins?.runtimeType.toString());
      }

      final a = op['attributes'];
      if (a is Map) {
        final keys = a.keys.map((e) => e.toString()).toList()..sort();
        for (final k in keys) {
          final v = a[k];
          h = Object.hash(
            h,
            k,
            v is num || v is bool || v is String ? v : v?.toString(),
          );
        }
      }
    }
    return h;
  }

  void _schedulePaginate({Duration delay = const Duration(milliseconds: 120)}) {
    _paginateDebounce?.cancel();
    final epoch = _paginateEpoch;
    _paginateDebounce = Timer(delay, () {
      if (!mounted) return;
      _paginateIfNeeded(epoch);
    });
  }

  void _disposeImages() {
    for (final img in _imageCache.values) {
      img.dispose();
    }
    _imageCache.clear();
  }

  void _resetPaginationAndCaches({bool notify = true}) {
    _paginateDebounce?.cancel();
    _paginateEpoch++; // 이전 paginate 전부 무효화
    _paginating = false;

    _pages = const [];
    _pngCache.clear();
    _imageSizeCache.clear();
    _disposeImages();

    _page = 1;
    _pagesCount = 1;

    _resetZoom();

    if (_pageCtrl.hasClients) {
      _pageCtrl.jumpToPage(0);
    }

    if (notify && mounted) setState(() {});
  }

  late List<_Block> _blocks;
  List<_PagePlan> _pages = const [];

  // 캐시
  final Map<int, Uint8List> _pngCache = <int, Uint8List>{}; // 1-based page
  final Map<String, ui.Image> _imageCache = <String, ui.Image>{};

  @override
  void initState() {
    super.initState();
    var safeDelta = widget.deltaJson
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: true);

    // ✅ 추가: 회차 제목을 delta 맨 앞에 삽입
    safeDelta = _withEpisodeTitleDelta(safeDelta);

    _blocks = _DeltaParser().parse(safeDelta);

    _styleSig = _calcStyleSig(widget);
    _deltaSig = _calcDeltaSig(safeDelta);
  }

  @override
  void didUpdateWidget(covariant PngPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    var safeDelta = widget.deltaJson
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: true);
    safeDelta = _withEpisodeTitleDelta(safeDelta);

    final newDeltaSig = _calcDeltaSig(safeDelta);
    final deltaChanged = newDeltaSig != _deltaSig;

    if (deltaChanged) {
      _deltaSig = newDeltaSig;
      _blocks = _DeltaParser().parse(safeDelta);
    }

    final newSig = _calcStyleSig(widget);
    if (deltaChanged || newSig != _styleSig) {
      _styleSig = newSig;
      _resetPaginationAndCaches();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _schedulePaginate();
      });
    }
  }

  @override
  void dispose() {
    _paginateDebounce?.cancel();
    _zoomCtrl.dispose();
    _pageCtrl.dispose();
    _disposeImages();
    super.dispose();
  }

  void _incLoading() {
    if (!mounted) return;
    setState(() => _loadingCount++);
  }

  void _decLoading() {
    if (!mounted) return;
    setState(() => _loadingCount = (_loadingCount - 1).clamp(0, 1 << 30));
  }

  void _applyScale(double newScale) {
    newScale = newScale.clamp(_minUiScale, _maxUiScale);

    final current = _zoomCtrl.value.getMaxScaleOnAxis();
    if (current == 0) return;

    final factor = newScale / current;
    if (!factor.isFinite) return;

    final m = _zoomCtrl.value.clone()..scaleByDouble(factor, factor, 1.0, 1.0);

    _zoomCtrl.value = m;
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
    if (!_pageCtrl.hasClients) return;
    _pageCtrl.jumpToPage(0);
  }

  void _goLast() {
    if (_pagesCount <= 1) return;
    if (!_pageCtrl.hasClients) return;
    _pageCtrl.jumpToPage(_pagesCount - 1);
  }

  void _goPrev() {
    if (!_pageCtrl.hasClients) return;
    final p = (_page - 1).clamp(1, _pagesCount);
    _pageCtrl.jumpToPage(p - 1);
  }

  void _goNext() {
    if (!_pageCtrl.hasClients) return;
    final p = (_page + 1).clamp(1, _pagesCount);
    _pageCtrl.jumpToPage(p - 1);
  }

  // ---------------------------
  // 페이지네이션(블록 -> 페이지별 드로잉 플랜)
  // ---------------------------
  Future<void> _paginateIfNeeded(int epoch) async {
    if (epoch != _paginateEpoch) return;
    if (_pageWidthPx <= 0 || _pageHeightPx <= 0) return;
    if (_pages.isNotEmpty) return;
    if (_paginating) return;

    _paginating = true;
    _incLoading();
    try {
      final contentW = _pageWidthPx - widget.horizontalMargin * 2;
      final contentH = _pageHeightPx - widget.verticalMargin * 2;

      final maxImageH = contentH * widget.maxImageHeightRatio;

      // 이미지 원본 사이즈 수집(페이지네이션 정확도용)
      for (final b in _blocks) {
        if (epoch != _paginateEpoch) return;
        if (b is _ImageBlock) {
          if (_imageSizeCache.containsKey(b.src)) continue;
          final img = await _loadImage(b.src);
          if (epoch != _paginateEpoch) return;
          if (img != null) {
            _imageSizeCache[b.src] = Size(
              img.width.toDouble(),
              img.height.toDouble(),
            );
          }
        }
      }

      if (epoch != _paginateEpoch) return;

      final engine = _CanvasLayoutEngine(
        baseStyle: TextStyle(
          fontSize: widget.baseFontSize,
          height: widget.lineHeight,
          letterSpacing: widget.letterSpacing,
          fontFamily: widget.fontFamily,
          color: widget.defaultTextColor,
          fontWeight: FontWeight.w400,
        ),
        contentWidth: contentW,
        contentHeight: contentH,
        imageSizes: _imageSizeCache,
        maxImageHeight: maxImageH,
      );

      final pages = await engine.paginate(_blocks);
      if (epoch != _paginateEpoch) return;
      if (!mounted) return;

      setState(() {
        _pages = pages;
        _pagesCount = pages.length.clamp(1, 1 << 30);
        _page = 1;
      });

      // UX: 첫/다음 페이지를 미리 렌더 캐시
      await _ensurePngForPage(1);
      if (epoch != _paginateEpoch) return;
      if (_pagesCount >= 2) {
        // ignore: unawaited_futures
        _ensurePngForPage(2);
      }
    } finally {
      if (mounted && epoch == _paginateEpoch) {
        _paginating = false;
      }
      _decLoading();
    }
  }

  // ---------------------------
  // 이미지 로딩(로컬/네트워크)
  // ---------------------------
  Future<ui.Image?> _loadImage(String src) async {
    final cached = _imageCache[src];
    if (cached != null) return cached;

    try {
      Uint8List bytes;

      if (src.startsWith('http://') || src.startsWith('https://')) {
        // 네트워크는 여기서 직접 요청하지 않습니다.
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

  // ---------------------------
  // 페이지 렌더 -> PNG bytes
  // ---------------------------
  Future<Uint8List> _ensurePngForPage(int pageNumber) async {
    final cached = _pngCache[pageNumber];
    if (cached != null) return cached;
    if (_pages.isEmpty) return Uint8List(0);

    final idx = (pageNumber - 1).clamp(0, _pages.length - 1);
    final plan = _pages[idx];

    final int outW = (_pageWidthPx * widget.renderScale).round();
    final int outH = (_pageHeightPx * widget.renderScale).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 배경
    final bgPaint = Paint()..color = widget.pageBackgroundColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
      bgPaint,
    );

    // 캔버스 스케일 다운(아래는 논리 px 기준)
    canvas.scale(widget.renderScale, widget.renderScale);

    final origin = Offset(widget.horizontalMargin, widget.verticalMargin);

    // 각 드로우 커맨드 실행
    for (final cmd in plan.commands) {
      await cmd.paint(
        canvas: canvas,
        origin: origin,
        loadImage: _loadImage,
        maxImageHeight:
            (_pageHeightPx - widget.verticalMargin * 2) *
            widget.maxImageHeightRatio,
      );
    }

    final picture = recorder.endRecording();
    if (outW <= 0 || outH <= 0) {
      picture.dispose();
      return Uint8List(0);
    }

    final img = await picture.toImage(outW, outH);

    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();

    final bytes = bd?.buffer.asUint8List() ?? Uint8List(0);
    _pngCache[pageNumber] = bytes;
    return bytes;
  }

  Uint8List _pngToJpg(Uint8List pngBytes, {int quality = 92}) {
    final decoded = img.decodeImage(pngBytes);
    if (decoded == null) return Uint8List(0);
    return Uint8List.fromList(img.encodeJpg(decoded, quality: quality));
  }

  Future<Uint8List> _buildPdfFromPages(List<int> pages) async {
    final doc = pw.Document();

    for (final pg in pages) {
      final pngBytes = await _ensurePngForPage(pg);
      if (pngBytes.isEmpty) continue;

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build:
              (_) => pw.Center(
                child: pw.Image(
                  pw.MemoryImage(pngBytes),
                  fit: pw.BoxFit.contain,
                ),
              ),
        ),
      );
    }

    return doc.save();
  }

  // ---------------------------
  // 저장/공유
  // ---------------------------
  String _safeFileName(String name) {
    final trimmed = name.trim().isEmpty ? 'document' : name.trim();
    final sanitized = trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return sanitized.length > 80 ? sanitized.substring(0, 80) : sanitized;
  }

  Future<File> _writeBytesToTemp({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _onDownloadTap() async {
    if (_isLoading) return;
    if (_pages.isEmpty) return;

    _incLoading();
    try {
      final base = _safeFileName(widget.title);

      final docs = await getApplicationDocumentsDirectory();
      final folder = Directory(p.join(docs.path, '${base}_png'));
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      for (int i = 1; i <= _pagesCount; i++) {
        final bytes = await _ensurePngForPage(i);
        final name = '${base}_${i.toString().padLeft(3, '0')}.png';
        final file = File(p.join(folder.path, name));
        await file.writeAsBytes(bytes, flush: true);
      }

      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
    } finally {
      _decLoading();
    }
  }

  Future<void> _onShareTap() async {
    if (_isLoading) return;
    if (_pages.isEmpty) return;

    // ✅ async gap 전에 sharePositionOrigin을 확보해서 경고 제거
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin =
        box == null ? null : (box.localToGlobal(Offset.zero) & box.size);

    final pick = await showShareOptionsDialog(
      context: context,
      currentPage: _page,
      pagesCount: _pagesCount,
      dialogTitle: '공유',
      confirmLabel: '공유',
    );
    if (pick == null) return;
    if (!mounted) return;

    List<int> pages = [];
    for (int i = pick.startPage; i <= pick.endPage; i++) {
      pages.add(i);
    }

    _incLoading();
    try {
      final base = _safeFileName(widget.title);

      // PDF
      if (pick.format == ShareFormat.pdf) {
        final pdfBytes = await _buildPdfFromPages(pages);
        final file = await _writeBytesToTemp(
          bytes: pdfBytes,
          fileName: '$base.pdf',
        );

        if (!mounted) return;
        await Share.shareXFiles(
          [
            XFile(
              file.path,
              mimeType: 'application/pdf',
              name: p.basename(file.path),
            ),
          ],
          text: widget.title,
          sharePositionOrigin: shareOrigin,
        );
        return;
      }

      // PNG / JPG (여러 장이면 여러 파일로 공유)
      final files = <XFile>[];
      for (final pg in pages) {
        final pngBytes = await _ensurePngForPage(pg);
        if (pngBytes.isEmpty) continue;

        if (pick.format == ShareFormat.png) {
          final name = '${base}_${pg.toString().padLeft(3, '0')}.png';
          final f = await _writeBytesToTemp(bytes: pngBytes, fileName: name);
          files.add(
            XFile(f.path, mimeType: 'image/png', name: p.basename(f.path)),
          );
        } else {
          final jpgBytes = _pngToJpg(pngBytes);
          if (jpgBytes.isEmpty) continue;

          final name = '${base}_${pg.toString().padLeft(3, '0')}.jpg';
          final f = await _writeBytesToTemp(bytes: jpgBytes, fileName: name);
          files.add(
            XFile(f.path, mimeType: 'image/jpeg', name: p.basename(f.path)),
          );
        }
      }

      if (!mounted) return;
      if (files.isEmpty) return;

      await Share.shareXFiles(
        files,
        text: widget.title,
        sharePositionOrigin: shareOrigin,
      );
    } catch (_) {
      // 필요하면 AppToast
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
          135,
          144,
          193,
          226,
        ).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxCardWidth = constraints.maxWidth * 0.95;

        _pageWidthPx = maxCardWidth;
        _pageHeightPx = maxCardWidth * 297 / 210; // A4 ratio

        // 폭 변화 감지
        final prevW = _lastLayoutWidth;
        _lastLayoutWidth = maxCardWidth;
        final widthChanged =
            prevW != null && (maxCardWidth - prevW).abs() > 0.5;
        if (widthChanged) {
          _resetPaginationAndCaches(notify: false);
          _schedulePaginate(delay: const Duration(milliseconds: 50));
        }

        if (!_paginateScheduled) {
          _paginateScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _paginateScheduled = false;
            if (!mounted) return;
            _schedulePaginate(delay: Duration.zero);
          });
        }

        final maxCardHeight = constraints.maxHeight * 0.90;
        final desiredH = _pageHeightPx;
        final cardHeight = desiredH > maxCardHeight ? maxCardHeight : desiredH;

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
                  final next = index + 2;
                  if (next <= _pagesCount) {
                    // ignore: unawaited_futures
                    _ensurePngForPage(next);
                  }
                },
                itemBuilder: (context, index) {
                  final pageNumber = index + 1;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: _cardTopPadding),
                      child: FutureBuilder<Uint8List>(
                        future: _ensurePngForPage(pageNumber),
                        builder: (context, snap) {
                          if (!snap.hasData || snap.data!.isEmpty) {
                            return SizedBox(
                              width: maxCardWidth,
                              height: cardHeight,
                            );
                          }

                          final bytes = snap.data!;
                          return ClipRect(
                            child: InteractiveViewer(
                              transformationController: _zoomCtrl,
                              panEnabled: true,
                              scaleEnabled: true,
                              minScale: _minUiScale,
                              maxScale: _maxUiScale,
                              onInteractionUpdate: (details) {
                                // ✅ 핀치로 바뀐 현재 스케일을 UI 상태에 반영(버튼 줌과 표시 동기화용)
                                _uiScale = _zoomCtrl.value
                                    .getMaxScaleOnAxis()
                                    .clamp(_minUiScale, _maxUiScale);
                              },
                              onInteractionEnd: (_) {
                                // ✅ 끝났을 때 한 번 더 정리(필요시)
                                _uiScale = _zoomCtrl.value
                                    .getMaxScaleOnAxis()
                                    .clamp(_minUiScale, _maxUiScale);
                              },
                              child: SizedBox(
                                width: maxCardWidth,
                                height: cardHeight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: widget.pageBackgroundColor,
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
                                  child: Image.memory(
                                    bytes,
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
              ),

              // 왼쪽 상단(목차 자리) — PNG는 목차 없이 비워둠
              Positioned(
                left: 10,
                top: _cardTopPadding - 55,
                child: IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.format_list_numbered,
                    color: const ui.Color.fromARGB(
                      255,
                      129,
                      152,
                      177,
                    ).withValues(alpha: 0.35),
                    size: 25,
                  ),
                ),
              ),

              // 오른쪽 상단: 다운로드 + 공유
              Positioned(
                right: 10,
                top: _cardTopPadding - 55,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed:
                          (_isLoading || _pages.isEmpty)
                              ? null
                              : _onDownloadTap,
                      icon: const Icon(
                        Icons.download_outlined,
                        color: _topIconColor,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 2),
                    IconButton(
                      onPressed:
                          (_isLoading || _pages.isEmpty) ? null : _onShareTap,
                      icon: const Icon(
                        Icons.ios_share,
                        color: _topIconColor,
                        size: 23,
                      ),
                    ),
                  ],
                ),
              ),

              // 하단 컨트롤 바
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
      },
    );
  }
}

class _DeltaParser {
  List<_Block> parse(List<Map<String, dynamic>> deltaJson) {
    final lines = <_Line>[];
    final currentRuns = <_Run>[];

    void flushLine(Map<String, dynamic>? newlineAttrs) {
      final block = _BlockStyle.fromDeltaAttrs(newlineAttrs ?? const {});
      lines.add(_Line(runs: List<_Run>.from(currentRuns), style: block));
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

          // ✅ 빈 줄도 라인으로 남겨야 하므로, text.isNotEmpty일 때만 run 추가
          if (text.isNotEmpty) {
            currentRuns.add(
              _Run(text: text, inline: _InlineStyle.fromDeltaAttrs(attrs)),
            );
          }

          // ✅ \n 만날 때마다 라인 flush (여기서 align/list/header/indent 등 라인 스타일 확정)
          if (i != parts.length - 1) {
            flushLine(attrs);
          }
        }
      } else if (insert is Map) {
        if (insert.containsKey('image')) {
          final src = insert['image'];
          if (src is String && src.isNotEmpty) {
            if (currentRuns.isNotEmpty) flushLine(const {});
            lines.add(_Line.image(src));
          }
        } else if (insert.containsKey('hr_solid')) {
          if (currentRuns.isNotEmpty) flushLine(const {});
          lines.add(_Line.hr(solid: true));
        } else if (insert.containsKey('hr')) {
          if (currentRuns.isNotEmpty) flushLine(const {});
          lines.add(_Line.hr(solid: false));
        }
      }
    }

    // 마지막에 남아있는 run flush
    if (currentRuns.isNotEmpty) {
      flushLine(const {});
    }

    // -------------------------------
    // lines -> blocks
    // -------------------------------
    final blocks = <_Block>[];
    _ParagraphBlock? current;

    for (final l in lines) {
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

      final isListLine = l.style.listType != _ListType.none;

      if (isListLine) {
        final key = l.style.groupKeyWithoutAlign();

        // ✅ 같은 리스트(ul/ol) + 같은 indent/header/blockquote/code는 한 블록으로 합치기
        // (align은 제외되므로, 같은 아이템 내부에서 줄마다 align이 달라도 하나로 유지)
        if (current == null ||
            current.style.listType == _ListType.none ||
            current.style.groupKeyWithoutAlign() != key) {
          current = _ParagraphBlock(style: l.style);
          blocks.add(current);
        }

        current.addLine(l);
      } else {
        // ✅ 일반 문단은 기존대로 "스타일 완전 동일"일 때만 합치기
        if (current == null || current.style != l.style) {
          current = _ParagraphBlock(style: l.style);
          blocks.add(current);
        }

        current.addLine(l);
      }
    }

    if (blocks.isEmpty) {
      blocks.add(_ParagraphBlock(style: const _BlockStyle()));
    }

    return blocks;
  }
}

enum _LineKind { text, image, hr }

class _LineSlice {
  final List<_Run> runs;
  final TextAlign align;
  const _LineSlice({required this.runs, required this.align});
}

class _Line {
  final _LineKind kind;
  final List<_Run> runs;
  final _BlockStyle style;

  final String? imageSource;
  final bool? hrSolid;

  _Line({required this.runs, required this.style})
    : kind = _LineKind.text,
      imageSource = null,
      hrSolid = null;

  _Line.image(this.imageSource)
    : kind = _LineKind.image,
      runs = const [],
      style = const _BlockStyle(),
      hrSolid = null;

  _Line.hr({required bool solid})
    : kind = _LineKind.hr,
      runs = const [],
      style = const _BlockStyle(),
      imageSource = null,
      hrSolid = solid;
}

class _Run {
  final String text;
  final _InlineStyle inline;
  const _Run({required this.text, required this.inline});
}

@immutable
class _InlineStyle {
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strike;
  final Color? color;
  final Color? background;
  final double? sizePt;

  const _InlineStyle({
    required this.bold,
    required this.italic,
    required this.underline,
    required this.strike,
    required this.color,
    required this.background,
    required this.sizePt,
  });

  static _InlineStyle fromDeltaAttrs(Map<String, dynamic> attrs) {
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

    return _InlineStyle(
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
class _BlockStyle {
  final int header; // 0 normal, 1/2/3...
  final TextAlign align; // left/center/right
  final int indent; // quill indent
  final _ListType listType; // ul/ol
  final bool blockQuote;
  final bool codeBlock;

  const _BlockStyle({
    this.header = 0,
    this.align = TextAlign.left,
    this.indent = 0,
    this.listType = _ListType.none,
    this.blockQuote = false,
    this.codeBlock = false,
  });

  static _BlockStyle fromDeltaAttrs(Map<String, dynamic> attrs) {
    int header = 0;
    final h = attrs['header'];
    if (h is num) header = h.toInt();
    if (h is String) header = int.tryParse(h) ?? 0;

    TextAlign align = TextAlign.left;
    final a = attrs['align'];

    // ✅ 여기 보강
    if (a == 'center') {
      align = TextAlign.center;
    } else if (a == 'right' || a == 'end') {
      align = TextAlign.right;
    } // ✅ end 대응
    else if (a == 'justify') {
      align = TextAlign.justify;
    } else if (a == 'left' || a == 'start') {
      align = TextAlign.left;
    }

    int indent = 0;
    final ind = attrs['indent'];
    if (ind is num) indent = ind.toInt();
    if (ind is String) indent = int.tryParse(ind) ?? 0;

    _ListType list = _ListType.none;
    final l = attrs['list'];
    if (l == 'bullet') list = _ListType.bullet;
    if (l == 'ordered') list = _ListType.ordered;

    final bq = attrs['blockquote'] == true;
    final code = attrs['code-block'] == true;

    return _BlockStyle(
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
      other is _BlockStyle &&
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

extension _BlockStyleGroupKey on _BlockStyle {
  // ✅ align 제외: 같은 리스트 아이템 덩어리로 묶기 위한 키
  Object groupKeyWithoutAlign() =>
      Object.hash(header, indent, listType, blockQuote, codeBlock);
}

enum _ListType { none, bullet, ordered }

/// =======================================================
/// Blocks
/// =======================================================

sealed class _Block {}

class _ParagraphBlock extends _Block {
  final _BlockStyle style;
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

/// =======================================================
/// Layout Engine -> Page plans (draw commands)
/// =======================================================

class _CanvasLayoutEngine {
  _CanvasLayoutEngine({
    required this.baseStyle,
    required this.contentWidth,
    required this.contentHeight,
    required this.imageSizes,
    required this.maxImageHeight,
  });

  final TextStyle baseStyle;
  final double contentWidth;
  final double contentHeight;
  final Map<String, Size> imageSizes;
  final double maxImageHeight;

  List<_LineSlice> _buildSlicesFromBlock(_ParagraphBlock b) {
    // 각 _Line은 이미 style.align을 가지고 있으므로 그걸 그대로 사용
    final out = <_LineSlice>[];

    for (final line in b.lines) {
      // 빈 줄도 "한 줄"로 유지해야 마지막 줄 정렬만 바꾸는 케이스가 정확히 재현됨
      out.add(_LineSlice(runs: line.runs, align: line.style.align));
    }
    return out;
  }

  TextPainter _buildTextPainterForRuns(
    List<_Run> runs,
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

  double _measureSliceHeight(_LineSlice s, TextStyle baseStyle, double innerW) {
    final tp = _buildTextPainterForRuns(s.runs, baseStyle, s.align);
    tp.layout(maxWidth: innerW);

    // ✅ 완전 빈 줄도 높이를 0으로 만들면 “중간 빈 줄”이 사라져서 레이아웃이 달라짐
    // 최소 높이를 한 줄(lineHeight 반영)로 잡아줌
    if (tp.height <= 0.1) {
      final fs = baseStyle.fontSize ?? 15.0;
      final lh = (baseStyle.height ?? 1.0);
      return (fs * lh);
    }
    return tp.height;
  }

  bool _isEmptyParagraphBlock(_ParagraphBlock b) {
    // 텍스트/개행을 합쳐서 공백 제거 후 남는 게 없으면 “빈 줄”
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

  Future<List<_PagePlan>> paginate(List<_Block> blocks) async {
    final pages = <_PagePlan>[];
    var current = _PagePlan(commands: []);
    double y = 0;

    // ✅ ordered list 상태 (페이지 넘어가도 유지)
    int orderedCounter = 0;
    bool inOrderedList = false;

    void newPage() {
      pages.add(current);
      current = _PagePlan(commands: []);
      y = 0;
      // ❗️페이지가 바뀌어도 ordered list는 "끊기지 않음"
    }

    for (final b in blocks) {
      // ---------------- HR ----------------
      if (b is _HrBlock) {
        // HR은 리스트를 끊는 게 자연스러움
        inOrderedList = false;
        orderedCounter = 0;

        const h = 18.0;
        if (y + h > contentHeight && y > 0) newPage();

        current.commands.add(
          _HrDrawCommand(y: y + 8, solid: b.solid, width: contentWidth),
        );
        y += h;
        continue;
      }

      // ---------------- IMAGE ----------------
      if (b is _ImageBlock) {
        // 이미지도 리스트를 끊는 게 자연스러움
        inOrderedList = false;
        orderedCounter = 0;

        double reservedH = math.min(contentHeight * 0.45, 320.0);

        final sz = imageSizes[b.src];
        if (sz != null && sz.width > 0 && sz.height > 0) {
          final scale = contentWidth / sz.width;
          double drawH = sz.height * scale;
          if (drawH > maxImageHeight) drawH = maxImageHeight;
          reservedH = drawH;
        }

        if (y + reservedH > contentHeight && y > 0) newPage();

        current.commands.add(
          _ImageDrawCommand(y: y, src: b.src, width: contentWidth),
        );

        y += reservedH + 14;
        continue;
      }

      if (b is _ParagraphBlock) {
        // ✅ ordered list 카운트 계산 (블록=한 아이템 덩어리 기준)
        String? markerText;

        if (b.style.listType == _ListType.ordered) {
          final isEmpty = _isEmptyParagraphBlock(b);

          if (!inOrderedList) {
            inOrderedList = true;
            orderedCounter = 0;
          }

          if (!isEmpty) {
            orderedCounter += 1;
            markerText = '$orderedCounter.';
          } else {
            markerText = null;
          }
        } else if (b.style.listType == _ListType.bullet) {
          inOrderedList = false;
          orderedCounter = 0;

          final isEmpty = _isEmptyParagraphBlock(b);
          markerText = isEmpty ? null : '•';
        } else {
          inOrderedList = false;
          orderedCounter = 0;
        }

        final pad = _BlockPadding.of(b.style);
        final innerW = math.max(0.0, contentWidth - pad.left - pad.right);
        final paraStyle = _BlockTextStyle.of(baseStyle, b.style);

        // ✅ 라인(정렬 포함) 기반 slices
        final slices = _buildSlicesFromBlock(b).toList(growable: true);

        int cursor = 0;
        bool isContinuation = false;

        while (cursor < slices.length) {
          final decoTop = pad.topDecoration;
          final decoBottom = pad.bottomDecoration;

          final available = contentHeight - y - decoTop - decoBottom - 0.5;

          if (available <= 8 && y > 0) {
            newPage();
            continue;
          }

          // ✅ 이 페이지에 들어갈 slice들을 최대한 담기
          final pageSlices = <_LineSlice>[];
          double usedH = 0;

          while (cursor < slices.length) {
            final s = slices[cursor];
            final h = _measureSliceHeight(s, paraStyle, innerW);

            // 다음 줄이 안 들어가면 stop
            if (pageSlices.isNotEmpty && usedH + h > available) break;

            // 첫 줄도 못 들어가면(아주 큰 글자/한 줄 랩이 과한 경우) -> 아래에서 run split 처리
            if (pageSlices.isEmpty && h > available && y > 0) break;

            pageSlices.add(s);
            usedH += h;
            cursor++;
          }

          // ✅ 아무 것도 못 담았고, 페이지 시작이 아니면 새 페이지
          if (pageSlices.isEmpty && y > 0) {
            newPage();
            continue;
          }

          // ✅ 한 페이지 시작(y==0)인데도 첫 slice가 너무 커서 못 담는 경우: 그 slice 내부를 run split
          if (pageSlices.isEmpty && cursor < slices.length) {
            final s = slices[cursor];

            final tp = _buildTextPainterForRuns(s.runs, paraStyle, s.align);
            tp.layout(maxWidth: innerW);

            final canUse = (contentHeight - decoTop - decoBottom - 0.5);
            int cut = _cutOffsetByLineMetrics(tp, canUse, innerW);
            if (cut <= 0) cut = 1;

            final split = _RunSplitter.split(s.runs, cut);
            final headRuns = split.$1;
            final tailRuns = split.$2;

            current.commands.add(
              _ParagraphDrawCommand(
                y: y,
                lines: [_LineSlice(runs: headRuns, align: s.align)],
                baseStyle: paraStyle,
                blockStyle: b.style,
                width: innerW,
                padding: pad,
                markerText: isContinuation ? null : markerText,
                isListContinuation: isContinuation,
              ),
            );

            // 다음 페이지로
            newPage();

            // tailRuns가 남으면 같은 align로 이어서 다시 처리
            if (tailRuns.isNotEmpty) {
              // cursor는 그대로(현재 slice 계속), slices[cursor]를 tail로 교체
              // 간단히: tail을 현재 커서 위치에 덮어쓰기
              // (dart list는 final이지만 내부 요소는 교체 가능)
              // ignore: avoid_function_literals_in_foreach_calls
              slices[cursor] = _LineSlice(runs: tailRuns, align: s.align);
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

          // ✅ 정상 케이스: pageSlices 한 덩어리 출력
          current.commands.add(
            _ParagraphDrawCommand(
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

          // 다음 페이지로 넘어갔으면 continuation
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

    return pages.isEmpty ? [_PagePlan(commands: [])] : pages;
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

    // ✅ 마지막 줄의 descent 만큼 위로 올려서 "안전한 y"에서 컷
    // lm.descent가 0일 수도 있어 fallback
    final descent = (lm.descent.isFinite && lm.descent > 0) ? lm.descent : 2.0;

    // used = 마지막 줄까지 누적 높이(= 그 줄의 bottom 근처)
    // 여기서 descent+epsilon 만큼 위로 당겨 텍스트 꼬리 잘림 방지
    final safeY = (used - descent - 1.0).clamp(0.0, available);

    final safeX = math.max(0.0, maxWidth - 4);

    final pos = tp.getPositionForOffset(Offset(safeX, safeY));
    return pos.offset;
  }
}

class _PagePlan {
  final List<_DrawCommand> commands;
  _PagePlan({required this.commands});
}

sealed class _DrawCommand {
  Future<void> paint({
    required Canvas canvas,
    required Offset origin,
    required Future<ui.Image?> Function(String src) loadImage,
    required double maxImageHeight,
  });
}

class _ParagraphDrawCommand extends _DrawCommand {
  _ParagraphDrawCommand({
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
  final List<_LineSlice> lines;
  final TextStyle baseStyle;
  final _BlockStyle blockStyle;
  final double width;
  final _BlockPadding padding;
  final String? markerText;
  final bool isListContinuation;

  double _firstVisibleFontSize(List<_LineSlice> lines, TextStyle baseStyle) {
    for (final line in lines) {
      for (final r in line.runs) {
        final s = r.text;
        final trimmed = s.replaceAll('\n', '').trim();
        if (trimmed.isEmpty) continue;

        final applied = r.inline.applyTo(baseStyle);
        final fs = applied.fontSize;
        if (fs != null && fs.isFinite && fs > 0) return fs;
      }
    }
    return (baseStyle.fontSize ?? 15.0);
  }

  double _markerFontSizeForBlock({
    required double textFontSize,
    required _BlockStyle blockStyle,
  }) {
    double scale = 0.95;

    // 헤더는 텍스트가 커서 마커가 과하게 커지지 않게 살짝 줄임
    if (blockStyle.header >= 1) scale = 0.80;

    // 코드블록은 너무 작아지지 않게
    if (blockStyle.codeBlock) scale = 0.92;

    return (textFontSize * scale).clamp(10.0, 42.0);
  }

  @override
  Future<void> paint({
    required Canvas canvas,
    required Offset origin,
    required Future<ui.Image?> Function(String src) loadImage,
    required double maxImageHeight,
  }) async {
    final isList = blockStyle.listType != _ListType.none;

    final y0 = origin.dy + y + padding.topDecoration;
    final contentW = width + padding.left + padding.right;

    // ✅ 전체 높이 계산 (데코 rect용)
    double totalH = 0;
    final tps = <TextPainter>[];
    final heights = <double>[];
    final hasVisibleLine = <bool>[];

    for (final line in lines) {
      final tp = TextPainter(
        text: TextSpan(
          children: [
            for (final r in line.runs)
              TextSpan(
                text: _sanitizeUtf16(r.text),
                style: r.inline.applyTo(baseStyle),
              ),
          ],
        ),
        textAlign: line.align,
        textDirection: TextDirection.ltr,
        textWidthBasis: TextWidthBasis.parent,
      )..layout(maxWidth: width);

      double h = tp.height;
      final visible = line.runs.any(
        (r) => r.text.replaceAll('\n', '').trim().isNotEmpty,
      );

      // ✅ 빈 줄 높이 보정(빈 줄이 사라지면 에디터랑 달라짐)
      if (h <= 0.1) {
        final fs = baseStyle.fontSize ?? 15.0;
        final lh = (baseStyle.height ?? 1.0);
        h = (fs * lh);
      }

      tps.add(tp);
      heights.add(h);
      hasVisibleLine.add(visible);
      totalH += h;
    }

    final paraRect = Rect.fromLTWH(
      origin.dx,
      origin.dy + y,
      contentW,
      padding.topDecoration + totalH + padding.bottomDecoration,
    );
    padding.paintDecoration(canvas, paraRect);

    // ✅ 마커는 “첫 번째로 내용이 있는 줄” 기준(없으면 마커 없음)
    if (isList && !isListContinuation) {
      final marker =
          (blockStyle.listType == _ListType.bullet) ? '•' : (markerText ?? '');

      if (marker.isNotEmpty) {
        final markerX = origin.dx + padding.listMarkerX;

        final baseFs = _firstVisibleFontSize(lines, baseStyle);
        final markerFs = _markerFontSizeForBlock(
          textFontSize: baseFs,
          blockStyle: blockStyle,
        );

        // 첫 유효 줄의 y 위치 계산
        double lineTop = y0;
        int firstVisibleIdx = -1;
        for (int i = 0; i < lines.length; i++) {
          if (hasVisibleLine[i]) {
            firstVisibleIdx = i;
            break;
          }
          lineTop += heights[i];
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

    // ✅ 텍스트는 줄마다 align에 맞춰 x를 계산해서 paint
    double dy = y0;
    final xBase = origin.dx + padding.left;

    for (int i = 0; i < tps.length; i++) {
      final tp = tps[i];
      final align = lines[i].align;

      double x = xBase;

      if (align == TextAlign.center) {
        x = xBase + (width - tp.width) / 2;
      } else if (align == TextAlign.right || align == TextAlign.end) {
        x = xBase + (width - tp.width);
      } else {
        // left/start/justify는 xBase
        x = xBase;
      }

      if (!x.isFinite) x = xBase;
      tp.paint(canvas, Offset(x, dy));
      dy += heights[i];
    }
  }
}

class _HrDrawCommand extends _DrawCommand {
  _HrDrawCommand({required this.y, required this.solid, required this.width});
  final double y;
  final bool solid;
  final double width;

  @override
  Future<void> paint({
    required Canvas canvas,
    required Offset origin,
    required Future<ui.Image?> Function(String src) loadImage,
    required double maxImageHeight,
  }) async {
    final paint =
        Paint()
          ..color = const Color.fromARGB(255, 129, 147, 182)
          ..strokeWidth = solid ? 1.0 : 0.6
          ..style = PaintingStyle.stroke;

    final start = Offset(origin.dx, origin.dy + y);
    final end = Offset(origin.dx + width, origin.dy + y);

    if (solid) {
      canvas.drawLine(start, end, paint);
    } else {
      const dashW = 5.0;
      const dashS = 5.0;
      double x = start.dx;
      while (x < end.dx) {
        final x2 = math.min(x + dashW, end.dx);
        canvas.drawLine(Offset(x, start.dy), Offset(x2, start.dy), paint);
        x += dashW + dashS;
      }
    }
  }
}

class _ImageDrawCommand extends _DrawCommand {
  _ImageDrawCommand({required this.y, required this.src, required this.width});
  final double y;
  final String src;
  final double width;

  @override
  Future<void> paint({
    required Canvas canvas,
    required Offset origin,
    required Future<ui.Image?> Function(String src) loadImage,
    required double maxImageHeight,
  }) async {
    final img = await loadImage(src);
    if (img == null) {
      final r = Rect.fromLTWH(origin.dx, origin.dy + y, width, 140);
      final border =
          Paint()
            ..color = const Color(0xFFBDBDBD)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
      canvas.drawRect(r, border);

      final tp = TextPainter(
        text: const TextSpan(
          text: '이미지를 불러올 수 없습니다',
          style: TextStyle(fontSize: 13, color: Color(0xFF777777)),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width - 20);

      tp.paint(canvas, Offset(r.left + 10, r.top + 10));
      return;
    }

    final iw = img.width.toDouble();
    final ih = img.height.toDouble();

    // 폭은 content width에 맞추고, 높이는 비율 유지
    final scale = width / iw;
    double drawH = ih * scale;
    double drawW = width;

    // 너무 크면 최대 높이로 축소
    if (drawH > maxImageHeight) {
      final s2 = maxImageHeight / drawH;
      drawH = maxImageHeight;
      drawW = drawW * s2;
    }

    final dx = origin.dx + (width - drawW) / 2;
    final dy = origin.dy + y;

    final dst = Rect.fromLTWH(dx, dy, drawW, drawH);
    final srcRect = Rect.fromLTWH(0, 0, iw, ih);

    final paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImageRect(img, srcRect, dst, paint);
  }
}

/// =======================================================
/// Helpers: block padding / style / run splitting
/// =======================================================

class _BlockPadding {
  final double left;
  final double right;
  final double topDecoration;
  final double bottomDecoration;

  final bool quote;
  final bool code;
  final _ListType list;
  final int indent;

  const _BlockPadding({
    required this.left,
    required this.right,
    required this.topDecoration,
    required this.bottomDecoration,
    required this.quote,
    required this.code,
    required this.list,
    required this.indent,
  });

  static _BlockPadding of(_BlockStyle s) {
    final baseIndent = 14.0 * s.indent;

    // ✅ chapter_write_page.dart 느낌의 header 들여쓰기
    double headerLeftIndent = 0;
    if (s.header == 2) headerLeftIndent = 6;
    if (s.header == 3) headerLeftIndent = 10;

    double left = baseIndent + headerLeftIndent;
    double right = 0;

    if (s.listType != _ListType.none) left += 22;

    final quote = s.blockQuote;
    final code = s.codeBlock;

    // ✅ header 위/아래 여백을 "decoration padding"으로 처리
    double headerTop = 0, headerBottom = 0;
    if (s.header == 1) {
      headerTop = 30;
      headerBottom = 14;
    }
    if (s.header == 2) {
      headerTop = 18;
      headerBottom = 10;
    }
    if (s.header == 3) {
      headerTop = 12;
      headerBottom = 8;
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

    return _BlockPadding(
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

  // paragraphRect 전체 높이 기반으로 데코를 그림
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
  static TextStyle of(TextStyle base, _BlockStyle s) {
    double size = base.fontSize ?? 15;
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
      height: base.height,
    );
  }
}

class _BlockSpacing {
  static double of(_BlockStyle s) {
    if (s.header > 0) return 0; // ✅ 헤더 여백은 padding에서 처리
    if (s.blockQuote || s.codeBlock) return 8;
    return 6;
  }
}

class _RunSplitter {
  /// runs를 "문자 offset" 기준으로 앞/뒤로 쪼갬 (TextPainter offset 기준)
  static (List<_Run>, List<_Run>) split(List<_Run> runs, int cutOffset) {
    if (cutOffset <= 0) return (<_Run>[], List<_Run>.from(runs));

    int remaining = cutOffset;
    final left = <_Run>[];
    final right = <_Run>[];

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
        if (a.isNotEmpty) left.add(_Run(text: a, inline: r.inline));
        if (b.isNotEmpty) right.add(_Run(text: b, inline: r.inline));
        remaining = 0;
      }
    }

    return (left, right);
  }
}
