// ebook_list_page.dart

import 'dart:math';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calendar_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
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

double _previewWidthForRatio(double aspectRatio) {
  const previewHeight = 220.0;

  return (previewHeight * aspectRatio).clamp(150.0, 360.0).toDouble();
}

Future<String> _resolvePersistedMainSquareImagePath(String? value) async {
  final raw = value?.trim();
  if (raw == null || raw.isEmpty) return '';

  final direct = File(raw);
  if (await direct.exists()) return direct.path;

  try {
    final appDocDir = await getApplicationDocumentsDirectory();
    final byFileName = File(p.join(appDocDir.path, p.basename(raw)));

    if (await byFileName.exists()) return byFileName.path;
  } catch (_) {}

  return '';
}

class _EbookListPageState extends State<EbookListPage>
    with SingleTickerProviderStateMixin {
  late final EbookListController controller;
  final DateTime _selectedDate = DateTime.now();
  bool _reduceTransparencyFlag = false;

  Future<_CalendarOnlyPreviewData>? _calendarPreviewFuture;

  Future<void> _openBookAtChapter(EpisodePreview p) async {
    final bookIndex = controller.ebooks.indexWhere(
      (b) => (b['documentId'] as String?) == p.bookId,
    );

    if (bookIndex < 0) return;

    final book = controller.ebooks[bookIndex];

    final genreName = book['genre'] as String?;
    final g = Genre.values.firstWhere(
      (e) => e.name == genreName,
      orElse: () => Genre.webNovel,
    );

    final result = await Navigator.push<Map<String, dynamic>>(
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
                initialCoverPath:
                    (book['coverPath'] as String?) ?? p.bookCoverPath,
                initialOpenChapterIndex: p.chapterIndex,
              ),
            ),
      ),
    );

    if (!mounted || result == null) return;

    await controller.editEbookAt(
      index: bookIndex,
      title: (result['title'] as String?) ?? (book['title'] as String),
      delta: result['delta'] as List<dynamic>,
      drawings:
          (result['drawings'] as List?)?.cast<Map<String, dynamic>>() ??
          <Map<String, dynamic>>[],
    );

    controller.ebooks[bookIndex]['genre'] = g.name;
    controller.ebooks[bookIndex]['documentId'] =
        (result['documentId'] as String?) ?? p.bookId;
    controller.ebooks[bookIndex]['coverPath'] = result['coverPath'] as String?;
    controller.ebooks[bookIndex]['updatedAt'] =
        DateTime.now().toIso8601String();

    await controller.persistEbooks();

    if (!mounted) return;
    AppToast.show(context, '저장 완료');
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

      final bookCoverPath = await _resolveBookCoverPath(
        (b['coverPath'] as String?) ?? prefs.getString('book_cover_$bookId'),
      );

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

        final coverPath = await _resolveBookCoverPath(
          (m['cover'] as String?) ?? (m['coverPath'] as String?),
        );

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

  static const String _mainSquareTitlePrefsKey = 'main_square_card_title';
  static const String _mainSquareSubtitlePrefsKey = 'main_square_card_subtitle';
  static const String _mainSquareTitleFontSizePrefsKey =
      'main_square_card_title_font_size';
  static const String _mainSquareSubtitleFontSizePrefsKey =
      'main_square_card_subtitle_font_size';
  static const String _mainSquareStylePrefsKey = 'main_square_card_style';
  static const String _mainSquareCardRatioPrefsKey = 'main_square_card_ratio';
  static const String _mainSquareIconPrefsKey = 'main_square_card_icon';
  static const String _mainSquareShowIconPrefsKey =
      'main_square_card_show_icon';
  static const String _mainSquareIconSizePrefsKey =
      'main_square_card_icon_size';
  static const String _mainSquareIconThinnessPrefsKey =
      'main_square_card_icon_thinness';
  static const String _mainSquareTextColorPrefsKey =
      'main_square_card_text_color';
  static const String _mainSquareBorderPrefsKey = 'main_square_card_border';
  static const String _mainSquareBackgroundImagePrefsKey =
      'main_square_card_background_image';
  static const String _mainSquareBackgroundImageTransparencyPrefsKey =
      'main_square_card_background_image_transparency';
  static const String _mainSquareUseLightContentPrefsKey =
      'main_square_card_use_light_content';
  static const String _mainSquareThreeDGlassModePrefsKey =
      'main_square_card_3d_glass_mode';
  static const String _mainSquareBackgroundImageScalePrefsKey =
      'main_square_card_background_image_scale';
  static const String _mainSquareBackgroundImageOffsetXPrefsKey =
      'main_square_card_background_image_offset_x';
  static const String _mainSquareBackgroundImageOffsetYPrefsKey =
      'main_square_card_background_image_offset_y';
  static const String _mainSquareTextPositionPrefsKey =
      'main_square_card_text_position';
  static const String _mainSquareIconPositionPrefsKey =
      'main_square_card_icon_position';

  String _mainSquareTitle = '새 작품 만들기';
  String _mainSquareSubtitle = '';
  double _mainSquareTitleFontSize = 16;
  double _mainSquareSubtitleFontSize = 12;
  String _mainSquareStyleId = 'white';
  String _mainSquareCardRatioId = 'square';
  String _mainSquareIconId = 'add';
  bool _mainSquareShowIcon = true;
  double _mainSquareIconSize = 36;
  double _mainSquareIconThinness = 50;
  String _mainSquareTextColorId = 'style';
  String _mainSquareBorderId = 'thin';
  String _mainSquareBackgroundImagePath = '';
  double _mainSquareBackgroundImageTransparency = 0;
  double _mainSquareBackgroundImageScale = 1;
  double _mainSquareBackgroundImageOffsetX = 0;
  double _mainSquareBackgroundImageOffsetY = 0;
  bool _mainSquareUseLightContentOnImage = false;
  bool _mainSquareThreeDGlassMode = false;
  String _mainSquareTextPositionId = 'center';
  String _mainSquareIconPositionId = 'center';

  static const List<_MainSquareCardRatioOption> _mainSquareCardRatios = [
    _MainSquareCardRatioOption(
      id: 'square',
      label: '정사각형',
      description: '1:1',
      aspectRatio: 1,
    ),
    _MainSquareCardRatioOption(
      id: 'portrait',
      label: '세로형',
      description: '4:5',
      aspectRatio: 0.8,
    ),
    _MainSquareCardRatioOption(
      id: 'tall',
      label: '긴 세로형',
      description: '3:4',
      aspectRatio: 0.75,
    ),
    _MainSquareCardRatioOption(
      id: 'landscape',
      label: '가로형',
      description: '4:3',
      aspectRatio: 1.3333333333,
    ),
    _MainSquareCardRatioOption(
      id: 'wide',
      label: '와이드',
      description: '16:9',
      aspectRatio: 1.7777777778,
    ),
  ];

  static const List<_MainSquareStyleOption> _mainSquareStyles = [
    _MainSquareStyleOption(
      id: 'white',
      label: '없음',
      backgroundColor: Colors.white,
      borderColor: Color.fromARGB(221, 170, 214, 244),
      iconColor: Color.fromARGB(221, 83, 129, 159),
      titleColor: Color.fromARGB(221, 12, 24, 46),
      subtitleColor: Color.fromARGB(221, 83, 129, 159),
    ),
    _MainSquareStyleOption(
      id: 'sky',
      label: '맑은 하늘',
      backgroundColor: Color(0xFFEAF7FF),
      gradientColors: [Color(0xFFFFFFFF), Color(0xFFEAF7FF), Color(0xFFDFF3FF)],
      borderColor: Color(0xFFB9DDF4),
      iconColor: Color(0xFF5A9FD0),
      titleColor: Color(0xFF18334A),
      subtitleColor: Color(0xFF5F8CA8),
    ),
    _MainSquareStyleOption(
      id: 'pink',
      label: '소프트 핑크',
      backgroundColor: Color(0xFFFFF4FA),
      gradientColors: [Color(0xFFFFFFFF), Color(0xFFFFF1F8), Color(0xFFFFE2EF)],
      borderColor: Color(0xFFFFC4DA),
      iconColor: Color(0xFFE579A3),
      titleColor: Color(0xFF4A1D2E),
      subtitleColor: Color(0xFFB96B8B),
    ),
    _MainSquareStyleOption(
      id: 'lavender',
      label: '라이트 라벤더',
      backgroundColor: Color(0xFFF6F2FF),
      gradientColors: [Color(0xFFFFFFFF), Color(0xFFF5F0FF), Color(0xFFECE4FF)],
      borderColor: Color(0xFFD4C6FF),
      iconColor: Color(0xFF8A75D6),
      titleColor: Color(0xFF2D254A),
      subtitleColor: Color(0xFF7D70AC),
    ),
    _MainSquareStyleOption(
      id: 'cream',
      label: '바닐라 크림',
      backgroundColor: Color(0xFFFFFAEC),
      gradientColors: [Color(0xFFFFFFFF), Color(0xFFFFF8E8), Color(0xFFFFEFCB)],
      borderColor: Color(0xFFEFDCA8),
      iconColor: Color(0xFFB99244),
      titleColor: Color(0xFF3F321A),
      subtitleColor: Color(0xFF967A42),
    ),
    _MainSquareStyleOption(
      id: 'mint',
      label: '클리어 민트',
      backgroundColor: Color(0xFFF0FFF9),
      gradientColors: [Color(0xFFFFFFFF), Color(0xFFEFFFF8), Color(0xFFDDF8EE)],
      borderColor: Color(0xFFAEE8D4),
      iconColor: Color(0xFF4BAA86),
      titleColor: Color(0xFF17392F),
      subtitleColor: Color(0xFF5B987F),
    ),
    _MainSquareStyleOption(
      id: 'aurora_gradient',
      label: '밝은 오로라',
      backgroundColor: Color(0xFFF6FBFF),
      gradientColors: [
        Color(0xFFFFFFFF),
        Color(0xFFEAF7FF),
        Color(0xFFF4ECFF),
        Color(0xFFEFFFF8),
      ],
      borderColor: Color(0xFFCFE0FA),
      iconColor: Color(0xFF6D8ED8),
      titleColor: Color(0xFF263653),
      subtitleColor: Color(0xFF6F7FA4),
    ),
  ];

  static const List<_MainSquareIconOption> _mainSquareIcons = [
    _MainSquareIconOption(id: 'add', label: '기본', icon: Icons.add),
    _MainSquareIconOption(id: 'edit_note', label: '글쓰기', icon: Icons.edit_note),
    _MainSquareIconOption(
      id: 'auto_stories',
      label: '책',
      icon: Icons.auto_stories,
    ),
    _MainSquareIconOption(id: 'draw', label: '드로잉', icon: Icons.draw_outlined),
    _MainSquareIconOption(id: 'star', label: '별', icon: Icons.star_border),
    _MainSquareIconOption(
      id: 'favorite',
      label: '하트',
      icon: Icons.favorite_border,
    ),
  ];

  static const List<_MainSquareTextColorOption> _mainSquareTextColors = [
    _MainSquareTextColorOption(id: 'style', label: '기본'),
    _MainSquareTextColorOption(
      id: 'black',
      label: '블랙',
      titleColor: Colors.black87,
      subtitleColor: Colors.black54,
    ),
    _MainSquareTextColorOption(
      id: 'white',
      label: '화이트',
      titleColor: Colors.white,
      subtitleColor: Color.fromARGB(225, 255, 255, 255),
    ),
    _MainSquareTextColorOption(
      id: 'blue',
      label: '블루',
      titleColor: Color(0xFF3C7FAC),
      subtitleColor: Color(0xFF5F8CA8),
    ),
    _MainSquareTextColorOption(
      id: 'pink',
      label: '핑크',
      titleColor: Color.fromARGB(255, 255, 157, 194),
      subtitleColor: Color.fromARGB(255, 255, 153, 189),
    ),
    _MainSquareTextColorOption(
      id: 'lavender',
      label: '라벤더',
      titleColor: Color.fromARGB(255, 206, 171, 255),
      subtitleColor: Color.fromARGB(255, 157, 136, 239),
    ),
    _MainSquareTextColorOption(
      id: 'mint',
      label: '민트',
      titleColor: Color.fromARGB(255, 164, 255, 246),
      subtitleColor: Color.fromARGB(255, 147, 255, 244),
    ),
    _MainSquareTextColorOption(
      id: 'gold',
      label: '골드',
      titleColor: Color.fromARGB(255, 227, 190, 117),
      subtitleColor: Color.fromARGB(255, 195, 166, 110),
    ),
  ];

  static const List<_MainSquareBorderOption> _mainSquareBorders = [
    _MainSquareBorderOption(
      id: 'thin',
      label: '기본 얇은 테두리',
      borderWidth: 1,
      cardBorderStyle: AddSquareCardBorderStyle.solid,
    ),
    _MainSquareBorderOption(
      id: 'thick',
      label: '두꺼운 테두리',
      borderWidth: 2,
      cardBorderStyle: AddSquareCardBorderStyle.solid,
    ),
    _MainSquareBorderOption(
      id: 'none',
      label: '테두리 없음',
      borderWidth: 0,
      cardBorderStyle: AddSquareCardBorderStyle.none,
    ),
    _MainSquareBorderOption(
      id: 'pastel',
      label: '파스텔 테두리',
      borderColor: Color(0xFFCDBEFF),
      borderWidth: 1.4,
      cardBorderStyle: AddSquareCardBorderStyle.solid,
    ),
    _MainSquareBorderOption(
      id: 'dashed',
      label: '점선 느낌',
      borderWidth: 1.2,
      cardBorderStyle: AddSquareCardBorderStyle.dashed,
    ),
  ];

  static const List<_MainSquareContentPositionOption>
  _mainSquareContentPositions = [
    _MainSquareContentPositionOption(
      id: 'topLeft',
      label: '상단 왼쪽',
      position: AddSquareCardContentPosition.topLeft,
    ),
    _MainSquareContentPositionOption(
      id: 'topCenter',
      label: '상단 중앙',
      position: AddSquareCardContentPosition.topCenter,
    ),
    _MainSquareContentPositionOption(
      id: 'topRight',
      label: '상단 오른쪽',
      position: AddSquareCardContentPosition.topRight,
    ),
    _MainSquareContentPositionOption(
      id: 'centerLeft',
      label: '중앙 왼쪽',
      position: AddSquareCardContentPosition.centerLeft,
    ),
    _MainSquareContentPositionOption(
      id: 'center',
      label: '정중앙',
      position: AddSquareCardContentPosition.center,
    ),
    _MainSquareContentPositionOption(
      id: 'centerRight',
      label: '중앙 오른쪽',
      position: AddSquareCardContentPosition.centerRight,
    ),
    _MainSquareContentPositionOption(
      id: 'bottomLeft',
      label: '하단 왼쪽',
      position: AddSquareCardContentPosition.bottomLeft,
    ),
    _MainSquareContentPositionOption(
      id: 'bottomCenter',
      label: '하단 중앙',
      position: AddSquareCardContentPosition.bottomCenter,
    ),
    _MainSquareContentPositionOption(
      id: 'bottomRight',
      label: '하단 오른쪽',
      position: AddSquareCardContentPosition.bottomRight,
    ),
  ];

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

  _MainSquareStyleOption get _mainSquareStyle => _mainSquareStyles.firstWhere(
    (e) => e.id == _mainSquareStyleId,
    orElse: () => _mainSquareStyles.first,
  );

  _MainSquareCardRatioOption get _mainSquareCardRatio =>
      _mainSquareCardRatios.firstWhere(
        (e) => e.id == _mainSquareCardRatioId,
        orElse: () => _mainSquareCardRatios.first,
      );

  _MainSquareIconOption get _mainSquareIcon => _mainSquareIcons.firstWhere(
    (e) => e.id == _mainSquareIconId,
    orElse: () => _mainSquareIcons.first,
  );

  _MainSquareTextColorOption get _mainSquareTextColor =>
      _mainSquareTextColors.firstWhere(
        (e) => e.id == _mainSquareTextColorId,
        orElse: () => _mainSquareTextColors.first,
      );

  _MainSquareBorderOption get _mainSquareBorder =>
      _mainSquareBorders.firstWhere(
        (e) => e.id == _mainSquareBorderId,
        orElse: () => _mainSquareBorders.first,
      );

  _MainSquareContentPositionOption get _mainSquareTextPosition =>
      _mainSquareContentPositions.firstWhere(
        (e) => e.id == _mainSquareTextPositionId,
        orElse: () => _mainSquareContentPositions[4],
      );

  _MainSquareContentPositionOption get _mainSquareIconPosition =>
      _mainSquareContentPositions.firstWhere(
        (e) => e.id == _mainSquareIconPositionId,
        orElse: () => _mainSquareContentPositions[4],
      );

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
    books.sort((a, b) {
      final ai = _bookOrderOf(a, controller.ebooks.indexOf(a));
      final bi = _bookOrderOf(b, controller.ebooks.indexOf(b));
      return ai.compareTo(bi);
    });
    return books;
  }

  @override
  void initState() {
    super.initState();
    controller = EbookListController(service: EbookService());
    _initReduceTransparency();
    _loadMainSquareCardSettings();

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

    controller.init().then((_) async {
      await _restoreBookCoverPathsFromPrefs();

      final changed = _normalizeControllerBookOrder();
      if (changed) {
        await controller.persistEbooks();
      }

      if (mounted) {
        setState(() {
          _reloadCalendarPreview();
        });
      }
    });
  }

  Future<String?> _resolveBookCoverPath(String? value) async {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;

    final direct = File(raw);
    if (await direct.exists()) return direct.path;

    final appDocDir = await getApplicationDocumentsDirectory();
    final byFileName = File(p.join(appDocDir.path, p.basename(raw)));

    if (await byFileName.exists()) return byFileName.path;

    return null;
  }

  Future<void> _restoreBookCoverPathsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    var changed = false;

    for (final book in controller.ebooks) {
      final docId = book['documentId'] as String?;
      if (docId == null || docId.isEmpty) continue;

      final current = await _resolveBookCoverPath(book['coverPath'] as String?);
      if (current != null) {
        book['coverPath'] = current;
        changed = true;
        continue;
      }

      final saved = prefs.getString('book_cover_$docId');
      final resolved = await _resolveBookCoverPath(saved);

      if (resolved != null) {
        book['coverPath'] = resolved;
        changed = true;
      }
    }

    if (changed) {
      await controller.persistEbooks();
    }
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

  int _bookOrderOf(Map<String, dynamic> book, int fallback) {
    final raw = book['bookOrder'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return fallback;
  }

  int _nextBookOrder() {
    var maxOrder = -1;

    for (var i = 0; i < controller.ebooks.length; i++) {
      final order = _bookOrderOf(controller.ebooks[i], i);
      if (order > maxOrder) maxOrder = order;
    }

    return maxOrder + 1;
  }

  bool _normalizeControllerBookOrder() {
    var changed = false;

    for (int i = 0; i < controller.ebooks.length; i++) {
      final raw = controller.ebooks[i]['bookOrder'];

      if (raw is! num) {
        controller.ebooks[i]['bookOrder'] = i;
        changed = true;
      }
    }

    return changed;
  }

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
    controller.ebooks.last['bookOrder'] = _nextBookOrder();

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
    final prefs = await SharedPreferences.getInstance();

    final curCover = (cur['coverPath'] as String?)?.trim();
    final savedCover = prefs.getString('book_cover_$docId')?.trim();

    final initialCoverPath =
        (curCover != null && curCover.isNotEmpty) ? curCover : savedCover;
    final genreName = cur['genre'] as String?;
    final genre = Genre.values.firstWhere(
      (e) => e.name == genreName,
      orElse: () => Genre.webNovel,
    );

    if (!mounted) return;
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
                initialCoverPath: initialCoverPath,
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
                    padding: const EdgeInsets.fromLTRB(16, 23, 16, 8),
                    child:
                        _isMainTab
                            ? AspectRatio(
                              aspectRatio: _mainSquareCardRatio.aspectRatio,
                              child: AddSquareCard(
                                onTap: _handleCreateTap,
                                onCustomizeTap: _openMainSquareCustomizeSheet,
                                title: _mainSquareTitle,
                                subtitle: _mainSquareSubtitle,
                                icon: _mainSquareIcon.icon,
                                showIcon: _mainSquareShowIcon,
                                iconSize: _mainSquareIconSize,
                                iconThinness: _mainSquareIconThinness,
                                titleFontSize: _mainSquareTitleFontSize,
                                subtitleFontSize: _mainSquareSubtitleFontSize,
                                backgroundColor:
                                    _mainSquareStyle.backgroundColor,
                                backgroundGradient: _mainSquareStyle.gradient,
                                glassEffect: _mainSquareStyle.glassEffect,
                                translucentEffect:
                                    _mainSquareStyle.translucentEffect,
                                threeDGlassMode: _mainSquareThreeDGlassMode,
                                backgroundImagePath:
                                    _mainSquareBackgroundImagePath,
                                backgroundImageTransparency:
                                    _mainSquareBackgroundImageTransparency,
                                backgroundImageScale:
                                    _mainSquareBackgroundImageScale,
                                backgroundImageOffsetX:
                                    _mainSquareBackgroundImageOffsetX,
                                backgroundImageOffsetY:
                                    _mainSquareBackgroundImageOffsetY,
                                textPosition: _mainSquareTextPosition.position,
                                iconPosition: _mainSquareIconPosition.position,
                                useLightContentOnImage:
                                    _mainSquareUseLightContentOnImage,
                                borderColor: _mainSquareBorder.resolveColor(
                                  _mainSquareStyle,
                                ),
                                borderWidth: _mainSquareBorder.borderWidth,
                                borderStyle: _mainSquareBorder.cardBorderStyle,
                                iconColor: _mainSquareTextColor
                                    .resolveTitleColor(_mainSquareStyle),
                                titleColor: _mainSquareTextColor
                                    .resolveTitleColor(_mainSquareStyle),
                                subtitleColor: _mainSquareTextColor
                                    .resolveSubtitleColor(_mainSquareStyle),
                              ),
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
                      onTap: () async {
                        final genre = _genreTabs[_genreIndex];
                        final genreBooks = _filteredEbooks();

                        await Navigator.push(
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

                                    _normalizeControllerBookOrder();

                                    await controller.persistEbooks();

                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                ),
                          ),
                        );

                        if (mounted) {
                          setState(() {});
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

  Future<void> _loadMainSquareCardSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTitle = prefs.getString(_mainSquareTitlePrefsKey)?.trim();
    final savedSubtitle = prefs.getString(_mainSquareSubtitlePrefsKey)?.trim();
    final savedTitleFontSize = prefs.getDouble(
      _mainSquareTitleFontSizePrefsKey,
    );
    final savedSubtitleFontSize = prefs.getDouble(
      _mainSquareSubtitleFontSizePrefsKey,
    );
    final savedStyle = prefs.getString(_mainSquareStylePrefsKey);
    final savedCardRatio = prefs.getString(_mainSquareCardRatioPrefsKey);
    final savedIcon = prefs.getString(_mainSquareIconPrefsKey);
    final savedShowIcon = prefs.getBool(_mainSquareShowIconPrefsKey);
    final savedIconSize = prefs.getDouble(_mainSquareIconSizePrefsKey);
    final savedIconThinness = prefs.getDouble(_mainSquareIconThinnessPrefsKey);
    final savedTextColor = prefs.getString(_mainSquareTextColorPrefsKey);
    final savedBorder = prefs.getString(_mainSquareBorderPrefsKey);
    final savedBackgroundImage =
        prefs.getString(_mainSquareBackgroundImagePrefsKey)?.trim();
    final savedBackgroundImageOpacity = prefs.getDouble(
      _mainSquareBackgroundImageTransparencyPrefsKey,
    );
    final savedUseLightContent = prefs.getBool(
      _mainSquareUseLightContentPrefsKey,
    );
    final savedThreeDGlassMode = prefs.getBool(
      _mainSquareThreeDGlassModePrefsKey,
    );
    final savedBackgroundImageScale = prefs.getDouble(
      _mainSquareBackgroundImageScalePrefsKey,
    );
    final savedBackgroundImageOffsetX = prefs.getDouble(
      _mainSquareBackgroundImageOffsetXPrefsKey,
    );
    final savedBackgroundImageOffsetY = prefs.getDouble(
      _mainSquareBackgroundImageOffsetYPrefsKey,
    );
    final savedTextPosition = prefs.getString(_mainSquareTextPositionPrefsKey);
    final savedIconPosition = prefs.getString(_mainSquareIconPositionPrefsKey);
    final resolvedBackgroundImage = await _resolvePersistedMainSquareImagePath(
      savedBackgroundImage,
    );

    if (resolvedBackgroundImage != (savedBackgroundImage ?? '')) {
      await prefs.setString(
        _mainSquareBackgroundImagePrefsKey,
        resolvedBackgroundImage,
      );
    }

    if (!mounted) return;

    setState(() {
      if (savedTitle != null && savedTitle.isNotEmpty) {
        _mainSquareTitle = savedTitle;
      }

      _mainSquareSubtitle = savedSubtitle ?? _mainSquareSubtitle;

      if (savedTitleFontSize != null) {
        _mainSquareTitleFontSize =
            savedTitleFontSize.clamp(10.0, 28.0).toDouble();
      }

      if (savedSubtitleFontSize != null) {
        _mainSquareSubtitleFontSize =
            savedSubtitleFontSize.clamp(8.0, 22.0).toDouble();
      }

      if (_mainSquareStyles.any((e) => e.id == savedStyle)) {
        _mainSquareStyleId = savedStyle!;
      }

      if (_mainSquareCardRatios.any((e) => e.id == savedCardRatio)) {
        _mainSquareCardRatioId = savedCardRatio!;
      }

      if (_mainSquareIcons.any((e) => e.id == savedIcon)) {
        _mainSquareIconId = savedIcon!;
      }

      _mainSquareShowIcon = savedShowIcon ?? true;

      if (savedIconSize != null) {
        _mainSquareIconSize = savedIconSize.clamp(20.0, 72.0).toDouble();
      }

      if (savedIconThinness != null) {
        _mainSquareIconThinness =
            savedIconThinness.clamp(0.0, 100.0).toDouble();
      }

      if (_mainSquareTextColors.any((e) => e.id == savedTextColor)) {
        _mainSquareTextColorId = savedTextColor!;
      }

      if (_mainSquareBorders.any((e) => e.id == savedBorder)) {
        _mainSquareBorderId = savedBorder!;
      }

      _mainSquareBackgroundImagePath = resolvedBackgroundImage;

      if (savedBackgroundImageOpacity != null) {
        _mainSquareBackgroundImageTransparency =
            savedBackgroundImageOpacity.clamp(0.0, 1.0).toDouble();
      }

      if (savedBackgroundImageScale != null) {
        _mainSquareBackgroundImageScale =
            savedBackgroundImageScale.clamp(1.0, 4.0).toDouble();
      }

      if (savedBackgroundImageOffsetX != null) {
        _mainSquareBackgroundImageOffsetX =
            savedBackgroundImageOffsetX.clamp(-0.5, 0.5).toDouble();
      }

      if (savedBackgroundImageOffsetY != null) {
        _mainSquareBackgroundImageOffsetY =
            savedBackgroundImageOffsetY.clamp(-0.5, 0.5).toDouble();
      }

      if (_mainSquareContentPositions.any((e) => e.id == savedTextPosition)) {
        _mainSquareTextPositionId = savedTextPosition!;
      }

      if (_mainSquareContentPositions.any((e) => e.id == savedIconPosition)) {
        _mainSquareIconPositionId = savedIconPosition!;
      }

      _mainSquareUseLightContentOnImage = savedUseLightContent ?? false;
      _mainSquareThreeDGlassMode = savedThreeDGlassMode ?? false;
    });
  }

  Future<void> _saveMainSquareCardSettings(
    _MainSquareCardSettings settings,
  ) async {
    final title =
        settings.title.trim().isEmpty ? '새 작품 만들기' : settings.title.trim();
    final subtitle = settings.subtitle.trim();

    final resolvedBackgroundImage = await _resolvePersistedMainSquareImagePath(
      settings.backgroundImagePath,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mainSquareTitlePrefsKey, title);
    await prefs.setString(_mainSquareSubtitlePrefsKey, subtitle);
    await prefs.setDouble(
      _mainSquareTitleFontSizePrefsKey,
      settings.titleFontSize.clamp(10.0, 28.0).toDouble(),
    );
    await prefs.setDouble(
      _mainSquareSubtitleFontSizePrefsKey,
      settings.subtitleFontSize.clamp(8.0, 22.0).toDouble(),
    );
    await prefs.setString(_mainSquareStylePrefsKey, settings.styleId);
    await prefs.setString(_mainSquareCardRatioPrefsKey, settings.cardRatioId);
    await prefs.setString(_mainSquareIconPrefsKey, settings.iconId);
    await prefs.setBool(_mainSquareShowIconPrefsKey, settings.showIcon);
    await prefs.setDouble(
      _mainSquareIconSizePrefsKey,
      settings.iconSize.clamp(20.0, 72.0).toDouble(),
    );
    await prefs.setDouble(
      _mainSquareIconThinnessPrefsKey,
      settings.iconThinness.clamp(0.0, 100.0).toDouble(),
    );
    await prefs.setString(_mainSquareTextColorPrefsKey, settings.textColorId);
    await prefs.setString(_mainSquareBorderPrefsKey, settings.borderId);
    await prefs.setString(
      _mainSquareBackgroundImagePrefsKey,
      resolvedBackgroundImage,
    );
    await prefs.setDouble(
      _mainSquareBackgroundImageTransparencyPrefsKey,
      settings.backgroundImageTransparency.clamp(0.0, 1.0).toDouble(),
    );
    await prefs.setDouble(
      _mainSquareBackgroundImageScalePrefsKey,
      settings.backgroundImageScale.clamp(1.0, 4.0).toDouble(),
    );
    await prefs.setDouble(
      _mainSquareBackgroundImageOffsetXPrefsKey,
      settings.backgroundImageOffsetX.clamp(-0.5, 0.5).toDouble(),
    );
    await prefs.setDouble(
      _mainSquareBackgroundImageOffsetYPrefsKey,
      settings.backgroundImageOffsetY.clamp(-0.5, 0.5).toDouble(),
    );
    await prefs.setString(
      _mainSquareTextPositionPrefsKey,
      settings.textPositionId,
    );
    await prefs.setString(
      _mainSquareIconPositionPrefsKey,
      settings.iconPositionId,
    );
    await prefs.setBool(
      _mainSquareUseLightContentPrefsKey,
      settings.useLightContentOnImage,
    );
    await prefs.setBool(
      _mainSquareThreeDGlassModePrefsKey,
      settings.threeDGlassMode,
    );

    if (!mounted) return;

    setState(() {
      _mainSquareTitle = title;
      _mainSquareSubtitle = subtitle;
      _mainSquareTitleFontSize =
          settings.titleFontSize.clamp(10.0, 28.0).toDouble();
      _mainSquareSubtitleFontSize =
          settings.subtitleFontSize.clamp(8.0, 22.0).toDouble();
      _mainSquareStyleId = settings.styleId;
      _mainSquareCardRatioId = settings.cardRatioId;
      _mainSquareIconId = settings.iconId;
      _mainSquareShowIcon = settings.showIcon;
      _mainSquareIconSize = settings.iconSize.clamp(20.0, 72.0).toDouble();
      _mainSquareIconThinness =
          settings.iconThinness.clamp(0.0, 100.0).toDouble();
      _mainSquareTextColorId = settings.textColorId;
      _mainSquareBorderId = settings.borderId;
      _mainSquareBackgroundImagePath = resolvedBackgroundImage;
      _mainSquareBackgroundImageTransparency =
          settings.backgroundImageTransparency.clamp(0.0, 1.0).toDouble();
      _mainSquareBackgroundImageScale =
          settings.backgroundImageScale.clamp(1.0, 4.0).toDouble();
      _mainSquareBackgroundImageOffsetX =
          settings.backgroundImageOffsetX.clamp(-0.5, 0.5).toDouble();
      _mainSquareBackgroundImageOffsetY =
          settings.backgroundImageOffsetY.clamp(-0.5, 0.5).toDouble();
      _mainSquareTextPositionId = settings.textPositionId;
      _mainSquareIconPositionId = settings.iconPositionId;
      _mainSquareUseLightContentOnImage = settings.useLightContentOnImage;
      _mainSquareThreeDGlassMode = settings.threeDGlassMode;
    });

    AppToast.show(context, '메인 카드 꾸미기 저장 완료');
  }

  void _openMainSquareCustomizeSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF0F2238).withValues(alpha: 0.13),
      builder: (_) {
        return _MainSquareCustomizeSheet(
          styles: _mainSquareStyles,
          cardRatios: _mainSquareCardRatios,
          icons: _mainSquareIcons,
          textColors: _mainSquareTextColors,
          borders: _mainSquareBorders,
          contentPositions: _mainSquareContentPositions,
          initialSettings: _MainSquareCardSettings(
            title: _mainSquareTitle,
            subtitle: _mainSquareSubtitle,
            titleFontSize: _mainSquareTitleFontSize,
            subtitleFontSize: _mainSquareSubtitleFontSize,
            styleId: _mainSquareStyleId,
            cardRatioId: _mainSquareCardRatioId,
            iconId: _mainSquareIconId,
            showIcon: _mainSquareShowIcon,
            iconSize: _mainSquareIconSize,
            iconThinness: _mainSquareIconThinness,
            textColorId: _mainSquareTextColorId,
            borderId: _mainSquareBorderId,
            backgroundImagePath: _mainSquareBackgroundImagePath,
            backgroundImageTransparency: _mainSquareBackgroundImageTransparency,
            backgroundImageScale: _mainSquareBackgroundImageScale,
            backgroundImageOffsetX: _mainSquareBackgroundImageOffsetX,
            backgroundImageOffsetY: _mainSquareBackgroundImageOffsetY,
            textPositionId: _mainSquareTextPositionId,
            iconPositionId: _mainSquareIconPositionId,
            useLightContentOnImage: _mainSquareUseLightContentOnImage,
            threeDGlassMode: _mainSquareThreeDGlassMode,
          ),
          onSave: _saveMainSquareCardSettings,
        );
      },
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

