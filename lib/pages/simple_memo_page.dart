// simple_memo_page.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_container.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_action_button.dart';
import 'package:ebook_tutorial_app/models/memo.dart';
import 'package:ebook_tutorial_app/data/memo_storage.dart';

class SimpleMemoPage extends StatefulWidget {
  const SimpleMemoPage({super.key});
  static const String resultEnterPickMode = 'enter_pick_mode';

  @override
  State<SimpleMemoPage> createState() => _SimpleMemoPageState();
}

class _SectionItem {
  final int index;
  final Memo memo;
  final String title;
  const _SectionItem({
    required this.index,
    required this.memo,
    required this.title,
  });
}

class _SimpleMemoPageState extends State<SimpleMemoPage> {
  final List<Memo> _memos = [];
  bool _selectionMode = false;
  final Set<int> _selectedIndices = <int>{};
  Map<String, List<_SectionItem>> _grouped = {};
  List<String> _sectionKeys = [];

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final loaded = await MemoStorage.load();
    if (!mounted) return;
    setState(() {
      _memos
        ..clear()
        ..addAll(loaded);
      _rebuildSections();
    });
  }

  String _dateKey(DateTime dt) {
    final l = dt.toLocal();
    return '${l.month.toString().padLeft(2, '0')}/${l.day.toString().padLeft(2, '0')}';
  }

  void _rebuildSections() {
    final map = <String, List<_SectionItem>>{};
    for (var i = 0; i < _memos.length; i++) {
      final memo = _memos[i];
      final key = _dateKey(memo.updatedAt); // 표시용 키 (월/일)
      (map[key] ??= <_SectionItem>[]).add(
        _SectionItem(index: i, memo: memo, title: _extractTitle(memo.text)),
      );
    }

    // 🔹
    final keys =
        map.keys.toList()..sort((a, b) {
          final now = DateTime.now().year;
          final am = int.parse(a.substring(0, 2));
          final ad = int.parse(a.substring(3, 5));
          final bm = int.parse(b.substring(0, 2));
          final bd = int.parse(b.substring(3, 5));

          // 실제 비교는 연도 포함 (연도 다르면 뒤로)
          final adt = DateTime(now, am, ad);
          final bdt = DateTime(now, bm, bd);
          return bdt.compareTo(adt); // 최신 날짜가 위로
        });

    _grouped = map;
    _sectionKeys = keys;
  }

  String _extractTitle(String text) {
    final nl = text.indexOf('\n');
    final t = (nl == -1 ? text : text.substring(0, nl)).trim();
    return t.isEmpty ? '제목 없음' : t;
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

  void _toggleSelect(int memoIndex) {
    setState(() {
      if (_selectedIndices.contains(memoIndex)) {
        _selectedIndices.remove(memoIndex);
      } else {
        _selectedIndices.add(memoIndex);
      }
    });
  }

  void _showMoreDialog(BuildContext context) {
    final theme = GlassTheme.fromFlags(reduceTransparency: false);
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
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassActionButton(
                      theme: theme,
                      icon: Icons.checklist_rtl,
                      label: '메모 선택',
                      onPressed: () {
                        Navigator.pop(context);
                        _enterSelectionMode();
                      },
                    ),
                    const SizedBox(height: 10),
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

  Future<void> _openMemoEditor(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      CupertinoPageRoute(
        builder: (_) => const _MemoEditorPage(),
        fullscreenDialog: true,
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _memos.add(Memo(result.trim(), DateTime.now()));
        _rebuildSections();
      });

      unawaited(MemoStorage.save(_memos));
    }
  }

  Future<void> _editMemo(BuildContext context, int index, Memo memo) async {
    final result = await Navigator.of(context).push<String>(
      CupertinoPageRoute(
        builder: (_) => _MemoEditorPage(initialText: memo.text),
        fullscreenDialog: true,
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _memos[index] = Memo(result.trim(), DateTime.now());
        _rebuildSections();
      });
      unawaited(MemoStorage.save(_memos));
    }
  }

  void _deleteSelected() {
    if (_selectedIndices.isEmpty) return;
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => CupertinoActionSheet(
            title: const Text('삭제 확인'),
            message: const Text('선택된 메모를 삭제하시겠습니까?'),
            actions: [
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () async {
                  setState(() {
                    final sorted =
                        _selectedIndices.toList()..sort((a, b) => b - a);
                    for (final i in sorted) {
                      if (i >= 0 && i < _memos.length) {
                        _memos.removeAt(i);
                      }
                    }
                    _exitSelectionMode();
                    _rebuildSections();
                  });
                  Navigator.pop(context);
                  unawaited(MemoStorage.save(_memos));
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

  List<Widget> _buildSectionSlivers() {
    final slivers = <Widget>[];
    for (var s = 0; s < _sectionKeys.length; s++) {
      final key = _sectionKeys[s];
      final items = _grouped[key]!;

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: s == 0 ? 8 : 6,
              top: s == 0 ? 8 : 18,
            ),
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = items[index];
              final memoIndex = item.index;
              final memo = item.memo;
              final title = item.title;
              final text = memo.text;

              final card = Column(
                key: ValueKey(memoIndex),
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Material(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color:
                              (_selectionMode &&
                                      _selectedIndices.contains(memoIndex))
                                  ? Colors.blue.shade100
                                  : const Color.fromARGB(221, 117, 160, 191),
                          width: 0.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            text,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 16,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              );

              if (_selectionMode) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _toggleSelect(memoIndex),
                  child: card,
                );
              } else {
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _editMemo(context, memoIndex, memo),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  child: card,
                );
              }
            }, childCount: items.length),
          ),
        ),
      );
    }
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    final hasMemos = _memos.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _selectionMode ? '${_selectedIndices.length}개 선택됨' : '간단 메모',
          style: const TextStyle(color: Colors.black87),
        ),
        leading:
            _selectionMode
                ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  tooltip: '선택 취소',
                  onPressed: _exitSelectionMode,
                )
                : IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  tooltip: '뒤로가기',
                  onPressed: () => Navigator.pop(context, true),
                ),
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(CupertinoIcons.delete, color: Colors.black87),
              tooltip: '삭제',
              onPressed: _deleteSelected,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: '새 메모 추가',
              onPressed: () => _openMemoEditor(context),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: '더보기',
              onPressed: () => _showMoreDialog(context),
            ),
          ],
        ],
      ),
      body: CustomScrollView(
        slivers: [
          if (!hasMemos)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '저장된 메모가 없습니다.\n오른쪽 상단 + 버튼으로 메모를 추가하세요.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            )
          else
            ..._buildSectionSlivers(),
        ],
      ),
    );
  }
}

class _MemoEditorPage extends StatefulWidget {
  final String? initialText;
  const _MemoEditorPage({this.initialText});

  @override
  State<_MemoEditorPage> createState() => _MemoEditorPageState();
}

class _MemoEditorPageState extends State<_MemoEditorPage> {
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

  void _cancel() => Navigator.of(context).maybePop();
  void _save() => Navigator.of(context).maybePop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: Text(widget.initialText == null ? 'New Memo' : 'Edit Memo'),
        leading: CupertinoNavigationBarBackButton(
          color: const Color.fromARGB(255, 52, 96, 143),
          onPressed: _cancel,
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
              placeholderStyle: const TextStyle(
                color: Color.fromARGB(221, 100, 159, 198),
                fontSize: 15,
              ),
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
