// edit_episodes_page.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ebook_tutorial_app/models/genre.dart';
import 'package:ebook_tutorial_app/controllers/writing_settings_controller.dart';
import 'package:ebook_tutorial_app/pages/book_builder_page.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class EditEpisodesPage extends StatefulWidget {
  const EditEpisodesPage({
    super.key,
    required this.genre,
    required this.genreBooks,
  });

  final Genre genre;
  final List<Map<String, dynamic>> genreBooks;

  @override
  State<EditEpisodesPage> createState() => _EditEpisodesPageState();
}

class GenreEpisodeItem {
  final String bookId;
  final String bookTitle;

  final String chapterTitle;
  final int chapterIndex;

  final String? coverPath;
  final String? bookCoverPath;
  final int? sizeBytes;
  final int? charCount;
  final DateTime? updatedAt;
  final bool pinned;

  final List<Map<String, dynamic>> delta;

  GenreEpisodeItem({
    required this.bookId,
    required this.bookTitle,
    required this.chapterTitle,
    required this.chapterIndex,
    required this.updatedAt,
    required this.delta,
    this.coverPath,
    this.bookCoverPath,
    this.sizeBytes,
    this.charCount,
    this.pinned = false,
  });
}

class _EditEpisodesPageState extends State<EditEpisodesPage> {
  final List<GenreEpisodeItem> _items = [];
  bool _groupByBook = false;

  Map<String, List<GenreEpisodeItem>> _groupItemsByBook() {
    final map = <String, List<GenreEpisodeItem>>{};

    for (final item in _items) {
      map.putIfAbsent(item.bookId, () => <GenreEpisodeItem>[]).add(item);
    }
    for (final entry in map.entries) {
      entry.value.sort((a, b) {
        final at = a.updatedAt?.millisecondsSinceEpoch ?? 0;
        final bt = b.updatedAt?.millisecondsSinceEpoch ?? 0;
        return bt.compareTo(at);
      });
    }

    return map;
  }