class _MainSquareCardSettings {
  final String title;
  final String subtitle;
  final double titleFontSize;
  final double subtitleFontSize;
  final String styleId;
  final String cardRatioId;
  final String iconId;
  final bool showIcon;
  final double iconSize;
  final double iconThinness;
  final String textColorId;
  final String borderId;
  final String backgroundImagePath;
  final double backgroundImageTransparency;
  final double backgroundImageScale;
  final double backgroundImageOffsetX;
  final double backgroundImageOffsetY;
  final String textPositionId;
  final String iconPositionId;
  final bool useLightContentOnImage;
  final bool threeDGlassMode;

  const _MainSquareCardSettings({
    required this.title,
    required this.subtitle,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.styleId,
    required this.cardRatioId,
    required this.iconId,
    required this.showIcon,
    required this.iconSize,
    required this.iconThinness,
    required this.textColorId,
    required this.borderId,
    required this.backgroundImagePath,
    required this.backgroundImageTransparency,
    required this.backgroundImageScale,
    required this.backgroundImageOffsetX,
    required this.backgroundImageOffsetY,
    required this.textPositionId,
    required this.iconPositionId,
    required this.useLightContentOnImage,
    required this.threeDGlassMode,
  });

  _MainSquareCardSettings copyWith({
    String? title,
    String? subtitle,
    double? titleFontSize,
    double? subtitleFontSize,
    String? styleId,
    String? cardRatioId,
    String? iconId,
    bool? showIcon,
    double? iconSize,
    double? iconThinness,
    String? textColorId,
    String? borderId,
    String? backgroundImagePath,
    double? backgroundImageTransparency,
    double? backgroundImageScale,
    double? backgroundImageOffsetX,
    double? backgroundImageOffsetY,
    String? textPositionId,
    String? iconPositionId,
    bool? useLightContentOnImage,
    bool? threeDGlassMode,
  }) {
    return _MainSquareCardSettings(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      subtitleFontSize: subtitleFontSize ?? this.subtitleFontSize,
      styleId: styleId ?? this.styleId,
      cardRatioId: cardRatioId ?? this.cardRatioId,
      iconId: iconId ?? this.iconId,
      showIcon: showIcon ?? this.showIcon,
      iconSize: iconSize ?? this.iconSize,
      iconThinness: iconThinness ?? this.iconThinness,
      textColorId: textColorId ?? this.textColorId,
      borderId: borderId ?? this.borderId,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      backgroundImageTransparency:
          backgroundImageTransparency ?? this.backgroundImageTransparency,
      backgroundImageScale: backgroundImageScale ?? this.backgroundImageScale,
      backgroundImageOffsetX:
          backgroundImageOffsetX ?? this.backgroundImageOffsetX,
      backgroundImageOffsetY:
          backgroundImageOffsetY ?? this.backgroundImageOffsetY,
      textPositionId: textPositionId ?? this.textPositionId,
      iconPositionId: iconPositionId ?? this.iconPositionId,
      useLightContentOnImage:
          useLightContentOnImage ?? this.useLightContentOnImage,
      threeDGlassMode: threeDGlassMode ?? this.threeDGlassMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'titleFontSize': titleFontSize,
      'subtitleFontSize': subtitleFontSize,
      'styleId': styleId,
      'cardRatioId': cardRatioId,
      'iconId': iconId,
      'showIcon': showIcon,
      'iconSize': iconSize,
      'iconThinness': iconThinness,
      'textColorId': textColorId,
      'borderId': borderId,
      'backgroundImagePath': backgroundImagePath,
      'backgroundImageTransparency': backgroundImageTransparency,
      'backgroundImageScale': backgroundImageScale,
      'backgroundImageOffsetX': backgroundImageOffsetX,
      'backgroundImageOffsetY': backgroundImageOffsetY,
      'textPositionId': textPositionId,
      'iconPositionId': iconPositionId,
      'useLightContentOnImage': useLightContentOnImage,
      'threeDGlassMode': threeDGlassMode,
    };
  }

