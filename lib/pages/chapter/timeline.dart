// timeline.dart

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import 'package:isar/isar.dart';
import 'package:ebook_tutorial_app/l10n/generated/app_localizations.dart';

import 'world_seat_isar.dart';

class TimelineTab extends StatefulWidget {
  final String documentId;

  final Future<bool> Function(
    BuildContext context,
    int sectionIndex,
    String barName,
  )?
  confirmDelete;

  const TimelineTab({super.key, required this.documentId, this.confirmDelete});

  @override
  State<TimelineTab> createState() => _TimelineTabState();
}

/// -------------------- Model --------------------

class TimelineColorSection {
  TimelineColorSection({
    required this.label,
    required this.color,
    required this.events,
  });

  final String label;
  final Color color;
  final List<TimelineEvent> events;
}

class TimelineEvent {
  TimelineEvent({required this.year, required this.desc});

  final String year;
  final String desc;
}

/// -------------------- Isar Store --------------------

class TimelineStoreIsar {
  final String documentId;

  TimelineStoreIsar(this.documentId);

  String _newUid() =>
      't_${documentId}_${DateTime.now().microsecondsSinceEpoch}';

  String _fallbackUnnamed() => 'Unnamed';

  TimelineColorSection _toModel(TimelineBarEntity e) {
    return TimelineColorSection(
      label: e.label,
      color: Color(e.colorArgb),
      events:
          e.events
              .map((ev) => TimelineEvent(year: ev.year, desc: ev.desc))
              .toList(),
    );
  }

  TimelineBarEntity _toEntity(
    TimelineColorSection s, {
    required String uid,
    required int order,
    required int now,
  }) {
    final cleanedLabel =
        s.label.trim().isEmpty ? _fallbackUnnamed() : s.label.trim();

    final cleanedEvents =
        (s.events.isEmpty
                ? [
                  TimelineEvent(year: DateTime.now().year.toString(), desc: ''),
                ]
                : s.events)
            .map(
              (e) =>
                  TimelineEventE()
                    ..year = e.year
                    ..desc = e.desc,
            )
            .toList();

    return TimelineBarEntity()
      ..documentId = documentId
      ..uid = uid
      ..label = cleanedLabel
      ..colorArgb = s.color.toARGB32()
      ..order = order
      ..events = cleanedEvents
      ..updatedAt = now;
  }

  Future<List<TimelineBarEntity>> _loadEntities() async {
    final isar = await WorldSeatIsar.instance;

    return isar.timelineBarEntitys
        .where()
        .documentIdEqualTo(documentId)
        .sortByOrder()
        .thenByUpdatedAtDesc()
        .findAll();
  }

  Future<List<TimelineColorSection>> loadAll() async {
    final rows = await _loadEntities();
    return rows.map(_toModel).toList(growable: false);
  }

  Future<void> seedIfEmpty(List<TimelineColorSection> seed) async {
    final isar = await WorldSeatIsar.instance;
    final existing =
        await isar.timelineBarEntitys
            .where()
            .documentIdEqualTo(documentId)
            .limit(1)
            .findAll();

    if (existing.isNotEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    await isar.writeTxn(() async {
      for (int i = 0; i < seed.length; i++) {
        final e = _toEntity(seed[i], uid: _newUid(), order: i, now: now + i);
        await isar.timelineBarEntitys.putByUid(e);
      }
    });
  }

  Future<void> upsertAt({
    required int order,
    required TimelineColorSection section,
    String? existingUid,
  }) async {
    final isar = await WorldSeatIsar.instance;
    final now = DateTime.now().millisecondsSinceEpoch;

    final uid = existingUid ?? _newUid();
    final e = _toEntity(section, uid: uid, order: order, now: now);

    await isar.writeTxn(() async {
      await isar.timelineBarEntitys.putByUid(e);
    });
  }

  Future<String?> uidAtIndex(int index) async {
    final rows = await _loadEntities();
    if (index < 0 || index >= rows.length) return null;
    return rows[index].uid;
  }

  Future<void> deleteByUid(String uid) async {
    final isar = await WorldSeatIsar.instance;
    await isar.writeTxn(() async {
      await isar.timelineBarEntitys.deleteByUid(uid);
    });
  }

  Future<void> persistOrderByCurrentList(List<String> uidsInOrder) async {
    final isar = await WorldSeatIsar.instance;
    final now = DateTime.now().millisecondsSinceEpoch;

    await isar.writeTxn(() async {
      for (int i = 0; i < uidsInOrder.length; i++) {
        final uid = uidsInOrder[i];
        final row = await isar.timelineBarEntitys.getByUid(uid);
        if (row == null) continue;
        row.order = i;
        row.updatedAt = now + i;
        await isar.timelineBarEntitys.put(row);
      }
    });
  }
}

/// -------------------- Tab State --------------------

class _TimelineTabState extends State<TimelineTab> {
  int? _draggingIndex;

