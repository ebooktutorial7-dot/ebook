// ebook_list_page.dart

import 'dart:math';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calendar_page.dart';

import 'package:ebook_tutorial_app/controllers/ebook_list_controller.dart';
import 'package:ebook_tutorial_app/controllers/writing_settings_controller.dart';
import 'package:ebook_tutorial_app/services/ebook_service.dart';
import 'package:ebook_tutorial_app/widgets/common/app_toast.dart';
import 'package:ebook_tutorial_app/models/genre.dart';
import 'package:ebook_tutorial_app/dialogs/dialogs.dart';
import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/utils/delta_utils.dart';
import 'package:ebook_tutorial_app/utils/platform_accessibility.dart';
import 'package:ebook_tutorial_app/widgets/card_design.dart';
import 'settings_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'all_books_page.dart';
import 'book_builder_page.dart';
import 'edit_episodes_page.dart';
import 'simple_memo_page.dart';

class EbookListPage extends StatefulWidget {
  const EbookListPage({super.key});

  @override
  State<EbookListPage> createState() => _EbookListPageState();
}

class EpisodePreview {
  final String bookId;
  final String bookTitle;
  final int chapterIndex;
  final String chapterTitle;
  final DateTime? updatedAt;
  final int? sizeBytes;
  final int? charCount;
  final String? coverPath;
  final String? bookCoverPath;
  final bool pinned;

  EpisodePreview({
    required this.bookId,
    required this.bookTitle,
    required this.chapterIndex,
    required this.chapterTitle,
    required this.updatedAt,
    this.sizeBytes,
    this.charCount,
    this.coverPath,
    this.bookCoverPath,
    this.pinned = false,
  });
}

