// world_seat.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ebook_tutorial_app/pages/chapter/character.dart';

class WorldSeatPage extends StatefulWidget {
  final String documentId;
  const WorldSeatPage({super.key, required this.documentId});

  static const _tabs = [
    Tab(text: 'Character'),
    Tab(text: 'Glossary'),
    Tab(text: 'Timeline'),
    Tab(text: 'Faction'),
    Tab(text: 'free memo'),
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
                physics: const BouncingScrollPhysics(),
                children: [
                  CharacterSeatTab(documentId: widget.documentId),
                  const _PlaceholderTab(title: 'Glossary'),
                  const _PlaceholderTab(title: 'Timeline'),
                  const _PlaceholderTab(title: 'Faction'),
                  const _PlaceholderTab(title: 'free memo'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  const _PlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return const _KeepAlive(
      child: Center(
        child: Text(
          '+',
          style: TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 170, 193, 216),
          ),
        ),
      ),
    );
  }
}

class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class CharacterSeatTab extends StatefulWidget {
  final String documentId;
  const CharacterSeatTab({super.key, required this.documentId});
  @override
  State<CharacterSeatTab> createState() => _CharacterSeatTabState();
}

class _CharacterSeatTabState extends State<CharacterSeatTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String get _prefsKeySeeded => 'world_seat_seeded_${widget.documentId}';
  String get _prefsKeyCharScroll =>
      'world_seat_character_scroll_${widget.documentId}';

  late final CharacterStore _store = CharacterStore(widget.documentId);

  final ScrollController _scrollCtrl = ScrollController();
  double? _restoredOffset;
  bool _restoreTried = false;

  Timer? _scrollDebounce;

  bool _loading = true;
  List<Character> _characters = [];

  List<Character> _seedExampleCharacters() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return [
      Character(
        id: 'demo_p_$now',
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
        id: 'demo_p_{$now}_1',
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

  Future<void> _load() async {
    try {
      var list = await _store.loadCharacters();

      final prefs = await SharedPreferences.getInstance();
      final seeded = prefs.getBool(_prefsKeySeeded) ?? false;

      if (!seeded && list.isEmpty) {
        list = _seedExampleCharacters();
        await _store.saveCharacters(list);
        await prefs.setBool(_prefsKeySeeded, true);
      }

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

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _attemptRestoreScroll(),
    );
  }

  Future<void> _save() async {
    await _store.saveCharacters(_characters);
  }

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

    setState(() {
      final idx = _characters.indexWhere((c) => c.id == result.id);
      if (idx >= 0) {
        _characters[idx] = result;
      } else {
        _characters = [result, ..._characters];
      }
    });

    await _save();

    _restoreTried = false;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _attemptRestoreScroll(),
    );
  }

  Future<void> _delete(Character c) async {
    await _persistScroll();
    if (!mounted) return;

    setState(() {
      _characters.removeWhere((x) => x.id == c.id);
    });

    await _save();

    _restoreTried = false;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _attemptRestoreScroll(),
    );
  }

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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add),
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
  final String? emptyText;
  final bool sheetStyle;

  const _CharacterSliverList({
    required this.items,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
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
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final c = items[i];

          return InkWell(
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
  final String? emptyText;

  const _SupportingCharacterGrid({
    required this.items,
    required this.onTap,
    required this.onDelete,
    this.emptyText,
  });

  String _clean(String s) => s.trim();
  String _fallback(String s, String fb) => _clean(s).isEmpty ? fb : _clean(s);

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
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, i) {
          final c = items[i];
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
                          Positioned.fill(
                            child: _SheetCover(coverPath: c.coverPath),
                          ),

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
                                          ? const Color.fromARGB(
                                            255,
                                            170,
                                            193,
                                            216,
                                          )
                                          : const Color.fromARGB(
                                            221,
                                            141,
                                            194,
                                            230,
                                          ),
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
        }, childCount: items.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2 / 3.05,
        ),
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
    File? f;
    final p = coverPath?.trim() ?? '';
    if (p.isNotEmpty) {
      final file = File(p);
      if (file.existsSync()) f = file;
    }

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
    File? f;
    if (coverPath != null && coverPath!.trim().isNotEmpty) {
      final file = File(coverPath!.trim());
      if (file.existsSync()) f = file;
    }

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
  }
}

class CharacterStore {
  final String documentId;

  CharacterStore(this.documentId);

  String get _fileName => 'characters_${_safeId(documentId)}.json';

  String _safeId(String s) => s.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<Character>> loadCharacters() async {
    final file = await _file();
    if (!await file.exists()) return [];

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    final list = <Character>[];
    for (final e in decoded) {
      if (e is Map) {
        list.add(Character.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return list;
  }

  Future<void> saveCharacters(List<Character> list) async {
    final file = await _file();
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await file.writeAsString(encoded, flush: true);
  }
}
