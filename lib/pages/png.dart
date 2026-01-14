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

import 'package:ebook_tutorial_app/widgets/common/app_toast.dart';
import 'dart:collection';
import 'dart:isolate';

const String kBgAlphaKey = 'bgAlpha';

List<Map<String, dynamic>> stripThemeBaseColorFromDelta(
  List<Map<String, dynamic>> delta, {
  String themeBaseColorHex = '#ffffff',
  bool stripBackgroundToo = false,
}) {
  final target = themeBaseColorHex.trim().toLowerCase();

  bool isTarget(dynamic v) {
    if (v is! String) return false;
    return v.trim().toLowerCase() == target;
  }

  return delta
      .map((op) {
        final m = Map<String, dynamic>.from(op);

        final attrsRaw = m['attributes'];
        if (attrsRaw is Map) {
          final attrs = Map<String, dynamic>.from(attrsRaw);

          var changed = false;

          if (isTarget(attrs['color'])) {
            attrs.remove('color');
            changed = true;
          }

          if (stripBackgroundToo && isTarget(attrs['background'])) {
            attrs.remove('background');
            changed = true;
          }

          if (changed) {
            if (attrs.isEmpty) {
              m.remove('attributes');
            } else {
              m['attributes'] = attrs;
            }
          }
        }

        return m;
      })
      .toList(growable: true);
}

ThemeData fixedLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    scaffoldBackgroundColor: Colors.white,

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1F3A56),
      surface: Colors.white,
      onSurface: Color(0xFF111111),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF111111),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF1F3A56),
        overlayColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
    ),

    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Color(0xFFE9F7FF)),
        foregroundColor: WidgetStatePropertyAll(Color(0xFF1F3A56)),
        elevation: WidgetStatePropertyAll(0.0),
        shadowColor: WidgetStatePropertyAll(Colors.transparent),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
      ),
    ),
  );
}

extension Matrix4ScaleCompat on Matrix4 {
  Matrix4 scaleByDouble(double x, double y, double z) {
    final s =
        Matrix4.identity()
          ..setEntry(0, 0, x)
          ..setEntry(1, 1, y)
          ..setEntry(2, 2, z);
    multiply(s);
    return this;
  }
}

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
  ShareRangeMode rangeMode = ShareRangeMode.all;

  int start = 1;
  int end = pagesCount;

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
      return Theme(
        data: fixedLightTheme(),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            void confirm() {
              if (rangeMode == ShareRangeMode.range) {
                final ok = applyFields(commitNormalize: true);
                if (!ok) {
                  setModalState(() {});
                  return;
                }
              } else {
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

            Widget minimalField(
              TextEditingController ctrl,
              FocusNode focus, {
              double width = 56,
            }) {
              final border =
                  rangeInvalid
                      ? const ui.Color.fromARGB(255, 239, 111, 109)
                      : const Color(0xFFD6E3F0);

              return Container(
                width: width,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
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
                      () => setModalState(
                        () => applyFields(commitNormalize: true),
                      ),
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

                        if (!showRange)
                          const SizedBox(height: 7)
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                  '1~$pagesCount',
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
        ),
      );
    },
  );

  startCtrl.dispose();
  endCtrl.dispose();
  startFocus.dispose();
  endFocus.dispose();

  return result;
}

class LruCache<K, V extends Object> {
  LruCache({required this.maxEntries}) : assert(maxEntries > 0);

  int maxEntries;
  final LinkedHashMap<K, V> _map = LinkedHashMap<K, V>();

  V? get(K key) {
    final v = _map.remove(key);
    if (v == null) return null;
    _map[key] = v;
    return v;
  }

  bool containsKey(K key) => _map.containsKey(key);

  void put(K key, V value, {void Function(K key, V value)? onEvict}) {
    _map.remove(key);
    _map[key] = value;

    while (_map.length > maxEntries) {
      final oldestKey = _map.keys.first;
      final oldestVal = _map.remove(oldestKey);
      if (oldestVal != null) {
        onEvict?.call(oldestKey, oldestVal);
      }
    }
  }

  void remove(K key) => _map.remove(key);

  void clear({void Function(K key, V value)? onEvict}) {
    if (onEvict != null) {
      for (final e in _map.entries) {
        onEvict(e.key, e.value);
      }
    }
    _map.clear();
  }

  int get length => _map.length;
  Iterable<K> get keys => _map.keys;
}

class ByteLruCache<K, V extends Object> {
  ByteLruCache({required this.maxBytes}) : assert(maxBytes > 0);

  int maxBytes;

  final LinkedHashMap<K, _ByteEntry<V>> _map =
      LinkedHashMap<K, _ByteEntry<V>>();
  int _totalBytes = 0;

  int get totalBytes => _totalBytes;

  V? get(K key) {
    final entry = _map.remove(key);
    if (entry == null) return null;
    _map[key] = entry;
    return entry.value;
  }

  bool containsKey(K key) => _map.containsKey(key);

