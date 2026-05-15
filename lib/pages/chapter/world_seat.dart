// world_seat.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ebook_tutorial_app/pages/chapter/character.dart';
import 'package:ebook_tutorial_app/pages/chapter/timeline.dart';

import 'package:flutter/cupertino.dart';
import 'package:ebook_tutorial_app/pages/chapter/faction.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:isar/isar.dart';
import 'world_seat_isar.dart';

Future<File?> resolveCharacterCoverFile(String? coverPath) async {
  final raw = coverPath?.trim();
  if (raw == null || raw.isEmpty) return null;

  final direct = File(raw);
  if (await direct.exists()) return direct;

  final appDir = await getApplicationDocumentsDirectory();

  final fromDocuments = File(p.join(appDir.path, raw));
  if (await fromDocuments.exists()) return fromDocuments;

  final fromCharacterCovers = File(
    p.join(appDir.path, 'character_covers', p.basename(raw)),
  );
  if (await fromCharacterCovers.exists()) return fromCharacterCovers;

  return null;
}

Future<bool> showDeleteSheet({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  final res = await showCupertinoModalPopup<bool>(
    context: context,
    builder: (_) {
      return CupertinoActionSheet(
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        message: Text(
          message,
          style: const TextStyle(
            fontSize: 13.5,
            color: Color.fromARGB(255, 178, 206, 246),
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(fontSize: 16)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소', style: TextStyle(fontSize: 16)),
        ),
      );
    },
  );

  return res ?? false;
}

class TimelineSeatTab extends StatelessWidget {
  final String documentId;
  const TimelineSeatTab({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return TimelineTab(
      documentId: documentId,
      confirmDelete: (ctx, sectionIndex, barName) async {
        final name = barName.trim().isEmpty ? 'Unnamed' : barName.trim();
        return await showDeleteSheet(
          context: ctx,
          title: '$name 삭제',
          message: '이 타임라인($name)을 삭제하시겠습니까?',
        );
      },
    );
  }
}

class WorldSeatPage extends StatefulWidget {
  final String documentId;
  final ValueChanged<Character>? onPicked;

  const WorldSeatPage({super.key, required this.documentId, this.onPicked});

  static const _tabs = [
    Tab(text: 'Character'),
    Tab(text: 'Glossary'),
    Tab(text: 'Free memo'),
    Tab(text: 'Faction'),
    Tab(text: 'Timeline'),
  ];

  @override
  State<WorldSeatPage> createState() => _WorldSeatPageState();
}

class _WorldSeatPageState extends State<WorldSeatPage>
    with SingleTickerProviderStateMixin {
  String get _prefsKeyTabIndex =>
      'world_seat_last_tab_index_${widget.documentId}';

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _initTabController();
  }

  Future<void> _initTabController() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_prefsKeyTabIndex) ?? 0;
    final initial = saved.clamp(0, WorldSeatPage._tabs.length - 1);

    if (!mounted) return;

    _tabController?.dispose();
    _tabController = TabController(
      length: WorldSeatPage._tabs.length,
      vsync: this,
      initialIndex: initial,
    )..addListener(() async {
      if (!_tabController!.indexIsChanging) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_prefsKeyTabIndex, _tabController!.index);
      }
    });

    setState(() {});
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = _tabController;
    final nav = Navigator.of(context);

    if (controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        title: const Text(
          'World Seat',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => nav.maybePop(),
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: controller,
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
                  unselectedLabelColor: const Color.fromARGB(
                    255,
                    170,
                    193,
                    216,
                  ),
                  tabs: WorldSeatPage._tabs,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: TabBarView(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  CharacterSeatTab(documentId: widget.documentId),
                  GlossarySeatTab(documentId: widget.documentId),
                  FreeMemoSeatTab(documentId: widget.documentId),
                  FutureBuilder(
                    future: WorldSeatIsar.instance,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return FactionPage(
                        isar: snapshot.data!,
                        documentId: widget.documentId,
                      );
                    },
                  ),
                  TimelineSeatTab(documentId: widget.documentId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlossarySeatTab extends StatefulWidget {
  final String documentId;
  const GlossarySeatTab({super.key, required this.documentId});

  @override
  State<GlossarySeatTab> createState() => _GlossarySeatTabState();
}

class _GlossarySeatTabState extends State<GlossarySeatTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<GlossaryEntity> _items = [];

  bool _searching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  void _sortForDisplay() {
    _items.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;

      if (a.pinned) {
        final ap = a.pinnedAt ?? 0;
        final bp = b.pinnedAt ?? 0;
        final c = bp.compareTo(ap);
        if (c != 0) return c;
      }

      return b.createdAt.compareTo(a.createdAt);
    });
  }

  String _makeUid() =>
      'g_${widget.documentId}_${DateTime.now().millisecondsSinceEpoch}';

  _GlossaryItem _toItem(GlossaryEntity e) {
    return _GlossaryItem(
      id: e.uid,
      term: e.term,
      desc: e.desc,
      pinned: e.pinned,
      createdAt: e.createdAt,
      pinnedAt: e.pinnedAt,
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _searchCtrl.clear();
        _query = '';
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchCtrl.clear();
      _query = '';
    });
  }

  Future<void> _load() async {
    try {
      final isar = await WorldSeatIsar.instance;

      final list =
          await isar.glossaryEntitys
              .filter()
              .documentIdEqualTo(widget.documentId)
              .findAll();

      _items
        ..clear()
        ..addAll(list);

      _sortForDisplay();
      if (mounted) setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items.clear();
      });
    }
  }

  Future<void> _openEditorById(String uid) async {
    final idx = _items.indexWhere((x) => x.uid == uid);
    await _openEditor(index: idx >= 0 ? idx : null);
  }

  Future<void> _confirmDeleteById(String uid) async {
    final idx = _items.indexWhere((x) => x.uid == uid);
    if (idx < 0) return;
    _confirmDelete(idx);
  }

  Future<void> _openEditor({int? index}) async {
    final GlossaryEntity? current =
        (index != null && index >= 0 && index < _items.length)
            ? _items[index]
            : null;

    final _GlossaryItem? init = current == null ? null : _toItem(current);

    final result = await Navigator.of(context).push<_GlossaryItem>(
      MaterialPageRoute(builder: (_) => _GlossaryEditorPage(initial: init)),
    );

    if (result == null) return;

    final term = result.term.trim();
    final desc = result.desc.trim();
    if (term.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      final isar = await WorldSeatIsar.instance;

      if (current != null) {
        await isar.writeTxn(() async {
          current.term = term;
          current.desc = desc;
          await isar.glossaryEntitys.put(current);
        });

        if (!mounted) return;
        setState(() {
          _items[index!] = current;
          _sortForDisplay();
        });
      } else {
        final e =
            GlossaryEntity()
              ..documentId = widget.documentId
              ..uid = _makeUid()
              ..term = term
              ..desc = desc
              ..pinned = false
              ..createdAt = now
              ..pinnedAt = null;

        await isar.writeTxn(() async {
          await isar.glossaryEntitys.put(e);
        });

        if (!mounted) return;
        setState(() {
          _items.insert(0, e);
          _sortForDisplay();
        });
      }
    } catch (_) {}
  }

  void _confirmDelete(int index) async {
    if (index < 0 || index >= _items.length) return;

    final ok = await showDeleteSheet(
      context: context,
      title: '용어 삭제',
      message: '이 용어를 삭제하시겠습니까?',
    );
    if (!ok) return;

    final uid = _items[index].uid;

    try {
      final isar = await WorldSeatIsar.instance;

      await isar.writeTxn(() async {
        final target =
            await isar.glossaryEntitys.filter().uidEqualTo(uid).findFirst();

        if (target != null) {
          await isar.glossaryEntitys.delete(target.id);
        }
      });

      if (!mounted) return;
      setState(() => _items.removeAt(index));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final q = _query.trim().toLowerCase();
    final visibleItems =
        q.isEmpty
            ? _items
            : _items.where((it) {
              final t = it.term.toLowerCase();
              final d = it.desc.toLowerCase();
              return t.contains(q) || d.contains(q);
            }).toList();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _toggleSearch,
                  icon: Icon(
                    _searching ? Icons.close : Icons.search,
                    size: 21,
                    color: Colors.black87,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child:
                      _searching
                          ? TextField(
                            controller: _searchCtrl,
                            autofocus: true,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: InputDecoration(
                              hintText: '검색',
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(172, 103, 171, 200),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              suffixIcon:
                                  _query.trim().isEmpty
                                      ? null
                                      : IconButton(
                                        onPressed: _clearSearch,
                                        icon: const Icon(
                                          Icons.backspace_outlined,
                                          size: 17,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                        ),
                                      ),
                            ),
                          )
                          : const Text(
                            'Glossary',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                ),
                IconButton(
                  onPressed: () => _openEditor(),
                  icon: const Icon(Icons.add, size: 22, color: Colors.black87),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _items.isEmpty
                      ? const Center(
                        child: Text(
                          '용어를 추가해 보세요.',
                          style: TextStyle(
                            color: Color.fromARGB(221, 83, 129, 159),
                            fontSize: 13,
                          ),
                        ),
                      )
                      : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: visibleItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final it = visibleItems[i];

                          return Dismissible(
                            key: ValueKey(it.uid),
                            direction: DismissDirection.startToEnd,
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: const Color.fromARGB(159, 255, 238, 182),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    it.pinned ? Icons.star : Icons.star_border,
                                    color: const Color.fromARGB(
                                      221,
                                      134,
                                      215,
                                      255,
                                    ),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    it.pinned ? '핀 해제' : '핀 추가',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(221, 51, 72, 81),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            confirmDismiss: (_) async {
                              final now = DateTime.now().millisecondsSinceEpoch;
                              final uid = it.uid;

                              try {
                                final isar = await WorldSeatIsar.instance;

                                await isar.writeTxn(() async {
                                  final target =
                                      await isar.glossaryEntitys
                                          .filter()
                                          .uidEqualTo(uid)
                                          .findFirst();
                                  if (target == null) return;

                                  final nextPinned = !target.pinned;
                                  target.pinned = nextPinned;
                                  target.pinnedAt = nextPinned ? now : null;

                                  await isar.glossaryEntitys.put(target);
                                });

                                if (!mounted) return false;

                                setState(() {
                                  final idx = _items.indexWhere(
                                    (x) => x.uid == uid,
                                  );
                                  if (idx < 0) return;
                                  _items[idx].pinned = !_items[idx].pinned;
                                  _items[idx].pinnedAt =
                                      _items[idx].pinned ? now : null;
                                  _sortForDisplay();
                                });
                              } catch (_) {}

                              return false;
                            },
                            child: GestureDetector(
                              onTap: () => _openEditorById(it.uid),
                              onLongPress: () => _confirmDeleteById(it.uid),
                              child: Stack(
                                children: [
                                  _GlossaryCard(
                                    term: it.term,
                                    desc: it.desc,
                                    pinned: it.pinned,
                                    query: _query,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlossaryItem {
  final String id;
  final String term;
  final String desc;

  final bool pinned;
  final int createdAt;
  final int? pinnedAt;

  const _GlossaryItem({
    required this.id,
    required this.term,
    required this.desc,
    this.pinned = false,
    required this.createdAt,
    this.pinnedAt,
  });
}

class _GlossaryEditorPage extends StatefulWidget {
  final _GlossaryItem? initial;
  const _GlossaryEditorPage({this.initial});

  @override
  State<_GlossaryEditorPage> createState() => _GlossaryEditorPageState();
}

class _GlossaryEditorPageState extends State<_GlossaryEditorPage> {
  late final TextEditingController _termCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _termCtrl = TextEditingController(text: widget.initial?.term ?? '');
    _descCtrl = TextEditingController(text: widget.initial?.desc ?? '');
  }

  @override
  void dispose() {
    _termCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).maybePop(
      _GlossaryItem(
        id: widget.initial?.id ?? '',
        term: _termCtrl.text,
        desc: _descCtrl.text,
        pinned: widget.initial?.pinned ?? false,
        createdAt: widget.initial?.createdAt ?? 0,
        pinnedAt: widget.initial?.pinnedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.initial == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNew ? '용어 추가' : '용어 편집',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              TextField(
                controller: _termCtrl,
                decoration: const InputDecoration(
                  hintText: '단어',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 200, 227, 255),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextField(
                    controller: _descCtrl,
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      hintText: '설명',
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 157, 206, 255),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlossaryCard extends StatelessWidget {
  final String term;
  final String desc;
  final bool pinned;
  final String query;

  const _GlossaryCard({
    required this.term,
    required this.desc,
    this.pinned = false,
    required this.query,
  });

  List<TextSpan> _buildHighlightSpans({
    required String text,
    required String query,
    required TextStyle normalStyle,
    required TextStyle highlightStyle,
  }) {
    if (query.trim().isEmpty) {
      return [TextSpan(text: text, style: normalStyle)];
    }

    final q = query.trim();
    final lowerText = text.toLowerCase();
    final lowerQuery = q.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start), style: normalStyle));
        break;
      }

      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: normalStyle),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + q.length),
          style: highlightStyle,
        ),
      );

      start = index + q.length;
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final t = term.trim().isEmpty ? 'Unnamed' : term.trim();
    final d = desc.trim().isEmpty ? '설명을 입력하세요' : desc.trim();
    final q = query.trim();

    const termNormal = TextStyle(
      fontSize: 15.5,
      fontWeight: FontWeight.w500,
      color: Color.fromARGB(221, 0, 0, 0),
    );

    const termHighlight = TextStyle(
      fontSize: 15.5,
      fontWeight: FontWeight.w500,
      color: Color.fromARGB(221, 0, 0, 0),
      backgroundColor: Color.fromARGB(123, 255, 247, 155),
    );

    final descNormal = TextStyle(
      fontSize: 12.5,
      height: 1.25,
      color:
          desc.trim().isEmpty
              ? const Color.fromARGB(255, 178, 203, 230)
              : const Color.fromARGB(221, 98, 126, 148),
      fontWeight: FontWeight.w400,
    );

    final descHighlight = TextStyle(
      fontSize: 12.5,
      height: 1.25,
      color: descNormal.color,
      fontWeight: FontWeight.w400,
      backgroundColor: const Color.fromARGB(123, 255, 247, 155),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (pinned) ...[
                const Icon(
                  Icons.star,
                  size: 20,
                  color: Color.fromARGB(255, 255, 224, 132),
                ),
                const SizedBox(width: 5),
              ],

              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: _buildHighlightSpans(
                      text: t,
                      query: q,
                      normalStyle: termNormal,
                      highlightStyle: termHighlight,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text.rich(
              TextSpan(
                children: _buildHighlightSpans(
                  text: d,
                  query: q,
                  normalStyle: descNormal,
                  highlightStyle: descHighlight,
                ),
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class FreeMemoSeatTab extends StatefulWidget {
  final String documentId;
  const FreeMemoSeatTab({super.key, required this.documentId});

  @override
  State<FreeMemoSeatTab> createState() => _FreeMemoSeatTabState();
}

class _FreeMemoSeatTabState extends State<FreeMemoSeatTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _searching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  final List<MemoEntity> _memos = [];

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _searchCtrl.clear();
        _query = '';
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchCtrl.clear();
      _query = '';
    });
  }

  Future<MemoEntity> _upsertMemo({
    MemoEntity? existing,
    required String text,
  }) async {
    final isar = await WorldSeatIsar.instance;
    final now = DateTime.now().millisecondsSinceEpoch;

    final e = existing ?? MemoEntity();
    e.documentId = widget.documentId;
    e.uid = existing?.uid ?? _newUid();
    e.text = text;
    e.updatedAt = now;

    await isar.writeTxn(() async {
      await isar.memoEntitys.putByUid(e);
    });

    return e;
  }

  Future<void> _loadMemos() async {
    final isar = await WorldSeatIsar.instance;

    final list =
        await isar.memoEntitys
            .where()
            .documentIdEqualTo(widget.documentId)
            .sortByUpdatedAtDesc()
            .findAll();

    if (!mounted) return;
    setState(() {
      _memos
        ..clear()
        ..addAll(list);
    });
  }

  String _formatMemoDate(DateTime dt) {
    final l = dt.toLocal();
    final m = l.month.toString().padLeft(2, '0');
    final d = l.day.toString().padLeft(2, '0');
    return '$m/$d';
  }

  List<int> _matchedMemoIndexes() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return List.generate(_memos.length, (i) => i);

    final out = <int>[];
    for (var i = 0; i < _memos.length; i++) {
      if (_memos[i].text.toLowerCase().contains(q)) out.add(i);
    }
    return out;
  }

  String _newUid() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'm_${widget.documentId}_$now';
  }

  Future<void> _deleteMemo(MemoEntity e) async {
    final isar = await WorldSeatIsar.instance;
    await isar.writeTxn(() async {
      await isar.memoEntitys.delete(e.id);
    });
  }

  Future<void> _openMemoEditor({MemoEntity? existing}) async {
    final edited = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => _MemoEditorPage(initialText: existing?.text ?? ''),
      ),
    );
    if (edited == null) return;

    final text = edited.trim();
    if (text.isEmpty) return;

    final saved = await _upsertMemo(existing: existing, text: text);

    if (!mounted) return;
    setState(() {
      final idx = _memos.indexWhere((m) => m.uid == saved.uid);
      if (idx >= 0) {
        _memos[idx] = saved;
      } else {
        _memos.insert(0, saved);
      }
      _memos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  Future<void> _confirmDeleteMemo(MemoEntity e) async {
    final ok = await showDeleteSheet(
      context: context,
      title: '메모 삭제',
      message: '이 메모를 삭제하시겠습니까?',
    );
    if (!ok) return;

    await _deleteMemo(e);

    if (!mounted) return;
    setState(() {
      _memos.removeWhere((x) => x.uid == e.uid);
    });
  }

  Widget _buildMemoSectionsByIndex(List<int> indexes) {
    final Map<String, List<int>> grouped = {};

    for (final idx in indexes) {
      final m = _memos[idx];
      final dt = DateTime.fromMillisecondsSinceEpoch(m.updatedAt);
      final key = _formatMemoDate(dt);
      (grouped[key] ??= <int>[]).add(idx);
    }

    final nowYear = DateTime.now().year;
    final keys =
        grouped.keys.toList()..sort((a, b) {
          final am = int.parse(a.substring(0, 2));
          final ad = int.parse(a.substring(3, 5));
          final bm = int.parse(b.substring(0, 2));
          final bd = int.parse(b.substring(3, 5));
          final adt = DateTime(nowYear, am, ad);
          final bdt = DateTime(nowYear, bm, bd);
          return bdt.compareTo(adt);
        });

    if (keys.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 12, bottom: 12),
        child: Text(
          '검색 결과가 없습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color.fromARGB(221, 83, 129, 159),
            fontSize: 13,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var s = 0; s < keys.length; s++) ...[
          Padding(
            padding: EdgeInsets.only(
              left: 7,
              right: 4,
              bottom: s == 0 ? 10 : 4,
              top: s == 0 ? 0 : 2,
            ),
            child: Text(
              keys[s],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(221, 83, 129, 159),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.90,
            ),
            itemCount: grouped[keys[s]]!.length,
            itemBuilder: (_, i) {
              final memoIndex = grouped[keys[s]]![i];
              final m = _memos[memoIndex];

              return GestureDetector(
                onTap: () => _openMemoEditor(existing: m),
                onLongPress: () => _confirmDeleteMemo(m),
                child: _MemoSquareCard(text: m.text, query: _query),
              );
            },
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final indexes = _matchedMemoIndexes();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _toggleSearch,
                  icon: Icon(
                    _searching ? Icons.close : Icons.search,
                    size: 21,
                    color: Colors.black87,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child:
                      _searching
                          ? TextField(
                            controller: _searchCtrl,
                            autofocus: true,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: InputDecoration(
                              hintText: '검색',
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(172, 103, 171, 200),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              suffixIcon:
                                  _query.trim().isEmpty
                                      ? null
                                      : GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: _clearSearch,
                                        child: const Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.backspace_outlined,
                                            size: 17,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                        ),
                                      ),
                            ),
                          )
                          : const Text(
                            'Free memo',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                ),
                IconButton(
                  onPressed: () => _openMemoEditor(existing: null),
                  icon: const Icon(Icons.add, size: 22, color: Colors.black87),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _memos.isEmpty
                      ? const Center(
                        child: Text(
                          '자유 메모를 추가해 보세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(221, 83, 129, 159),
                            fontSize: 13,
                          ),
                        ),
                      )
                      : SingleChildScrollView(
                        child: _buildMemoSectionsByIndex(indexes),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoEditorPage extends StatefulWidget {
  final String initialText;
  const _MemoEditorPage({required this.initialText});

  @override
  State<_MemoEditorPage> createState() => _MemoEditorPageState();
}

class _MemoEditorPageState extends State<_MemoEditorPage> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).maybePop(_ctrl.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialText.trim().isEmpty ? '새 메모' : '메모 편집',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: TextField(
            controller: _ctrl,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: '메모를 입력하세요',
              hintStyle: TextStyle(
                color: Color.fromARGB(255, 178, 203, 230),
                fontSize: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoSquareCard extends StatelessWidget {
  final String text;
  final String query;

  const _MemoSquareCard({required this.text, required this.query});

  List<TextSpan> _buildHighlightSpans({
    required String text,
    required String query,
    required TextStyle normalStyle,
    required TextStyle highlightStyle,
  }) {
    if (query.trim().isEmpty) {
      return [TextSpan(text: text, style: normalStyle)];
    }

    final q = query.trim();
    final lowerText = text.toLowerCase();
    final lowerQuery = q.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start), style: normalStyle));
        break;
      }

      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: normalStyle),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + q.length),
          style: highlightStyle,
        ),
      );

      start = index + q.length;
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final t = text.trim();
    final display = t.isEmpty ? 'Tap to edit' : t;

    final normalStyle = TextStyle(
      fontSize: 12.5,
      height: 1.25,
      color:
          t.isEmpty
              ? const Color.fromARGB(221, 83, 129, 159)
              : const Color.fromARGB(221, 22, 42, 61),
      fontWeight: FontWeight.w500,
    );

    final highlightStyle = TextStyle(
      fontSize: 12.5,
      height: 1.25,
      color: normalStyle.color,
      fontWeight: FontWeight.w500,
      backgroundColor: const Color.fromARGB(123, 255, 247, 155),
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromARGB(255, 185, 209, 235)),
      ),
      child: Text.rich(
        TextSpan(
          children: _buildHighlightSpans(
            text: display,
            query: query,
            normalStyle: normalStyle,
            highlightStyle: highlightStyle,
          ),
        ),
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class CharacterSeatTab extends StatefulWidget {
  final String documentId;

  final ValueChanged<Character>? onPicked;

  const CharacterSeatTab({super.key, required this.documentId, this.onPicked});

  @override
  State<CharacterSeatTab> createState() => _CharacterSeatTabState();
}

class _CharacterSeatTabState extends State<CharacterSeatTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String get _prefsKeyCharScroll =>
      'world_seat_character_scroll_${widget.documentId}';

  late final CharacterStoreIsar _store = CharacterStoreIsar(widget.documentId);

  final ScrollController _scrollCtrl = ScrollController();
  double? _restoredOffset;
  bool _restoreTried = false;

  Timer? _scrollDebounce;

  bool _loading = true;
  List<Character> _characters = [];

  int? _draggingProtagonistIndex;

  List<Character> _seedExampleCharacters() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return [
      Character(
        id: 'demo_p_${now}_10',
        kind: CharacterKind.protagonist,
        name: '히카라',
        birthday: '01/14',
        height: '190',
        bloodType: 'O+',
        specialNote: '목표: 엘프 종족의 근원을 찾는다.',
        personalityKeywords: const ['책임감'],
        likes: const ['관측', '고서'],
        dislikes: const ['무책임'],
        physicalNotes: const ['푸른 눈'],
        palette: const [
          PaletteGroup(
            label: '메인 톤',
            colors: [Color.fromARGB(190, 174, 218, 252)],
          ),
        ],
        images: const [],
        color: const Color.fromARGB(190, 174, 218, 252),
        coverPath: null,
        sheetAssetPath: null,
      ),
      Character(
        id: 'demo_p_${now}_1',
        kind: CharacterKind.protagonist,
        name: '엘릭시',
        birthday: '07/10',
        height: '171',
        bloodType: 'O+',
        specialNote: '마법 약초를 연구한다.',
        personalityKeywords: const ['호기심'],
        likes: const ['약초', '약학'],
        dislikes: const ['벌레'],
        physicalNotes: const ['금빛 머리카락'],
        palette: const [
          PaletteGroup(
            label: '메인 톤',
            colors: [Color.fromARGB(217, 255, 255, 213)],
          ),
        ],
        images: const [],
        color: const Color.fromARGB(217, 255, 255, 213),
        coverPath: null,
        sheetAssetPath: null,
      ),
    ];
  }

  // ---------------------------
  // lifecycle
  // ---------------------------

  @override
  void initState() {
    super.initState();
    _loadScrollOffset();
    _scrollCtrl.addListener(_persistScrollDebounced);
    _load();
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_persistScrollDebounced);
    _scrollDebounce?.cancel();
    _persistScroll();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ---------------------------
  // scroll state (prefs)
  // ---------------------------

  Future<void> _loadScrollOffset() async {
    final prefs = await SharedPreferences.getInstance();
    _restoredOffset = prefs.getDouble(_prefsKeyCharScroll);
  }

  void _persistScrollDebounced() {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 250), _persistScroll);
  }

  Future<void> _persistScroll() async {
    if (!_scrollCtrl.hasClients) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsKeyCharScroll, _scrollCtrl.position.pixels);
  }

  void _attemptRestoreScroll() {
    if (_restoreTried) return;

    if (!_scrollCtrl.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _attemptRestoreScroll(),
      );
      return;
    }

    if (_restoredOffset == null) {
      _restoreTried = true;
      return;
    }

    final pos = _scrollCtrl.position;
    final target = _restoredOffset!.clamp(0.0, pos.maxScrollExtent);
    _scrollCtrl.jumpTo(target);
    _restoreTried = true;
  }

  // ---------------------------
  // Isar load + seed (Isar only)
  // ---------------------------

  Future<void> _ensureSeedIfNeeded() async {
    final existing = await _store.loadAll();
    if (existing.isNotEmpty) return;
    final seed = _seedExampleCharacters();
    for (final c in seed) {
      await _store.upsert(c);
    }
  }

  Future<void> _load() async {
    try {
      await _ensureSeedIfNeeded();
      final list = await _store.loadAll();

      if (!mounted) return;
      setState(() {
        _characters = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _characters = [];
        _loading = false;
      });
    }
  }

  // ---------------------------
  // CRUD (Isar)
  // ---------------------------

  Future<void> _openEditor({Character? initial, CharacterKind? kind}) async {
    final nav = Navigator.of(context);

    await _persistScroll();

    final result = await nav.push<Character>(
      MaterialPageRoute(
        builder: (_) => WorldPage(initialCharacter: initial, initialKind: kind),
      ),
    );

    if (!mounted) return;
    if (result == null) return;

    // ✅ 드로어 모드면 바깥으로 넘기고 여기서 종료
    if (widget.onPicked != null) {
      widget.onPicked!(result);
      return;
    }

    // ✅ 기존 모드면 내부 저장 + 리스트 갱신
    await _store.upsert(result);

    setState(() {
      final idx = _characters.indexWhere((c) => c.id == result.id);
      if (idx >= 0) {
        _characters[idx] = result;
      } else {
        _characters = [..._characters, result];
      }
    });

    _restoreTried = false;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _attemptRestoreScroll(),
    );
  }

  Future<void> _delete(Character c) async {
    await _persistScroll();
    if (!mounted) return;

    final ok = await showDeleteSheet(
      context: context,
      title: '캐릭터 삭제',
      message: '이 캐릭터를 삭제하시겠습니까?',
    );
    if (!ok) return;

    await _store.deleteByUid(c.id);

    if (!mounted) return;
    setState(() {
      _characters.removeWhere((x) => x.id == c.id);
    });

    unawaited(
      _store.persistOrderByKind(
        kind: c.kind,
        uidsInOrder:
            _characters
                .where((x) => x.kind == c.kind)
                .map((x) => x.id)
                .toList(),
      ),
    );

    _restoreTried = false;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _attemptRestoreScroll(),
    );
  }

  void _reorderCharactersByKind({
    required CharacterKind kind,
    required int oldIndex,
    required int newIndex,
  }) {
    final group = _characters.where((c) => c.kind == kind).toList();

    if (oldIndex < 0 || oldIndex >= group.length) return;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    if (newIndex < 0) newIndex = 0;
    if (newIndex > group.length) newIndex = group.length;
    if (oldIndex == newIndex) return;

    final moved = group.removeAt(oldIndex);
    group.insert(newIndex, moved);

    final protagonists =
        kind == CharacterKind.protagonist
            ? group
            : _characters
                .where((c) => c.kind == CharacterKind.protagonist)
                .toList();

    final supporting =
        kind == CharacterKind.supporting
            ? group
            : _characters
                .where((c) => c.kind == CharacterKind.supporting)
                .toList();

    setState(() {
      _characters = [...protagonists, ...supporting];
    });

    unawaited(
      _store.persistOrderByKind(
        kind: kind,
        uidsInOrder: group.map((c) => c.id).toList(),
      ),
    );
  }

  void _reorderGridCharactersByKind({
    required CharacterKind kind,
    required int oldIndex,
    required int newIndex,
  }) {
    final group = _characters.where((c) => c.kind == kind).toList();

    if (oldIndex < 0 || oldIndex >= group.length) return;
    if (newIndex < 0 || newIndex >= group.length) return;
    if (oldIndex == newIndex) return;

    // ✅ 그리드는 newIndex 보정하지 않음
    final moved = group.removeAt(oldIndex);
    group.insert(newIndex, moved);

    final protagonists =
        kind == CharacterKind.protagonist
            ? group
            : _characters
                .where((c) => c.kind == CharacterKind.protagonist)
                .toList();

    final supporting =
        kind == CharacterKind.supporting
            ? group
            : _characters
                .where((c) => c.kind == CharacterKind.supporting)
                .toList();

    setState(() {
      _characters = [...protagonists, ...supporting];
    });

    unawaited(
      _store.persistOrderByKind(
        kind: kind,
        uidsInOrder: group.map((c) => c.id).toList(),
      ),
    );
  }

  // ---------------------------
  // UI
  // ---------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final protagonists =
        _characters.where((c) => c.kind == CharacterKind.protagonist).toList();

    final supporting =
        _characters.where((c) => c.kind == CharacterKind.supporting).toList();

    return SafeArea(
      top: false,
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '주인공 캐릭터',
              onAdd:
                  () => _openEditor(
                    initial: null,
                    kind: CharacterKind.protagonist,
                  ),
            ),
          ),
          _CharacterSliverList(
            items: protagonists,
            sheetStyle: true,
            draggingIndex: _draggingProtagonistIndex,
            onReorderStart: (i) {
              setState(() => _draggingProtagonistIndex = i);
            },
            onReorderEnd: (_) {
              setState(() => _draggingProtagonistIndex = null);
            },
            onReorder: (oldIndex, newIndex) {
              _reorderCharactersByKind(
                kind: CharacterKind.protagonist,
                oldIndex: oldIndex,
                newIndex: newIndex,
              );
            },
            onTap: (c) => _openEditor(initial: c),
            onEdit: (c) => _openEditor(initial: c),
            onDelete: _delete,
            emptyText: '아직 주인공 캐릭터가 없습니다.\n오른쪽 위 + 로 추가하세요.',
          ),
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '등장 인물 캐릭터',
              onAdd:
                  () => _openEditor(
                    initial: null,
                    kind: CharacterKind.supporting,
                  ),
            ),
          ),
          _SupportingCharacterGrid(
            items: supporting,
            onReorder: (oldIndex, newIndex) {
              _reorderGridCharactersByKind(
                kind: CharacterKind.supporting,
                oldIndex: oldIndex,
                newIndex: newIndex,
              );
            },
            onTap: (c) => _openEditor(initial: c),
            onDelete: _delete,
            emptyText: '아직 등장 인물이 없습니다.\n오른쪽 위 + 로 추가하세요.',
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;

  const _SectionHeader({required this.title, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 10, 10, 0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add, size: 22, color: Colors.black87),
            onPressed: onAdd,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _CharacterSliverList extends StatelessWidget {
  final List<Character> items;
  final void Function(Character) onTap;
  final void Function(Character) onEdit;
  final void Function(Character) onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index) onReorderStart;
  final void Function(int index) onReorderEnd;
  final int? draggingIndex;
  final String? emptyText;
  final bool sheetStyle;

  const _CharacterSliverList({
    required this.items,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
    required this.onReorderStart,
    required this.onReorderEnd,
    required this.draggingIndex,
    this.emptyText,
    this.sheetStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Center(
            child: Text(
              emptyText ?? '아직 캐릭터가 없습니다.\n오른쪽 위 + 로 추가하세요.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color.fromARGB(255, 170, 193, 216),
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      sliver: SliverReorderableList(
        itemCount: items.length,
        onReorderStart: onReorderStart,
        onReorderEnd: onReorderEnd,
        proxyDecorator: (child, index, animation) {
          return Material(
            type: MaterialType.transparency,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            child: AnimatedScale(
              scale: 1.05,
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOut,
              child: child,
            ),
          );
        },
        onReorder: onReorder,
        itemBuilder: (context, i) {
          final c = items[i];
          final isDragging = draggingIndex == i;

          return ReorderableDelayedDragStartListener(
            key: ValueKey('protagonist_${c.id}'),
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnimatedScale(
                scale: isDragging ? 1.04 : 1.0,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onTap(c),
                  splashFactory: NoSplash.splashFactory,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  child:
                      sheetStyle
                          ? _CharacterSheetCard(
                            character: c,
                            onEdit: () => onEdit(c),
                            onDelete: () => onDelete(c),
                          )
                          : _CharacterSimpleCard(
                            character: c,
                            onEdit: () => onEdit(c),
                            onDelete: () => onDelete(c),
                          ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SupportingCharacterGrid extends StatelessWidget {
  final List<Character> items;
  final void Function(Character) onTap;
  final void Function(Character) onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;
  final String? emptyText;

  const _SupportingCharacterGrid({
    required this.items,
    required this.onTap,
    required this.onDelete,
    required this.onReorder,
    this.emptyText,
  });

  String _clean(String s) => s.trim();
  String _fallback(String s, String fb) => _clean(s).isEmpty ? fb : _clean(s);

  Widget _buildCard(Character c) {
    final name = _fallback(c.name, 'Unnamed');
    final profile = _clean(c.specialNote);

    final Color accent = (c.color ?? const Color(0xFFB0C1D8)).withValues(
      alpha: 1.0,
    );

    return InkWell(
      onTap: () => onTap(c),
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      borderRadius: BorderRadius.circular(14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Positioned.fill(child: _SheetCover(coverPath: c.coverPath)),

                    Positioned(
                      left: 0,
                      top: 0,
                      height: 40,
                      child: Container(width: 3, color: accent),
                    ),

                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () => onDelete(c),
                        borderRadius: BorderRadius.circular(999),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 17,
                            color: Color.fromARGB(255, 222, 237, 255),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          profile.isEmpty ? 'Tap to edit' : profile,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.15,
                            color:
                                profile.isEmpty
                                    ? const Color.fromARGB(255, 170, 193, 216)
                                    : const Color.fromARGB(221, 141, 194, 230),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Center(
            child: Text(
              emptyText ?? '아직 캐릭터가 없습니다.\n오른쪽 위 + 로 추가하세요.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color.fromARGB(255, 170, 193, 216),
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      sliver: ReorderableSliverGridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2 / 3.05,
        onReorder: onReorder,

        // ✅ 주인공 proxyDecorator 느낌과 동일하게:
        // 배경/그림자 제거 + 이동 중 살짝 확대
        dragWidgetBuilderV2: DragWidgetBuilderV2(
          isScreenshotDragWidget: false,
          builder: (index, child, screenshot) {
            return Material(
              type: MaterialType.transparency,
              color: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              child: AnimatedScale(
                scale: 1.05,
                duration: const Duration(milliseconds: 80),
                curve: Curves.easeOut,
                child: child,
              ),
            );
          },
        ),

        children: [
          for (final c in items)
            KeyedSubtree(
              key: ValueKey('supporting_${c.id}'),
              child: _buildCard(c),
            ),
        ],
      ),
    );
  }
}

class _CharacterSheetCard extends StatelessWidget {
  final Character character;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CharacterSheetCard({
    required this.character,
    required this.onEdit,
    required this.onDelete,
  });

  String _clean(String s) => s.trim();
  String _fallback(String s, String fb) => _clean(s).isEmpty ? fb : _clean(s);

  @override
  Widget build(BuildContext context) {
    final name = _fallback(character.name, 'Unnamed');
    final birthday = _clean(character.birthday);
    final height = _clean(character.height);
    final blood = _clean(character.bloodType);
    final profile = _clean(character.specialNote);

    final Color accent = (character.color ?? const Color(0xFFB0C1D8))
        .withValues(alpha: 1.0);

    const double imageSize = 150;
    const double leftBarW = 3;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 170, height: 0.5, color: Colors.black),
                    Container(width: 50, height: 7, color: accent),

                    const SizedBox(height: 10),

                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),

                    const SizedBox(height: 10),
                    _BioRow(label: 'Birthday', value: birthday),
                    _BioRow(label: 'Height', value: height),
                    _BioRow(label: 'Blood', value: blood),

                    const SizedBox(height: 10),

                    const Text(
                      'PROFILE',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      profile.isEmpty ? 'Tap to edit' : profile,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        color: Color.fromARGB(221, 141, 194, 230),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
              child: SizedBox(
                width: imageSize,
                height: imageSize,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _SheetCover(coverPath: character.coverPath),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(width: leftBarW, color: accent),
                    ),

                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(999),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 17,
                            color: Color.fromARGB(255, 222, 237, 255),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BioRow extends StatelessWidget {
  final String label;
  final String value;

  const _BioRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final v = value.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(221, 123, 192, 237),
              ),
            ),
          ),
          Expanded(
            child: Text(
              v.isEmpty ? '-' : v,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(221, 5, 16, 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetCover extends StatelessWidget {
  final String? coverPath;

  const _SheetCover({required this.coverPath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: resolveCharacterCoverFile(coverPath),
      builder: (context, snapshot) {
        final f = snapshot.data;

        if (f == null) {
          return Container(
            color: const Color.fromARGB(112, 235, 247, 255),
            child: const Center(
              child: Icon(
                Icons.add,
                size: 20,
                color: Color.fromARGB(255, 186, 221, 255),
              ),
            ),
          );
        }

        return Image.file(
          f,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Container(
                color: const Color.fromARGB(255, 236, 244, 252),
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 22,
                    color: Color.fromARGB(255, 170, 193, 216),
                  ),
                ),
              ),
        );
      },
    );
  }
}

class _CharacterSimpleCard extends StatelessWidget {
  final Character character;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CharacterSimpleCard({
    required this.character,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        character.name.trim().isEmpty ? 'Unnamed' : character.name.trim();

    final subtitleParts = <String>[];
    if (character.birthday.trim().isNotEmpty) {
      subtitleParts.add('Birthday: ${character.birthday.trim()}');
    }
    if (character.height.trim().isNotEmpty) {
      subtitleParts.add('Height: ${character.height.trim()}');
    }
    final subtitle = subtitleParts.join('  ·  ');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 170, 193, 216)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _MiniCover(coverPath: character.coverPath),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle.isEmpty ? 'Tap to edit' : subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 170, 193, 216),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCover extends StatelessWidget {
  final String? coverPath;
  const _MiniCover({required this.coverPath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: resolveCharacterCoverFile(coverPath),
      builder: (context, snapshot) {
        final f = snapshot.data;

        return Container(
          width: 44,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 170, 193, 216),
            border: Border.all(color: const Color.fromARGB(255, 170, 193, 216)),
          ),
          clipBehavior: Clip.hardEdge,
          child:
              f == null
                  ? const Center(child: Icon(Icons.person, size: 20))
                  : Image.file(f, fit: BoxFit.cover),
        );
      },
    );
  }
}

class CharacterStoreIsar {
  final String documentId;
  CharacterStoreIsar(this.documentId);

  // -----------------------
  // UI → Isar Entity
  // -----------------------

  CharacterEntity _toEntity(
    Character c, {
    required int now,
    required int order,
  }) {
    return CharacterEntity()
      ..documentId = documentId
      ..uid = c.id
      ..kind = c.kind.key
      ..order = order
      ..colorArgb = c.color?.toARGB32()
      ..name = c.name
      ..birthday = c.birthday
      ..height = c.height
      ..bloodType = c.bloodType
      ..specialNote = c.specialNote
      ..coverPath = c.coverPath
      ..sheetAssetPath = c.sheetAssetPath
      ..personalityKeywords = List<String>.from(c.personalityKeywords)
      ..likes = List<String>.from(c.likes)
      ..dislikes = List<String>.from(c.dislikes)
      ..physicalNotes = List<String>.from(c.physicalNotes)
      ..palette =
          c.palette
              .map(
                (p) =>
                    CharacterPaletteE()
                      ..label = p.label
                      ..colorsArgb = p.colors.map((x) => x.toARGB32()).toList(),
              )
              .toList()
      ..images =
          c.images
              .map(
                (i) =>
                    CharacterImageE()
                      ..label = i.label
                      ..assetPath = i.assetPath,
              )
              .toList()
      ..updatedAt = now;
  }

  // -----------------------
  // Isar Entity → UI
  // -----------------------

  Character _toModel(CharacterEntity e) {
    return Character(
      id: e.uid,
      kind: CharacterKindX.fromKey(e.kind),
      color: e.colorArgb == null ? null : Color(e.colorArgb!),
      name: e.name,
      birthday: e.birthday,
      height: e.height,
      bloodType: e.bloodType,
      specialNote: e.specialNote,
      coverPath: e.coverPath,
      sheetAssetPath: e.sheetAssetPath,
      personalityKeywords: List<String>.from(e.personalityKeywords),
      likes: List<String>.from(e.likes),
      dislikes: List<String>.from(e.dislikes),
      physicalNotes: List<String>.from(e.physicalNotes),
      palette:
          e.palette
              .map(
                (p) => PaletteGroup(
                  label: p.label,
                  colors: p.colorsArgb.map((x) => Color(x)).toList(),
                ),
              )
              .toList(),
      images:
          e.images
              .map(
                (i) => CharacterImage(label: i.label, assetPath: i.assetPath),
              )
              .toList(),
    );
  }

  int _kindRank(String kind) {
    if (kind == CharacterKind.protagonist.key) return 0;
    return 1;
  }

  Future<int> _nextOrderForKind(CharacterKind kind) async {
    final isar = await WorldSeatIsar.instance;

    final rows =
        await isar.characterEntitys
            .filter()
            .documentIdEqualTo(documentId)
            .kindEqualTo(kind.key)
            .findAll();

    var maxOrder = -1;
    for (final row in rows) {
      if (row.order > maxOrder) {
        maxOrder = row.order;
      }
    }

    return maxOrder + 1;
  }

  // -----------------------
  // CRUD
  // -----------------------

  Future<List<Character>> loadAll() async {
    final isar = await WorldSeatIsar.instance;

    final rows =
        await isar.characterEntitys
            .where()
            .documentIdEqualTo(documentId)
            .findAll();

    rows.sort((a, b) {
      final kindCompare = _kindRank(a.kind).compareTo(_kindRank(b.kind));
      if (kindCompare != 0) return kindCompare;

      final orderCompare = a.order.compareTo(b.order);
      if (orderCompare != 0) return orderCompare;

      return b.updatedAt.compareTo(a.updatedAt);
    });

    return rows.map(_toModel).toList(growable: false);
  }

  Future<void> upsert(Character c) async {
    final isar = await WorldSeatIsar.instance;
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await isar.characterEntitys.getByUid(c.id);
    final order = existing?.order ?? await _nextOrderForKind(c.kind);

    await isar.writeTxn(() async {
      await isar.characterEntitys.putByUid(
        _toEntity(c, now: now, order: order),
      );
    });
  }

  Future<void> persistOrderByKind({
    required CharacterKind kind,
    required List<String> uidsInOrder,
  }) async {
    final isar = await WorldSeatIsar.instance;
    final now = DateTime.now().millisecondsSinceEpoch;

    await isar.writeTxn(() async {
      for (int i = 0; i < uidsInOrder.length; i++) {
        final uid = uidsInOrder[i];

        final row = await isar.characterEntitys.getByUid(uid);
        if (row == null) continue;
        if (row.documentId != documentId) continue;
        if (row.kind != kind.key) continue;

        row.order = i;
        row.updatedAt = now + i;

        await isar.characterEntitys.put(row);
      }
    });
  }

  Future<void> deleteByUid(String uid) async {
    final isar = await WorldSeatIsar.instance;

    await isar.writeTxn(() async {
      final row = await isar.characterEntitys.getByUid(uid);
      if (row != null) {
        await isar.characterEntitys.delete(row.id);
      }
    });
  }
}
