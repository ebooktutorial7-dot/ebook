// simple_memo_page.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_container.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_action_button.dart';
import 'package:ebook_tutorial_app/models/memo.dart';
import 'package:ebook_tutorial_app/data/memo_storage.dart';
import 'package:ebook_tutorial_app/models/genre.dart';
import 'package:ebook_tutorial_app/l10n/generated/app_localizations.dart';

extension _SimpleMemoL10nContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class SimpleMemoPage extends StatefulWidget {
  const SimpleMemoPage({super.key, required this.genre});

  final Genre genre;

  @override
  State<SimpleMemoPage> createState() => _SimpleMemoPageState();
}

class _SectionItem {
  final Genre genre;
  final int index;
  final Memo memo;
  final String title;

  const _SectionItem({
    required this.genre,
    required this.index,
    required this.memo,
    required this.title,
  });
}

class _SimpleMemoPageState extends State<SimpleMemoPage> {
  final Map<Genre, List<Memo>> _memosByGenre = {};
  bool _selectionMode = false;
  final Set<String> _selectedKeys = <String>{};

  Map<String, List<_SectionItem>> _grouped = {};
  List<String> _sectionKeys = [];

  static const Color _selectedBorderColor = Color.fromARGB(255, 91, 179, 255);
  static const double _selectedBorderWidth = 1.7;

  static const Color _normalBorderColor = Color.fromARGB(221, 117, 198, 255);
  static const double _normalBorderWidth = 0.5;

  bool get _isMain => widget.genre == Genre.main;

  String _storageKeyOf(Genre genre) => 'memo_${genre.name}';

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final next = <Genre, List<Memo>>{};

    if (_isMain) {
      for (final genre in Genre.values) {
        if (genre == Genre.main) continue;
        final loaded = await MemoStorage.load(key: _storageKeyOf(genre));
        next[genre] = loaded;
      }
    } else {
      final loaded = await MemoStorage.load(key: _storageKeyOf(widget.genre));
      next[widget.genre] = loaded;
    }

    if (!mounted) return;

    final l10n = context.l10n;

