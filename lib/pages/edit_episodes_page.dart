// edit_episodes_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_container.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_action_button.dart';
import 'package:ebook_tutorial_app/models/genre.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditEpisodesPage extends StatefulWidget {
  const EditEpisodesPage({super.key, required this.genre});

  final Genre genre;

  static const String resultEnterPickMode = 'enter_pick_mode';

  @override
  State<EditEpisodesPage> createState() => _EditEpisodesPageState();
}

class Episode {
  final String title;
  final DateTime updatedAt;

  Episode({required this.title, required this.updatedAt});

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      title: (json['title'] as String?) ?? '',
      updatedAt:
          DateTime.tryParse((json['updatedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class EpisodeStorage {
  static String _key(String genreName) => 'episodes_$genreName';

  static Future<List<Episode>> load({required String genreName}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(genreName));
    if (raw == null || raw.isEmpty) return <Episode>[];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return <Episode>[];

    return decoded
        .map((e) => Episode.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<void> save(
    List<Episode> episodes, {
    required String genreName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(episodes.map((e) => e.toJson()).toList());
    await prefs.setString(_key(genreName), raw);
  }
}

class _EditEpisodesPageState extends State<EditEpisodesPage> {
  final List<Episode> _episodes = [];

  bool _selectionMode = false;
  final Set<int> _selected = <int>{};

  String get storageKey => 'episodes_${widget.genre.name}';

  @override
  void initState() {
    super.initState();
    unawaited(_loadEpisodes());
  }

  Future<void> _loadEpisodes() async {
    final loaded = await EpisodeStorage.load(genreName: widget.genre.name);
    if (!mounted) return;
    setState(() {
      _episodes
        ..clear()
        ..addAll(loaded);
    });
  }

  Future<void> _saveEpisodes() async {
    await EpisodeStorage.save(_episodes, genreName: widget.genre.name);
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
                      label: '책 선택',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(
                          context,
                          EditEpisodesPage.resultEnterPickMode,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    GlassActionButton(
                      theme: theme,
                      icon: Icons.check_box_outlined,
                      label: '회차 선택',
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectionMode = true;
                          _selected.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('닫기', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _addEpisode() async {
    final title = await _openTitleEditor(context, initial: '');
    if (title == null) return;
    final t = title.trim();
    if (t.isEmpty) return;

    setState(() {
      _episodes.add(Episode(title: t, updatedAt: DateTime.now()));
    });
    await _saveEpisodes();
  }

  Future<void> _editEpisode(int index) async {
    if (index < 0 || index >= _episodes.length) return;
    final cur = _episodes[index];

    final title = await _openTitleEditor(context, initial: cur.title);
    if (title == null) return;
    final t = title.trim();
    if (t.isEmpty) return;

    setState(() {
      _episodes[index] = Episode(title: t, updatedAt: DateTime.now());
    });
    await _saveEpisodes();
  }

  void _toggleSelect(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selected.clear();
    });
  }

  void _deleteSelected() {
    if (_selected.isEmpty) return;

    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => CupertinoActionSheet(
            title: const Text('삭제 확인'),
            message: const Text('선택된 회차를 삭제하시겠습니까?'),
            actions: [
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () async {
                  final sorted = _selected.toList()..sort((a, b) => b - a);
                  setState(() {
                    for (final i in sorted) {
                      if (i >= 0 && i < _episodes.length) {
                        _episodes.removeAt(i);
                      }
                    }
                    _exitSelectionMode();
                  });
                  Navigator.pop(context);
                  await _saveEpisodes();
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

  @override
  Widget build(BuildContext context) {
    final titleText = _selectionMode ? '${_selected.length}개 선택됨' : 'episodes';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
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
                  onPressed: () => Navigator.pop(context),
                ),
        actions: [
          if (_selectionMode)
            TextButton(
              onPressed: _deleteSelected,
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black87),
              tooltip: '회차 추가',
              onPressed: _addEpisode,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: '더보기',
              onPressed: () => _showMoreDialog(context),
            ),
          ],
        ],
      ),
      body:
          _episodes.isEmpty
              ? const Center(
                child: Text(
                  '저장된 회차가 없습니다.\n오른쪽 상단 + 버튼으로 회차를 추가하세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _episodes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final ep = _episodes[i];
                  final selected = _selectionMode && _selected.contains(i);

                  final tile = Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color:
                            selected
                                ? const Color.fromARGB(255, 91, 179, 255)
                                : const Color.fromARGB(221, 159, 188, 208),
                        width: selected ? 1.7 : 0.5,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        ep.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        ep.updatedAt.toLocal().toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color.fromARGB(255, 117, 148, 188),
                      ),
                    ),
                  );

                  if (_selectionMode) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _toggleSelect(i),
                      child: tile,
                    );
                  }

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTap: () => _editEpisode(i),
                    child: tile,
                  );
                },
              ),
    );
  }
}

Future<String?> _openTitleEditor(
  BuildContext context, {
  required String initial,
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text('회차 제목'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: '예: 1화 / 프롤로그 / 12화'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('저장'),
            ),
          ],
        ),
  );
}
