// ebook_list_page.dart

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

import 'all_books_page.dart';
import 'book_builder_page.dart';
import 'edit_episodes_page.dart';
import 'login_page.dart';
import 'simple_memo_page.dart';

class EbookListPage extends StatefulWidget {
  const EbookListPage({super.key});

  @override
  State<EbookListPage> createState() => _EbookListPageState();
}

class _EbookListPageState extends State<EbookListPage>
    with SingleTickerProviderStateMixin {
  late final EbookListController controller;
  bool _reduceTransparencyFlag = false;

  static const double _shelfHeight =
      A4MiniCard.a4Height + A4MiniCard.captionGap + A4MiniCard.captionHeight;
  static const double _memoSquare = 110;

  TabController? _genreController;
  int _genreIndex = 0;

  static const List<Genre> _genreTabs = [
    Genre.webNovel,
    Genre.novel,
    Genre.poem,
    Genre.freeForm,
    Genre.selfHelp,
    Genre.science,
    Genre.pictureBook,
  ];

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
    return controller.ebooks.where((b) {
      final name = b['genre'] as String?;
      final g = Genre.values.firstWhere(
        (e) => e.name == name,
        orElse: () => Genre.webNovel,
      );
      return g == selected;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    controller = EbookListController(service: EbookService());
    _initReduceTransparency();

    _genreController = TabController(length: _genreTabs.length, vsync: this)
      ..addListener(() {
        if (!_genreController!.indexIsChanging) {
          setState(() => _genreIndex = _genreController!.index);
        }
      });

    controller.init().then((_) {
      if (mounted) setState(() {});
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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
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
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: AddSquareCard(
                        onTap: () {
                          final genre = _genreTabs[_genreIndex];
                          _createNewBook(genre);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                                    controller.ebooks.removeWhere((b) {
                                      final name = b['genre'] as String?;
                                      final g = Genre.values.firstWhere(
                                        (e) => e.name == name,
                                        orElse: () => Genre.webNovel,
                                      );
                                      return g == genre;
                                    });

                                    controller.ebooks.addAll(nextGenreBooks);

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
                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => EditEpisodesPage(
                                  genre: _genreTabs[_genreIndex],
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

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => SimpleMemoPage(
                                  genre: _genreTabs[_genreIndex],
                                ),
                          ),
                        );
                        if (result == true) {
                          final g = _genreTabs[_genreIndex];
                          await controller.reloadMemos(genre: g);
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShelf() {
    final books = _filteredEbooks();

    return SizedBox(
      height: _shelfHeight,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),

        onReorder: (oldIndex, newIndex) async {
          return;
        },

        itemCount: books.length,
        itemBuilder: (_, i) {
          final book = books[i];
          final originalIndex = controller.ebooks.indexOf(book);

          return Padding(
            key: ValueKey('ebook_${book['id']}'),
            padding: const EdgeInsets.only(right: 11),
            child: GestureDetector(
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemoPreviewRow() {
    final genre = _genreTabs[_genreIndex];
    final preview = controller.memoPreview(genre);

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

                final genre = _genreTabs[_genreIndex];

                final ok = await controller.editMemoInlineAt(
                  genre: genre,
                  previewIndex: i,
                  newText: edited.trim(),
                );

                if (ok && mounted) setState(() {});
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
