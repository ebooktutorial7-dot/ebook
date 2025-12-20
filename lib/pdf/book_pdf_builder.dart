// lib/pdf/book_pdf_builder.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle, NetworkAssetBundle;
import 'package:pdf/widgets.dart' as pw;

import 'package:ebook_tutorial_app/pages/book_builder_page.dart'
    show ChapterItem;

Future<Uint8List> buildBookPdf({
  required List<ChapterItem> chapters,
  bool showChapterTitle = true,
}) async {
  // ✅ Regular / Bold 둘 다 로드해야 제목(bold) 한글이 안 깨집니다.
  final fontKr = pw.Font.ttf(
    await rootBundle.load('lib/assets/fonts/NotoSansKR-Regular.ttf'),
  );
  final fontKrBold = pw.Font.ttf(
    await rootBundle.load('lib/assets/fonts/NotoSansKR-Bold.ttf'),
  );

  final fontJp = pw.Font.ttf(
    await rootBundle.load('lib/assets/fonts/NotoSansJP-Regular.ttf'),
  );
  final fontJpBold = pw.Font.ttf(
    await rootBundle.load('lib/assets/fonts/NotoSansJP-Bold.ttf'),
  );

  final doc = pw.Document();

  // ✅ MultiPage build는 sync라서, 이미지 로드는 미리 async로 다 해둡니다.
  final widgets = <pw.Widget>[];

  for (final chapter in chapters) {
    final title = chapter.title.trim();

    // 회차 제목
    if (showChapterTitle && title.isNotEmpty) {
      widgets.add(
        pw.Text(
          title,
          style: pw.TextStyle(
            font: fontKrBold,
            fontSize: 16,
            height: 1.3,
            fontFallback: [fontJpBold],
          ),
        ),
      );
      widgets.add(pw.SizedBox(height: 12));
    }

    // 회차 본문(텍스트 + 이미지)
    final bodyWidgets = await _deltaToPdfWidgets(
      delta: chapter.delta,
      fontKr: fontKr,
      fontJp: fontJp,
    );

    if (bodyWidgets.isEmpty) {
      widgets.add(
        pw.Text(
          '(내용 없음)',
          style: pw.TextStyle(font: fontKr, fontFallback: [fontJp]),
        ),
      );
    } else {
      widgets.addAll(bodyWidgets);
    }

    widgets.add(pw.SizedBox(height: 28));
  }

  doc.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      theme: pw.ThemeData.withFont(base: fontKr, bold: fontKrBold),
      build:
          (_) =>
              widgets.isEmpty
                  ? [
                    pw.Text(
                      '(내용 없음)',
                      style: pw.TextStyle(font: fontKr, fontFallback: [fontJp]),
                    ),
                  ]
                  : widgets,
    ),
  );

  return doc.save();
}

/// Quill delta → PDF 위젯(텍스트 + 이미지)
Future<List<pw.Widget>> _deltaToPdfWidgets({
  required List<Map<String, dynamic>> delta,
  required pw.Font fontKr,
  required pw.Font fontJp,
}) async {
  final out = <pw.Widget>[];
  final textBuf = StringBuffer();

  Future<void> flushText() async {
    final text = textBuf.toString().trimRight();
    textBuf.clear();

    if (text.isEmpty) return;

    out.add(
      pw.Paragraph(
        text: text,
        style: pw.TextStyle(
          font: fontKr,
          fontSize: 12,
          height: 1.6,
          fontFallback: [fontJp],
        ),
      ),
    );
  }

  for (final op in delta) {
    final insert = op['insert'];

    // 1) 일반 텍스트
    if (insert is String) {
      textBuf.write(insert);
      continue;
    }

    // 2) 임베드(이미지 등)
    if (insert is Map) {
      // flutter_quill의 이미지 insert는 보통 {'image': '...'} 형태
      if (insert.containsKey('image')) {
        await flushText();

        final dynamic raw = insert['image'];
        final String? source = _normalizeImageSource(raw);
        if (source == null || source.isEmpty) continue;

        final bytes = await _loadImageBytes(source);
        if (bytes == null || bytes.isEmpty) continue;

        // 이미지가 너무 커서 페이지 깨지는 문제 예방: 폭 제한 + 가운데 정렬
        out.add(
          pw.Center(
            child: pw.Container(
              constraints: const pw.BoxConstraints(maxWidth: 420),
              child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
            ),
          ),
        );
        out.add(pw.SizedBox(height: 12));
      }

      // 필요하면 hr 같은 다른 embed도 여기서 처리 가능
    }
  }

  await flushText();
  return out;
}

/// quill image data가 String일 수도, Map일 수도 있어서 정규화
String? _normalizeImageSource(dynamic raw) {
  if (raw is String) return raw;
  if (raw is Map && raw['source'] is String) return raw['source'] as String;
  return null;
}

/// 로컬 파일 / 네트워크 URL 둘 다 bytes 로드
Future<Uint8List?> _loadImageBytes(String source) async {
  try {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      final uri = Uri.parse(source);
      final bd = await NetworkAssetBundle(uri).load(uri.toString());
      return bd.buffer.asUint8List();
    } else {
      final f = File(source);
      if (!f.existsSync()) return null;
      return await f.readAsBytes();
    }
  } catch (_) {
    return null;
  }
}