  factory _MainSquareCardSettings.fromMap(Map<String, dynamic> map) {
    return _MainSquareCardSettings(
      title: (map['title'] as String?) ?? '새 작품 만들기',
      subtitle: (map['subtitle'] as String?) ?? '',
      titleFontSize:
          ((map['titleFontSize'] as num?)?.toDouble() ?? 16)
              .clamp(10.0, 28.0)
              .toDouble(),
      subtitleFontSize:
          ((map['subtitleFontSize'] as num?)?.toDouble() ?? 12)
              .clamp(8.0, 22.0)
              .toDouble(),
      styleId: (map['styleId'] as String?) ?? 'white',
      cardRatioId: (map['cardRatioId'] as String?) ?? 'square',
      iconId: (map['iconId'] as String?) ?? 'add',
      showIcon: (map['showIcon'] as bool?) ?? true,
      iconSize:
          ((map['iconSize'] as num?)?.toDouble() ?? 36)
              .clamp(20.0, 72.0)
              .toDouble(),
      iconThinness:
          ((map['iconThinness'] as num?)?.toDouble() ?? 50)
              .clamp(0.0, 100.0)
              .toDouble(),
      textColorId: (map['textColorId'] as String?) ?? 'style',
      borderId: (map['borderId'] as String?) ?? 'thin',
      backgroundImagePath: (map['backgroundImagePath'] as String?) ?? '',
      backgroundImageTransparency:
          ((map['backgroundImageTransparency'] as num?)?.toDouble() ?? 0)
              .clamp(0.0, 1.0)
              .toDouble(),
      backgroundImageScale:
          ((map['backgroundImageScale'] as num?)?.toDouble() ?? 1)
              .clamp(1.0, 4.0)
              .toDouble(),
      backgroundImageOffsetX:
          ((map['backgroundImageOffsetX'] as num?)?.toDouble() ?? 0)
              .clamp(-0.5, 0.5)
              .toDouble(),
      backgroundImageOffsetY:
          ((map['backgroundImageOffsetY'] as num?)?.toDouble() ?? 0)
              .clamp(-0.5, 0.5)
              .toDouble(),
      textPositionId: (map['textPositionId'] as String?) ?? 'center',
      iconPositionId: (map['iconPositionId'] as String?) ?? 'center',
      useLightContentOnImage: (map['useLightContentOnImage'] as bool?) ?? false,
      threeDGlassMode: (map['threeDGlassMode'] as bool?) ?? false,
    );
  }
}

