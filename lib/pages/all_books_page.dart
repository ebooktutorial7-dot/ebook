// all_books_page.dart

import 'dart:math';
import 'book_builder_page.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ebook_tutorial_app/utils/platform_accessibility.dart';
import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_container.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_action_button.dart';
import 'package:ebook_tutorial_app/models/genre.dart';
import 'package:ebook_tutorial_app/widgets/card_design.dart';

class AllBooksPage extends StatefulWidget {
  const AllBooksPage({
    super.key,
    required this.ebooks,
    required this.onChanged,
    this.startInSelectionMode = false,
  });

  final List<Map<String, dynamic>> ebooks;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;
  final bool startInSelectionMode;

  @override
  State<AllBooksPage> createState() => _AllBooksPageState();
}

class _AllBooksPageState extends State<AllBooksPage> {
  static const double _cardWidth = A4MiniCard.a4Width;
  static const double _cardTotalHeight =
      A4MiniCard.a4Height + A4MiniCard.captionGap + A4MiniCard.captionHeight;

  late List<Map<String, dynamic>> _ebooks;
  bool _selectionMode = false;
  final Set<int> _selectedIndices = <int>{};

  bool _reduceTransparencyFlag = false;

  String _newDocumentId() =>
      'doc_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 32)}';

  @override
  void initState() {
    super.initState();
    _ebooks = widget.ebooks.map((e) => Map<String, dynamic>.from(e)).toList();
    _sortBooksByLatestEdit();
    _initReduceTransparency();

    if (widget.startInSelectionMode) {
      _selectionMode = true;
      _selectedIndices.clear();
    }
  }

  Future<void> _initReduceTransparency() async {
    final flag = await PlatformAccessibility.getReduceTransparencyFlag();
    if (!mounted) return;
    setState(() => _reduceTransparencyFlag = flag);
  }

  GlassTheme get _glassTheme =>
      GlassTheme.fromFlags(reduceTransparency: _reduceTransparencyFlag);

  String _plainFromDelta(List<Map<String, dynamic>> delta, {int maxLen = 20}) {
    final buf = StringBuffer();
    for (final op in delta) {
      final insert = op['insert'];
      if (insert is String) {
        buf.write(insert);
        if (buf.length >= maxLen) break;
      }
    }
    final full = buf.toString().replaceAll('\n', ' ').trim();
    return (full.length <= maxLen) ? full : '${full.substring(0, maxLen - 1)}…';
  }

  void _emitChange() {
    final next = _ebooks.map((e) => Map<String, dynamic>.from(e)).toList();
    widget.onChanged(next);
  }

