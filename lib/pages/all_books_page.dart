// lib/pages/all_books_page.dart

import 'dart:math'; // 🔹 documentId
import 'book_builder_page.dart'; // 🔹 BookBuilderPage로 이동

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:ebook_tutorial_app/utils/platform_accessibility.dart';
import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_container.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_action_button.dart';

// 🔹 새 카드 디자인 import
import 'package:ebook_tutorial_app/widgets/card_design.dart';

class AllBooksPage extends StatefulWidget {
  const AllBooksPage({
    super.key,
    required this.ebooks,
    required this.onChanged,
  });

  final List<Map<String, dynamic>> ebooks;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  @override
  State<AllBooksPage> createState() => _AllBooksPageState();
}

class _AllBooksPageState extends State<AllBooksPage> {
  // 🔹 카드 사이즈/비율을 A4MiniCard의 값과 맞춤
  static const double _cardWidth = A4MiniCard.a4Width;
  static const double _cardTotalHeight =
      A4MiniCard.a4Height + A4MiniCard.captionGap + A4MiniCard.captionHeight;

  late List<Map<String, dynamic>> _ebooks;
  bool _selectionMode = false;
  final Set<int> _selectedIndices = <int>{};

  bool _reduceTransparencyFlag = false;

  // 🔹 EbookListPage와 동일한 규칙으로 documentId 생성
  String _newDocumentId() =>
      'doc_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 32)}';

  @override
  void initState() {
    super.initState();
    _ebooks = widget.ebooks.map((e) => Map<String, dynamic>.from(e)).toList();
    _initReduceTransparency();
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

  void _reorder(int oldIndex, int newIndex) {
    if (_selectionMode) return;
    if (oldIndex == newIndex ||
        oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= _ebooks.length ||
        newIndex >= _ebooks.length) {
      return;
    }
    setState(() {
      final item = _ebooks.removeAt(oldIndex);
      _ebooks.insert(newIndex, item);
    });
    _emitChange();
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
      barrierColor: Colors.black12,
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
        _selectionMode ? '${_selectedIndices.length}개 선택됨' : '책 목록',
        style: const TextStyle(color: Colors.black),
      ),
      actions: [
        if (_selectionMode)
          IconButton(
            icon: const Icon(CupertinoIcons.delete, color: Colors.black87),
            tooltip: '삭제',
            onPressed: _deleteSelected,
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

  // 🔹 여기서 직접 _A4MiniCard 안 쓰고, card_design.dart의 A4MiniCard 사용
  Widget _buildCardItem({required int index}) {
    final map = _ebooks[index];
    final title = (map['title'] as String?) ?? '제목 없음';
    final preview = _plainFromDelta(
      (map['delta'] as List?)?.cast<Map<String, dynamic>>() ?? const [],
      maxLen: 30,
    );
    final isSelected = _selectedIndices.contains(index);

    // 🔹 표지 경로 가져오기
    final coverPath = map['coverPath'] as String?;

    final card = A4MiniCard(
      title: title,
      preview: preview,
      selected: isSelected,
      coverPath: coverPath,
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

          // 🔹 책 탭 시 BookBuilderPage로 이동
          onTap: () async {
            final book = _ebooks[index];

            // 🔹 레거시 문서면 documentId 부여
            if (book['documentId'] == null) {
              book['documentId'] = _newDocumentId();
            }

            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BookBuilderPage(
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

              // 🔹 새 표지 경로 반영
              book['coverPath'] = result['coverPath'] as String?;
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

              return ReorderableGridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  // 🔹 전체 아이템 비율도 A4MiniCard 기준으로 맞춤
                  childAspectRatio: _cardWidth / _cardTotalHeight,
                ),
                physics: const BouncingScrollPhysics(),
                dragStartDelay: const Duration(milliseconds: 150),
                dragEnabled: !_selectionMode,
                dragWidgetBuilder:
                    (index, child) => Transform.scale(
                      scale: 1.03,
                      child: Material(
                        type: MaterialType.transparency,
                        child: child,
                      ),
                    ),
                onReorder: (oldIndex, newIndex) => _reorder(oldIndex, newIndex),
                itemCount: _ebooks.length,
                itemBuilder: (_, i) {
                  return Container(
                    key: ValueKey('ebook_$i'),
                    child: _buildCardItem(index: i),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
