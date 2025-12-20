// lib/pages/ebook_list_page.dart
import 'dart:math'; // 🔹 documentId 생성을 위해 추가

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ebook_tutorial_app/controllers/ebook_list_controller.dart';
import 'package:ebook_tutorial_app/controllers/writing_settings_controller.dart';
import 'package:ebook_tutorial_app/services/ebook_service.dart';
import 'package:ebook_tutorial_app/widgets/common/app_toast.dart';

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

class _EbookListPageState extends State<EbookListPage> {
  late final EbookListController controller;
  bool _reduceTransparencyFlag = false;

  static const double _shelfHeight =
      A4MiniCard.a4Height + A4MiniCard.captionGap + A4MiniCard.captionHeight;
  static const double _memoSquare = 110;

  @override
  void initState() {
    super.initState();
    controller = EbookListController(service: EbookService());
    _initReduceTransparency();
    controller.init().then((_) {
      if (mounted) setState(() {});
    });
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

  // 🔹 새 작품 만들기: 고유 documentId 부여 후 BookBuilderPage로 진입
  Future<void> _createNewFreeForm() async {
    final docId = _newDocumentId();

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider(
              create:
                  (_) => WritingSettingsController(documentId: docId)..load(),
              child: BookBuilderPage(
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

    // 🔹 documentId 보존
    controller.ebooks.last['documentId'] =
        (result['documentId'] as String?) ?? docId;

    // 🔹 표지 사진 경로도 함께 저장
    controller.ebooks.last['coverPath'] = result['coverPath'] as String?;

    // 🔹 디스크 저장
    await controller.persistEbooks();

    if (!mounted) return;
    AppToast.show(context, '저장 완료'); // 🔹 토스트
    setState(() {});
  }

  // 🔹 기존 작품 편집: 문서별 WritingSettingsController와 함께 BookBuilderPage 열기
  Future<void> _editEbook(int index) async {
    final cur = controller.ebooks[index];

    // 레거시 문서 보호: documentId 없으면 생성 후 즉시 저장
    if (cur['documentId'] == null) {
      cur['documentId'] = _newDocumentId();
      await controller.persistEbooks();
      if (!mounted) return;
    }
    final String docId = cur['documentId'] as String;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider(
              create:
                  (_) => WritingSettingsController(documentId: docId)..load(),
              child: BookBuilderPage(
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

    // 🔹 documentId 최신화
    controller.ebooks[index]['documentId'] =
        (result['documentId'] as String?) ?? (cur['documentId'] as String);

    // 🔹 표지 사진 경로 최신화
    controller.ebooks[index]['coverPath'] = result['coverPath'] as String?;

    await controller.persistEbooks();
    if (!mounted) return;
    AppToast.show(context, '저장 완료'); // 🔹 토스트
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
        leading:
            controller.selectionMode
                ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color.fromARGB(255, 117, 148, 188),
                  ),
                  tooltip: '선택 취소',
                  onPressed: () {
                    setState(controller.exitSelectionMode);
                  },
                )
                : null,
        title: Text(
          controller.selectionMode
              ? '${controller.selectedIndices.length}개 선택됨'
              : '책 목록',
        ),
        actions: [
          if (controller.selectionMode)
            IconButton(
              icon: const Icon(
                CupertinoIcons.delete,
                color: Color.fromARGB(255, 117, 148, 188),
              ),
              tooltip: '삭제',
              onPressed: () async {
                await controller.deleteSelected();
                if (mounted) setState(() {});
              },
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black87),
              tooltip: '장르 선택',
              onPressed:
                  () => showGenreDialog(
                    context,
                    theme: _glassTheme,
                    onTap: (g) async {
                      if (g == '자유 서식') {
                        await _createNewFreeForm();
                      } else {
                        AppToast.show(context, '선택한 장르: $g');
                      }
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
                      setState(controller.enterPickMode);
                      AppToast.show(context, '선택 모드입니다. 항목을 눌러 선택하세요.');
                    },
                    onLogout: () => _logout(context),
                  ),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
            if (!controller.selectionMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: AddSquareCard(onTap: _createNewFreeForm),
                ),
              ),
            if (!controller.selectionMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => AllBooksPage(
                              ebooks: controller.ebooks,
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
                            '책 목록',
                            style: TextStyle(
                              fontSize: 20,
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
            if (!controller.selectionMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditEpisodesPage(),
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
                            'edit 회차',
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
            if (!controller.selectionMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SimpleMemoPage()),
                    );
                    if (result == true) {
                      await controller.reloadMemos();
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
                            '간단 메모',
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
    );
  }

  Widget _buildShelf() {
    if (controller.selectionMode) {
      return SizedBox(
        height: _shelfHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.ebooks.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final selected = controller.selectedIndices.contains(i);
            final preview = controller.deltaToPreview(controller.ebooks[i]);
            final id = controller.ebooks[i]['id'] as int;
            final coverPath =
                controller.ebooks[i]['coverPath'] as String?; // 🔹 추가

            return GestureDetector(
              key: ValueKey('ebook_$id'),
              onTap: () {
                setState(() {
                  if (selected) {
                    controller.selectedIndices.remove(i);
                  } else {
                    controller.selectedIndices.add(i);
                  }
                  if (controller.selectedIndices.isEmpty) {
                    controller.exitSelectionMode();
                  }
                });
              },
              child: SizedBox(
                width: A4MiniCard.a4Width,
                height: _shelfHeight,
                child: A4MiniCard(
                  title: controller.ebooks[i]['title'] as String,
                  preview: preview,
                  selected: selected,
                  coverPath: coverPath, // 🔹
                ),
              ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: _shelfHeight,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        onReorder: (oldIndex, newIndex) async {
          await controller.onReorder(oldIndex, newIndex);
          if (mounted) setState(() {});
        },
        buildDefaultDragHandles: true,
        proxyDecorator:
            (child, index, animation) => AnimatedBuilder(
              animation: animation,
              builder:
                  (context, _) => Transform.scale(scale: 1.03, child: child),
            ),
        itemBuilder: (_, i) {
          final preview = controller.deltaToPreview(controller.ebooks[i]);
          final id = controller.ebooks[i]['id'] as int;
          final coverPath =
              controller.ebooks[i]['coverPath'] as String?; // 🔹 추가

          return Padding(
            key: ValueKey('ebook_$id'),
            padding: const EdgeInsets.only(right: 11),
            child: GestureDetector(
              onTap: () => _editEbook(i),
              child: SizedBox(
                width: A4MiniCard.a4Width,
                child: A4MiniCard(
                  title: controller.ebooks[i]['title'] as String,
                  preview: preview,
                  selected: false,
                  coverPath: coverPath, // 🔹 전달
                ),
              ),
            ),
          );
        },
        itemCount: controller.ebooks.length,
      ),
    );
  }

  Widget _buildMemoPreviewRow() {
    if (controller.selectionMode || controller.memoPreview.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: _memoSquare + 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.memoPreview.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final item = controller.memoPreview[i];
          return SizedBox(
            width: _memoSquare,
            child: MemoSquareCard(
              text: item.memo.text,
              onTap: () async {
                // 🔹 간단한 인라인 에디터
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
                final ok = await controller.editMemoInlineAt(i, edited.trim());
                if (ok && mounted) setState(() {});
              },
            ),
          );
        },
      ),
    );
  }
}

/// 🔹 페이지 내부 간단 메모 에디터 (파일 추가 없이 임베드)
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