class _MainSquareCardPreset {
  final String id;
  final String name;
  final _MainSquareCardSettings settings;

  const _MainSquareCardPreset({
    required this.id,
    required this.name,
    required this.settings,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'settings': settings.toMap()};
  }

  factory _MainSquareCardPreset.fromMap(Map<String, dynamic> map) {
    final rawSettings = map['settings'];
    return _MainSquareCardPreset(
      id:
          (map['id'] as String?) ??
          'preset_${DateTime.now().millisecondsSinceEpoch}',
      name: (map['name'] as String?) ?? '프리셋',
      settings: _MainSquareCardSettings.fromMap(
        rawSettings is Map
            ? Map<String, dynamic>.from(rawSettings)
            : const <String, dynamic>{},
      ),
    );
  }
}

class _MainSquareCardRatioOption {
  final String id;
  final String label;
  final String description;
  final double aspectRatio;

  const _MainSquareCardRatioOption({
    required this.id,
    required this.label,
    required this.description,
    required this.aspectRatio,
  });
}

class _MainSquareStyleOption {
  final String id;
  final String label;
  final Color backgroundColor;
  final List<Color>? gradientColors;
  final Color borderColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;

  const _MainSquareStyleOption({
    required this.id,
    required this.label,
    required this.backgroundColor,
    this.gradientColors,
    required this.borderColor,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
  });