  DateTime _parseUpdatedAt(Map<String, dynamic> book) {
    final raw = book['updatedAt'];
    if (raw is String) {
      return DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _sortBooksByLatestEdit() {
    _ebooks.sort((a, b) {
      final aTime = _parseUpdatedAt(a);
      final bTime = _parseUpdatedAt(b);
      return bTime.compareTo(aTime); // 최신 편집이 앞
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _selectionMode = true;
      _selectedIndices.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIndices.clear();
    });
  }

  void _toggleSelect(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _deleteSelected() {
    if (_selectedIndices.isEmpty) return;
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => CupertinoActionSheet(
            title: const Text('삭제 확인'),
            message: const Text('선택된 책을 삭제하시겠습니까?'),
            actions: [
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  setState(() {
                    final sorted =
                        _selectedIndices.toList()..sort((a, b) => b - a);
                    for (final i in sorted) {
                      if (i >= 0 && i < _ebooks.length) {
                        _ebooks.removeAt(i);
                      }
                    }
                    _exitSelectionMode();
                  });
                  Navigator.pop(context);
                  _emitChange();
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

  void _showMoreDialog() {
    final theme = _glassTheme;
    showDialog(
      context: context,
      barrierColor: const Color(0xFF0F2238).withValues(alpha: 0.13),
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
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '더보기',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassActionButton(
                      theme: theme,
                      icon: Icons.checklist_rtl,
                      label: '책 선택',
                      onPressed: () {
                        Navigator.pop(context);
                        _enterSelectionMode();
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        '닫기',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.accentColor,
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading:
          _selectionMode
              ? IconButton(
                icon: const Icon(Icons.close, color: Colors.black87),
                tooltip: '선택 취소',
                onPressed: _exitSelectionMode,
              )
              : null,
      title: Text(
        _selectionMode ? '${_selectedIndices.length}개 선택됨' : 'book list',
        style: const TextStyle(color: Colors.black),
      ),
      actions: [
        if (_selectionMode)
          TextButton(
            onPressed: _deleteSelected,
            child: const Text(
              'Delete',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            tooltip: '더보기',
            onPressed: _showMoreDialog,
          ),
      ],
    );
  }

  Widget _buildCardItem({required int index}) {
    final map = _ebooks[index];
    final title = (map['title'] as String?) ?? '제목 없음';
    final preview = _plainFromDelta(
      (map['delta'] as List?)?.cast<Map<String, dynamic>>() ?? const [],
      maxLen: 30,
    );
    final isSelected = _selectedIndices.contains(index);

    final coverPath = map['coverPath'] as String?;

    final card = A4MiniCard(
      title: title,
      preview: preview,
      selected: isSelected,
      coverPath: coverPath,
      selectionMode: _selectionMode,
    );

    if (_selectionMode) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggleSelect(index),
        child: card,
      );
    } else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          enableFeedback: false,
          borderRadius: BorderRadius.circular(16),

          onTap: () async {
            final book = _ebooks[index];

            if (book['documentId'] == null) {
              book['documentId'] = _newDocumentId();
            }
            final genreName = book['genre'] as String?;
            final genre = Genre.values.firstWhere(
              (e) => e.name == genreName,
              orElse: () => Genre.webNovel,
            );
            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BookBuilderPage(
                      genre: genre,
                      initialTitle: (book['title'] as String?) ?? '제목을 입력하세요',
                      initialDeltaJson:
                          (book['delta'] as List?)
                              ?.cast<Map<String, dynamic>>() ??
                          const [],
                      initialDrawingJson:
                          (book['drawings'] as List?)
                              ?.cast<Map<String, dynamic>>() ??
                          const [],
                      pageIndex: index,
                      initialPenName: (book['penName'] as String?) ?? '',
                      documentId: book['documentId'] as String,
                    ),
              ),
            );

            if (!mounted || result == null) return;

            setState(() {
              book['title'] =
                  (result['title'] as String?) ?? (book['title'] as String?);

              book['delta'] =
                  (result['delta'] as List?)?.cast<Map<String, dynamic>>() ??
                  (book['delta'] as List? ?? const []);

              book['drawings'] =
                  (result['drawings'] as List?)?.cast<Map<String, dynamic>>() ??
                  (book['drawings'] as List? ?? const []);

              book['penName'] =
                  (result['penName'] as String?) ??
                  (book['penName'] as String? ?? '');

              book['documentId'] =
                  (result['documentId'] as String?) ??
                  (book['documentId'] as String);

              if (result['chapters'] != null) {
                book['chapters'] =
                    (result['chapters'] as List)
                        .map(
                          (e) =>
                              e is Map<String, dynamic>
                                  ? e
                                  : Map<String, dynamic>.from(e as Map),
                        )
                        .toList();
              }

              book['updatedAt'] =
                  result['updatedAt'] ?? DateTime.now().toIso8601String();

              book['coverPath'] = result['coverPath'] as String?;

              _sortBooksByLatestEdit();
            });

            _emitChange();
          },
          child: card,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth / (_cardWidth + 16))
                  .floor()
                  .clamp(2, 6);

              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: _cardWidth / _cardTotalHeight,
                ),
                itemCount: _ebooks.length,
                itemBuilder: (_, i) {
                  return _buildCardItem(index: i);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
