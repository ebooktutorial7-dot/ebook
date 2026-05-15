// pdf_preview_page.dart

import 'dart:io';
import 'dart:isolate';
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render_maintained/pdf_render.dart';
import 'package:pdf/pdf.dart' as pdf;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;

import 'package:ebook_tutorial_app/pages/book_builder_page.dart'
    show ChapterItem;
import 'package:ebook_tutorial_app/pdf/book_pdf_builder.dart' show buildBookPdf;

import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/widgets/common/app_toast.dart';

import 'package:ebook_tutorial_app/widgets/pdf/pdf_chapter_picker_dialog.dart';

const _loaderColor = ui.Color.fromARGB(255, 150, 194, 224);
const _topIconColor = ui.Color.fromARGB(255, 71, 95, 121);

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
  ShareFormat format = ShareFormat.pdf;
  ShareRangeMode rangeMode = ShareRangeMode.all;
  int start = 1;
  int end = pagesCount;

  final startCtrl = TextEditingController(text: '1');
  final endCtrl = TextEditingController(text: '$pagesCount');
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

  void put(K key, V value) {
    _map.remove(key);
    _map[key] = value;
    while (_map.length > maxEntries) {
      final oldestKey = _map.keys.first;
      _map.remove(oldestKey);
    }
  }

  void clear() => _map.clear();
}

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

String _safeFileNameStandalone(String name) {
  final trimmed = name.trim().isEmpty ? 'document' : name.trim();
  final sanitized = trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  return sanitized.length > 80 ? sanitized.substring(0, 80) : sanitized;
}