    setState(() {
      _memosByGenre
        ..clear()
        ..addAll(next);
      _rebuildSections(l10n);
    });
  }

  Future<void> _saveGenre(Genre genre) async {
    final memos = _memosByGenre[genre] ?? <Memo>[];
    await MemoStorage.save(memos, key: _storageKeyOf(genre));
  }

  String _groupKey(DateTime dt) {
    final l = dt.toLocal();
    return '${l.year.toString().padLeft(4, '0')}-'
        '${l.month.toString().padLeft(2, '0')}-'
        '${l.day.toString().padLeft(2, '0')}';
  }

  String _sectionLabel(String key) {
    if (key.length != 10) return key;
    return '${key.substring(5, 7)}/${key.substring(8, 10)}';
  }

  String _itemKey(Genre genre, int index) => '${genre.name}_$index';

  String _genreLabel(BuildContext context, Genre genre) {
    final l10n = context.l10n;

    switch (genre) {
      case Genre.main:
        return l10n.bookListTitle;
      case Genre.webNovel:
        return l10n.genreWebNovel;
      case Genre.novel:
        return l10n.genreNovel;
      case Genre.poem:
        return l10n.genrePoetry;
      case Genre.freeForm:
        return l10n.genreFreeForm;
      case Genre.selfHelp:
        return l10n.genreSelfImprovement;
      case Genre.science:
        return l10n.genreScienceBook;
    }
  }

  void _rebuildSections(AppLocalizations l10n) {
    final items = <_SectionItem>[];

    for (final entry in _memosByGenre.entries) {
      final genre = entry.key;
      final memos = entry.value;

      for (var i = 0; i < memos.length; i++) {
        final memo = memos[i];
        items.add(
          _SectionItem(
            genre: genre,
            index: i,
            memo: memo,
            title: _extractTitle(memo.text, l10n),
          ),
        );
      }
    }

    items.sort((a, b) => b.memo.updatedAt.compareTo(a.memo.updatedAt));

    final grouped = <String, List<_SectionItem>>{};
    for (final item in items) {
      final key = _groupKey(item.memo.updatedAt);
      (grouped[key] ??= <_SectionItem>[]).add(item);
    }

    _grouped = grouped;
    _sectionKeys = grouped.keys.toList();
  }

  String _extractTitle(String text, AppLocalizations l10n) {
    final nl = text.indexOf('\n');
    final t = (nl == -1 ? text : text.substring(0, nl)).trim();
    return t.isEmpty ? l10n.untitledBook : t;
  }

  IconData _genreIcon(Genre genre) {
    switch (genre) {
      case Genre.main:
        return Icons.home;
      case Genre.webNovel:
        return Icons.auto_stories;
      case Genre.novel:
        return Icons.menu_book;
      case Genre.poem:
        return Icons.format_quote;
      case Genre.freeForm:
        return Icons.edit_note;
      case Genre.selfHelp:
        return Icons.self_improvement;
      case Genre.science:
        return Icons.science;
    }
  }

  Future<Genre?> _pickGenreForMain() async {
    if (!_isMain) return widget.genre;

    final theme = GlassTheme.fromFlags(reduceTransparency: false);
    final genres = Genre.values.where((e) => e != Genre.main).toList();

    return showDialog<Genre>(
      context: context,
      barrierColor: const Color(0xFF0F2238).withValues(alpha: 0.13),
      builder:
          (dialogCtx) => Dialog(
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
                    Text(
                      context.l10n.genreSelect,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final genre in genres) ...[
                      GlassActionButton(
                        theme: theme,
                        icon: _genreIcon(genre),
                        label: _genreLabel(context, genre),
                        onPressed: () => Navigator.of(dialogCtx).pop(genre),
                      ),
                      const SizedBox(height: 8),
                    ],
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      child: Text(
                        context.l10n.close,
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

  void _enterSelectionMode() {
    setState(() {
      _selectionMode = true;
      _selectedKeys.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedKeys.clear();
    });
  }

  void _toggleSelect(String key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });
  }

  void _showMoreDialog(BuildContext context) {
    final theme = GlassTheme.fromFlags(reduceTransparency: false);

    showDialog(
      context: context,
      barrierColor: const Color(0xFF0F2238).withValues(alpha: 0.13),
      builder:
          (dialogCtx) => Dialog(
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
                    Text(
                      context.l10n.more,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassActionButton(
                      theme: theme,
                      icon: Icons.checklist_rtl,
                      label: context.l10n.selectMemo,
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        _enterSelectionMode();
                      },
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      child: Text(
                        context.l10n.close,
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

  Future<void> _openMemoEditor() async {
    Genre targetGenre = widget.genre;

    if (_isMain) {
      final pickedGenre = await _pickGenreForMain();
      if (!mounted) return;
      if (pickedGenre == null) return;
      targetGenre = pickedGenre;
    }

    final result = await Navigator.of(context).push<String>(
      CupertinoPageRoute(
        builder: (_) => const _MemoEditorPage(),
        fullscreenDialog: true,
      ),
    );

    if (!mounted) return;
    if (result == null || result.trim().isEmpty) return;

    final l10n = context.l10n;

    setState(() {
      final list = _memosByGenre[targetGenre] ?? <Memo>[];
      list.add(Memo(result.trim(), DateTime.now()));
      _memosByGenre[targetGenre] = list;
      _rebuildSections(l10n);
    });

    await _saveGenre(targetGenre);
  }

  Future<void> _editMemo(
    BuildContext context,
    Genre genre,
    int index,
    Memo memo,
  ) async {
    final result = await Navigator.of(context).push<String>(
      CupertinoPageRoute(
        builder: (_) => _MemoEditorPage(initialText: memo.text),
        fullscreenDialog: true,
      ),
    );

    if (!mounted) return;
    if (result == null || result.trim().isEmpty) return;

    final l10n = this.context.l10n;

    setState(() {
      final list = _memosByGenre[genre] ?? <Memo>[];
      if (index >= 0 && index < list.length) {
        list[index] = Memo(result.trim(), DateTime.now());
        _memosByGenre[genre] = list;
        _rebuildSections(l10n);
      }
    });

    await _saveGenre(genre);
  }

  void _deleteSelected() {
    if (_selectedKeys.isEmpty) return;

    showCupertinoModalPopup(
      context: context,
      builder: (sheetCtx) {
        return CupertinoActionSheet(
          title: Text(context.l10n.deleteBooksConfirmTitle),
          message: Text(context.l10n.selectedMemosDeleteMessage),
          actions: [
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () async {
                final itemMap = <String, _SectionItem>{};
                for (final key in _sectionKeys) {
                  for (final item in _grouped[key] ?? const <_SectionItem>[]) {
                    itemMap[_itemKey(item.genre, item.index)] = item;
                  }
                }

                final removeByGenre = <Genre, List<int>>{};
                for (final key in _selectedKeys) {
                  final item = itemMap[key];
                  if (item == null) continue;
                  (removeByGenre[item.genre] ??= <int>[]).add(item.index);
                }

                final l10n = context.l10n;

                setState(() {
                  for (final entry in removeByGenre.entries) {
                    final genre = entry.key;
                    final indices = entry.value..sort((a, b) => b.compareTo(a));
                    final list = _memosByGenre[genre] ?? <Memo>[];

                    for (final index in indices) {
                      if (index >= 0 && index < list.length) {
                        list.removeAt(index);
                      }
                    }

                    _memosByGenre[genre] = list;
                  }

                  _selectionMode = false;
                  _selectedKeys.clear();
                  _rebuildSections(l10n);
                });

                Navigator.of(sheetCtx).pop();

                for (final genre in removeByGenre.keys) {
                  await _saveGenre(genre);
                }
              },
              child: Text(context.l10n.delete),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetCtx).pop(),
            child: Text(context.l10n.cancel),
          ),
        );
      },
    );
  }

  List<Widget> _buildSectionSlivers() {
    final slivers = <Widget>[];

    for (var s = 0; s < _sectionKeys.length; s++) {
      final key = _sectionKeys[s];
      final items = _grouped[key] ?? const <_SectionItem>[];

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
              _sectionLabel(key),
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
              final key = _itemKey(item.genre, memoIndex);
              final selected = _selectionMode && _selectedKeys.contains(key);

              final card = Column(
                key: ValueKey(key),
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Material(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color:
                                  selected
                                      ? Colors.transparent
                                      : _normalBorderColor,
                              width: _normalBorderWidth,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_isMain) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F8FC),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFE3EDF7),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        _genreLabel(context, item.genre),
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF5F7D9B),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  Expanded(
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
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (selected)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedBorderColor,
                                    width: _selectedBorderWidth,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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
                  onTap: () => _toggleSelect(key),
                  child: card,
                );
              } else {
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _editMemo(context, item.genre, memoIndex, memo),
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
    final hasMemos = _grouped.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _selectionMode
              ? context.l10n.selectedMemosCount(_selectedKeys.length)
              : context.l10n.simpleMemoTitle,
          style: const TextStyle(color: Colors.black87),
        ),
        leading:
            _selectionMode
                ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  tooltip: context.l10n.cancelSelection,
                  onPressed: _exitSelectionMode,
                )
                : IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  tooltip: context.l10n.back,
                  onPressed: () => Navigator.pop(context, true),
                ),
        actions: [
          if (_selectionMode)
            TextButton(
              onPressed: _deleteSelected,
              child: Text(
                context.l10n.delete,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: context.l10n.simpleMemoAddTooltip,
              onPressed: _openMemoEditor,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: context.l10n.more,
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
                    _isMain
                        ? context.l10n.simpleMemoEmptyMain
                        : context.l10n.simpleMemoEmptyGenre,
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
        middle: Text(
          widget.initialText == null
              ? context.l10n.memoAdd
              : context.l10n.memoEdit,
        ),
        leading: CupertinoNavigationBarBackButton(
          color: const Color.fromARGB(255, 52, 96, 143),
          onPressed: _cancel,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _save,
          child: Text(
            context.l10n.save,
            style: const TextStyle(color: Color.fromARGB(255, 52, 96, 143)),
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
              placeholder: context.l10n.memoHint,
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