class _EbookListPageState extends State<EbookListPage>
    with SingleTickerProviderStateMixin {
  late final EbookListController controller;
  final DateTime _selectedDate = DateTime.now();
  bool _reduceTransparencyFlag = false;

  Future<_CalendarOnlyPreviewData>? _calendarPreviewFuture;

  Future<void> _openBookAtChapter(EpisodePreview p) async {
    final book = controller.ebooks.firstWhere(
      (b) => (b['documentId'] as String?) == p.bookId,
      orElse: () => const <String, dynamic>{},
    );
    if (book.isEmpty) return;

    final genreName = book['genre'] as String?;
    final g = Genre.values.firstWhere(
      (e) => e.name == genreName,
      orElse: () => Genre.webNovel,
    );

    await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider(
              create:
                  (_) =>
                      WritingSettingsController(documentId: p.bookId)..load(),
              child: BookBuilderPage(
                genre: g,
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
                documentId: p.bookId,
                initialOpenChapterIndex: p.chapterIndex,
              ),
            ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  String _episodeTitleLine({
    required String bookTitle,
    required String chapterTitle,
  }) {
    final bt = bookTitle.trim();
    final ct = chapterTitle.trim();

    if (ct.isEmpty) return bt;
    if (bt.isEmpty) return ct;

    if (bt == ct) return bt;
    if (ct.contains(bt)) return ct;

    return '$bt · $ct';
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

  Widget _buildLatestEpisodePreview() {
    return FutureBuilder<EpisodePreview?>(
      future: _loadLatestEpisodePreview(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data == null) return const SizedBox.shrink();
        final p = snap.data!;

        const subColor = Color.fromARGB(221, 83, 129, 159);

        final metaText =
            '${_formatBytes(p.sizeBytes)} · ${p.charCount ?? 0}자 · ${_formatYMD(p.updatedAt)}';

        final titleLine = _episodeTitleLine(
          bookTitle: p.bookTitle,
          chapterTitle: p.chapterTitle,
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openBookAtChapter(p),
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
                      chapterCover: p.coverPath,
                      bookCover: p.bookCoverPath,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '최신 회차',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(221, 109, 173, 215),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (p.pinned)
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
                                  titleLine,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        p.pinned
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<EpisodePreview?> _loadLatestEpisodePreview() async {
    final prefs = await SharedPreferences.getInstance();
    final books = _filteredEbooks();

    EpisodePreview? best;

    for (final b in books) {
      final bookId = (b['documentId'] as String?) ?? '';
      if (bookId.isEmpty) continue;

      final bookCoverPath = prefs.getString('book_cover_$bookId')?.trim();

      final raw = prefs.getString('book_chapters_$bookId');
      if (raw == null || raw.isEmpty) continue;

      final decoded = jsonDecode(raw);
      if (decoded is! List) continue;

      for (final e in decoded) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);

        final updatedStr = m['updatedAt'] as String?;
        final updatedAt =
            (updatedStr != null && updatedStr.isNotEmpty)
                ? DateTime.tryParse(updatedStr)
                : null;

        final chapterIndex = (m['index'] as num?)?.toInt() ?? 0;
        final chapterTitle = (m['title'] as String?) ?? '';

        final sizeBytes = (m['sizeBytes'] as num?)?.toInt();
        final charCount = (m['charCount'] as num?)?.toInt();

        final coverPath =
            ((m['cover'] as String?) ?? (m['coverPath'] as String?))?.trim();

        final pinned = (m['pinned'] as bool?) ?? false;

        final candidate = EpisodePreview(
          bookId: bookId,
          bookTitle: (b['title'] as String?) ?? '(제목 없음)',
          chapterIndex: chapterIndex,
          chapterTitle: chapterTitle,
          updatedAt: updatedAt,
          sizeBytes: sizeBytes,
          charCount: charCount,
          coverPath: coverPath,
          bookCoverPath: bookCoverPath,
          pinned: pinned,
        );

        if (best == null) {
          best = candidate;
        } else {
          final current = best;

          if (candidate.pinned && !current.pinned) {
            best = candidate;
          } else if (candidate.pinned == current.pinned) {
            final bt = current.updatedAt?.millisecondsSinceEpoch ?? 0;
            final ct = candidate.updatedAt?.millisecondsSinceEpoch ?? 0;
            if (ct > bt) best = candidate;
          }
        }
      }
    }

    return best;
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

  static const double _shelfHeight =
      A4MiniCard.genreBadgeTopSpace +
      A4MiniCard.a4Height +
      A4MiniCard.captionGap +
      A4MiniCard.captionHeight;
  static const double _memoSquare = 110;

  TabController? _genreController;
  int _genreIndex = 0;

  static const List<Genre> _genreTabs = [
    Genre.main,
    Genre.webNovel,
    Genre.novel,
    Genre.poem,
    Genre.freeForm,
    Genre.selfHelp,
    Genre.science,
  ];

  bool get _isMainTab => _genreTabs[_genreIndex] == Genre.main;

  Future<_CalendarOnlyPreviewData> _loadCalendarOnlyPreview() async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final rawEvents = prefs.getString('calendar_range_events_common');
    final events = <RangeEvent>[];

    if (rawEvents != null && rawEvents.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawEvents);
        if (decoded is List) {
          for (final e in decoded) {
            if (e is Map) {
              events.add(RangeEvent.fromMap(Map<String, dynamic>.from(e)));
            }
          }
        }
      } catch (_) {}
    }

    final todayKey =
        '${today.year.toString().padLeft(4, '0')}'
        '${today.month.toString().padLeft(2, '0')}'
        '${today.day.toString().padLeft(2, '0')}';

    DayLog todayLog = DayLog.empty();

    final rawDay = prefs.getString('calendar_day_$todayKey');
    if (rawDay != null && rawDay.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawDay);
        todayLog = DayLog.fromMap(Map<String, dynamic>.from(decoded));
      } catch (_) {}
    }

    int todayEventCount = 0;
    for (final ev in events) {
      if (ev.includes(today)) {
        todayEventCount += 1;
      }
    }

    return _CalendarOnlyPreviewData(
      selectedDate: today,
      displayedMonth: DateTime(today.year, today.month, 1),
      events: events,
      todayLog: todayLog,
      todayEventCount: todayEventCount,
    );
  }

  void _reloadCalendarPreview() {
    if (!_isMainTab) {
      _calendarPreviewFuture = null;
      return;
    }
    _calendarPreviewFuture = _loadCalendarOnlyPreview();
  }

  Widget _buildGenreTabBar() {
    final theme = Theme.of(context);
    final tc = _genreController;
    if (tc == null) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TabBar(
          controller: tc,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          indicator: const BoxDecoration(),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
          labelColor: theme.colorScheme.onSurface,
          unselectedLabelColor: const Color.fromARGB(255, 145, 187, 230),
          tabs: _genreTabs.map((g) => Tab(text: genreLabel(g))).toList(),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filteredEbooks() {
    final selected = _genreTabs[_genreIndex];

    final books =
        (selected == Genre.main)
            ? [...controller.ebooks]
            : controller.ebooks.where((b) {
              final name = b['genre'] as String?;
              final g = Genre.values.firstWhere(
                (e) => e.name == name,
                orElse: () => Genre.webNovel,
              );
              return g == selected;
            }).toList();

    DateTime parseUpdatedAt(Map<String, dynamic> book) {
      final raw = book['updatedAt'];
      if (raw is String) {
        return DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    books.sort((a, b) {
      final aTime = parseUpdatedAt(a);
      final bTime = parseUpdatedAt(b);
      return bTime.compareTo(aTime);
    });

    return books;
  }

  @override
  void initState() {
    super.initState();
    controller = EbookListController(service: EbookService());
    _initReduceTransparency();

    _genreController = TabController(length: _genreTabs.length, vsync: this)
      ..addListener(() {
        if (!_genreController!.indexIsChanging) {
          setState(() {
            _genreIndex = _genreController!.index;
            _reloadCalendarPreview();
          });
        }
      });

    _reloadCalendarPreview();

    controller.init().then((_) {
      if (mounted) {
        setState(() {
          _reloadCalendarPreview();
        });
      }
    });
  }

  @override
  void dispose() {
    _genreController?.dispose();
    super.dispose();
  }

  Future<void> _initReduceTransparency() async {
    final flag = await PlatformAccessibility.getReduceTransparencyFlag();
    if (!mounted) return;
    setState(() => _reduceTransparencyFlag = flag);
  }

  GlassTheme get _glassTheme =>
      GlassTheme.fromFlags(reduceTransparency: _reduceTransparencyFlag);

  String _newDocumentId() =>
      'doc_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 32)}';

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<void> _createNewBook(Genre genre) async {
    final docId = _newDocumentId();

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider(
              create:
                  (_) => WritingSettingsController(documentId: docId)..load(),
              child: BookBuilderPage(
                genre: genre,
                initialTitle: '제목을 입력하세요',
                initialDeltaJson: deltaFromPlain('작품 내용을 입력하세요'),
                initialDrawingJson: const <Map<String, dynamic>>[],
                pageIndex: 0,
                initialPenName: '',
                documentId: docId,
              ),
            ),
      ),
    );

    if (!mounted || result == null) return;

    await controller.addFreeForm(
      title: (result['title'] as String?) ?? '제목을 입력하세요',
      delta:
          (result['delta'] as List?)?.cast<Map<String, dynamic>>() ?? const [],
      drawings:
          (result['drawings'] as List?)?.cast<Map<String, dynamic>>() ??
          const [],
    );

    controller.ebooks.last['genre'] = genre.name;
    controller.ebooks.last['documentId'] =
        (result['documentId'] as String?) ?? docId;
    controller.ebooks.last['coverPath'] = result['coverPath'] as String?;
    controller.ebooks.last['updatedAt'] = DateTime.now().toIso8601String();
    await controller.persistEbooks();

    if (!mounted) return;
    AppToast.show(context, '저장 완료');
    setState(() {});
  }

  Future<void> _editEbook(int index) async {
    final cur = controller.ebooks[index];

    if (cur['documentId'] == null) {
      cur['documentId'] = _newDocumentId();
      await controller.persistEbooks();
      if (!mounted) return;
    }
    final String docId = cur['documentId'] as String;
    final genreName = cur['genre'] as String?;
    final genre = Genre.values.firstWhere(
      (e) => e.name == genreName,
      orElse: () => Genre.webNovel,
    );
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider(
              create:
                  (_) => WritingSettingsController(documentId: docId)..load(),
              child: BookBuilderPage(
                genre: genre,
                initialTitle: cur['title'] as String,
                initialDeltaJson:
                    (cur['delta'] as List).cast<Map<String, dynamic>>(),
                initialDrawingJson:
                    (cur['drawings'] as List).cast<Map<String, dynamic>>(),
                pageIndex: index,
                initialPenName: (cur['penName'] as String?) ?? '',
                documentId: docId,
              ),
            ),
      ),
    );

    if (!mounted || result == null) return;

    await controller.editEbookAt(
      index: index,
      title: result['title'] as String,
      delta: result['delta'] as List<dynamic>,
      drawings:
          (result['drawings'] as List?)?.cast<Map<String, dynamic>>() ??
          <Map<String, dynamic>>[],
    );
    controller.ebooks[index]['genre'] = genre.name;
    controller.ebooks[index]['documentId'] =
        (result['documentId'] as String?) ?? (cur['documentId'] as String);
    controller.ebooks[index]['coverPath'] = result['coverPath'] as String?;
    controller.ebooks[index]['updatedAt'] = DateTime.now().toIso8601String();

    await controller.persistEbooks();
    if (!mounted) return;
    AppToast.show(context, '저장 완료');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Book'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            tooltip: '장르 선택',
            onPressed:
                () => showGenreDialog(
                  context,
                  theme: _glassTheme,
                  onTap: (g) async {
                    final genre = genreFromLabel(g);
                    await _createNewBook(genre);
                  },
                ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            tooltip: '더보기',
            onPressed:
                () => showMoreDialog(
                  context: context,
                  theme: _glassTheme,
                  onPickMode: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => AllBooksPage(
                              ebooks: controller.ebooks,
                              startInSelectionMode: true,
                              onChanged: (next) async {
                                controller.ebooks
                                  ..clear()
                                  ..addAll(next);
                                await controller.persistEbooks();
                                if (mounted) setState(() {});
                              },
                            ),
                      ),
                    );
                  },
                  onSettings: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                  },
                  onLogout: () => _logout(context),
                ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            _buildGenreTabBar(),
            const SizedBox(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child:
                        _isMainTab
                            ? AspectRatio(
                              aspectRatio: 1,
                              child: AddSquareCard(onTap: _handleCreateTap),
                            )
                            : SizedBox(
                              height: 300,
                              child: AddWideCard(onTap: _handleCreateTap),
                            ),
                  ),
                  const SizedBox(height: 27),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: InkWell(
                      onTap: () {
                        final genre = _genreTabs[_genreIndex];
                        final genreBooks = _filteredEbooks();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => AllBooksPage(
                                  ebooks: genreBooks,
                                  onChanged: (nextGenreBooks) async {
                                    if (genre == Genre.main) {
                                      controller.ebooks
                                        ..clear()
                                        ..addAll(nextGenreBooks);
                                    } else {
                                      controller.ebooks.removeWhere((b) {
                                        final name = b['genre'] as String?;
                                        final g = Genre.values.firstWhere(
                                          (e) => e.name == name,
                                          orElse: () => Genre.webNovel,
                                        );
                                        return g == genre;
                                      });

                                      controller.ebooks.addAll(nextGenreBooks);
                                    }

                                    await controller.persistEbooks();
                                    if (mounted) setState(() {});
                                  },
                                ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'book list',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 22,
                              color: Color.fromARGB(255, 117, 148, 188),
                              semanticLabel: 'book list',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  _buildShelf(),
                  const SizedBox(height: 27),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: InkWell(
                      onTap: () {
                        final genre = _genreTabs[_genreIndex];
                        final genreBooks = _filteredEbooks();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => EditEpisodesPage(
                                  genre: genre,
                                  genreBooks: genreBooks,
                                ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'edit episodes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 22,
                              color: Color.fromARGB(255, 117, 148, 188),
                              semanticLabel: 'edit episodes',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildLatestEpisodePreview(),
                  const SizedBox(height: 27),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: InkWell(
                      onTap: () async {
                        final currentGenre = _genreTabs[_genreIndex];

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SimpleMemoPage(genre: currentGenre),
                          ),
                        );

                        if (result == true) {
                          await controller.reloadMemos(genre: currentGenre);
                          if (mounted) setState(() {});
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'simple memo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 22,
                              color: Color.fromARGB(255, 117, 148, 188),
                              semanticLabel: 'simple memo',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildMemoPreviewRow(),

                  if (_isMainTab) ...[
                    const SizedBox(height: 27),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      CalendarPage(initialDate: _selectedDate),
                            ),
                          );
                          if (mounted) {
                            setState(() {
                              _reloadCalendarPreview();
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'calendar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 22,
                                color: Color.fromARGB(255, 117, 148, 188),
                                semanticLabel: 'calendar',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildCalendarPreviewCard(),
                    const SizedBox(height: 27),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCreateTap() {
    if (_isMainTab) {
      showGenreDialog(
        context,
        theme: _glassTheme,
        onTap: (g) async {
          final genre = genreFromLabel(g);
          if (genre == Genre.main) return;
          await _createNewBook(genre);
        },
      );
      return;
    }

    final genre = _genreTabs[_genreIndex];
    _createNewBook(genre);
  }

  Widget _buildShelf() {
    final books = _filteredEbooks();

    if (books.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _shelfHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        physics: const BouncingScrollPhysics(),
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 11),
        itemBuilder: (_, i) {
          final book = books[i];
          final originalIndex = controller.ebooks.indexOf(book);

          final genreName = book['genre'] as String?;
          final genre = Genre.values.firstWhere(
            (e) => e.name == genreName,
            orElse: () => Genre.webNovel,
          );

          return GestureDetector(
            onTap: () {
              if (originalIndex >= 0) _editEbook(originalIndex);
            },
            child: SizedBox(
              width: A4MiniCard.a4Width,
              child: A4MiniCard(
                title: book['title'] as String,
                preview: controller.deltaToPreview(book),
                selected: false,
                coverPath: book['coverPath'] as String?,
                selectionMode: false,
                genreText: _isMainTab ? genreLabel(genre) : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarPreviewCard() {
    return FutureBuilder<_CalendarOnlyPreviewData>(
      future: _calendarPreviewFuture,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: SizedBox(
              height: 470,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }

        final data = snap.data!;
        final log = data.todayLog;

        final doneTasks = log.tasks.where((e) => e.done).length;
        final totalTasks = log.tasks.length;
        final releaseCount = log.releases.length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CalendarPage(initialDate: _selectedDate),
                ),
              );

              if (mounted) {
                setState(() {
                  _reloadCalendarPreview();
                });
              }
            },
            borderRadius: BorderRadius.circular(12),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withValues(alpha: 0.92),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IgnorePointer(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color.fromARGB(255, 119, 188, 235),
                          onPrimary: Colors.white,
                          onSurface: Colors.black87,
                        ),
                        textTheme: Theme.of(context).textTheme.copyWith(
                          labelSmall: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 150, 190, 243),
                          ),
                        ),
                      ),
                      child: CalendarDatePickerClone(
                        events: data.events,
                        displayedMonth: data.displayedMonth,
                        selectedDate: data.selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        onMonthChanged: (_) {},
                        onDateSelected: (_) {},
                        onEventTap: (_) {},
                        onMoreTap: (_, __) {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_box_outlined,
                            size: 15,
                            color: Color(0xFF7594BC),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$doneTasks/$totalTasks',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5F7D9B),
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Icon(
                            Icons.cloud_upload_outlined,
                            size: 15,
                            color: Color(0xFF7594BC),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$releaseCount개',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5F7D9B),
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Icon(
                            Icons.event_note_outlined,
                            size: 15,
                            color: Color(0xFFFF75A3),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${data.todayEventCount}개',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5F7D9B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      child: Text(
                        totalTasks == 0 &&
                                releaseCount == 0 &&
                                data.todayEventCount == 0
                            ? '오늘 등록된 기록이 없습니다.'
                            : '오늘 할 일 $doneTasks/$totalTasks · 업로드 $releaseCount개 · 일정 ${data.todayEventCount}개',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(221, 83, 129, 159),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemoPreviewRow() {
    final genre = _genreTabs[_genreIndex];
    final preview =
        genre == Genre.main
            ? controller.memoPreviewAll()
            : controller.memoPreview(genre);

    if (preview.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: _memoSquare + 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: preview.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final item = preview[i];
          return SizedBox(
            width: _memoSquare,
            child: MemoSquareCard(
              text: item.memo.text,
              onTap: () async {
                final edited = await Navigator.of(context).push<String>(
                  PageRouteBuilder(
                    pageBuilder:
                        (_, __, ___) =>
                            _InlineMemoEditor(initialText: item.memo.text),
                    transitionDuration: const Duration(milliseconds: 120),
                    reverseTransitionDuration: const Duration(
                      milliseconds: 120,
                    ),
                    transitionsBuilder:
                        (_, animation, __, child) =>
                            FadeTransition(opacity: animation, child: child),
                  ),
                );

                if (edited == null || edited.trim().isEmpty) return;

                final ok = await controller.editMemoInlineItem(
                  item: item,
                  newText: edited.trim(),
                );

                if (ok && mounted) {
                  setState(() {});
                }
              },
            ),
          );
        },
      ),
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
        middle: Text(widget.initialText == null ? 'New Memo' : 'Edit Memo'),
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

class _CalendarOnlyPreviewData {
  final DateTime selectedDate;
  final DateTime displayedMonth;
  final List<RangeEvent> events;
  final DayLog todayLog;
  final int todayEventCount;

  const _CalendarOnlyPreviewData({
    required this.selectedDate,
    required this.displayedMonth,
    required this.events,
    required this.todayLog,
    required this.todayEventCount,
  });
}