  bool get glassEffect => false;
  bool get translucentEffect => false;

  LinearGradient? get gradient {
    final colors = gradientColors;
    if (colors == null || colors.isEmpty) return null;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }
}

class _MainSquareIconOption {
  final String id;
  final String label;
  final IconData icon;

  const _MainSquareIconOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class _MainSquareTextColorOption {
  final String id;
  final String label;
  final Color? titleColor;
  final Color? subtitleColor;

  const _MainSquareTextColorOption({
    required this.id,
    required this.label,
    this.titleColor,
    this.subtitleColor,
  });

  Color resolveTitleColor(_MainSquareStyleOption style) {
    return titleColor ?? style.titleColor;
  }

  Color resolveSubtitleColor(_MainSquareStyleOption style) {
    return subtitleColor ??
        titleColor?.withValues(alpha: 0.82) ??
        style.subtitleColor;
  }
}

class _MainSquareBorderOption {
  final String id;
  final String label;
  final Color? borderColor;
  final double borderWidth;
  final AddSquareCardBorderStyle cardBorderStyle;

  const _MainSquareBorderOption({
    required this.id,
    required this.label,
    this.borderColor,
    required this.borderWidth,
    required this.cardBorderStyle,
  });

  Color resolveColor(_MainSquareStyleOption style) {
    return borderColor ?? style.borderColor;
  }
}

class _MainSquareContentPositionOption {
  final String id;
  final String label;
  final AddSquareCardContentPosition position;

  const _MainSquareContentPositionOption({
    required this.id,
    required this.label,
    required this.position,
  });
}

class _MainSquareCustomizeSheet extends StatefulWidget {
  const _MainSquareCustomizeSheet({
    required this.styles,
    required this.cardRatios,
    required this.icons,
    required this.textColors,
    required this.borders,
    required this.contentPositions,
    required this.initialSettings,
    required this.onSave,
  });

  final List<_MainSquareStyleOption> styles;
  final List<_MainSquareCardRatioOption> cardRatios;
  final List<_MainSquareIconOption> icons;
  final List<_MainSquareTextColorOption> textColors;
  final List<_MainSquareBorderOption> borders;
  final List<_MainSquareContentPositionOption> contentPositions;
  final _MainSquareCardSettings initialSettings;
  final Future<void> Function(_MainSquareCardSettings settings) onSave;

  @override
  State<_MainSquareCustomizeSheet> createState() =>
      _MainSquareCustomizeSheetState();
}

class _MainSquareCustomizeSheetState extends State<_MainSquareCustomizeSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;

  late double _titleFontSize;
  late double _subtitleFontSize;

  late String _styleId;
  late String _cardRatioId;
  late String _iconId;
  late bool _showIcon;
  late double _iconSize;
  late double _iconThinness;
  late String _textColorId;
  late String _borderId;
  late String _backgroundImagePath;
  late double _backgroundImageTransparency;
  late double _backgroundImageScale;
  late double _backgroundImageOffsetX;
  late double _backgroundImageOffsetY;
  double _gestureStartBackgroundImageScale = 1;
  late String _textPositionId;
  late String _iconPositionId;
  late bool _useLightContentOnImage;
  late bool _threeDGlassMode;

  List<_MainSquareCardPreset> _savedPresets = const [];
  bool _saving = false;

  static const String _mainSquareSavedPresetsPrefsKey =
      'main_square_card_saved_presets';

  static const Color _ink = Color(0xFF102235);
  static const Color _subInk = Color(0xFF5F7D9B);
  static const Color _muted = Color(0xFF8AA0B6);
  static const Color _blue = Color(0xFF77BCEB);
  static const Color _blueDark = Color(0xFF4E94C5);
  static const Color _danger = Color(0xFFE15F7A);

  _MainSquareStyleOption get _selectedStyle => widget.styles.firstWhere(
    (e) => e.id == _styleId,
    orElse: () => widget.styles.first,
  );

  _MainSquareCardRatioOption get _selectedCardRatio =>
      widget.cardRatios.firstWhere(
        (e) => e.id == _cardRatioId,
        orElse: () => widget.cardRatios.first,
      );

  _MainSquareIconOption get _selectedIcon => widget.icons.firstWhere(
    (e) => e.id == _iconId,
    orElse: () => widget.icons.first,
  );

