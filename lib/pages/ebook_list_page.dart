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
  static const String _mainSquareStylePrefsKey = 'main_square_card_style';
  static const String _mainSquareCardRatioPrefsKey = 'main_square_card_ratio';
  static const String _mainSquareIconPrefsKey = 'main_square_card_icon';
  static const String _mainSquareShowIconPrefsKey =
      'main_square_card_show_icon';
  static const String _mainSquareIconSizePrefsKey =
      'main_square_card_icon_size';
  static const String _mainSquareIconThinnessPrefsKey =
      'main_square_card_icon_thinness';
  static const String _mainSquareIconColorPrefsKey =
      'main_square_card_icon_color';
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
  String _mainSquareStyleId = 'white';
  String _mainSquareCardRatioId = 'square';
  String _mainSquareIconId = 'add';
  bool _mainSquareShowIcon = true;
  double _mainSquareIconSize = 36;
  double _mainSquareIconThinness = 50;
  String _mainSquareIconColorId = 'style';
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
      label: '하늘 그라데이션',
      backgroundColor: Color(0xFFEAF7FF),
      gradientColors: [Color(0xFFF8FDFF), Color(0xFFDFF3FF)],
      borderColor: Color(0xFFA9D8F5),
      iconColor: Color(0xFF4E94C5),
      titleColor: Color(0xFF18334A),
      subtitleColor: Color(0xFF5F8CA8),
    ),
    _MainSquareStyleOption(
      id: 'pink',
      label: '벚꽃 그라데이션',
      backgroundColor: Color(0xFFFFF0F6),
      gradientColors: [Color(0xFFFFFAFC), Color(0xFFFFE3EF)],
      borderColor: Color(0xFFFFB8D1),
      iconColor: Color(0xFFD95F8D),
      titleColor: Color(0xFF4A1D2E),
      subtitleColor: Color(0xFFB35B7A),
    ),
    _MainSquareStyleOption(
      id: 'lavender',
      label: '라벤더 그라데이션',
      backgroundColor: Color(0xFFF4F0FF),
      gradientColors: [Color(0xFFFBF9FF), Color(0xFFEAE2FF)],
      borderColor: Color(0xFFCDBEFF),
      iconColor: Color(0xFF7B67C8),
      titleColor: Color(0xFF2D254A),
      subtitleColor: Color(0xFF7669A8),
    ),
    _MainSquareStyleOption(
      id: 'cream',
      label: '크림 그라데이션',
      backgroundColor: Color(0xFFFFF8E8),
      gradientColors: [Color(0xFFFFFCF2), Color(0xFFFFEFC5)],
      borderColor: Color(0xFFEED79C),
      iconColor: Color(0xFFB48A35),
      titleColor: Color(0xFF3F321A),
      subtitleColor: Color(0xFF967A42),
    ),
    _MainSquareStyleOption(
      id: 'mint',
      label: '민트 그라데이션',
      backgroundColor: Color(0xFFEFFFF8),
      gradientColors: [Color(0xFFF8FFFC), Color(0xFFDDF8EE)],
      borderColor: Color(0xFFA9E6D0),
      iconColor: Color(0xFF3B9D7A),
      titleColor: Color(0xFF17392F),
      subtitleColor: Color(0xFF5B987F),
    ),
    _MainSquareStyleOption(
      id: 'aurora_gradient',
      label: '오로라',
      backgroundColor: Color(0xFFF3FAFF),
      gradientColors: [Color(0xFFEAF7FF), Color(0xFFF2E9FF), Color(0xFFEFFFF8)],
      borderColor: Color(0xFFBED6F6),
      iconColor: Color(0xFF5D86C8),
      titleColor: Color(0xFF263653),
      subtitleColor: Color(0xFF6F7FA4),
    ),
    _MainSquareStyleOption(
      id: 'glass_sky',
      label: '유리 하늘',
      backgroundColor: Color.fromARGB(116, 245, 252, 255),
      gradientColors: [
        Color.fromARGB(170, 255, 255, 255),
        Color.fromARGB(105, 199, 234, 255),
      ],
      borderColor: Color.fromARGB(170, 153, 205, 240),
      iconColor: Color(0xFF4E94C5),
      titleColor: Color(0xFF18334A),
      subtitleColor: Color(0xFF5F8CA8),
      glassEffect: true,
    ),
    _MainSquareStyleOption(
      id: 'glass_pink',
      label: '유리 핑크',
      backgroundColor: Color.fromARGB(116, 255, 248, 251),
      gradientColors: [
        Color.fromARGB(175, 255, 255, 255),
        Color.fromARGB(100, 255, 207, 226),
      ],
      borderColor: Color.fromARGB(165, 255, 184, 209),
      iconColor: Color(0xFFD95F8D),
      titleColor: Color(0xFF4A1D2E),
      subtitleColor: Color(0xFFB35B7A),
      glassEffect: true,
    ),
    _MainSquareStyleOption(
      id: 'translucent_white',
      label: '반투명 화이트',
      backgroundColor: Color.fromARGB(150, 255, 255, 255),
      borderColor: Color.fromARGB(155, 170, 214, 244),
      iconColor: Color.fromARGB(221, 83, 129, 159),
      titleColor: Color.fromARGB(221, 12, 24, 46),
      subtitleColor: Color.fromARGB(221, 83, 129, 159),
      translucentEffect: true,
    ),
    _MainSquareStyleOption(
      id: 'translucent_blue',
      label: '반투명 블루',
      backgroundColor: Color.fromARGB(120, 226, 245, 255),
      gradientColors: [
        Color.fromARGB(145, 255, 255, 255),
        Color.fromARGB(95, 181, 226, 255),
      ],
      borderColor: Color.fromARGB(150, 137, 199, 238),
      iconColor: Color(0xFF4E94C5),
      titleColor: Color(0xFF18334A),
      subtitleColor: Color(0xFF5F8CA8),
      translucentEffect: true,
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

  static const List<_MainSquareIconColorOption> _mainSquareIconColors = [
    _MainSquareIconColorOption(id: 'style', label: '기본'),
    _MainSquareIconColorOption(
      id: 'blue',
      label: '블루',
      color: Color.fromARGB(221, 83, 129, 159),
    ),
    _MainSquareIconColorOption(id: 'black', label: '블랙', color: Colors.black87),
    _MainSquareIconColorOption(id: 'white', label: '화이트', color: Colors.white),
    _MainSquareIconColorOption(
      id: 'pink',
      label: '핑크',
      color: Color(0xFFD95F8D),
    ),
    _MainSquareIconColorOption(
      id: 'lavender',
      label: '라벤더',
      color: Color(0xFF7B67C8),
    ),
    _MainSquareIconColorOption(
      id: 'mint',
      label: '민트',
      color: Color(0xFF3B9D7A),
    ),
    _MainSquareIconColorOption(
      id: 'gold',
      label: '골드',
      color: Color(0xFFB48A35),
    ),
  ];

  static const List<_MainSquareTextColorOption> _mainSquareTextColors = [
    _MainSquareTextColorOption(id: 'style', label: '기본'),
    _MainSquareTextColorOption(
      id: 'navy',
      label: '네이비',
      titleColor: Color(0xFF102235),
      subtitleColor: Color(0xFF335E7E),
    ),
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
      titleColor: Color(0xFFD95F8D),
      subtitleColor: Color(0xFFB35B7A),
    ),
    _MainSquareTextColorOption(
      id: 'lavender',
      label: '라벤더',
      titleColor: Color(0xFF7B67C8),
      subtitleColor: Color(0xFF7669A8),
    ),
    _MainSquareTextColorOption(
      id: 'mint',
      label: '민트',
      titleColor: Color(0xFF3B9D7A),
      subtitleColor: Color(0xFF5B987F),
    ),
    _MainSquareTextColorOption(
      id: 'gold',
      label: '골드',
      titleColor: Color(0xFFB48A35),
      subtitleColor: Color(0xFF967A42),
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

  _MainSquareIconColorOption get _mainSquareIconColor =>
      _mainSquareIconColors.firstWhere(
        (e) => e.id == _mainSquareIconColorId,
        orElse: () => _mainSquareIconColors.first,
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
                                iconColor: _mainSquareIconColor.resolveColor(
                                  _mainSquareStyle,
                                ),
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
    final savedStyle = prefs.getString(_mainSquareStylePrefsKey);
    final savedCardRatio = prefs.getString(_mainSquareCardRatioPrefsKey);
    final savedIcon = prefs.getString(_mainSquareIconPrefsKey);
    final savedShowIcon = prefs.getBool(_mainSquareShowIconPrefsKey);
    final savedIconSize = prefs.getDouble(_mainSquareIconSizePrefsKey);
    final savedIconThinness = prefs.getDouble(_mainSquareIconThinnessPrefsKey);
    final savedIconColor = prefs.getString(_mainSquareIconColorPrefsKey);
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

      if (_mainSquareIconColors.any((e) => e.id == savedIconColor)) {
        _mainSquareIconColorId = savedIconColor!;
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
    await prefs.setString(_mainSquareIconColorPrefsKey, settings.iconColorId);
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
      _mainSquareStyleId = settings.styleId;
      _mainSquareCardRatioId = settings.cardRatioId;
      _mainSquareIconId = settings.iconId;
      _mainSquareShowIcon = settings.showIcon;
      _mainSquareIconSize = settings.iconSize.clamp(20.0, 72.0).toDouble();
      _mainSquareIconThinness =
          settings.iconThinness.clamp(0.0, 100.0).toDouble();
      _mainSquareIconColorId = settings.iconColorId;
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
      builder: (_) {
        return _MainSquareCustomizeSheet(
          styles: _mainSquareStyles,
          cardRatios: _mainSquareCardRatios,
          icons: _mainSquareIcons,
          iconColors: _mainSquareIconColors,
          textColors: _mainSquareTextColors,
          borders: _mainSquareBorders,
          contentPositions: _mainSquareContentPositions,
          initialSettings: _MainSquareCardSettings(
            title: _mainSquareTitle,
            subtitle: _mainSquareSubtitle,
            styleId: _mainSquareStyleId,
            cardRatioId: _mainSquareCardRatioId,
            iconId: _mainSquareIconId,
            showIcon: _mainSquareShowIcon,
            iconSize: _mainSquareIconSize,
            iconThinness: _mainSquareIconThinness,
            iconColorId: _mainSquareIconColorId,
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
  final String styleId;
  final String cardRatioId;
  final String iconId;
  final bool showIcon;
  final double iconSize;
  final double iconThinness;
  final String iconColorId;
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
    required this.styleId,
    required this.cardRatioId,
    required this.iconId,
    required this.showIcon,
    required this.iconSize,
    required this.iconThinness,
    required this.iconColorId,
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
    String? styleId,
    String? cardRatioId,
    String? iconId,
    bool? showIcon,
    double? iconSize,
    double? iconThinness,
    String? iconColorId,
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
      styleId: styleId ?? this.styleId,
      cardRatioId: cardRatioId ?? this.cardRatioId,
      iconId: iconId ?? this.iconId,
      showIcon: showIcon ?? this.showIcon,
      iconSize: iconSize ?? this.iconSize,
      iconThinness: iconThinness ?? this.iconThinness,
      iconColorId: iconColorId ?? this.iconColorId,
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
      'styleId': styleId,
      'cardRatioId': cardRatioId,
      'iconId': iconId,
      'showIcon': showIcon,
      'iconSize': iconSize,
      'iconThinness': iconThinness,
      'iconColorId': iconColorId,
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
      iconColorId: (map['iconColorId'] as String?) ?? 'style',
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
  final bool glassEffect;
  final bool translucentEffect;
  final Color borderColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;

  const _MainSquareStyleOption({
    required this.id,
    required this.label,
    required this.backgroundColor,
    this.gradientColors,
    this.glassEffect = false,
    this.translucentEffect = false,
    required this.borderColor,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
  });

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

class _MainSquareIconColorOption {
  final String id;
  final String label;
  final Color? color;

  const _MainSquareIconColorOption({
    required this.id,
    required this.label,
    this.color,
  });

  Color resolveColor(_MainSquareStyleOption style) {
    return color ?? style.iconColor;
  }
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
    required this.iconColors,
    required this.textColors,
    required this.borders,
    required this.contentPositions,
    required this.initialSettings,
    required this.onSave,
  });

  final List<_MainSquareStyleOption> styles;
  final List<_MainSquareCardRatioOption> cardRatios;
  final List<_MainSquareIconOption> icons;
  final List<_MainSquareIconColorOption> iconColors;
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
  late String _styleId;
  late String _cardRatioId;
  late String _iconId;
  late bool _showIcon;
  late double _iconSize;
  late double _iconThinness;
  late String _iconColorId;
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

  _MainSquareIconColorOption get _selectedIconColor =>
      widget.iconColors.firstWhere(
        (e) => e.id == _iconColorId,
        orElse: () => widget.iconColors.first,
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
    _styleId = widget.initialSettings.styleId;
    _cardRatioId = widget.initialSettings.cardRatioId;
    _iconId = widget.initialSettings.iconId;
    _showIcon = widget.initialSettings.showIcon;
    _iconSize = widget.initialSettings.iconSize.clamp(20.0, 72.0).toDouble();
    _iconThinness =
        widget.initialSettings.iconThinness.clamp(0.0, 100.0).toDouble();
    _iconColorId = widget.initialSettings.iconColorId;
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
      styleId: _styleId,
      cardRatioId: _cardRatioId,
      iconId: _iconId,
      showIcon: _showIcon,
      iconSize: _iconSize,
      iconThinness: _iconThinness,
      iconColorId: _iconColorId,
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
      _styleId = settings.styleId;
      _cardRatioId = settings.cardRatioId;
      _iconId = settings.iconId;
      _showIcon = settings.showIcon;
      _iconSize = settings.iconSize.clamp(20.0, 72.0).toDouble();
      _iconThinness = settings.iconThinness.clamp(0.0, 100.0).toDouble();
      _iconColorId = settings.iconColorId;
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
          title: const Text('프리셋 이름'),
          content: TextFormField(
            initialValue: draftName,
            autofocus: true,
            maxLength: 16,
            decoration: const InputDecoration(
              hintText: '예: 사진 포스터',
              counterText: '',
            ),
            onChanged: (value) {
              draftName = value;
            },
            onFieldSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
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
      _styleId = 'white';
      _cardRatioId = 'square';
      _iconId = 'add';
      _showIcon = true;
      _iconSize = 36;
      _iconThinness = 50;
      _iconColorId = 'style';
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

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
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

  Widget _smallActionButton({
    required String text,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor:
            destructive ? const Color(0xFFE15F7A) : const Color(0xFF4E94C5),
        side: BorderSide(
          color:
              destructive ? const Color(0xFFFFCDD8) : const Color(0xFFD7E6F4),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text),
    );
  }

  Widget _positionChoices({
    required String selectedId,
    required ValueChanged<String> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          widget.contentPositions.map((option) {
            final selected = selectedId == option.id;

            return ChoiceChip(
              selected: selected,
              label: Text(option.label),
              selectedColor: const Color(0xFFEAF7FF),
              backgroundColor: Colors.white,
              side: BorderSide(
                color:
                    selected
                        ? const Color(0xFF77BCEB)
                        : const Color(0xFFD7E6F4),
              ),
              onSelected: (_) => onChanged(option.id),
            );
          }).toList(),
    );
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

            final previewCard = FittedBox(
              fit: BoxFit.contain,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: 240 * _selectedCardRatio.aspectRatio,
                height: 240,
                child: AddSquareCard(
                  onTap: () {},
                  title: _titleController.text,
                  subtitle: _subtitleController.text,
                  icon: _selectedIcon.icon,
                  showIcon: _showIcon,
                  iconSize: _iconSize,
                  iconThinness: _iconThinness,
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
                  iconColor: _selectedIconColor.resolveColor(_selectedStyle),
                  titleColor: _selectedTextColor.resolveTitleColor(
                    _selectedStyle,
                  ),
                  subtitleColor: _selectedTextColor.resolveSubtitleColor(
                    _selectedStyle,
                  ),
                  showCustomizeButton: false,
                ),
              ),
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
                    previewCard,
                    if (canDragImage)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -28,
                        child: IgnorePointer(
                          child: Text(
                            '위치 · 확대/축소 · 더블 탭 초기화',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: const Color(
                                0xFF5F7D9B,
                              ).withValues(alpha: 0.85),
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9E4EF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '메인 카드 꾸미기',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    TextButton(onPressed: _reset, child: const Text('초기화')),
                  ],
                ),
                const SizedBox(height: 14),
                _mainCardPreview(),
                const SizedBox(height: 52),
                _sectionTitle('효과'),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _threeDGlassMode,
                  title: const Text(
                    '글라스 모드',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    '투명한 유리, 배경 흐림, 렌즈 반사를 적용합니다.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6F879F)),
                  ),
                  activeThumbColor: const Color(0xFF77BCEB),
                  activeTrackColor: const Color(
                    0xFF77BCEB,
                  ).withValues(alpha: 0.28),
                  onChanged: (value) {
                    setState(() {
                      _threeDGlassMode = value;

                      // 글라스 모드를 켤 때는 기본값을 화이트로 맞춥니다.
                      // 이후 사용자가 문구/아이콘 색상을 다시 선택하면 그 색상이 적용됩니다.
                      if (value) {
                        _textColorId = 'white';
                        _iconColorId = 'white';
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),
                _sectionTitle('프리셋'),
                Row(
                  children: [
                    _smallActionButton(
                      text: '현재 프리셋 저장',
                      onTap: _saveCurrentAsPreset,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '저장한 조합은 칩을 눌러 다시 적용할 수 있습니다.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6F879F),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_savedPresets.isEmpty)
                  const Text(
                    '저장된 프리셋이 없습니다.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8AA0B6)),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _savedPresets.map((preset) {
                          return InputChip(
                            label: Text(preset.name),
                            selectedColor: const Color(0xFFEAF7FF),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFD7E6F4)),
                            onSelected: (_) {
                              _applySettings(preset.settings);
                            },
                            onDeleted: () => _deletePreset(preset.id),
                            deleteIcon: const Icon(Icons.close, size: 16),
                          );
                        }).toList(),
                  ),
                const SizedBox(height: 20),
                _sectionTitle('카드 비율'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      widget.cardRatios.map((option) {
                        final selected = _cardRatioId == option.id;

                        return ChoiceChip(
                          selected: selected,
                          avatar: Container(
                            width: option.aspectRatio >= 1 ? 20 : 14,
                            height: option.aspectRatio >= 1 ? 14 : 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color:
                                    selected
                                        ? const Color(0xFF77BCEB)
                                        : const Color(0xFFB7C7D7),
                                width: selected ? 1.4 : 1,
                              ),
                            ),
                          ),
                          label: Text('${option.label} ${option.description}'),
                          selectedColor: const Color(0xFFEAF7FF),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color:
                                selected
                                    ? const Color(0xFF77BCEB)
                                    : const Color(0xFFD7E6F4),
                          ),
                          onSelected: (_) {
                            setState(() => _cardRatioId = option.id);
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
                _sectionTitle('문구'),
                TextField(
                  controller: _titleController,
                  maxLength: 23,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: '큰 문구',
                    hintText: '새 작품 만들기',
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF8FBFF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFD7E6F4)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFD7E6F4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF77BCEB),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _subtitleController,
                  maxLength: 40,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: '작은 문구',
                    hintText: '선택 사항',
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF8FBFF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFD7E6F4)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFD7E6F4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF77BCEB),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _sectionTitle('텍스트 위치'),
                _positionChoices(
                  selectedId: _textPositionId,
                  onChanged: (id) => setState(() => _textPositionId = id),
                ),
                const SizedBox(height: 20),
                _sectionTitle('문구 색상'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      widget.textColors.map((option) {
                        final color = option.resolveTitleColor(_selectedStyle);
                        final selected = _textColorId == option.id;

                        return ChoiceChip(
                          selected: selected,
                          avatar: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    option.id == 'white'
                                        ? const Color(0xFFB7C7D7)
                                        : color,
                              ),
                            ),
                          ),
                          label: Text(option.label),
                          selectedColor: const Color(0xFFEAF7FF),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color:
                                selected
                                    ? const Color(0xFF77BCEB)
                                    : const Color(0xFFD7E6F4),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _textColorId = option.id;

                              // 글라스 모드에서 다른 색상을 직접 고르면
                              // 사진 위 밝은 문구 자동 흰색 우선 적용을 끕니다.
                              if (_threeDGlassMode && option.id != 'white') {
                                _useLightContentOnImage = false;
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
                if (_hasBackgroundImage && _useLightContentOnImage) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '밝은 문구 모드가 켜져 있으면 사진 위에서는 흰색 문구가 우선 적용됩니다.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6F7F91),
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _sectionTitle('배경 스타일'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      widget.styles.map((style) {
                        return ChoiceChip(
                          selected: _styleId == style.id,
                          avatar: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color:
                                  style.gradient == null
                                      ? style.backgroundColor
                                      : null,
                              gradient: style.gradient,
                              shape: BoxShape.circle,
                              border: Border.all(color: style.borderColor),
                            ),
                          ),
                          label: Text(style.label),
                          selectedColor: const Color(0xFFEAF7FF),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color:
                                _styleId == style.id
                                    ? const Color(0xFF77BCEB)
                                    : const Color(0xFFD7E6F4),
                          ),
                          onSelected: (_) {
                            setState(() => _styleId = style.id);
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
                _sectionTitle('배경 이미지'),
                Row(
                  children: [
                    _smallActionButton(
                      text: '사진 선택',
                      onTap: _pickBackgroundImage,
                    ),
                    const SizedBox(width: 8),
                    if (_hasBackgroundImage)
                      _smallActionButton(
                        text: '이미지 삭제',
                        onTap: _clearBackgroundImage,
                        destructive: true,
                      ),
                  ],
                ),
                if (_hasBackgroundImage) ...[
                  const SizedBox(height: 10),
                  Text(
                    p.basename(_backgroundImagePath),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5F7D9B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(
                        width: 74,
                        child: Text(
                          '투명도',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F7D9B),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _backgroundImageTransparency,
                          min: 0,
                          max: 1,
                          divisions: 10,
                          label:
                              '${(_backgroundImageTransparency * 100).round()}%',
                          onChanged:
                              (value) => setState(
                                () =>
                                    _backgroundImageTransparency =
                                        value.clamp(0.0, 1.0).toDouble(),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FBFF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD7E6F4)),
                    ),
                    child: const Text(
                      '큰 미리보기 카드에서 사진을 직접 드래그해 위치를 바꾸고, 두 손가락으로 확대/축소하세요. 사진 밖 흰 배경이 보이지 않도록 원본 사진 영역 안에서만 움직입니다. 더블 탭하면 위치와 확대가 초기화됩니다.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        color: Color(0xFF5F7D9B),
                      ),
                    ),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _useLightContentOnImage,
                    title: const Text(
                      '어두운 사진용 흰 글자',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      '어두운 배경 이미지를 쓸 때 +와 문구를 흰색으로 바꿉니다.',
                      style: TextStyle(fontSize: 11),
                    ),
                    onChanged:
                        (value) =>
                            setState(() => _useLightContentOnImage = value),
                  ),
                ],
                const SizedBox(height: 20),
                _sectionTitle('테두리 스타일'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      widget.borders.map((option) {
                        final borderColor = option.resolveColor(_selectedStyle);

                        return ChoiceChip(
                          selected: _borderId == option.id,
                          avatar: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border:
                                  option.cardBorderStyle ==
                                          AddSquareCardBorderStyle.none
                                      ? null
                                      : Border.all(
                                        color: borderColor,
                                        width:
                                            option.borderWidth
                                                .clamp(1.0, 2.0)
                                                .toDouble(),
                                      ),
                            ),
                            child:
                                option.cardBorderStyle ==
                                        AddSquareCardBorderStyle.dashed
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
                          selectedColor: const Color(0xFFEAF7FF),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color:
                                _borderId == option.id
                                    ? const Color(0xFF77BCEB)
                                    : const Color(0xFFD7E6F4),
                          ),
                          onSelected: (_) {
                            setState(() => _borderId = option.id);
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
                _sectionTitle('아이콘'),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _showIcon,
                  title: const Text(
                    '아이콘 보이기',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  onChanged: (value) => setState(() => _showIcon = value),
                ),
                if (_showIcon) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        widget.icons.map((option) {
                          return ChoiceChip(
                            selected: _iconId == option.id,
                            avatar: Icon(option.icon, size: 18),
                            label: Text(option.label),
                            selectedColor: const Color(0xFFEAF7FF),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color:
                                  _iconId == option.id
                                      ? const Color(0xFF77BCEB)
                                      : const Color(0xFFD7E6F4),
                            ),
                            onSelected: (_) {
                              setState(() => _iconId = option.id);
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '아이콘 위치',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _positionChoices(
                    selectedId: _iconPositionId,
                    onChanged: (id) => setState(() => _iconPositionId = id),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(
                        width: 74,
                        child: Text(
                          '크기',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F7D9B),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _iconSize.clamp(20.0, 72.0).toDouble(),
                          min: 20,
                          max: 72,
                          divisions: 13,
                          label: '${_iconSize.round()}px',
                          onChanged:
                              (value) => setState(
                                () =>
                                    _iconSize =
                                        value.clamp(20.0, 72.0).toDouble(),
                              ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 74,
                        child: Text(
                          '얇기',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F7D9B),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _iconThinness.clamp(0.0, 100.0).toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 10,
                          label: '${_iconThinness.round()}%',
                          onChanged:
                              (value) => setState(
                                () =>
                                    _iconThinness =
                                        value.clamp(0.0, 100.0).toDouble(),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '아이콘 색상',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        widget.iconColors.map((option) {
                          final color = option.resolveColor(_selectedStyle);

                          return ChoiceChip(
                            selected: _iconColorId == option.id,
                            avatar: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      option.id == 'white'
                                          ? const Color(0xFFB7C7D7)
                                          : color,
                                ),
                              ),
                            ),
                            label: Text(option.label),
                            selectedColor: const Color(0xFFEAF7FF),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color:
                                  _iconColorId == option.id
                                      ? const Color(0xFF77BCEB)
                                      : const Color(0xFFD7E6F4),
                            ),
                            onSelected: (_) {
                              setState(() {
                                _iconColorId = option.id;

                                // 글라스 모드에서 다른 아이콘 색상을 직접 고르면
                                // 사진 위 밝은 문구 자동 흰색 우선 적용을 끕니다.
                                if (_threeDGlassMode && option.id != 'white') {
                                  _useLightContentOnImage = false;
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF77BCEB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        _saving
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              '저장',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