  Widget _bookToggleBar() {
    const iconColor = Color.fromARGB(255, 117, 148, 188);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => setState(() => _groupByBook = !_groupByBook),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories, color: iconColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _groupByBook ? 'all' : 'selected',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(221, 83, 129, 159),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _resolveLocalCoverPath(
    String? rawPath,
    Directory appDir,
  ) async {
    final raw = rawPath?.trim();
    if (raw == null || raw.isEmpty) return null;

    if (raw.startsWith('file://')) {
      final uri = Uri.tryParse(raw);
      if (uri != null && uri.isScheme('file')) {
        final filePath = uri.toFilePath();
        if (await File(filePath).exists()) return filePath;
      }
    }

    final direct = File(raw);
    if (await direct.exists()) return direct.path;

    if (!p.isAbsolute(raw)) {
      final fromDocuments = File(p.join(appDir.path, raw));
      if (await fromDocuments.exists()) return fromDocuments.path;
    }

    return null;
  }

  Widget _groupedListView() {
    final grouped = _groupItemsByBook();
    final bookIds =
        grouped.keys.toList()..sort((a, b) {
          final at = grouped[a]?.first.updatedAt?.millisecondsSinceEpoch ?? 0;
          final bt = grouped[b]?.first.updatedAt?.millisecondsSinceEpoch ?? 0;
          return bt.compareTo(at);
        });

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: bookIds.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final bookId = bookIds[i];
        final list = grouped[bookId] ?? const <GenreEpisodeItem>[];
        if (list.isEmpty) return const SizedBox.shrink();

        final bookTitle = list.first.bookTitle;
        final bookCover = list.first.bookCoverPath;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withValues(alpha: 0.92),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 10),
              childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              leading: _miniCover(chapterCover: null, bookCover: bookCover),
              title: Text(
                bookTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                '${list.length}개 회차',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(221, 83, 129, 159),
                ),
              ),
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, idx) => _episodeCard(list[idx]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    unawaited(_reload());
  }

  Future<void> _reload() async {
    final loaded = await _loadMergedChapters();
    if (!mounted) return;
    setState(() {
      _items
        ..clear()
        ..addAll(loaded);
    });
  }

  Future<List<GenreEpisodeItem>> _loadMergedChapters() async {
    final prefs = await SharedPreferences.getInstance();
    final appDir = await getApplicationDocumentsDirectory();
    final merged = <GenreEpisodeItem>[];

    for (final b in widget.genreBooks) {
      final bookId = (b['documentId'] as String?) ?? '';
      if (bookId.isEmpty) continue;
      final bookTitle = (b['title'] as String?) ?? '(제목 없음)';

      final bookCoverRaw =
          (prefs.getString('book_cover_$bookId') ??
                  b['coverPath'] as String? ??
                  b['cover'] as String? ??
                  b['imagePath'] as String?)
              ?.trim();

      final bookCoverPath = await _resolveLocalCoverPath(bookCoverRaw, appDir);
      final raw = prefs.getString('book_chapters_$bookId');
      if (raw == null || raw.isEmpty) continue;

      final decoded = jsonDecode(raw);
      if (decoded is! List) continue;

      for (final e in decoded) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        final coverRaw =
            ((m['cover'] as String?) ??
                    (m['coverPath'] as String?) ??
                    (m['imagePath'] as String?) ??
                    (m['coverImagePath'] as String?))
                ?.trim();

        final coverPath = await _resolveLocalCoverPath(coverRaw, appDir);

        final chapterTitle = (m['title'] as String?) ?? '';
        final chapterIndex = (m['index'] as num?)?.toInt() ?? 0;

        final updatedStr = m['updatedAt'] as String?;
        final updatedAt =
            (updatedStr != null && updatedStr.isNotEmpty)
                ? DateTime.tryParse(updatedStr)
                : null;

        final deltaRaw = m['delta'];
        final delta =
            (deltaRaw is List)
                ? deltaRaw
                    .map((x) => Map<String, dynamic>.from(x as Map))
                    .toList()
                : <Map<String, dynamic>>[];

        final sizeBytes = (m['sizeBytes'] as num?)?.toInt();
        final charCount = (m['charCount'] as num?)?.toInt();
        final pinned = (m['pinned'] as bool?) ?? false;

        merged.add(
          GenreEpisodeItem(
            bookId: bookId,
            bookTitle: bookTitle,
            chapterTitle: chapterTitle,
            chapterIndex: chapterIndex,
            updatedAt: updatedAt,
            delta: delta,
            coverPath: coverPath,
            bookCoverPath: bookCoverPath,
            sizeBytes: sizeBytes,
            charCount: charCount,
            pinned: pinned,
          ),
        );
      }
    }

    merged.sort((a, b) {
      final at = a.updatedAt?.millisecondsSinceEpoch ?? 0;
      final bt = b.updatedAt?.millisecondsSinceEpoch ?? 0;
      return bt.compareTo(at);
    });

    return merged;
  }

  String _formatBytes(int? bytes) {
    if (bytes == null || bytes <= 0) return '0B';
    const kb = 1024;
    const mb = 1024 * 1024;
    if (bytes < kb) return '${bytes}B';
    if (bytes < mb) return '${(bytes / kb).toStringAsFixed(1)}KB';
    return '${(bytes / mb).toStringAsFixed(1)}MB';
  }

  String _formatYMD(DateTime? dt) {
    if (dt == null) return '—';
    final l = dt.toLocal();
    return '${l.year}.${l.month.toString().padLeft(2, '0')}.${l.day.toString().padLeft(2, '0')}.';
  }

  Widget _miniCover({String? chapterCover, String? bookCover}) {
    final path =
        (chapterCover != null && chapterCover.isNotEmpty)
            ? chapterCover
            : (bookCover != null && bookCover.isNotEmpty)
            ? bookCover
            : null;

    final hasImage = path != null && File(path).existsSync();
    const w = 79.0;
    const h = w * 1.5;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color:
            hasImage
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.04),
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
              ? Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const Center(
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
              )
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

  Widget _episodeCard(GenreEpisodeItem item) {
    const subColor = Color.fromARGB(221, 83, 129, 159);

    final metaText =
        '${_formatBytes(item.sizeBytes)} · ${item.charCount ?? 0}자 · ${_formatYMD(item.updatedAt)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openBookAndChapter(item),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withValues(alpha: 0.92),
          ),
          padding: const EdgeInsets.fromLTRB(1, 6, 10, 1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _miniCover(
                chapterCover: item.coverPath,
                bookCover: item.bookCoverPath,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        if (item.pinned)
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
                            item.chapterTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w400,
                              color:
                                  item.pinned
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
                      metaText,
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
              const Icon(
                Icons.chevron_right,
                color: Color.fromARGB(255, 117, 148, 188),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openBookAndChapter(GenreEpisodeItem item) async {
    final book = widget.genreBooks.firstWhere(
      (b) => (b['documentId'] as String?) == item.bookId,
      orElse: () => const <String, dynamic>{},
    );
    if (book.isEmpty) return;

    final String docId = item.bookId;

    await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider(
              create:
                  (_) => WritingSettingsController(documentId: docId)..load(),
              child: BookBuilderPage(
                genre: widget.genre,
                initialTitle: (book['title'] as String?) ?? '제목을 입력하세요',
                initialDeltaJson:
                    ((book['delta'] as List?)?.cast<Map<String, dynamic>>()) ??
                    const [],
                initialDrawingJson:
                    ((book['drawings'] as List?)
                        ?.cast<Map<String, dynamic>>()) ??
                    const [],
                pageIndex: 0,
                initialPenName: (book['penName'] as String?) ?? '',
                documentId: docId,
                initialOpenChapterIndex: item.chapterIndex,
              ),
            ),
      ),
    );

    if (!mounted) return;
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('episodes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          tooltip: '뒤로가기',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _items.isEmpty
              ? const Center(child: Text('저장된 회차가 없습니다.'))
              : Column(
                children: [
                  _bookToggleBar(),
                  Expanded(
                    child:
                        _groupByBook
                            ? _groupedListView()
                            : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: _items.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 10),
                              itemBuilder: (_, i) => _episodeCard(_items[i]),
                            ),
                  ),
                ],
              ),
    );
  }
}