  _MainSquareTextColorOption get _selectedTextColor =>
      widget.textColors.firstWhere(
        (e) => e.id == _textColorId,
        orElse: () => widget.textColors.first,
      );

  _MainSquareBorderOption get _selectedBorder => widget.borders.firstWhere(
    (e) => e.id == _borderId,
    orElse: () => widget.borders.first,
  );

  _MainSquareContentPositionOption get _selectedTextPosition =>
      widget.contentPositions.firstWhere(
        (e) => e.id == _textPositionId,
        orElse: () => widget.contentPositions[4],
      );

  _MainSquareContentPositionOption get _selectedIconPosition =>
      widget.contentPositions.firstWhere(
        (e) => e.id == _iconPositionId,
        orElse: () => widget.contentPositions[4],
      );

  bool get _hasBackgroundImage {
    final path = _backgroundImagePath.trim();
    return path.isNotEmpty && File(path).existsSync();
  }

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.initialSettings.title,
    );
    _subtitleController = TextEditingController(
      text: widget.initialSettings.subtitle,
    );

    _titleFontSize =
        widget.initialSettings.titleFontSize.clamp(10.0, 28.0).toDouble();
    _subtitleFontSize =
        widget.initialSettings.subtitleFontSize.clamp(8.0, 22.0).toDouble();

    _styleId = widget.initialSettings.styleId;
    _cardRatioId = widget.initialSettings.cardRatioId;
    _iconId = widget.initialSettings.iconId;
    _showIcon = widget.initialSettings.showIcon;
    _iconSize = widget.initialSettings.iconSize.clamp(20.0, 72.0).toDouble();
    _iconThinness =
        widget.initialSettings.iconThinness.clamp(0.0, 100.0).toDouble();
    _textColorId = widget.initialSettings.textColorId;
    _borderId = widget.initialSettings.borderId;
    _backgroundImagePath = widget.initialSettings.backgroundImagePath;
    _backgroundImageTransparency =
        widget.initialSettings.backgroundImageTransparency
            .clamp(0.0, 1.0)
            .toDouble();
    _backgroundImageScale =
        widget.initialSettings.backgroundImageScale.clamp(1.0, 4.0).toDouble();
    _backgroundImageOffsetX =
        widget.initialSettings.backgroundImageOffsetX
            .clamp(-0.5, 0.5)
            .toDouble();
    _backgroundImageOffsetY =
        widget.initialSettings.backgroundImageOffsetY
            .clamp(-0.5, 0.5)
            .toDouble();
    _textPositionId = widget.initialSettings.textPositionId;
    _iconPositionId = widget.initialSettings.iconPositionId;
    _useLightContentOnImage = widget.initialSettings.useLightContentOnImage;
    _threeDGlassMode = widget.initialSettings.threeDGlassMode;

    _loadSavedPresets();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  _MainSquareCardSettings _currentSettings() {
    return _MainSquareCardSettings(
      title: _titleController.text,
      subtitle: _subtitleController.text,
      titleFontSize: _titleFontSize,
      subtitleFontSize: _subtitleFontSize,
      styleId: _styleId,
      cardRatioId: _cardRatioId,
      iconId: _iconId,
      showIcon: _showIcon,
      iconSize: _iconSize,
      iconThinness: _iconThinness,
      textColorId: _textColorId,
      borderId: _borderId,
      backgroundImagePath: _backgroundImagePath,
      backgroundImageTransparency: _backgroundImageTransparency,
      backgroundImageScale: _backgroundImageScale,
      backgroundImageOffsetX: _backgroundImageOffsetX,
      backgroundImageOffsetY: _backgroundImageOffsetY,
      textPositionId: _textPositionId,
      iconPositionId: _iconPositionId,
      useLightContentOnImage: _useLightContentOnImage,
      threeDGlassMode: _threeDGlassMode,
    );
  }

  Future<void> _applySettings(_MainSquareCardSettings settings) async {
    final resolvedBackgroundImage = await _resolvePersistedMainSquareImagePath(
      settings.backgroundImagePath,
    );

    if (!mounted) return;

    setState(() {
      _titleController.text = settings.title;
      _subtitleController.text = settings.subtitle;
      _titleFontSize = settings.titleFontSize.clamp(10.0, 28.0).toDouble();
      _subtitleFontSize = settings.subtitleFontSize.clamp(8.0, 22.0).toDouble();
      _styleId = settings.styleId;
      _cardRatioId = settings.cardRatioId;
      _iconId = settings.iconId;
      _showIcon = settings.showIcon;
      _iconSize = settings.iconSize.clamp(20.0, 72.0).toDouble();
      _iconThinness = settings.iconThinness.clamp(0.0, 100.0).toDouble();
      _textColorId = settings.textColorId;
      _borderId = settings.borderId;
      _backgroundImagePath = resolvedBackgroundImage;
      _backgroundImageTransparency =
          settings.backgroundImageTransparency.clamp(0.0, 1.0).toDouble();
      _backgroundImageScale =
          settings.backgroundImageScale.clamp(1.0, 4.0).toDouble();
      _backgroundImageOffsetX =
          settings.backgroundImageOffsetX.clamp(-0.5, 0.5).toDouble();
      _backgroundImageOffsetY =
          settings.backgroundImageOffsetY.clamp(-0.5, 0.5).toDouble();
      _textPositionId = settings.textPositionId;
      _iconPositionId = settings.iconPositionId;
      _useLightContentOnImage = settings.useLightContentOnImage;
      _threeDGlassMode = settings.threeDGlassMode;
    });
  }

  Future<void> _loadSavedPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_mainSquareSavedPresetsPrefsKey);
    if (raw == null || raw.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final presets = <_MainSquareCardPreset>[];

      for (final item in decoded.whereType<Map>()) {
        final preset = _MainSquareCardPreset.fromMap(
          Map<String, dynamic>.from(item),
        );

        final resolvedBackgroundImage =
            await _resolvePersistedMainSquareImagePath(
              preset.settings.backgroundImagePath,
            );

        presets.add(
          _MainSquareCardPreset(
            id: preset.id,
            name: preset.name,
            settings: preset.settings.copyWith(
              backgroundImagePath: resolvedBackgroundImage,
            ),
          ),
        );
      }

      if (!mounted) return;
      setState(() => _savedPresets = presets);

      await _persistSavedPresets();
    } catch (_) {}
  }

  Future<void> _persistSavedPresets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _mainSquareSavedPresetsPrefsKey,
      jsonEncode(_savedPresets.map((e) => e.toMap()).toList()),
    );
  }

  Future<String?> _askPresetName() async {
    var draftName = '프리셋 ${_savedPresets.length + 1}';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            '프리셋 이름',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          content: TextFormField(
            initialValue: draftName,
            autofocus: true,
            maxLength: 16,
            decoration: _inputDecoration(label: '이름', hint: '예: 사진 포스터'),
            onChanged: (value) => draftName = value,
            onFieldSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(draftName.trim());
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );

    final name = result?.trim();
    if (name == null || name.isEmpty) return null;
    return name;
  }

  Future<void> _saveCurrentAsPreset() async {
    final name = await _askPresetName();
    if (!mounted || name == null) return;

    final current = _currentSettings();
    final resolvedBackgroundImage = await _resolvePersistedMainSquareImagePath(
      current.backgroundImagePath,
    );

    final next = _MainSquareCardPreset(
      id: 'preset_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      settings: current.copyWith(backgroundImagePath: resolvedBackgroundImage),
    );

    setState(() {
      _savedPresets = [..._savedPresets, next];
    });

    await _persistSavedPresets();

    if (!mounted) return;
    AppToast.show(context, '프리셋 저장 완료');
  }

  Future<void> _deletePreset(String id) async {
    setState(() {
      _savedPresets = _savedPresets.where((e) => e.id != id).toList();
    });

    await _persistSavedPresets();
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() => _saving = true);

    await widget.onSave(_currentSettings());

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _titleController.text = '새 작품 만들기';
      _subtitleController.text = '';
      _titleFontSize = 16;
      _subtitleFontSize = 12;
      _styleId = 'white';
      _cardRatioId = 'square';
      _iconId = 'add';
      _showIcon = true;
      _iconSize = 36;
      _iconThinness = 50;
      _textColorId = 'style';
      _borderId = 'thin';
      _backgroundImagePath = '';
      _backgroundImageTransparency = 0;
      _backgroundImageScale = 1;
      _backgroundImageOffsetX = 0;
      _backgroundImageOffsetY = 0;
      _textPositionId = 'center';
      _iconPositionId = 'center';
      _useLightContentOnImage = false;
      _threeDGlassMode = false;
    });
  }

  Future<void> _pickBackgroundImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );

      if (picked == null) return;

      final appDocDir = await getApplicationDocumentsDirectory();
      final ext =
          p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path);
      final fileName =
          'main_square_background_${DateTime.now().millisecondsSinceEpoch}$ext';

      final savedFile = await File(
        picked.path,
      ).copy(p.join(appDocDir.path, fileName));

      if (!mounted) return;

      setState(() {
        _backgroundImagePath = savedFile.path;
        _backgroundImageTransparency = 0;
        _backgroundImageScale = 1;
        _backgroundImageOffsetX = 0;
        _backgroundImageOffsetY = 0;
      });
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, '사진을 불러오지 못했습니다');
    }
  }

  void _clearBackgroundImage() {
    setState(() {
      _backgroundImagePath = '';
      _backgroundImageTransparency = 0;
      _backgroundImageScale = 1;
      _backgroundImageOffsetX = 0;
      _backgroundImageOffsetY = 0;
      _useLightContentOnImage = false;
    });
  }

  void _startBackgroundImageGesture() {
    _gestureStartBackgroundImageScale =
        _backgroundImageScale.clamp(1.0, 4.0).toDouble();
  }

  void _updateBackgroundImageGesture(
    ScaleUpdateDetails details,
    Size previewSize,
  ) {
    if (!_hasBackgroundImage ||
        previewSize.width <= 0 ||
        previewSize.height <= 0) {
      return;
    }

    final delta = details.focalPointDelta;

    setState(() {
      _backgroundImageOffsetX =
          (_backgroundImageOffsetX + delta.dx / previewSize.width)
              .clamp(-0.5, 0.5)
              .toDouble();
      _backgroundImageOffsetY =
          (_backgroundImageOffsetY + delta.dy / previewSize.height)
              .clamp(-0.5, 0.5)
              .toDouble();

      if (details.pointerCount >= 2) {
        _backgroundImageScale =
            (_gestureStartBackgroundImageScale * details.scale)
                .clamp(1.0, 4.0)
                .toDouble();
      }
    });
  }

  void _resetBackgroundImagePosition() {
    setState(() {
      _backgroundImageScale = 1;
      _backgroundImageOffsetX = 0;
      _backgroundImageOffsetY = 0;
      _gestureStartBackgroundImageScale = 1;
    });
  }

  static InputDecoration _inputDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      counterText: '',
      filled: false,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
      labelStyle: const TextStyle(
        color: _subInk,
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
      floatingLabelStyle: const TextStyle(
        color: _blueDark,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      hintStyle: const TextStyle(
        color: _muted,
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE6ECF3), width: 0.8),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE6ECF3), width: 0.8),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: _blue, width: 1.1),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: _blueDark),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                    height: 1.18,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: _subInk,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 18),
          child,
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _miniLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _ink,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _simpleButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final color = destructive ? _danger : _blueDark;

    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 17, color: color),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.15,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: color,
        splashFactory: NoSplash.splashFactory,
        overlayColor: Colors.transparent,
      ),
    );
  }

  Widget _choice({
    required bool selected,
    required Widget label,
    required VoidCallback onTap,
    Widget? leading,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        minimumSize: const Size(0, 38),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: selected ? _blueDark : _subInk,
        splashFactory: NoSplash.splashFactory,
        overlayColor: Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading, const SizedBox(width: 8)],
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? _blueDark : _subInk,
              height: 1.15,
            ),
            child: label,
          ),
          if (selected) ...[
            const SizedBox(width: 6),
            const Icon(Icons.check, size: 15, color: _blueDark),
          ],
        ],
      ),
    );
  }

  Widget _colorDot(Color color, {bool white = false}) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: white ? const Color(0xFFB7C7D7) : color,
          width: 1,
        ),
      ),
    );
  }

  Widget _wrap(List<Widget> children) {
    return Wrap(spacing: 12, runSpacing: 12, children: children);
  }

  Widget _switchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 19, color: value ? _blueDark : _muted),
            const SizedBox(width: 11),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: _ink,
                    height: 1.22,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: _subInk,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch.adaptive(
            value: value,
            activeThumbColor: _blue,
            activeTrackColor: _blue.withValues(alpha: 0.28),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _sliderRow({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    final Color active = Colors.black87.withValues(alpha: 0.70);
    final Color inactive = Colors.black87.withValues(alpha: 0.16);
    final Color thumb = Colors.black87.withValues(alpha: 0.70);
    const Color valueTextColor = Color(0xFF9AA6B2);

    final safeValue = value.clamp(min, max).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        height: 38,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 72,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87.withValues(alpha: 0.74),
                  height: 1.2,
                ),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 0.55,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 4.5,
                  ),
                  inactiveTrackColor: inactive,
                  activeTrackColor: active,
                  thumbColor: thumb,
                  valueIndicatorShape: SliderComponentShape.noOverlay,
                  showValueIndicator: ShowValueIndicator.never,
                ),
                child: Slider(
                  value: safeValue,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 48,
              child: Text(
                label,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: valueTextColor,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainCardPreview() {
    final previewWidth = _previewWidthForRatio(_selectedCardRatio.aspectRatio);
    const previewHeight = 220.0;
    final canDragImage = _hasBackgroundImage;

    return Center(
      child: SizedBox(
        width: previewWidth,
        height: previewHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final previewSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            return MouseRegion(
              cursor:
                  canDragImage
                      ? SystemMouseCursors.move
                      : SystemMouseCursors.basic,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart:
                    canDragImage ? (_) => _startBackgroundImageGesture() : null,
                onScaleUpdate:
                    canDragImage
                        ? (details) {
                          _updateBackgroundImageGesture(details, previewSize);
                        }
                        : null,
                onDoubleTap:
                    canDragImage ? _resetBackgroundImagePosition : null,
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    AddSquareCard(
                      onTap: () {},
                      title: _titleController.text,
                      subtitle: _subtitleController.text,
                      icon: _selectedIcon.icon,
                      showIcon: _showIcon,
                      iconSize: _iconSize,
                      iconThinness: _iconThinness,
                      titleFontSize: _titleFontSize,
                      subtitleFontSize: _subtitleFontSize,
                      contentScale:
                          previewWidth /
                          (MediaQuery.sizeOf(context).width - 32),
                      backgroundColor: _selectedStyle.backgroundColor,
                      backgroundGradient: _selectedStyle.gradient,
                      glassEffect: _selectedStyle.glassEffect,
                      translucentEffect: _selectedStyle.translucentEffect,
                      threeDGlassMode: _threeDGlassMode,
                      backgroundImagePath: _backgroundImagePath,
                      backgroundImageTransparency: _backgroundImageTransparency,
                      backgroundImageScale: _backgroundImageScale,
                      backgroundImageOffsetX: _backgroundImageOffsetX,
                      backgroundImageOffsetY: _backgroundImageOffsetY,
                      textPosition: _selectedTextPosition.position,
                      iconPosition: _selectedIconPosition.position,
                      useLightContentOnImage: _useLightContentOnImage,
                      borderColor: _selectedBorder.resolveColor(_selectedStyle),
                      borderWidth: _selectedBorder.borderWidth,
                      borderStyle: _selectedBorder.cardBorderStyle,
                      iconColor: _selectedTextColor.resolveTitleColor(
                        _selectedStyle,
                      ),
                      titleColor: _selectedTextColor.resolveTitleColor(
                        _selectedStyle,
                      ),
                      subtitleColor: _selectedTextColor.resolveSubtitleColor(
                        _selectedStyle,
                      ),
                      showCustomizeButton: false,
                    ),

                    if (canDragImage)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -26,
                        child: IgnorePointer(
                          child: Text(
                            '드래그 이동 · 두 손가락 확대 · 더블 탭 초기화',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: _subInk.withValues(alpha: 0.88),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _presetTooltipPill(_MainSquareCardPreset preset) {
    const Color tooltipBg = Color(0xEEFFFFFF);
    const Color tooltipBorder = Color(0xFFE6ECF3);
    const Color tooltipInk = Color(0xFF1F3A56);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _applySettings(preset.settings),
        borderRadius: BorderRadius.circular(999),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Container(
          height: 34,
          padding: const EdgeInsets.only(left: 15, right: 8),
          decoration: BoxDecoration(
            color: tooltipBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: tooltipBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                preset.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: tooltipInk,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.15,
                ),
              ),
              const SizedBox(width: 7),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _deletePreset(preset.id),
                child: const Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(Icons.close, size: 14, color: tooltipInk),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                size: 18,
                color: _blueDark,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
              _simpleButton(text: '초기화', icon: Icons.refresh, onTap: _reset),
            ],
          ),
          const SizedBox(height: 18),
          _mainCardPreview(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _effectSection() {
    return _section(
      title: '효과',
      icon: Icons.blur_on_rounded,
      child: _switchRow(
        title: '글라스 모드',
        subtitle: '부드러운 유리감과 렌즈 반사를 적용합니다.',
        icon: Icons.water_drop_outlined,
        value: _threeDGlassMode,
        onChanged: (value) {
          setState(() {
            _threeDGlassMode = value;

            if (value) {
              _textColorId = 'white';
            }
          });
        },
      ),
    );
  }

  Widget _presetSection() {
    return _section(
      title: '프리셋',
      icon: Icons.bookmark_border,
      subtitle: '현재 조합을 저장해두고 나중에 다시 적용할 수 있습니다.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _simpleButton(
            text: '현재 프리셋 저장',
            icon: Icons.add_rounded,
            onTap: _saveCurrentAsPreset,
          ),
          const SizedBox(height: 10),
          if (_savedPresets.isEmpty)
            const Text(
              '저장된 프리셋이 없습니다.',
              style: TextStyle(fontSize: 12, color: _muted),
            )
          else
            Theme(
              data: Theme.of(context).copyWith(
                chipTheme: Theme.of(context).chipTheme.copyWith(
                  backgroundColor: Colors.transparent,
                  selectedColor: Colors.transparent,
                  disabledColor: Colors.transparent,
                  secondarySelectedColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  elevation: 0,
                  pressElevation: 0,
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _savedPresets.map(_presetTooltipPill).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _textSection() {
    const fieldStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: _ink,
      height: 1.25,
    );

    return _section(
      title: '문구',
      icon: Icons.text_fields_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            maxLength: 23,
            style: fieldStyle,
            onChanged: (_) => setState(() {}),
            decoration: _inputDecoration(label: '큰 문구', hint: '새 작품 만들기'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _subtitleController,
            maxLength: 40,
            style: fieldStyle,
            onChanged: (_) => setState(() {}),
            decoration: _inputDecoration(label: '작은 문구', hint: '선택 사항'),
          ),
          const SizedBox(height: 22),
          _sliderRow(
            title: '큰 문구',
            value: _titleFontSize,
            min: 10,
            max: 28,
            divisions: 18,
            label: '${_titleFontSize.round()}px',
            onChanged: (value) {
              setState(() {
                _titleFontSize = value.clamp(10.0, 28.0).toDouble();
              });
            },
          ),
          const SizedBox(height: 8),
          _sliderRow(
            title: '작은 문구',
            value: _subtitleFontSize,
            min: 8,
            max: 22,
            divisions: 14,
            label: '${_subtitleFontSize.round()}px',
            onChanged: (value) {
              setState(() {
                _subtitleFontSize = value.clamp(8.0, 22.0).toDouble();
              });
            },
          ),
          const SizedBox(height: 22),
          _miniLabel('텍스트 위치'),
          _positionChoices(
            selectedId: _textPositionId,
            onChanged: (id) => setState(() => _textPositionId = id),
          ),
          const SizedBox(height: 22),
          _miniLabel('문구 아이콘 색상'),
          _wrap(
            widget.textColors.map((option) {
              final color = option.resolveTitleColor(_selectedStyle);
              final selected = _textColorId == option.id;

              return _choice(
                selected: selected,
                leading: _colorDot(color, white: option.id == 'white'),
                label: Text(option.label),
                onTap: () {
                  setState(() {
                    _textColorId = option.id;

                    if (_threeDGlassMode && option.id != 'white') {
                      _useLightContentOnImage = false;
                    }
                  });
                },
              );
            }).toList(),
          ),
          if (_hasBackgroundImage && _useLightContentOnImage) ...[
            const SizedBox(height: 14),
            const Text(
              '밝은 문구 모드가 켜져 있으면 사진 위에서는 흰색 문구가 우선 적용됩니다.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: _subInk,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cardStyleSection() {
    return _section(
      title: '카드 스타일',
      icon: Icons.dashboard_customize_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _miniLabel('카드 비율'),
          _wrap(
            widget.cardRatios.map((option) {
              final selected = _cardRatioId == option.id;

              return _choice(
                selected: selected,
                leading: Container(
                  width: option.aspectRatio >= 1 ? 20 : 14,
                  height: option.aspectRatio >= 1 ? 14 : 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: selected ? _blue : const Color(0xFFB7C7D7),
                      width: selected ? 1.4 : 1,
                    ),
                  ),
                ),
                label: Text('${option.label} ${option.description}'),
                onTap: () => setState(() => _cardRatioId = option.id),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          _miniLabel('배경 스타일'),
          _wrap(
            widget.styles.map((style) {
              final selected = _styleId == style.id;

              return _choice(
                selected: selected,
                leading: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color:
                        style.gradient == null ? style.backgroundColor : null,
                    gradient: style.gradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: style.borderColor),
                  ),
                ),
                label: Text(style.label),
                onTap: () => setState(() => _styleId = style.id),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          _miniLabel('테두리 스타일'),
          _wrap(
            widget.borders.map((option) {
              final selected = _borderId == option.id;
              final borderColor = option.resolveColor(_selectedStyle);

              return _choice(
                selected: selected,
                leading: Container(
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border:
                        option.cardBorderStyle == AddSquareCardBorderStyle.none
                            ? null
                            : Border.all(
                              color: borderColor,
                              width: option.borderWidth.clamp(1.0, 2.0),
                            ),
                  ),
                  child:
                      option.cardBorderStyle == AddSquareCardBorderStyle.dashed
                          ? Center(
                            child: Text(
                              '··',
                              style: TextStyle(
                                fontSize: 12,
                                height: 0.8,
                                color: borderColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                          : null,
                ),
                label: Text(option.label),
                onTap: () => setState(() => _borderId = option.id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _positionChoices({
    required String selectedId,
    required ValueChanged<String> onChanged,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.contentPositions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 7,
        crossAxisSpacing: 7,
        childAspectRatio: 2.7,
      ),
      itemBuilder: (context, index) {
        final option = widget.contentPositions[index];
        final selected = selectedId == option.id;

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: () => onChanged(option.id),
            borderRadius: BorderRadius.circular(999),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: selected ? const Color(0xEEFFFFFF) : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color:
                      selected
                          ? const Color(0xFFE6ECF3)
                          : const Color(0xFFE9EEF4),
                  width: 1,
                ),
              ),
              child: Text(
                selected ? '${option.label} ✓' : option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                  color: selected ? const Color(0xFF1F3A56) : _subInk,
                  height: 1.1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _backgroundImageSection() {
    return _section(
      title: '배경 이미지',
      icon: Icons.image_outlined,
      subtitle: '사진을 넣으면 미리보기 카드에서 직접 위치와 확대를 조절할 수 있습니다.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _simpleButton(
                text: '사진 선택',
                icon: Icons.photo_library_outlined,
                onTap: _pickBackgroundImage,
              ),
              if (_hasBackgroundImage)
                _simpleButton(
                  text: '이미지 삭제',
                  icon: Icons.delete_outline,
                  onTap: _clearBackgroundImage,
                  destructive: true,
                ),
              if (_hasBackgroundImage)
                _simpleButton(
                  text: '위치 초기화',
                  icon: Icons.center_focus_strong,
                  onTap: _resetBackgroundImagePosition,
                ),
            ],
          ),
          if (_hasBackgroundImage) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.insert_photo_outlined,
                  size: 16,
                  color: _blueDark,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    p.basename(_backgroundImagePath),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: _subInk),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sliderRow(
              title: '투명도',
              value: _backgroundImageTransparency,
              min: 0,
              max: 1,
              divisions: 10,
              label: '${(_backgroundImageTransparency * 100).round()}%',
              onChanged: (value) {
                setState(() {
                  _backgroundImageTransparency =
                      value.clamp(0.0, 1.0).toDouble();
                });
              },
            ),
            const SizedBox(height: 10),
            _switchRow(
              title: '어두운 사진용 흰 글자',
              subtitle: '사진 배경 위에서 아이콘과 문구를 흰색으로 보여줍니다.',
              icon: Icons.contrast,
              value: _useLightContentOnImage,
              onChanged: (value) {
                setState(() => _useLightContentOnImage = value);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _iconSection() {
    return _section(
      title: '아이콘',
      icon: Icons.add_circle_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _switchRow(
            title: '아이콘 보이기',
            icon: Icons.visibility_outlined,
            value: _showIcon,
            onChanged: (value) => setState(() => _showIcon = value),
          ),
          if (_showIcon) ...[
            const SizedBox(height: 16),
            _miniLabel('아이콘 모양'),
            _wrap(
              widget.icons.map((option) {
                final selected = _iconId == option.id;

                return _choice(
                  selected: selected,
                  leading: Icon(
                    option.icon,
                    size: 17,
                    color: selected ? _blueDark : _subInk,
                  ),
                  label: Text(option.label),
                  onTap: () => setState(() => _iconId = option.id),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _miniLabel('아이콘 위치'),
            _positionChoices(
              selectedId: _iconPositionId,
              onChanged: (id) => setState(() => _iconPositionId = id),
            ),
            const SizedBox(height: 16),
            _sliderRow(
              title: '크기',
              value: _iconSize,
              min: 20,
              max: 72,
              divisions: 13,
              label: '${_iconSize.round()}px',
              onChanged: (value) {
                setState(() {
                  _iconSize = value.clamp(20.0, 72.0).toDouble();
                });
              },
            ),
            const SizedBox(height: 10),
            _sliderRow(
              title: '얇기',
              value: _iconThinness,
              min: 0,
              max: 100,
              divisions: 10,
              label: '${_iconThinness.round()}%',
              onChanged: (value) {
                setState(() {
                  _iconThinness = value.clamp(0.0, 100.0).toDouble();
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _sheetHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 0),
      child: Row(
        children: [
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close, color: _subInk),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    const Color tooltipBg = Color(0xEEFFFFFF);
    const Color tooltipBorder = Color(0xFFE6ECF3);
    const Color tooltipInk = Color(0xFF1F3A56);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomPadding),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _saving ? null : _save,
            borderRadius: BorderRadius.circular(999),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: tooltipBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: tooltipBorder, width: 1),
              ),
              child: Center(
                child:
                    _saving
                        ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.6,
                            color: tooltipInk,
                          ),
                        )
                        : const Text(
                          '저장',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: tooltipInk,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            height: 1.15,
                          ),
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final sheetHeight = screenHeight * 0.94;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: sheetHeight,
            child: Column(
              children: [
                _sheetHeader(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 2, 18, 10),
                    children: [
                      _previewSection(),
                      _effectSection(),
                      _presetSection(),
                      _textSection(),
                      _cardStyleSection(),
                      _backgroundImageSection(),
                      _iconSection(),
                    ],
                  ),
                ),
                _bottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