  late final TimelineStoreIsar _store = TimelineStoreIsar(widget.documentId);

  bool _didStartLoad = false;
  bool _loading = true;
  List<TimelineColorSection> _sections = [];
  List<String> _uids = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didStartLoad) return;
    _didStartLoad = true;

    final l10n = AppLocalizations.of(context);
    _load(l10n);
  }

  List<TimelineColorSection> _seedDefault(AppLocalizations l10n) {
    return [
      TimelineColorSection(
        label: l10n.timelineSeedCreate,
        color: const Color.fromARGB(255, 255, 194, 222),
        events: [
          TimelineEvent(year: '2029', desc: l10n.timelineSeedEditWord),
          TimelineEvent(year: '2030', desc: ''),
          TimelineEvent(year: '2031', desc: ''),
          TimelineEvent(year: '2039', desc: ''),
        ],
      ),
      TimelineColorSection(
        label: l10n.timelineSeedCreateOne,
        color: const Color.fromARGB(255, 255, 244, 169),
        events: [
          TimelineEvent(year: '2040', desc: l10n.timelineSeedReorderColor),
        ],
      ),
      TimelineColorSection(
        label: l10n.timelineSeedCreate,
        color: const Color.fromARGB(255, 207, 241, 255),
        events: [
          TimelineEvent(year: '2090', desc: l10n.timelineSeedEditColorName),
          TimelineEvent(year: '2091', desc: ''),
        ],
      ),
      TimelineColorSection(
        label: l10n.timelineSeedUnnamed,
        color: const Color.fromARGB(255, 125, 211, 254),
        events: [
          TimelineEvent(year: '2100', desc: l10n.timelineSeedEditContent),
        ],
      ),
    ];
  }

  Future<void> _load(AppLocalizations l10n) async {
    try {
      await _store.seedIfEmpty(_seedDefault(l10n));

      final isar = await WorldSeatIsar.instance;
      final rows =
          await isar.timelineBarEntitys
              .where()
              .documentIdEqualTo(widget.documentId)
              .sortByOrder()
              .thenByUpdatedAtDesc()
              .findAll();

      final sections =
          rows
              .map(
                (e) => TimelineColorSection(
                  label: e.label,
                  color: Color(e.colorArgb),
                  events:
                      e.events
                          .map(
                            (ev) => TimelineEvent(year: ev.year, desc: ev.desc),
                          )
                          .toList(),
                ),
              )
              .toList();

      if (!mounted) return;

      setState(() {
        _sections = sections;
        _uids = rows.map((e) => e.uid).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _sections = [];
        _uids = [];
        _loading = false;
      });
    }
  }

  Future<void> _openEditor({int? sectionIndex}) async {
    final l10n = AppLocalizations.of(context);

    final initial =
        (sectionIndex != null &&
                sectionIndex >= 0 &&
                sectionIndex < _sections.length)
            ? _EditPayload.fromSection(_sections[sectionIndex])
            : null;

    final result = await Navigator.of(context).push<_EditResult>(
      MaterialPageRoute(builder: (_) => _TimelineBarEditPage(initial: initial)),
    );

    if (!mounted || result == null) return;

    if (result.deleted && sectionIndex != null) {
      final confirm = widget.confirmDelete;

      if (confirm == null) {
        await _deleteSectionAt(sectionIndex);
        return;
      }

      final ok = await confirm(
        context,
        sectionIndex,
        _sections[sectionIndex].label,
      );

      if (!mounted) return;

      if (ok) {
        await _deleteSectionAt(sectionIndex);
      }

      return;
    }

    final payload = result.payload;
    if (payload == null) return;

    final newSection = payload.toSection(unnamedLabel: l10n.unnamed);

    if (sectionIndex != null &&
        sectionIndex >= 0 &&
        sectionIndex < _sections.length) {
      final uid = _uids[sectionIndex];

      setState(() {
        _sections[sectionIndex] = newSection;
      });

      await _store.upsertAt(
        order: sectionIndex,
        section: newSection,
        existingUid: uid,
      );
      return;
    }

    setState(() {
      _sections.add(newSection);
      _uids.add('');
    });

    final newIndex = _sections.length - 1;
    await _store.upsertAt(order: newIndex, section: newSection);
    unawaited(_load(l10n));
  }

  Future<void> _deleteSectionAt(int index) async {
    if (index < 0 || index >= _sections.length) return;

    final uid = _uids[index];

    setState(() {
      _sections.removeAt(index);
      _uids.removeAt(index);
    });

    if (uid.isNotEmpty) {
      await _store.deleteByUid(uid);
    }

    unawaited(
      _store.persistOrderByCurrentList(
        _uids.where((e) => e.isNotEmpty).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    l10n.timeline,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _openEditor(),
                    icon: const Icon(
                      Icons.add,
                      size: 22,
                      color: Colors.black87,
                    ),
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
                    _sections.isEmpty
                        ? Center(
                          child: Text(
                            l10n.timelineEmpty,
                            style: const TextStyle(
                              color: Color.fromARGB(221, 83, 129, 159),
                              fontSize: 13,
                            ),
                          ),
                        )
                        : ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          padding: const EdgeInsets.only(top: 6),
                          itemCount: _sections.length,
                          onReorderStart:
                              (i) => setState(() => _draggingIndex = i),
                          onReorderEnd:
                              (_) => setState(() => _draggingIndex = null),
                          proxyDecorator: (child, index, animation) {
                            return Material(
                              type: MaterialType.transparency,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              child: AnimatedScale(
                                scale: 1.08,
                                duration: const Duration(milliseconds: 80),
                                curve: Curves.easeOut,
                                child: child,
                              ),
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;

                              final item = _sections.removeAt(oldIndex);
                              _sections.insert(newIndex, item);

                              final uid = _uids.removeAt(oldIndex);
                              _uids.insert(newIndex, uid);
                            });

                            unawaited(
                              _store.persistOrderByCurrentList(
                                _uids.where((e) => e.isNotEmpty).toList(),
                              ),
                            );
                          },
                          itemBuilder: (context, index) {
                            final section = _sections[index];

                            return Padding(
                              key: ValueKey(
                                'timeline_${index}_${section.label}_${_uids[index]}',
                              ),
                              padding: EdgeInsets.zero,
                              child: _ColorSectionView(
                                section: section,
                                sectionIndex: index,
                                onTapEvent:
                                    () => _openEditor(sectionIndex: index),
                                dragHandleIndex: index,
                                isDragging: _draggingIndex == index,
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// -------------------- UI --------------------

class _ColorSectionView extends StatelessWidget {
  const _ColorSectionView({
    required this.section,
    required this.sectionIndex,
    required this.onTapEvent,
    required this.dragHandleIndex,
    required this.isDragging,
  });

  final TimelineColorSection section;
  final int sectionIndex;
  final VoidCallback onTapEvent;
  final int dragHandleIndex;
  final bool isDragging;

  double _calcBarMinHeightFromLabel(String label) {
    const textStyle = TextStyle(
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      fontSize: 14,
      height: 1.05,
    );

    final tp = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: 18);

    return tp.height + 18;
  }

  @override
  Widget build(BuildContext context) {
    final bool showOnRight = sectionIndex.isEven;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child:
                showOnRight
                    ? const SizedBox.shrink()
                    : _EventsColumn(
                      events: section.events,
                      alignEndToBar: true,
                      onTap: onTapEvent,
                      barColor: section.color,
                    ),
          ),
          _ColorBar(
            label: section.label,
            color: section.color,
            minHeight: _calcBarMinHeightFromLabel(section.label),
            dragHandleIndex: dragHandleIndex,
            isDragging: isDragging,
          ),
          Expanded(
            child:
                showOnRight
                    ? _EventsColumn(
                      events: section.events,
                      alignEndToBar: false,
                      onTap: onTapEvent,
                      barColor: section.color,
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ColorBar extends StatelessWidget {
  const _ColorBar({
    required this.label,
    required this.color,
    required this.minHeight,
    required this.dragHandleIndex,
    required this.isDragging,
  });

  final String label;
  final Color color;
  final double minHeight;
  final int dragHandleIndex;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    const double w = 22;

    final bar = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: AnimatedScale(
        scale: isDragging ? 1.10 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: w,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: color),
          child: Center(
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                label,
                softWrap: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return ReorderableDragStartListener(index: dragHandleIndex, child: bar);
  }
}

class _EventsColumn extends StatelessWidget {
  const _EventsColumn({
    required this.events,
    required this.alignEndToBar,
    required this.onTap,
    required this.barColor,
  });

  final List<TimelineEvent> events;
  final bool alignEndToBar;
  final VoidCallback onTap;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment:
          alignEndToBar ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        for (final e in events) ...[
          _EventTile(
            event: e,
            alignEndToBar: alignEndToBar,
            onTap: onTap,
            barColor: barColor,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.event,
    required this.alignEndToBar,
    required this.onTap,
    required this.barColor,
  });

  final TimelineEvent event;
  final bool alignEndToBar;
  final VoidCallback onTap;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: Color(0xFF2A2A2A),
      fontSize: 11.5,
      height: 1.20,
    );

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 230),
        child: Padding(
          padding: EdgeInsets.only(
            left: alignEndToBar ? 0 : 2,
            right: alignEndToBar ? 2 : 0,
            top: 6,
            bottom: 6,
          ),
          child: Column(
            crossAxisAlignment:
                alignEndToBar
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                event.year,
                style: TextStyle(
                  color: barColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                event.desc,
                style: textStyle,
                textAlign: alignEndToBar ? TextAlign.right : TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// -------------------- Edit Page --------------------

class _EditPayload {
  final String barName;
  final Color barColor;
  final List<TimelineEvent> events;

  const _EditPayload({
    required this.barName,
    required this.barColor,
    required this.events,
  });

  factory _EditPayload.fromSection(TimelineColorSection s) {
    return _EditPayload(
      barName: s.label,
      barColor: s.color,
      events:
          s.events.isEmpty
              ? [TimelineEvent(year: DateTime.now().year.toString(), desc: '')]
              : s.events
                  .map((e) => TimelineEvent(year: e.year, desc: e.desc))
                  .toList(),
    );
  }

  TimelineColorSection toSection({required String unnamedLabel}) {
    final name = barName.trim().isEmpty ? unnamedLabel : barName.trim();

    final cleanedEvents =
        events.map((e) => TimelineEvent(year: e.year, desc: e.desc)).toList();

    return TimelineColorSection(
      label: name,
      color: barColor,
      events:
          cleanedEvents.isEmpty
              ? [TimelineEvent(year: DateTime.now().year.toString(), desc: '')]
              : cleanedEvents,
    );
  }
}

class _EditResult {
  final _EditPayload? payload;
  final bool deleted;

  const _EditResult._({this.payload, required this.deleted});

  factory _EditResult.saved(_EditPayload p) =>
      _EditResult._(payload: p, deleted: false);

  factory _EditResult.delete() =>
      const _EditResult._(payload: null, deleted: true);
}

class _TimelineBarEditPage extends StatefulWidget {
  final _EditPayload? initial;

  const _TimelineBarEditPage({required this.initial});

  @override
  State<_TimelineBarEditPage> createState() => _TimelineBarEditPageState();
}

class _EditEventRow extends StatelessWidget {
  const _EditEventRow({
    required this.yearCtrl,
    required this.descCtrl,
    required this.descriptionHint,
    required this.isDragging,
    required this.onRemove,
    required this.dragIndex,
  });

  final TextEditingController yearCtrl;
  final TextEditingController descCtrl;
  final String descriptionHint;
  final bool isDragging;
  final VoidCallback onRemove;
  final int dragIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReorderableDragStartListener(
          index: dragIndex,
          child: Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: AnimatedScale(
              scale: isDragging ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: const Icon(
                Icons.drag_indicator,
                size: 15,
                color: Color.fromARGB(221, 145, 195, 222),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 70,
          child: TextField(
            controller: yearCtrl,
            keyboardType: TextInputType.number,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: 16,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              hintText: '2026',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AnimatedScale(
            scale: isDragging ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: TextField(
              controller: descCtrl,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 13, height: 1.25),
              decoration: InputDecoration(
                hintText: descriptionHint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(221, 147, 212, 255),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.close, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

class _TimelineBarEditPageState extends State<_TimelineBarEditPage> {
  late final TextEditingController _nameCtrl;
  Color _color = const Color.fromARGB(255, 122, 171, 190);

  final List<TextEditingController> _yearCtrls = [];
  final List<TextEditingController> _descCtrls = [];

  int? _draggingEventIndex;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.initial?.barName ?? '');
    _color = widget.initial?.barColor ?? _color;

    final initEvents =
        widget.initial?.events ??
        [TimelineEvent(year: DateTime.now().year.toString(), desc: '')];

    for (final e in initEvents) {
      _yearCtrls.add(TextEditingController(text: e.year));
      _descCtrls.add(TextEditingController(text: e.desc));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();

    for (final c in _yearCtrls) {
      c.dispose();
    }

    for (final c in _descCtrls) {
      c.dispose();
    }

    super.dispose();
  }

  void _addEventRow() {
    setState(() {
      _yearCtrls.add(
        TextEditingController(text: DateTime.now().year.toString()),
      );
      _descCtrls.add(TextEditingController(text: ''));
    });
  }

  void _removeEventRow(int i) {
    if (i < 0 || i >= _yearCtrls.length) return;

    setState(() {
      _yearCtrls[i].dispose();
      _descCtrls[i].dispose();
      _yearCtrls.removeAt(i);
      _descCtrls.removeAt(i);

      if (_yearCtrls.isEmpty) {
        _yearCtrls.add(
          TextEditingController(text: DateTime.now().year.toString()),
        );
        _descCtrls.add(TextEditingController(text: ''));
      }
    });
  }

  void _save() {
    final name = _nameCtrl.text.trim();

    final events = <TimelineEvent>[];

    for (int i = 0; i < _yearCtrls.length; i++) {
      final y = _yearCtrls[i].text;
      final d = _descCtrls[i].text;
      events.add(TimelineEvent(year: y, desc: d));
    }

    Navigator.of(context).maybePop(
      _EditResult.saved(
        _EditPayload(barName: name, barColor: _color, events: events),
      ),
    );
  }

  void _deleteSection() {
    Navigator.of(context).maybePop(_EditResult.delete());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget label(String s) => Text(
      s,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color.fromARGB(221, 101, 181, 234),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _isEdit ? l10n.timelineEdit : l10n.timelineAdd,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _deleteSection,
              icon: const Icon(Icons.close),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            label(l10n.barName),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(
                fontSize: 16,
                height: 1.25,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: l10n.barNameHint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(221, 101, 181, 234),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                label(l10n.wordDescription),
                const Spacer(),
                IconButton(
                  onPressed: _addEventRow,
                  icon: const Icon(Icons.add, size: 20),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _yearCtrls.length,
              onReorderStart: (i) => setState(() => _draggingEventIndex = i),
              onReorderEnd: (_) => setState(() => _draggingEventIndex = null),
              proxyDecorator: (child, index, animation) {
                return Material(
                  type: MaterialType.transparency,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  child: AnimatedScale(
                    scale: 1.05,
                    duration: const Duration(milliseconds: 70),
                    curve: Curves.easeOut,
                    child: child,
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;

                  final y = _yearCtrls.removeAt(oldIndex);
                  final d = _descCtrls.removeAt(oldIndex);

                  _yearCtrls.insert(newIndex, y);
                  _descCtrls.insert(newIndex, d);
                });
              },
              itemBuilder: (context, i) {
                return Padding(
                  key: ValueKey('edit_event_$i'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EditEventRow(
                    yearCtrl: _yearCtrls[i],
                    descCtrl: _descCtrls[i],
                    descriptionHint: l10n.description,
                    isDragging: _draggingEventIndex == i,
                    onRemove: () => _removeEventRow(i),
                    dragIndex: i,
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            label(l10n.barColor),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: _color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ClipRect(
              child: Align(
                alignment: Alignment.center,
                widthFactor: 1,
                heightFactor: 1,
                child: ColorPicker(
                  color: _color,
                  onColorChanged: (c) => setState(() => _color = c),
                  heading: const SizedBox.shrink(),
                  subheading: const SizedBox.shrink(),
                  showColorCode: false,
                  colorCodeHasColor: false,
                  wheelDiameter: 170,
                  wheelWidth: 14,
                  wheelSquarePadding: 7,
                  enableShadesSelection: false,
                  pickersEnabled: const <ColorPickerType, bool>{
                    ColorPickerType.wheel: true,
                    ColorPickerType.primary: false,
                    ColorPickerType.accent: false,
                    ColorPickerType.both: false,
                    ColorPickerType.bw: false,
                    ColorPickerType.custom: false,
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