  void put(
    K key,
    V value, {
    required int bytesWeight,
    void Function(K key, V value, int bytesWeight)? onEvict,
  }) {
    if (bytesWeight <= 0) return;

    final prev = _map.remove(key);
    if (prev != null) {
      _totalBytes -= prev.bytesWeight;
      if (_totalBytes < 0) _totalBytes = 0;
    }

    if (bytesWeight > maxBytes) {
      return;
    }

    _map[key] = _ByteEntry(value: value, bytesWeight: bytesWeight);
    _totalBytes += bytesWeight;

    while (_totalBytes > maxBytes && _map.isNotEmpty) {
      final oldestKey = _map.keys.first;
      final oldest = _map.remove(oldestKey);
      if (oldest != null) {
        _totalBytes -= oldest.bytesWeight;
        if (_totalBytes < 0) _totalBytes = 0;
        onEvict?.call(oldestKey, oldest.value, oldest.bytesWeight);
      }
    }
  }

  void remove(
    K key, {
    void Function(K key, V value, int bytesWeight)? onEvict,
  }) {
    final e = _map.remove(key);
    if (e == null) return;
    _totalBytes -= e.bytesWeight;
    if (_totalBytes < 0) _totalBytes = 0;
    onEvict?.call(key, e.value, e.bytesWeight);
  }

  void clear({void Function(K key, V value, int bytesWeight)? onEvict}) {
    if (onEvict != null) {
      for (final e in _map.entries) {
        onEvict(e.key, e.value.value, e.value.bytesWeight);
      }
    }
    _map.clear();
    _totalBytes = 0;
  }

  int get length => _map.length;
  Iterable<K> get keys => _map.keys;
}

class _ByteEntry<V> {
  final V value;
  final int bytesWeight;
  const _ByteEntry({required this.value, required this.bytesWeight});
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
    this.horizontalMargin = 17,
    this.verticalMargin = 18,
    this.baseFontSize = 14,
    this.lineHeight = 1.45,
    this.letterSpacing = 0.0,
    this.fontFamily,
    this.pageBackgroundColor = Colors.white,
    this.defaultTextColor = const Color(0xFF111111),