Future<File> _writeBytesToTempStandalone({
  required Uint8List bytes,
  required String fileName,
}) async {
  final dir = await getTemporaryDirectory();
  final file = File(p.join(dir.path, fileName));
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

Future<void> _shareXFiles({
  required List<XFile> files,
  String? text,
  String? subject,
  Rect? sharePositionOrigin,
}) async {
  await SharePlus.instance.share(
    ShareParams(
      files: files,
      text: text,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    ),
  );
}

Future<T> _withDocPage<T>(
  PdfDocument doc,
  int pageNumber,
  Future<T> Function(PdfPage page) run,
) async {
  final page = await doc.getPage(pageNumber);
  try {
    return await run(page);
  } finally {
    try {
      final r = (page as dynamic).close();
      if (r is Future) await r;
    } catch (_) {}
    try {
      final r = (page as dynamic).dispose();
      if (r is Future) await r;
    } catch (_) {}
  }
}

Uint8List _pngToJpgSyncStandalone(Uint8List pngBytes, int quality) {
  final decoded = img.decodeImage(pngBytes);
  if (decoded == null) return Uint8List(0);
  return Uint8List.fromList(img.encodeJpg(decoded, quality: quality));
}

Future<Uint8List> _pngToJpgInIsolateStandalone(
  Uint8List pngBytes, {
  int quality = 92,
}) async {
  if (pngBytes.isEmpty) return Uint8List(0);
  return Isolate.run(() => _pngToJpgSyncStandalone(pngBytes, quality));
}

Future<List<T?>> _runWithConcurrencyNullableStandalone<T>({
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

  await Future.wait(List.generate(math.max(1, concurrency), (_) => worker()));
  return results;
}

Future<File?> _renderImageToTempFileFromDoc({
  required PdfDocument doc,
  required int pageNumber,
  required int targetLongSidePx,
  required String baseName,
  required ShareFormat format,
}) async {
  final pngBytes = await _withDocPage(doc, pageNumber, (page) {
    return _renderExportPngBytesFromPage(
      page,
      targetLongSidePx: targetLongSidePx,
    );
  });
  if (pngBytes.isEmpty) return null;

  final bool asJpg = format == ShareFormat.jpg;
  final outBytes =
      asJpg
          ? await _pngToJpgInIsolateStandalone(pngBytes, quality: 92)
          : pngBytes;
  if (outBytes.isEmpty) return null;

  final dir = await getTemporaryDirectory();
  final ext = asJpg ? 'jpg' : 'png';
  final seq = pageNumber.toString().padLeft(3, '0');
  final nonce = DateTime.now().microsecondsSinceEpoch.toString();
  final file = File(p.join(dir.path, 'share_${baseName}_${seq}_$nonce.$ext'));

  await file.writeAsBytes(outBytes, flush: true);
  if (!await file.exists()) return null;
  if (await file.length() <= 0) return null;

  return file;
}

Future<Uint8List> _buildPdfFromRenderedPagesStandalone({
  required PdfDocument doc,
  required List<int> pages,
  required String title,
}) async {
  const double maxLongSidePt = 842.0;
  final out = pw.Document();
  final base = _safeFileNameStandalone(title);

  final tempFiles = <File>[];
  final pageFormats = <int, pdf.PdfPageFormat>{};

  try {
    final tasks = <Future<File?> Function()>[];
    for (final pg in pages) {
      tasks.add(() async {
        return _withDocPage(doc, pg, (page) async {
          final w = page.width.toDouble();
          final h = page.height.toDouble();
          final portrait = h >= w;
          final aspect = (h == 0) ? 1.0 : (w / h);

          const longSide = maxLongSidePt;
          final shortSide = longSide * (portrait ? aspect : (1.0 / aspect));
          final pageW = portrait ? shortSide : longSide;
          final pageH = portrait ? longSide : shortSide;
          pageFormats[pg] = pdf.PdfPageFormat(pageW, pageH);
          final pngBytes = await _renderExportPngBytesFromPage(
            page,
            targetLongSidePx: 2600,
          );
          if (pngBytes.isEmpty) return null;

          final jpgBytes = await _pngToJpgInIsolateStandalone(
            pngBytes,
            quality: 83,
          );
          if (jpgBytes.isEmpty) return null;

          final dir = await getTemporaryDirectory();
          final seq = pg.toString().padLeft(3, '0');
          final nonce = DateTime.now().microsecondsSinceEpoch.toString();
          final file = File(
            p.join(dir.path, 'share_${base}_${seq}_$nonce.jpg'),
          );
          await file.writeAsBytes(jpgBytes, flush: false);

          if (!await file.exists()) return null;
          if (await file.length() <= 0) return null;
          return file;
        });
      });
    }

    final files = await _runWithConcurrencyNullableStandalone<File>(
      tasks: tasks,
      concurrency: 3,
    );

    for (int i = 0; i < pages.length; i++) {
      final pg = pages[i];
      final f = files[i];
      final pf = pageFormats[pg];
      if (f == null || pf == null) continue;

      tempFiles.add(f);

      out.addPage(
        pw.Page(
          pageFormat: pf,
          margin: pw.EdgeInsets.zero,
          build:
              (_) => pw.FullPage(
                ignoreMargins: true,
                child: pw.FittedBox(
                  fit: pw.BoxFit.contain,
                  child: pw.Image(_FileBackedImage(f)),
                ),
              ),
        ),
      );
    }

    return out.save();
  } finally {
    for (final f in tempFiles) {
      try {
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }
}

Future<int> pdfPageCountFromBytes(Uint8List pdfBytes) async {
  PdfDocument? doc;
  try {
    doc = await PdfDocument.openData(pdfBytes);
    return math.max(1, doc.pageCount);
  } finally {
    try {
      doc?.dispose();
    } catch (_) {}
  }
}

Future<List<File>> createPickedPdfFilesForZip({
  required String title,
  required Uint8List pdfBytes,
  required SharePickResult pick,
}) async {
  PdfDocument? doc;
  final safeTitle = title.trim().isEmpty ? 'document' : title.trim();

  try {
    doc = await PdfDocument.openData(pdfBytes);
    final pagesCount = math.max(1, doc.pageCount);

    final start = pick.startPage.clamp(1, pagesCount);
    final end = pick.endPage.clamp(1, pagesCount);
    final pages = <int>[for (int i = start; i <= end; i++) i];

    final base = _safeFileNameStandalone(safeTitle);

    // ===== PDF =====
    if (pick.format == ShareFormat.pdf) {
      final isAll = start == 1 && end == pagesCount;

      final Uint8List outBytes;
      if (pick.rangeMode == ShareRangeMode.all && isAll) {
        outBytes = pdfBytes;
      } else {
        outBytes = await _buildPdfFromRenderedPagesStandalone(
          doc: doc,
          pages: pages,
          title: safeTitle,
        );
      }

      if (outBytes.isEmpty) return <File>[];

      final file = await _writeBytesToTempStandalone(
        bytes: outBytes,
        fileName: '$base.pdf',
      );

      return <File>[file];
    }

    // ===== PNG / JPG =====
    final tasks = <Future<File?> Function()>[];

    for (final pg in pages) {
      tasks.add(() async {
        return _renderImageToTempFileFromDoc(
          doc: doc!,
          pageNumber: pg,
          targetLongSidePx: 2600,
          baseName: base,
          format: pick.format,
        );
      });
    }

    final files = await _runWithConcurrencyNullableStandalone<File>(
      tasks: tasks,
      concurrency: pick.format == ShareFormat.jpg ? 2 : 3,
    );

    return files.whereType<File>().toList(growable: false);
  } finally {
    try {
      doc?.dispose();
    } catch (_) {}
  }
}

Future<void> sharePdfBytesWithPick({
  required String title,
  required Uint8List pdfBytes,
  required SharePickResult pick,
  required void Function(String msg) toast,
  Rect? sharePositionOrigin,
}) async {
  PdfDocument? doc;
  final safeTitle = title.trim().isEmpty ? 'document' : title.trim();

  try {
    doc = await PdfDocument.openData(pdfBytes);
    final pagesCount = math.max(1, doc.pageCount);

    final start = pick.startPage.clamp(1, pagesCount);
    final end = pick.endPage.clamp(1, pagesCount);

    final pages = <int>[for (int i = start; i <= end; i++) i];
    final base = _safeFileNameStandalone(safeTitle);

    // ===== PDF =====
    if (pick.format == ShareFormat.pdf) {
      final bool isAll = (start == 1 && end == pagesCount);

      if (pick.rangeMode == ShareRangeMode.all && isAll) {
        final file = await _writeBytesToTempStandalone(
          bytes: pdfBytes,
          fileName: '$base.pdf',
        );
        await _shareXFiles(
          files: [
            XFile(
              file.path,
              mimeType: 'application/pdf',
              name: p.basename(file.path),
            ),
          ],
          text: safeTitle,
          sharePositionOrigin: sharePositionOrigin,
        );
        return;
      }

      final outBytes = await _buildPdfFromRenderedPagesStandalone(
        doc: doc,
        pages: pages,
        title: safeTitle,
      );

      if (outBytes.isEmpty) {
        toast('공유할 파일이 없습니다');
        return;
      }

      final file = await _writeBytesToTempStandalone(
        bytes: outBytes,
        fileName: '$base.pdf',
      );
      await _shareXFiles(
        files: [
          XFile(
            file.path,
            mimeType: 'application/pdf',
            name: p.basename(file.path),
          ),
        ],
        text: safeTitle,
        sharePositionOrigin: sharePositionOrigin,
      );
      return;
    }

    // ===== PNG/JPG =====
    final tasks = <Future<File?> Function()>[];
    for (final pg in pages) {
      tasks.add(() async {
        return _renderImageToTempFileFromDoc(
          doc: doc!,
          pageNumber: pg,
          targetLongSidePx: 2600,
          baseName: base,
          format: pick.format,
        );
      });
    }

    final files = await _runWithConcurrencyNullableStandalone<File>(
      tasks: tasks,
      concurrency: (pick.format == ShareFormat.jpg) ? 2 : 3,
    );

    final xfiles = files
        .whereType<File>()
        .map((f) {
          final isPng = pick.format == ShareFormat.png;
          return XFile(
            f.path,
            mimeType: isPng ? 'image/png' : 'image/jpeg',
            name: p.basename(f.path),
          );
        })
        .toList(growable: false);

    if (xfiles.isEmpty) {
      toast('공유할 파일이 없습니다');
      return;
    }

    await _shareXFiles(
      files: xfiles,
      text: safeTitle,
      sharePositionOrigin: sharePositionOrigin,
    );

    for (final xf in xfiles) {
      try {
        await File(xf.path).delete();
      } catch (_) {}
    }
  } catch (e) {
    toast('공유 실패: $e');
  } finally {
    try {
      doc?.dispose();
    } catch (_) {}
  }
}

class _ExportKey {
  final int page;
  final int longSidePx;
  const _ExportKey(this.page, this.longSidePx);

  @override
  bool operator ==(Object other) =>
      other is _ExportKey &&
      other.page == page &&
      other.longSidePx == longSidePx;

  @override
  int get hashCode => Object.hash(page, longSidePx);
}

Future<Uint8List> _renderExportPngBytesFromPage(
  PdfPage page, {
  required int targetLongSidePx,
}) async {
  PdfPageImage? pageImage;
  ui.Image? imgObj;

  try {
    final w = page.width.toDouble();
    final h = page.height.toDouble();
    final longSide = math.max(w, h);
    if (longSide <= 0) return Uint8List(0);

    final scale = (targetLongSidePx / longSide).clamp(0.1, 20.0);
    final renderW = (w * scale).round().clamp(1, 1000000);
    final renderH = (h * scale).round().clamp(1, 1000000);

    pageImage = await page.render(
      width: renderW,
      height: renderH,
      backgroundFill: true,
    );

    imgObj = await pageImage.createImageIfNotAvailable();
    final bd = await imgObj.toByteData(format: ui.ImageByteFormat.png);

    return bd?.buffer.asUint8List() ?? Uint8List(0);
  } catch (_) {
    return Uint8List(0);
  } finally {
    try {
      imgObj?.dispose();
    } catch (_) {}
    try {
      pageImage?.dispose();
    } catch (_) {}
  }
}

class ByteLruCache<K, V extends Object> {
  ByteLruCache({required this.maxBytes}) : assert(maxBytes > 0);

  int maxBytes;
  final LinkedHashMap<K, _ByteEntry<V>> _map =
      LinkedHashMap<K, _ByteEntry<V>>();
  int _totalBytes = 0;

  int get totalBytes => _totalBytes;
  bool containsKey(K key) => _map.containsKey(key);
  Iterable<V> get values => _map.values.map((e) => e.value);

  V? get(K key) {
    final entry = _map.remove(key);
    if (entry == null) return null;
    _map[key] = entry;
    return entry.value;
  }

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
      onEvict?.call(key, prev.value, prev.bytesWeight);
    }

    if (bytesWeight > maxBytes) return;

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

  void clear({void Function(K key, V value, int bytesWeight)? onEvict}) {
    if (onEvict != null) {
      for (final e in _map.entries) {
        onEvict(e.key, e.value.value, e.value.bytesWeight);
      }
    }
    _map.clear();
    _totalBytes = 0;
  }
}

class _ByteEntry<V> {
  final V value;
  final int bytesWeight;
  const _ByteEntry({required this.value, required this.bytesWeight});
}

class _FileBackedImage extends pw.ImageProvider {
  _FileBackedImage(
    this.file, {
    pdf.PdfImageOrientation orientation = pdf.PdfImageOrientation.topLeft,
    double? dpi,
  }) : super(1, 1, orientation, dpi);

  final File file;

  @override
  pdf.PdfImage buildImage(pw.Context context, {int? width, int? height}) {
    final bytes = file.readAsBytesSync();
    return pdf.PdfImage.file(context.document, bytes: bytes);
  }
}

class _PendingImage {
  final int page;
  final ui.Image image;
  const _PendingImage(this.page, this.image);
}

class _PageLife extends StatefulWidget {
  const _PageLife({
    required this.pageNumber,
    required this.onAttach,
    required this.onDetach,
    required this.child,
  });

  final int pageNumber;
  final VoidCallback onAttach;
  final VoidCallback onDetach;
  final Widget child;

  @override
  State<_PageLife> createState() => _PageLifeState();
}

class _PageLifeState extends State<_PageLife> {
  @override
  void initState() {
    super.initState();
    widget.onAttach();
  }

  @override
  void dispose() {
    widget.onDetach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _CustomPdfPreviewPageState extends State<CustomPdfPreviewPage> {
  PdfDocument? _doc;

  int _pdfSession = 0;

  final List<_PendingImage> _pendingDisposeImages = [];
  bool _disposeScheduled = false;

  bool _isPinnedPage(int pg) => (pg - _page).abs() <= 4;

  final Map<int, int> _pageImgRefCount = <int, int>{};

  void _retainPageImage(int page) {
    _pageImgRefCount[page] = (_pageImgRefCount[page] ?? 0) + 1;
  }

  void _deferDisposeImage(int page, ui.Image image) {
    _pendingDisposeImages.add(_PendingImage(page, image));
    _scheduleDisposePendingImages();
  }

  void _releasePageImage(int page) {
    final cur = (_pageImgRefCount[page] ?? 0) - 1;
    if (cur <= 0) {
      _pageImgRefCount.remove(page);
    } else {
      _pageImgRefCount[page] = cur;
    }
    _scheduleDisposePendingImages();
  }

  bool _isPageImageInUse(int page) => (_pageImgRefCount[page] ?? 0) > 0;

  void _scheduleDisposePendingImages() {
    if (_disposeScheduled) return;
    _disposeScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final toDispose = <ui.Image>[];
      final keep = <_PendingImage>[];

      for (final item in _pendingDisposeImages) {
        final pg = item.page;

        final stillCached = _pageImgCache.containsKey(pg);
        final nowPinned = _isPinnedPage(pg);
        final stillInUse = _isPageImageInUse(pg);

        if (stillCached || nowPinned || stillInUse) {
          keep.add(item);
        } else {
          toDispose.add(item.image);
        }
      }

      _pendingDisposeImages
        ..clear()
        ..addAll(keep);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final img in toDispose) {
          try {
            img.dispose();
          } catch (_) {}
        }

        _disposeScheduled = false;

        if (_pendingDisposeImages.isNotEmpty) {
          _scheduleDisposePendingImages();
        }
      });
    });
  }

  Future<T> _withPage<T>(
    int pageNumber,
    Future<T> Function(PdfPage page) run,
  ) async {
    final doc = _doc;
    if (doc == null) throw StateError('PDF not opened');
    final page = await doc.getPage(pageNumber);
    try {
      return await run(page);
    } finally {
      try {
        final r = (page as dynamic).close();
        if (r is Future) await r;
      } catch (_) {}
      try {
        final r = (page as dynamic).dispose();
        if (r is Future) await r;
      } catch (_) {}
    }
  }

  int _page = 1;
  int _pagesCount = 1;

  late Uint8List _currentPdfBytes;

  // ===== Page image cache: Byte-LRU (메모리 안정) =====
  static const int _pageImgCacheBudgetBytes =
      180 * 1024 * 1024; // 180MB (필요시 조절)
  late final ByteLruCache<int, ui.Image> _pageImgCache =
      ByteLruCache<int, ui.Image>(maxBytes: _pageImgCacheBudgetBytes);

  // 중복 렌더 방지(in-flight)
  final Map<int, Future<ui.Image>> _pageImgInFlight = <int, Future<ui.Image>>{};
  final PageController _pageCtrl = PageController();
  final TransformationController _zoomCtrl = TransformationController();

  // ===== Page image prefetch (near pages) =====
  final List<int> _pageImgPrefetchQueue = <int>[];
  final Set<int> _pageImgPrefetchQueued = <int>{};
  int _pageImgPrefetchRunning = 0;
  static const int _pageImgPrefetchConcurrency = 2;
  static const int _exportCacheBudgetBytes = 80 * 1024 * 1024;
  late final ByteLruCache<_ExportKey, Uint8List> _exportPngCache =
      ByteLruCache<_ExportKey, Uint8List>(maxBytes: _exportCacheBudgetBytes);

  // 중복 렌더 방지(in-flight)
  final Map<_ExportKey, Future<Uint8List>> _exportInFlight =
      <_ExportKey, Future<Uint8List>>{};

  // export 프리패치 큐 + 동시성 제한
  final List<_ExportKey> _exportPrefetchQueue = <_ExportKey>[];
  final Set<_ExportKey> _exportPrefetchQueued = <_ExportKey>{};
  int _exportPrefetchRunning = 0;
  static const int _exportPrefetchConcurrency = 2;

  bool _pauseExportPrefetch = false;

  void _clearExportPrefetchQueue() {
    _exportPrefetchQueue.clear();
    _exportPrefetchQueued.clear();
    _exportPrefetchRunning = 0;
  }

  void _clearExportCache() {
    _exportInFlight.clear();
    _exportPngCache.clear();
    _clearExportPrefetchQueue();
  }

  Future<Uint8List> _ensureExportPngBytes(
    int pageNumber, {
    required int targetLongSidePx,
  }) {
    final key = _ExportKey(pageNumber, targetLongSidePx);
    final cached = _exportPngCache.get(key);
    if (cached != null && cached.isNotEmpty) {
      return Future.value(cached);
    }

    final inflight = _exportInFlight[key];
    if (inflight != null) {
      return inflight;
    }

    final fut = () async {
      final Uint8List bytes;
      try {
        bytes = await _withPage(pageNumber, (page) {
          return _renderExportPngBytesFromPage(
            page,
            targetLongSidePx: targetLongSidePx,
          );
        });
      } catch (_) {
        return Uint8List(0);
      }
      if (bytes.isNotEmpty) {
        _exportPngCache.put(key, bytes, bytesWeight: bytes.lengthInBytes);
      }
      return bytes;
    }();

    _exportInFlight[key] = fut.whenComplete(() {
      _exportInFlight.remove(key);
    });

    return _exportInFlight[key]!;
  }

  void _enqueueExportPrefetch({
    required int center,
    required Iterable<int> pages,
    required int targetLongSidePx,
  }) {
    if (_pagesCount <= 0) return;

    final uniquePages =
        pages.map((p) => p.clamp(1, _pagesCount)).toSet().toList()
          ..sort((a, b) => (a - center).abs().compareTo((b - center).abs()));

    for (final pg in uniquePages) {
      final key = _ExportKey(pg, targetLongSidePx);
      if (_exportPngCache.containsKey(key)) continue;
      if (_exportInFlight.containsKey(key)) continue;
      if (_exportPrefetchQueued.contains(key)) continue;

      _exportPrefetchQueued.add(key);
      _exportPrefetchQueue.add(key);
    }
    _pumpExportPrefetch();
  }

  void _pumpExportPrefetch() {
    if (_pauseExportPrefetch) return;
    if (_exportPrefetchRunning >= _exportPrefetchConcurrency) return;

    while (_exportPrefetchRunning < _exportPrefetchConcurrency &&
        _exportPrefetchQueue.isNotEmpty) {
      final key = _exportPrefetchQueue.removeAt(0);
      _exportPrefetchQueued.remove(key);
      _exportPrefetchRunning++;

      _ensureExportPngBytes(
        key.page,
        targetLongSidePx: key.longSidePx,
      ).whenComplete(() {
        if (!mounted) return;
        _exportPrefetchRunning = math.max(0, _exportPrefetchRunning - 1);
        _pumpExportPrefetch();
      });
    }
  }

  void _enqueuePageImagePrefetchNear(int center, Iterable<int> pages) {
    if (_pagesCount <= 0) return;
    final unique =
        pages.map((p) => p.clamp(1, _pagesCount)).toSet().toList()
          ..sort((a, b) => (a - center).abs().compareTo((b - center).abs()));

    for (final pg in unique) {
      if (_pageImgCache.containsKey(pg)) continue;
      if (_pageImgInFlight.containsKey(pg)) continue;
      if (_pageImgPrefetchQueued.contains(pg)) continue;
      _pageImgPrefetchQueued.add(pg);
      _pageImgPrefetchQueue.add(pg);
    }
    _pumpPageImagePrefetch();
  }

  void _pumpPageImagePrefetch() {
    if (_pageImgPrefetchRunning >= _pageImgPrefetchConcurrency) return;
    while (_pageImgPrefetchRunning < _pageImgPrefetchConcurrency &&
        _pageImgPrefetchQueue.isNotEmpty) {
      final pg = _pageImgPrefetchQueue.removeAt(0);
      _pageImgPrefetchQueued.remove(pg);
      _pageImgPrefetchRunning++;

      _ensurePageImage(pg).whenComplete(() {
        if (!mounted) return;
        _pageImgPrefetchRunning = math.max(0, _pageImgPrefetchRunning - 1);
        _pumpPageImagePrefetch();
      });
    }
  }

  void _clearPageImagePrefetchQueue() {
    _pageImgPrefetchQueue.clear();
    _pageImgPrefetchQueued.clear();
    _pageImgPrefetchRunning = 0;
  }

  final List<int> _thumbPrefetchQueue = <int>[];
  final Set<int> _thumbPrefetchQueued = <int>{};
  int _thumbPrefetchRunning = 0;
  static const int _thumbPrefetchConcurrency = 2;

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
  }

  final Map<int, Future<Uint8List>> _thumbInFlight = <int, Future<Uint8List>>{};
  static const int _maxThumbCachePages = 32;
  late final LruCache<int, Uint8List> _thumbCacheLru = LruCache<int, Uint8List>(
    maxEntries: _maxThumbCachePages,
  );

  static const double _cardTopPadding = 70;
  static const double _controlBottom = 30;

  double _uiScale = 1.0;
  static const double _minUiScale = 1.0;
  static const double _maxUiScale = 4.0;
  static const double _stepUiScale = 0.15;

  int _loadingCount = 0;
  bool get _isLoading => _loadingCount > 0;

  GlassTheme get _glassTheme =>
      GlassTheme.fromFlags(reduceTransparency: widget.reduceTransparency);

  void _toast(String msg) {
    AppToast.show(context, msg);
  }

  String _shareDoneToast(ShareFormat f) {
    switch (f) {
      case ShareFormat.pdf:
        return 'PDF 공유 완료';
      case ShareFormat.png:
        return 'PNG 공유 완료';
      case ShareFormat.jpg:
        return 'JPG 공유 완료';
    }
  }

  String get _shareEmptyToast => '공유할 파일이 없습니다';
  String get _shareFailToast => '공유 실패';

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

    for (final p in _pendingDisposeImages) {
      try {
        p.image.dispose();
      } catch (_) {}
    }
    _pendingDisposeImages.clear();

    _disposeDocAndCache(disposeImages: true);
    _pageImgInFlight.clear();
    _clearPageImagePrefetchQueue();

    _thumbInFlight.clear();
    _thumbCacheLru.clear();
    _clearExportCache();

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
      _pageImgCache.clear(
        onEvict: (k, v, w) {
          _deferDisposeImage(k, v);
        },
      );
    }

    _pageImgInFlight.clear();

    _clearExportCache();
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
    final int mySession = ++_pdfSession;
    _incLoading();

    setState(() {
      _doc = null;
      _pagesCount = 1;
      _page = 1;
    });
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || mySession != _pdfSession) {
      _decLoading();
      return;
    }
    _pageImgCache.clear(
      onEvict: (k, v, w) {
        _deferDisposeImage(k, v);
      },
    );
    _pageImgInFlight.clear();
    _thumbCacheLru.clear();
    _thumbInFlight.clear();
    _clearExportCache();

    _clearThumbPrefetchQueue();
    _doc?.dispose();
    _doc = null;

    try {
      final doc = await PdfDocument.openData(bytes);
      if (!mounted || mySession != _pdfSession) {
        try {
          doc.dispose();
        } catch (_) {}
        return;
      }

      setState(() {
        _doc = doc;
        _pagesCount = doc.pageCount;
        _page = 1;
      });
      if (mySession != _pdfSession) return;
      _enqueueThumbPrefetchNear(1, [1, 2, 3, 4]);

      _jumpToFirstSafely();
      _resetZoom();
      _enqueuePageImagePrefetchNear(1, [1, 2, 3]);
    } catch (e) {
      if (!mounted || mySession != _pdfSession) return;
      _toast('PDF 열기 실패: $e');
    } finally {
      _decLoading();
    }
  }

  Future<ui.Image> _ensurePageImage(int pageNumber) {
    final cached = _pageImgCache.get(pageNumber);
    if (cached != null) return Future.value(cached);

    final inflight = _pageImgInFlight[pageNumber];
    if (inflight != null) return inflight;

    final fut = _renderPageImageRaw(pageNumber).whenComplete(() {
      _pageImgInFlight.remove(pageNumber);
    });
    _pageImgInFlight[pageNumber] = fut;
    return fut;
  }

  Future<ui.Image> _renderPageImageRaw(int pageNumber) async {
    final int mySession = _pdfSession;
    const scale = 3.0;

    try {
      if (mySession != _pdfSession) {
        final recorder = ui.PictureRecorder();
        return recorder.endRecording().toImage(1, 1);
      }

      final img = await _withPage(pageNumber, (page) async {
        if (mySession != _pdfSession) {
          final recorder = ui.PictureRecorder();
          return recorder.endRecording().toImage(1, 1);
        }

        final pageImage = await page.render(
          width: (page.width * scale).round(),
          height: (page.height * scale).round(),
          backgroundFill: true,
        );

        return await pageImage.createImageIfNotAvailable();
      });

      final weight = img.width * img.height * 4;
      _pageImgCache.put(
        pageNumber,
        img,
        bytesWeight: weight,
        onEvict: (k, v, w) {
          if (_isPinnedPage(k)) return;
          _deferDisposeImage(k, v);
        },
      );

      return img;
    } catch (_) {
      final recorder = ui.PictureRecorder();
      return recorder.endRecording().toImage(1, 1);
    }
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

  void _enqueueThumbPrefetchNear(int center, Iterable<int> pages) {
    if (_pagesCount <= 0) return;
    final unique =
        pages.map((p) => p.clamp(1, _pagesCount)).toSet().toList()
          ..sort((a, b) => (a - center).abs().compareTo((b - center).abs()));

    for (final pg in unique) {
      if (_thumbCacheLru.containsKey(pg)) continue;
      if (_thumbInFlight.containsKey(pg)) continue;
      if (_thumbPrefetchQueued.contains(pg)) continue;
      _thumbPrefetchQueued.add(pg);
      _thumbPrefetchQueue.add(pg);
    }
    _pumpThumbPrefetch();
  }

  void _pumpThumbPrefetch() {
    if (_thumbPrefetchRunning >= _thumbPrefetchConcurrency) return;
    while (_thumbPrefetchRunning < _thumbPrefetchConcurrency &&
        _thumbPrefetchQueue.isNotEmpty) {
      final pg = _thumbPrefetchQueue.removeAt(0);
      _thumbPrefetchQueued.remove(pg);
      _thumbPrefetchRunning++;

      _ensureThumbForPage(pg).whenComplete(() {
        if (!mounted) return;
        _thumbPrefetchRunning = math.max(0, _thumbPrefetchRunning - 1);
        _pumpThumbPrefetch();
      });
    }
  }

  void _clearThumbPrefetchQueue() {
    _thumbPrefetchQueue.clear();
    _thumbPrefetchQueued.clear();
    _thumbPrefetchRunning = 0;
  }

  Future<Uint8List> _ensureThumbForPage(int pageNumber) {
    final cached = _thumbCacheLru.get(pageNumber);
    if (cached != null) return Future.value(cached);
    final inflight = _thumbInFlight[pageNumber];
    if (inflight != null) return inflight;

    final fut = _renderThumbBytes(pageNumber).whenComplete(() {
      _thumbInFlight.remove(pageNumber);
    });
    _thumbInFlight[pageNumber] = fut;
    return fut;
  }

  Future<Uint8List> _renderThumbBytes(int pageNumber) async {
    final int mySession = _pdfSession;
    PdfPageImage? pageImage;
    ui.Image? imgObj;
    try {
      if (mySession != _pdfSession) return Uint8List(0);
      final bytes = await _withPage(pageNumber, (page) async {
        if (mySession != _pdfSession) return Uint8List(0);
        const targetW = 240;
        final scale = (targetW / page.width).clamp(0.2, 2.0);

        pageImage = await page.render(
          width: (page.width * scale).round(),
          height: (page.height * scale).round(),
          backgroundFill: true,
        );
        if (mySession != _pdfSession) return Uint8List(0);
        imgObj = await pageImage!.createImageIfNotAvailable();
        if (mySession != _pdfSession) return Uint8List(0);
        final bd = await imgObj!.toByteData(format: ui.ImageByteFormat.png);
        return bd?.buffer.asUint8List() ?? Uint8List(0);
      });
      if (mySession != _pdfSession) return Uint8List(0);

      if (bytes.isNotEmpty) {
        _thumbCacheLru.put(pageNumber, bytes);
      }
      return bytes;
    } catch (_) {
      return Uint8List(0);
    } finally {
      if (mySession == _pdfSession) {
        try {
          imgObj?.dispose();
        } catch (_) {}
        try {
          pageImage?.dispose();
        } catch (_) {}
      }
    }
  }

  Future<void> _openChapterPickerSameDesign() async {
    final picked = await showPdfChapterPickerDialog(
      context: context,
      chapters: widget.chapters,
      glassTheme: _glassTheme,
      barrierColor: const Color(0xFF0F2238).withValues(alpha: 0.21),
    );

    if (picked == null) return;

    final targetChapters =
        picked.useAll
            ? widget.chapters
            : picked.selected
                .map((i) => widget.chapters[i])
                .toList(growable: false);

    await _rebuildPreviewPdf(targetChapters);
  }

  Future<void> _rebuildPreviewPdf(List<ChapterItem> chapters) async {
    if (chapters.isEmpty) {
      _toast('선택된 회차가 없습니다');
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
      _toast('PDF 생성 실패: $e');
    } finally {
      _decLoading();
    }
  }

  String _safeFileName(String name) {
    final trimmed = name.trim().isEmpty ? 'document' : name.trim();
    final sanitized = trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return sanitized.length > 80 ? sanitized.substring(0, 80) : sanitized;
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

  Future<File?> _renderExportImageToTempFileFromPage({
    required PdfPage page,
    required int pageNumber,
    required int targetLongSidePx,
    required String baseName,
    bool asJpg = true,
    int jpgQuality = 90,
  }) async {
    final pngBytes = await _renderExportPngBytesFromPage(
      page,
      targetLongSidePx: targetLongSidePx,
    );
    if (pngBytes.isEmpty) return null;

    final bytes =
        asJpg
            ? await _pngToJpgInIsolate(pngBytes, quality: jpgQuality)
            : pngBytes;
    if (bytes.isEmpty) return null;

    final dir = await getTemporaryDirectory();
    final ext = asJpg ? 'jpg' : 'png';
    final seq = pageNumber.toString().padLeft(3, '0');

    final nonce = DateTime.now().microsecondsSinceEpoch.toString();
    final file = File(p.join(dir.path, 'share_${baseName}_${seq}_$nonce.$ext'));

    await file.writeAsBytes(bytes, flush: false);
    return file;
  }

  Future<File?> _renderExportImageToTempFile({
    required int pageNumber,
    required int targetLongSidePx,
    required String baseName,
    bool useCache = true,
    bool asJpg = true,
    int jpgQuality = 90,
  }) async {
    if (useCache) {
      final pngBytes = await _ensureExportPngBytes(
        pageNumber,
        targetLongSidePx: targetLongSidePx,
      );

      debugPrint('[share] page=$pageNumber pngBytes=${pngBytes.length}');

      if (pngBytes.isEmpty) return null;

      final bytes =
          asJpg
              ? await _pngToJpgInIsolate(pngBytes, quality: jpgQuality)
              : pngBytes;

      debugPrint(
        '[share] page=$pageNumber outBytes=${bytes.length} asJpg=$asJpg',
      );

      if (bytes.isEmpty) return null;

      final dir = await getTemporaryDirectory();
      final ext = asJpg ? 'jpg' : 'png';
      final seq = pageNumber.toString().padLeft(3, '0');
      final nonce = DateTime.now().microsecondsSinceEpoch.toString();

      final file = File(
        p.join(dir.path, 'share_${baseName}_${seq}_$nonce.$ext'),
      );
      await file.writeAsBytes(bytes, flush: false);

      final exists = await file.exists();
      final size = exists ? await file.length() : -1;
      debugPrint('[share] wrote=${file.path} exists=$exists size=$size');

      if (!exists || size <= 0) return null;

      return file;
    }

    return _withPage(pageNumber, (page) {
      return _renderExportImageToTempFileFromPage(
        page: page,
        pageNumber: pageNumber,
        targetLongSidePx: targetLongSidePx,
        baseName: baseName,
        asJpg: asJpg,
        jpgQuality: jpgQuality,
      );
    });
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

    await Future.wait(List.generate(math.max(1, concurrency), (_) => worker()));
    return results;
  }

  Future<Uint8List> _buildPdfFromRenderedPagesFileSpool(List<int> pages) async {
    const double maxLongSidePt = 842.0;
    final out = pw.Document();

    final base = _safeFileName(widget.title);
    final tempFiles = <File>[];
    final pageFormats = <int, pdf.PdfPageFormat>{};

    try {
      final tasks = <Future<File?> Function()>[];
      for (final pg in pages) {
        tasks.add(() async {
          return _withPage(pg, (page) async {
            final w = page.width.toDouble();
            final h = page.height.toDouble();
            final portrait = h >= w;
            final aspect = (h == 0) ? 1.0 : (w / h);

            const longSide = maxLongSidePt;
            final shortSide = longSide * (portrait ? aspect : (1.0 / aspect));
            final pageW = portrait ? shortSide : longSide;
            final pageH = portrait ? longSide : shortSide;
            pageFormats[pg] = pdf.PdfPageFormat(pageW, pageH);

            return _renderExportImageToTempFileFromPage(
              page: page,
              pageNumber: pg,
              targetLongSidePx: 2600,
              baseName: base,
              asJpg: true,
              jpgQuality: 83,
            );
          });
        });
      }

      final files = await _runWithConcurrencyNullable<File>(
        tasks: tasks,
        concurrency: 3,
      );

      for (int i = 0; i < pages.length; i++) {
        final pg = pages[i];
        final f = files[i];
        if (f == null) continue;
        tempFiles.add(f);

        final pf = pageFormats[pg];
        if (pf == null) continue;

        out.addPage(
          pw.Page(
            pageFormat: pf,
            margin: pw.EdgeInsets.zero,
            build:
                (_) => pw.FullPage(
                  ignoreMargins: true,
                  child: pw.FittedBox(
                    fit: pw.BoxFit.contain,
                    child: pw.Image(_FileBackedImage(f)),
                  ),
                ),
          ),
        );
      }

      return out.save();
    } finally {
      for (final f in tempFiles) {
        try {
          if (await f.exists()) {
            await f.delete();
          }
        } catch (_) {}
      }
    }
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

  Future<List<XFile>> _buildImageXFilesForPages({
    required List<int> pages,
    required ShareFormat format,
    required String baseName,
  }) async {
    Future<List<T>> runWithConcurrency<T>({
      required List<Future<T?> Function()> tasks,
      int concurrency = 2,
    }) async {
      if (tasks.isEmpty) return <T>[];

      final results = List<T?>.filled(tasks.length, null);
      var nextIndex = 0;

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

      return results.whereType<T>().toList();
    }

    final tasks = <Future<XFile?> Function()>[];
    for (final pg in pages) {
      tasks.add(() async {
        const targetLongSidePx = 2600;

        final file = await _renderExportImageToTempFile(
          pageNumber: pg,
          targetLongSidePx: targetLongSidePx,
          baseName: baseName,
          useCache: true,
          asJpg: format == ShareFormat.jpg,
          jpgQuality: 92,
        );
        if (file == null) return null;

        final isPng = format == ShareFormat.png;
        return XFile(
          file.path,
          mimeType: isPng ? 'image/png' : 'image/jpeg',
          name: p.basename(file.path),
        );
      });
    }

    final concurrency = (format == ShareFormat.jpg) ? 2 : 3;

    return runWithConcurrency<XFile>(tasks: tasks, concurrency: concurrency);
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
      _toast('앱에 저장 완료: ${p.basename(file.path)}');
    } catch (e) {
      if (!mounted) return;
      _toast('저장 실패: $e');
    } finally {
      _decLoading();
    }
  }

  Future<void> _onShareTap() async {
    if (_isLoading) return;

    final pick = await showShareOptionsDialog(
      context: context,
      currentPage: _page,
      pagesCount: _pagesCount,
      dialogTitle: '공유',
      confirmLabel: '공유',
    );
    if (pick == null) return;
    if (!mounted) return;

    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box == null ? null : (box.localToGlobal(Offset.zero) & box.size);

    final pages = <int>[for (int i = pick.startPage; i <= pick.endPage; i++) i];
    final base = _safeFileName(widget.title);
    final doneToast = _shareDoneToast(pick.format);
    final int exportLongSidePx = (pick.format == ShareFormat.pdf) ? 3400 : 2600;
    _enqueueExportPrefetch(
      center: pick.startPage,
      pages: [
        pick.startPage,
        pick.startPage + 1,
        pick.startPage + 2,
        pick.startPage + 3,
      ],
      targetLongSidePx: exportLongSidePx,
    );

    _incLoading();

    _pauseExportPrefetch = true;

    try {
      // ===== PDF =====
      if (pick.format == ShareFormat.pdf) {
        if (pick.rangeMode == ShareRangeMode.all) {
          final file = await _writePdfToTempFile(fileNameBase: widget.title);
          if (!mounted) return;
          await _shareXFiles(
            files: [
              XFile(
                file.path,
                mimeType: 'application/pdf',
                name: p.basename(file.path),
              ),
            ],
            text: widget.title,
            sharePositionOrigin: origin,
          );
          if (!mounted) return;
          _toast(doneToast);
          return;
        }

        final pdfBytes = await _buildPdfFromRenderedPagesFileSpool(pages);
        if (pdfBytes.isEmpty) {
          if (!mounted) return;
          _toast(_shareEmptyToast);
          return;
        }
        final file = await _writeBytesToTemp(
          bytes: pdfBytes,
          fileName: '$base.pdf',
        );
        if (!mounted) return;
        await _shareXFiles(
          files: [
            XFile(
              file.path,
              mimeType: 'application/pdf',
              name: p.basename(file.path),
            ),
          ],
          text: widget.title,
          sharePositionOrigin: origin,
        );
        if (!mounted) return;
        _toast(doneToast);
        return;
      }

      // ===== PNG/JPG =====
      final files = await _buildImageXFilesForPages(
        pages: pages,
        format: pick.format,
        baseName: base,
      );
      if (!mounted) return;
      if (files.isEmpty) {
        _toast(_shareEmptyToast);
        return;
      }
      await _shareXFiles(
        files: files,
        text: widget.title,
        sharePositionOrigin: origin,
      );
      if (!mounted) return;
      _toast(doneToast);

      for (final xf in files) {
        try {
          await File(xf.path).delete();
        } catch (_) {}
      }
    } catch (_) {
      if (!mounted) return;
      _toast(_shareFailToast);
    } finally {
      _pauseExportPrefetch = false;
      _pumpExportPrefetch();

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

  Widget _pageSliderBar() {
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

    final int previewPage = _sliderValueToPage(currentDouble);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
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

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 30,
                      child: Row(
                        children: [
                          const SizedBox(width: sidePad),
                          SizedBox(
                            width: usableW,
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
                                  final pg = _sliderValueToPage(v);
                                  setState(() {
                                    _sliderDragValue = v;
                                    _page = pg;
                                  });
                                  _enqueueThumbPrefetchNear(pg, [
                                    pg - 1,
                                    pg,
                                    pg + 1,
                                    pg + 2,
                                  ]);
                                  _enqueuePageImagePrefetchNear(pg, [
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

                  if (_isSliderDragging && _pagesCount > 0)
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
            physics:
                _isSliderDragging
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
            itemCount: _pagesCount,
            onPageChanged: (index) {
              _resetZoom();
              final newPage = index + 1;
              setState(() => _page = newPage);

              _enqueueThumbPrefetchNear(newPage, [
                newPage - 1,
                newPage,
                newPage + 1,
                newPage + 2,
              ]);
            },
            itemBuilder: (context, index) {
              final doc = _doc;
              if (doc == null) return const SizedBox.shrink();

              final pageNumber = index + 1;

              return _PageLife(
                pageNumber: pageNumber,
                onAttach: () => _retainPageImage(pageNumber),
                onDetach: () => _releasePageImage(pageNumber),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxCardWidth = constraints.maxWidth * 0.95;
                    final maxCardHeight = constraints.maxHeight * 0.90;

                    return Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: _cardTopPadding),
                        child: FutureBuilder<ui.Image>(
                          future: _ensurePageImage(pageNumber),
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
                ),
              );
            },
          ),

          // ===== 카드 위 아이콘: 좌/우 =====

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
                    Icons.download_outlined,
                    color: _topIconColor,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 2),
                IconButton(
                  onPressed:
                      (_isLoading || _isSliderDragging) ? null : _onShareTap,
                  icon: const Icon(
                    Icons.ios_share,
                    color: _topIconColor,
                    size: 23,
                  ),
                ),
              ],
            ),
          ),

          // ===== 슬라이더 바(하단 pill 바 바로 위) =====
          Positioned(
            left: 0,
            right: 0,
            bottom: _controlBottom + 60,
            child: IgnorePointer(
              ignoring: _isLoading || _doc == null || _pagesCount <= 1,
              child: Opacity(
                opacity:
                    (_isLoading || _doc == null || _pagesCount <= 1)
                        ? 0.35
                        : 1.0,
                child: _pageSliderBar(),
              ),
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