    this.renderScale = 2.8,
    this.maxImageHeightRatio = 0.65,
  });

  final String title;
  final String? episodeTitle;
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
  final Map<int, Future<Uint8List>> _exportInFlight =
      <int, Future<Uint8List>>{};
  int _page = 1;
  int _pagesCount = 1;

  final PageController _pageCtrl = PageController();
  final TransformationController _zoomCtrl = TransformationController();
  final Map<String, Size> _imageSizeCache = <String, Size>{};

  static const double _cardTopPadding = 70;
  static const double _controlBottom = 30;

  double _uiScale = 1.0;
  static const double _minUiScale = 1.0;
  static const double _maxUiScale = 4.0;
  static const double _stepUiScale = 0.15;

  static const double _kA4W = 595.275590551;
  static const double _kA4H = 841.88976378;

  double _effectiveHorizontalMarginPx() {
    if (_pageWidthPx <= 0) return widget.horizontalMargin;
    return widget.horizontalMargin * (_pageWidthPx / _kA4W);
  }

  double _effectiveVerticalMarginPx() {
    if (_pageHeightPx <= 0) return widget.verticalMargin;
    return widget.verticalMargin * (_pageHeightPx / _kA4H);
  }

  int _loadingCount = 0;
  bool get _isLoading => _loadingCount > 0;

  double _pageWidthPx = 0;
  double _pageHeightPx = 0;

  double? _lastLayoutWidth;
  int _styleSig = 0;

  int _deltaSig = 0;
  bool _paginateScheduled = false;

  double _previewRenderScale = 2.0;
  static const double _exportRenderScale = 2.8;

  Timer? _paginateDebounce;
  int _paginateEpoch = 0;
  bool _paginating = false;
  double? _sliderDragValue;
  bool get _isSliderDragging => _sliderDragValue != null;
  int _lastPreviewPage = 1;
  int _sliderValueToPage(double v) {
    final pc = math.max(1, _pagesCount);
    return v.round().clamp(1, pc);
  }

  void _jumpToPage(int page) {
    final pc = math.max(1, _pagesCount);
    final p = page.clamp(1, pc);

    if (!_pageCtrl.hasClients) return;
    _pageCtrl.jumpToPage(p - 1);

    setState(() => _page = p);

    _enqueuePrefetchNear(p, [p - 1, p, p + 1, p + 2]);
  }

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
        'attributes': {'header': 3},
      },
      {'insert': '\n'},
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

  Widget _pageSliderBar({
    required double maxCardWidth,
    required double cardHeight,
  }) {
    final int pageCount = math.max(1, _pagesCount);

    final double currentDouble =
        ((_sliderDragValue ?? _page.toDouble()).clamp(
          1.0,
          pageCount.toDouble(),
        )).toDouble();

    final Color active = Colors.black87.withValues(alpha: 0.72);
    final Color inactive = Colors.black87.withValues(alpha: 0.18);
    final Color thumb = Colors.black87.withValues(alpha: 0.72);

    const double thumbW = 84;
    const double thumbH = 118;
    const double bubbleTopGap = 8;

    final double onePx = 1.0 / MediaQuery.of(context).devicePixelRatio;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        color: widget.pageBackgroundColor.withValues(alpha: 0.0),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 30 + thumbH + bubbleTopGap + 7,
          child: LayoutBuilder(
            builder: (context, row) {
              const double sidePad = 15.0;

              final double usableW = (row.maxWidth - (sidePad * 2)).clamp(
                80.0,
                row.maxWidth,
              );

              final double t =
                  (pageCount <= 1)
                      ? 0.0
                      : ((currentDouble - 1.0) / (pageCount - 1));
              final double thumbX = sidePad + (usableW * t);

              final int previewPage = _sliderValueToPage(currentDouble);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(width: sidePad),
                          SizedBox(
                            width: usableW,
                            child: SliderTheme(
                              data: SliderThemeData(
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
                                  final pg = _sliderValueToPage(v);

                                  setState(() {
                                    _sliderDragValue = v;
                                    _page = pg;
                                  });

                                  _enqueuePrefetchNear(pg, [
                                    pg - 1,
                                    pg,
                                    pg + 1,
                                    pg + 2,
                                  ]);

                                  if (pg != _lastPreviewPage) {
                                    _lastPreviewPage = pg;
                                    if (_pageCtrl.hasClients) {
                                      _pageCtrl.jumpToPage(pg - 1);
                                    }
                                  }
                                },
                                onChangeEnd: (v) {
                                  final pg = _sliderValueToPage(v);
                                  setState(() => _sliderDragValue = null);
                                  _jumpToPage(pg);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: sidePad),
                        ],
                      ),
                    ),
                  ),
                  if (_isSliderDragging && _pages.isNotEmpty)
                    Positioned(
                      left: (thumbX - (thumbW / 2)).clamp(
                        0.0,
                        row.maxWidth - thumbW,
                      ),
                      bottom: 30 + bubbleTopGap + 7,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const ui.Color.fromARGB(
                                255,
                                121,
                                147,
                                164,
                              ).withValues(alpha: 0.4),
                              width: onePx,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: thumbW,
                                  height: thumbH,
                                  child: FutureBuilder<Uint8List>(
                                    future: _ensureThumbForPage(previewPage),
                                    builder: (context, snap) {
                                      final bytes = snap.data;
                                      if (bytes == null || bytes.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      return Image.memory(
                                        bytes,
                                        fit: BoxFit.contain,
                                        filterQuality: FilterQuality.low,
                                        cacheWidth: 240,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  '$previewPage / $_pagesCount',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: const ui.Color.fromARGB(
                                      255,
                                      115,
                                      142,
                                      160,
                                    ).withValues(alpha: 0.4),
                                  ),
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
          ),
        ),
      ),
    );
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
    _imageCache.clear(onEvict: (k, v) => v.dispose());
  }

  void _clearPrefetchQueue() {
    _prefetchQueue.clear();
    _prefetchQueued.clear();
  }

  void _enqueuePrefetchNear(int center, Iterable<int> pages) {
    if (_pages.isEmpty) return;

    final unique =
        pages.toSet().toList()
          ..sort((a, b) => (a - center).abs().compareTo((b - center).abs()));

    for (final raw in unique) {
      final pg = raw.clamp(1, _pagesCount);

      if (_pngCacheLru.containsKey(pg)) continue;
      if (_pngInFlight.containsKey(pg)) continue;
      if (_prefetchQueued.contains(pg)) continue;

      _prefetchQueued.add(pg);
      _prefetchQueue.add(pg);
    }

    _pumpPrefetch();
  }

  void _pumpPrefetch() {
    if (_prefetchRunning >= _prefetchConcurrency) return;

    while (_prefetchRunning < _prefetchConcurrency &&
        _prefetchQueue.isNotEmpty) {
      final pg = _prefetchQueue.removeAt(0);
      _prefetchQueued.remove(pg);

      _prefetchRunning++;
      _ensurePngForPage(pg).whenComplete(() {
        if (!mounted) return;
        _prefetchRunning = math.max(0, _prefetchRunning - 1);
        _pumpPrefetch();
      });
    }
  }

  Future<List<T>> _runWithConcurrency<T>({
    required List<Future<T> Function()> tasks,
    int concurrency = 2,
  }) async {
    if (tasks.isEmpty) return <T>[];

    final results = List<T?>.filled(tasks.length, null);
    int nextIndex = 0;

    Future<void> worker() async {
      while (true) {
        final i = nextIndex++;
        if (i >= tasks.length) return;

        try {
          results[i] = await tasks[i]();
        } catch (_) {}
      }
    }

    final runners = List.generate(math.max(1, concurrency), (_) => worker());
    await Future.wait(runners);

    return results.whereType<T>().toList();
  }

  Future<List<T?>> _runWithConcurrencyNullable<T>({
    required List<Future<T?> Function()> tasks,
    int concurrency = 2,
  }) async {
    if (tasks.isEmpty) return <T?>[];

    final results = List<T?>.filled(tasks.length, null);
    int nextIndex = 0;

    Future<void> worker() async {
      while (true) {
        final i = nextIndex++;
        if (i >= tasks.length) return;

        try {
          results[i] = await tasks[i]();
        } catch (_) {
          results[i] = null;
        }
      }
    }

    final runners = List.generate(math.max(1, concurrency), (_) => worker());
    await Future.wait(runners);
    return results;
  }

  void _resetPaginationAndCaches({bool notify = true}) {
    _paginateDebounce?.cancel();
    _paginateEpoch++;
    _paginating = false;

    _pages = const [];
    _clearPrefetchQueue();
    _pngInFlight.clear();

    _thumbInFlight.clear();
    _pngCacheLru.clear();
    _thumbCacheLru.clear();

    _exportPngCacheLru.clear();

    _exportInFlight.clear();

    _imageSizeCache.clear();
    _fileBytesCache.clear();

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

  static const int _maxImageCacheEntries = 60;
  late final LruCache<String, ui.Image> _imageCache =
      LruCache<String, ui.Image>(maxEntries: _maxImageCacheEntries);

  final Map<int, Future<Uint8List>> _thumbInFlight = <int, Future<Uint8List>>{};
  static const int _maxThumbCachePages = 32;
  late final LruCache<int, Uint8List> _thumbCacheLru = LruCache<int, Uint8List>(
    maxEntries: _maxThumbCachePages,
  );

  static const double _thumbRenderScale = 0.9;
  final Map<int, Future<Uint8List>> _pngInFlight = <int, Future<Uint8List>>{};
  static const int _fileBytesCacheBudgetBytes = 60 * 1024 * 1024;
  late final ByteLruCache<String, Uint8List> _fileBytesCache =
      ByteLruCache<String, Uint8List>(maxBytes: _fileBytesCacheBudgetBytes);

  Future<Uint8List?> _readFileBytesCached(String path) async {
    final cached = _fileBytesCache.get(path);
    if (cached != null) return cached;

    final f = File(path);
    if (!await f.exists()) return null;

    final bytes = await f.readAsBytes();
    if (bytes.isEmpty) return null;

    _fileBytesCache.put(path, bytes, bytesWeight: bytes.length);
    return bytes;
  }

  static const int _pngCacheBudgetBytes = 120 * 1024 * 1024;
  late final ByteLruCache<int, Uint8List> _pngCacheLru =
      ByteLruCache<int, Uint8List>(maxBytes: _pngCacheBudgetBytes);

  final List<int> _prefetchQueue = <int>[];
  final Set<int> _prefetchQueued = <int>{};
  int _prefetchRunning = 0;
  static const int _prefetchConcurrency = 2;

  int _lastPageForDirection = 1;

  @override
  void initState() {
    super.initState();

    var safeDelta = widget.deltaJson
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: true);

    safeDelta = stripThemeBaseColorFromDelta(
      safeDelta,
      themeBaseColorHex: '#ffffff',
      stripBackgroundToo: false,
    );

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

    safeDelta = stripThemeBaseColorFromDelta(
      safeDelta,
      themeBaseColorHex: '#ffffff',
      stripBackgroundToo: false,
    );

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
    _exportInFlight.clear();
    _exportPngCacheLru.clear();
    _fileBytesCache.clear();
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
  // 페이지네이션
  // ---------------------------
  Future<void> _paginateIfNeeded(int epoch) async {
    if (epoch != _paginateEpoch) return;
    if (_pageWidthPx <= 0 || _pageHeightPx <= 0) return;
    if (_pages.isNotEmpty) return;
    if (_paginating) return;

    _paginating = true;
    _incLoading();
    try {
      final hm = _effectiveHorizontalMarginPx();
      final vm = _effectiveVerticalMarginPx();

      final contentW = _pageWidthPx - hm * 2;
      final contentH = _pageHeightPx - vm * 2;

      final maxImageH = contentH * widget.maxImageHeightRatio;

      for (final b in _blocks) {
        if (epoch != _paginateEpoch) return;
        if (b is _ImageBlock) {
          if (_imageSizeCache.containsKey(b.src)) continue;
          final img = await _loadImage(b.src, targetWidthPx: 256);
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
          fontFamilyFallback: const [
            'Apple SD Gothic Neo',
            'Noto Sans KR',
            'Roboto',
            'sans-serif',
          ],
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

      await _ensurePngForPage(1);
      _enqueuePrefetchNear(1, [2, 3, 4]);
    } finally {
      if (mounted && epoch == _paginateEpoch) {
        _paginating = false;
      }
      _decLoading();
    }
  }

  String _imgKey(String src, int? w) => w == null ? src : '$src@w$w';

  Future<ui.Image?> _loadImage(String src, {int? targetWidthPx}) async {
    final key = _imgKey(src, targetWidthPx);

    final cached = _imageCache.get(key);
    if (cached != null) return cached;

    try {
      Uint8List bytes;

      if (src.startsWith('http://') || src.startsWith('https://')) {
        return null;
      } else {
        final b = await _readFileBytesCached(src);
        if (b == null) return null;
        bytes = b;
      }

      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidthPx,
      );
      final frame = await codec.getNextFrame();
      codec.dispose();

      final imgObj = frame.image;
      _imageCache.put(key, imgObj, onEvict: (k, v) => v.dispose());
      return imgObj;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------
  // 페이지 렌더 -> PNG bytes
  // ---------------------------

  Future<Uint8List> _ensurePngForPage(int pageNumber) {
    if (_pages.isEmpty) return Future.value(Uint8List(0));
    final cached = _pngCacheLru.get(pageNumber);
    if (cached != null) {
      return Future.value(cached);
    }

    final inflight = _pngInFlight[pageNumber];
    if (inflight != null) return inflight;

    final fut = _renderPngForPage(pageNumber).whenComplete(() {
      _pngInFlight.remove(pageNumber);
    });

    _pngInFlight[pageNumber] = fut;
    return fut;
  }

  Future<Uint8List> _renderPngForPage(int pageNumber) async {
    final int epoch = _paginateEpoch;

    final bytes = await _renderPngForPageWithScale(
      pageNumber,
      _previewRenderScale,
    );

    if (bytes.isEmpty) return bytes;
    if (!mounted || epoch != _paginateEpoch) {
      return Uint8List(0);
    }

    _pngCacheLru.put(pageNumber, bytes, bytesWeight: bytes.length);

    return bytes;
  }

  // ===== EXPORT PNG cache (고해상도 공유/저장용) =====
  static const int _exportPngCacheBudgetBytes = 90 * 1024 * 1024;
  late final ByteLruCache<int, Uint8List> _exportPngCacheLru =
      ByteLruCache<int, Uint8List>(maxBytes: _exportPngCacheBudgetBytes);

  Future<Uint8List> _renderExportPngForPage(int pageNumber) {
    if (_pages.isEmpty) return Future.value(Uint8List(0));

    final cached = _exportPngCacheLru.get(pageNumber);
    if (cached != null) return Future.value(cached);

    final inflight = _exportInFlight[pageNumber];
    if (inflight != null) return inflight;

    final int epoch = _paginateEpoch;

    final fut = _renderPngForPageWithScale(pageNumber, _exportRenderScale)
        .then((bytes) {
          if (!mounted || epoch != _paginateEpoch) return Uint8List(0);
          if (bytes.isEmpty) return bytes;
          _exportPngCacheLru.put(pageNumber, bytes, bytesWeight: bytes.length);

          return bytes;
        })
        .whenComplete(() {
          _exportInFlight.remove(pageNumber);
        });

    _exportInFlight[pageNumber] = fut;
    return fut;
  }

  Future<Uint8List> _ensureThumbForPage(int pageNumber) {
    final cached = _thumbCacheLru.get(pageNumber);
    if (cached != null) {
      return Future.value(cached);
    }

    final inflight = _thumbInFlight[pageNumber];
    if (inflight != null) return inflight;

    final fut = _renderPngForPageWithScale(pageNumber, _thumbRenderScale)
        .then((bytes) {
          if (bytes.isNotEmpty) {
            _thumbCacheLru.put(pageNumber, bytes);
          }
          return bytes;
        })
        .whenComplete(() {
          _thumbInFlight.remove(pageNumber);
        });

    _thumbInFlight[pageNumber] = fut;
    return fut;
  }

  Set<String> _collectImageSrcsFromPlan(_PagePlan plan) {
    final srcs = <String>{};
    for (final cmd in plan.commands) {
      if (cmd is _ImageDrawCommand) {
        srcs.add(cmd.src);
      }
    }
    return srcs;
  }

  Future<void> _preloadImagesForPlan(_PagePlan plan, double scale) async {
    final srcs = _collectImageSrcsFromPlan(plan);
    if (srcs.isEmpty) return;

    final hm = _effectiveHorizontalMarginPx();
    final double contentW = _pageWidthPx - hm * 2;
    final int targetPx = (contentW * scale).round().clamp(64, 4096);

    final tasks = <Future<void> Function()>[];

    for (final src in srcs) {
      tasks.add(() async {
        await _loadImage(src, targetWidthPx: targetPx);
      });
    }
    await _runWithConcurrency<void>(tasks: tasks, concurrency: 2);
  }

  Future<Uint8List> _renderPngForPageWithScale(
    int pageNumber,
    double scale,
  ) async {
    if (_pages.isEmpty) return Uint8List(0);

    final idx = (pageNumber - 1).clamp(0, _pages.length - 1);
    final plan = _pages[idx];

    await _preloadImagesForPlan(plan, scale);

    final int outW = (_pageWidthPx * scale).round();
    final int outH = (_pageHeightPx * scale).round();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.scale(scale, scale);
    final bgPaint = Paint()..color = widget.pageBackgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, _pageWidthPx, _pageHeightPx), bgPaint);

    final hm = _effectiveHorizontalMarginPx();
    final vm = _effectiveVerticalMarginPx();
    final origin = Offset(hm, vm);

    for (final cmd in plan.commands) {
      await cmd.paint(
        canvas: canvas,
        origin: origin,
        loadImage: _loadImage,
        maxImageHeight: (_pageHeightPx - vm * 2) * widget.maxImageHeightRatio,
        renderScale: scale,
      );
    }

    final picture = recorder.endRecording();
    if (outW <= 0 || outH <= 0) {
      picture.dispose();
      return Uint8List(0);
    }

    final img = await picture.toImage(outW, outH);
    picture.dispose();
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();

    return bd?.buffer.asUint8List() ?? Uint8List(0);
  }

  static Uint8List _pngToJpgSync(Uint8List pngBytes, int quality) {
    final decoded = img.decodeImage(pngBytes);
    if (decoded == null) return Uint8List(0);
    return Uint8List.fromList(img.encodeJpg(decoded, quality: quality));
  }

  Future<Uint8List> _pngToJpgInIsolate(
    Uint8List pngBytes, {
    int quality = 92,
  }) async {
    if (pngBytes.isEmpty) return Uint8List(0);
    return Isolate.run(() => _pngToJpgSync(pngBytes, quality));
  }

  Future<Uint8List> _buildPdfFromPages(List<int> pages) async {
    final doc = pw.Document();

    for (final pg in pages) {
      final pngBytes = await _renderExportPngForPage(pg);
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

      final tasks = <Future<void> Function()>[];

      for (int i = 1; i <= _pagesCount; i++) {
        final pg = i;
        tasks.add(() async {
          final bytes = await _renderExportPngForPage(pg);
          if (bytes.isEmpty) return;

          final name = '${base}_${i.toString().padLeft(3, '0')}.png';
          final file = File(p.join(folder.path, name));
          await file.writeAsBytes(bytes, flush: true);
        });
      }
      await _runWithConcurrency<void>(tasks: tasks, concurrency: 2);

      if (!mounted) return;
      AppToast.show(context, '저장 완료\n${folder.path}');
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, '저장 실패');
    } finally {
      _decLoading();
    }
  }

  Future<void> _onShareTap() async {
    const int concurrency = 2;
    if (_isLoading) return;
    if (_pages.isEmpty) return;

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

    final pages = <int>[for (int i = pick.startPage; i <= pick.endPage; i++) i];

    _incLoading();
    try {
      final base = _safeFileName(widget.title);

      final String formatLabel;
      switch (pick.format) {
        case ShareFormat.pdf:
          formatLabel = 'PDF 공유 완료';
          break;
        case ShareFormat.png:
          formatLabel = 'PNG 공유 완료';
          break;
        case ShareFormat.jpg:
          formatLabel = 'JPG 공유 완료';
          break;
      }

      // =========================
      // PDF
      // =========================
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

        if (!mounted) return;
        AppToast.show(context, formatLabel);
        return;
      }

      // =========================
      // PNG / JPG
      // =========================
      final tasks = <Future<XFile?> Function()>[];

      for (final pg in pages) {
        tasks.add(() async {
          final pngBytes = await _renderExportPngForPage(pg);
          if (pngBytes.isEmpty) return null;

          if (pick.format == ShareFormat.png) {
            final name = '${base}_${pg.toString().padLeft(3, '0')}.png';
            final f = await _writeBytesToTemp(bytes: pngBytes, fileName: name);
            return XFile(
              f.path,
              mimeType: 'image/png',
              name: p.basename(f.path),
            );
          } else {
            final jpgBytes = await _pngToJpgInIsolate(pngBytes);
            if (jpgBytes.isEmpty) return null;

            final name = '${base}_${pg.toString().padLeft(3, '0')}.jpg';
            final f = await _writeBytesToTemp(bytes: jpgBytes, fileName: name);
            return XFile(
              f.path,
              mimeType: 'image/jpeg',
              name: p.basename(f.path),
            );
          }
        });
      }

      final xfiles = await _runWithConcurrencyNullable<XFile>(
        tasks: tasks,
        concurrency: concurrency,
      );

      final files = xfiles.whereType<XFile>().toList();

      if (!mounted) return;
      if (files.isEmpty) {
        AppToast.show(context, '공유할 파일이 없습니다');
        return;
      }

      await Share.shareXFiles(
        files,
        text: widget.title,
        sharePositionOrigin: shareOrigin,
      );

      if (!mounted) return;
      AppToast.show(context, formatLabel);
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, '공유 실패');
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
    return Theme(
      data: fixedLightTheme(),
      child: Builder(
        builder: (context) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final maxCardWidth = constraints.maxWidth * 0.95;
              _pageWidthPx = maxCardWidth;
              _pageHeightPx = maxCardWidth * 297 / 210;

              final dpr = MediaQuery.of(context).devicePixelRatio;
              _previewRenderScale = (dpr * 1.1).clamp(1.2, 3.5);

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
              final cardHeight =
                  desiredH > maxCardHeight ? maxCardHeight : desiredH;

              return Scaffold(
                appBar: AppBar(title: Text(widget.title)),
                body: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageCtrl,

                      physics:
                          _isSliderDragging
                              ? const NeverScrollableScrollPhysics()
                              : const BouncingScrollPhysics(),

                      itemCount: _pagesCount,
                      onPageChanged: (index) {
                        _resetZoom();
                        final newPage = index + 1;

                        setState(() {
                          _page = newPage;
                          if (_isSliderDragging) {
                            _lastPreviewPage = newPage;
                            _sliderDragValue = newPage.toDouble();
                          }
                        });

                        final dir = (newPage - _lastPageForDirection).sign;
                        _lastPageForDirection = newPage;
                        final pages = <int>[newPage - 1, newPage + 1];
                        if (dir > 0) pages.add(newPage + 2);
                        if (dir < 0) pages.add(newPage - 2);

                        _enqueuePrefetchNear(newPage, pages);
                      },

                      itemBuilder: (context, index) {
                        final pageNumber = index + 1;

                        return Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: _cardTopPadding,
                            ),
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
                                      _uiScale = _zoomCtrl.value
                                          .getMaxScaleOnAxis()
                                          .clamp(_minUiScale, _maxUiScale);
                                    },
                                    onInteractionEnd: (_) {
                                      _uiScale = _zoomCtrl.value
                                          .getMaxScaleOnAxis()
                                          .clamp(_minUiScale, _maxUiScale);
                                    },
                                    child: SizedBox(
                                      width: maxCardWidth,
                                      height: cardHeight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
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
                                (_isLoading || _pages.isEmpty)
                                    ? null
                                    : _onShareTap,
                            icon: const Icon(
                              Icons.ios_share,
                              color: _topIconColor,
                              size: 23,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ===== 슬라이더 바 =====
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: _controlBottom + 60,
                      child: IgnorePointer(
                        ignoring: _isLoading || _pages.isEmpty,
                        child: Opacity(
                          opacity: (_isLoading || _pages.isEmpty) ? 0.35 : 1.0,
                          child: _pageSliderBar(
                            maxCardWidth: maxCardWidth,
                            cardHeight: cardHeight,
                          ),
                        ),
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
                                    onPressed:
                                        _page >= _pagesCount ? null : _goNext,
                                    icon: Icons.chevron_right,
                                  ),
                                  _tightIconButton(
                                    onPressed:
                                        _page >= _pagesCount ? null : _goLast,
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
        },
      ),
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
          if (text.isNotEmpty) {
            currentRuns.add(
              _Run(text: text, inline: _InlineStyle.fromDeltaAttrs(attrs)),
            );
          }
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

    Color? parseColorAny(dynamic v) {
      if (v == null) return null;

      if (v is int) {
        return Color(v & 0xFFFFFFFF);
      }

      if (v is String) {
        final s = v.trim();
        if (!s.startsWith('#')) return null;

        final hex = s.substring(1);
        if (hex.length == 6) {
          final n = int.tryParse(hex, radix: 16);
          if (n == null) return null;
          return Color(0xFF000000 | n);
        }
        if (hex.length == 8) {
          final n = int.tryParse(hex, radix: 16);
          if (n == null) return null;
          return Color(n);
        }
      }

      return null;
    }

    double? parseSize(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    // ---- background ----
    Color? bg = parseColorAny(attrs['background']);

    final dynA = attrs[kBgAlphaKey];
    if (bg != null && dynA != null) {
      int a = 255;
      if (dynA is int) a = dynA.clamp(0, 255);
      if (dynA is num) a = dynA.toInt().clamp(0, 255);
      bg = bg.withAlpha(a);
    }

    return _InlineStyle(
      bold: b('bold'),
      italic: b('italic'),
      underline: b('underline'),
      strike: b('strike'),
      color: parseColorAny(attrs['color']),
      background: bg,
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
  final int header;
  final TextAlign align;
  final int indent;
  final _ListType listType;
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
/// Layout Engine -> Page plans
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
  final Map<int, double> _sliceHeightCache = <int, double>{};

  static const String _zwsp = '\u200B';
  static const String _urlBreakAfterChars = r'/:?&=#._-~%+@';
  static const int _hardTokenGraphemeThreshold = 28;
  static const int _hardTokenInsertEvery = 8;

  bool _isWhitespaceChar(String ch) => RegExp(r'\s').hasMatch(ch);

  String _stripZwsp(String s) => s.replaceAll(_zwsp, '');

  bool _looksLikeUrl(String token) {
    final t = token.toLowerCase();
    return t.startsWith('http://') ||
        t.startsWith('https://') ||
        t.startsWith('www.') ||
        t.contains('://');
  }

  int _sliceMeasureKey(_LineSlice s, TextStyle baseStyle, double innerW) {
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
        if (i % _hardTokenInsertEvery == 0) {
          out.write(_zwsp);
        }
      }
      return out.toString();
    }

    return token;
  }

  List<_Run> _softWrapRuns(List<_Run> runs) {
    final out = <_Run>[];

    for (final r in runs) {
      final raw = _stripZwsp(r.text);
      if (raw.length < _hardTokenGraphemeThreshold) {
        out.add(r.text == raw ? r : _Run(text: raw, inline: r.inline));
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
      out.add(cooked == r.text ? r : _Run(text: cooked, inline: r.inline));
    }

    return out;
  }

  int _snapCutToNiceBoundary(String text, int cutOffset, {int lookBack = 48}) {
    if (cutOffset <= 0) return 0;
    if (text.isEmpty) return cutOffset;
    if (cutOffset > text.length) cutOffset = text.length;

    bool isWhitespace(String ch) => RegExp(r'\s').hasMatch(ch) || ch == _zwsp;

    bool isPunct(String ch) {
      const punct =
          '.,!?;:…·。！？、'
          ')]}’”"\''
          '—–-';
      return punct.contains(ch);
    }

    final start = math.max(0, cutOffset - lookBack);
    for (int i = cutOffset - 1; i >= start; i--) {
      final ch = text[i];

      if (isWhitespace(ch)) {
        return i;
      }
      if (isPunct(ch)) {
        return i + 1;
      }
    }

    return cutOffset;
  }

  List<_Run> _trimLeadingWhitespaceRuns(List<_Run> runs) {
    final out = <_Run>[];
    bool trimming = true;

    for (final r in runs) {
      if (!trimming) {
        out.add(r);
        continue;
      }
      final s = r.text;
      final trimmed = s.replaceFirst(RegExp(r'^[\s\u200B]+'), '');

      if (trimmed.isEmpty) {
        continue;
      }

      out.add(_Run(text: trimmed, inline: r.inline));
      trimming = false;
    }

    return out;
  }

  List<_LineSlice> _buildSlicesFromBlock(_ParagraphBlock b) {
    final out = <_LineSlice>[];

    for (final line in b.lines) {
      final cookedRuns = _softWrapRuns(line.runs);

      out.add(_LineSlice(runs: cookedRuns, align: line.style.align));
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

  Future<List<_PagePlan>> paginate(List<_Block> blocks) async {
    _sliceHeightCache.clear();
    final pages = <_PagePlan>[];
    var current = _PagePlan(commands: []);
    double y = 0;
    int orderedCounter = 0;
    bool inOrderedList = false;

    void newPage() {
      pages.add(current);
      current = _PagePlan(commands: []);
      y = 0;
    }

    for (final b in blocks) {
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

        if (y + blockH > contentHeight && y > 0) newPage();

        current.commands.add(
          _HrDrawCommand(
            y: y + padV + lineYInsideBox,
            solid: b.solid,
            width: contentWidth,
          ),
        );

        y += blockH;
        continue;
      }

      if (b is _ImageBlock) {
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

        y += reservedH + 10;
        continue;
      }

      if (b is _ParagraphBlock) {
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
        final slices = _buildSlicesFromBlock(b).toList(growable: true);

        int cursor = 0;
        bool isContinuation = false;

        while (cursor < slices.length) {
          final decoTop = pad.topDecoration;
          final decoBottom = pad.bottomDecoration;

          final available = contentHeight - y - decoTop - decoBottom - 0.5;

          if (available <= 8) {
            newPage();
            continue;
          }

          final pageSlices = <_LineSlice>[];
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
            final s = slices[cursor];

            final tp = _buildTextPainterForRuns(s.runs, paraStyle, s.align);
            tp.layout(maxWidth: innerW);

            final canUse = (contentHeight - decoTop - decoBottom - 0.5);
            int cut = _cutOffsetByLineMetrics(tp, canUse, innerW);
            if (cut <= 0) cut = 1;

            final flatText = s.runs.map((e) => e.text).join();
            cut = _snapCutToNiceBoundary(flatText, cut, lookBack: 32);
            if (cut <= 0) cut = 1;

            final split = _RunSplitter.split(s.runs, cut);
            final headRuns = split.$1;
            final tailRuns = _trimLeadingWhitespaceRuns(split.$2);

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
            newPage();
            if (tailRuns.isNotEmpty) {
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
    final descent = (lm.descent.isFinite && lm.descent > 0) ? lm.descent : 2.0;
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
    required Future<ui.Image?> Function(String src, {int? targetWidthPx})
    loadImage,
    required double maxImageHeight,
    required double renderScale,
  });
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

  List<_PreparedLine>? _prepared;
  double? _totalHCache;
  double? _firstVisibleFontSizeCache;

  // ------------------------
  // Prepare (TextPainter / Span 생성 1회)
  // ------------------------
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
    required _BlockStyle blockStyle,
  }) {
    double scale = 0.95;
    if (blockStyle.header >= 1) scale = 0.80;
    if (blockStyle.codeBlock) scale = 0.92;
    return (textFontSize * scale).clamp(10.0, 42.0);
  }

  // ------------------------
  // Paint
  // ------------------------
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

    final isList = blockStyle.listType != _ListType.none;

    final y0 = origin.dy + y + padding.topDecoration;
    final contentW = width + padding.left + padding.right;
    final paraRect = Rect.fromLTWH(
      origin.dx,
      origin.dy + y,
      contentW,
      padding.topDecoration + totalH + padding.bottomDecoration,
    );
    padding.paintDecoration(canvas, paraRect);

    if (isList && !isListContinuation) {
      final marker =
          blockStyle.listType == _ListType.bullet ? '•' : (markerText ?? '');

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

    // ---- text lines ----
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

class _HrDrawCommand extends _DrawCommand {
  _HrDrawCommand({required this.y, required this.solid, required this.width});
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

class _ImageDrawCommand extends _DrawCommand {
  _ImageDrawCommand({required this.y, required this.src, required this.width});
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
    double headerLeftIndent = 0;
    if (s.header == 2) headerLeftIndent = 6;
    if (s.header == 3) headerLeftIndent = 10;

    double left = baseIndent + headerLeftIndent;
    double right = 0;

    if (s.listType != _ListType.none) left += 22;

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
  static double of(_BlockStyle s) {
    if (s.header > 0) return 0;
    if (s.blockQuote || s.codeBlock) return 6;
    return 4;
  }
}

class _RunSplitter {
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
