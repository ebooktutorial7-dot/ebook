// calendar_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ebook_tutorial_app/models/genre.dart';

final Color kDialogBarrierColor = const Color(
  0xFF0F2238,
).withValues(alpha: 0.13);

class CalendarPage extends StatefulWidget {
  final Genre genre;
  final DateTime? initialDate;

  const CalendarPage({super.key, required this.genre, this.initialDate});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with WidgetsBindingObserver {
  late DateTime _selectedDate;
  late DateTime _monthCursor;
  DayLog _log = DayLog.empty();
  final Map<String, DayLog> _monthCache = {};

  bool _loading = true;

  final List<RangeEvent> _rangeEvents = [];

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _prefsRangeEventsKey() => 'calendar_range_events_common';

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bootstrap();
    }
  }

  Future<Object?> _openRangeEventEditor(RangeEvent ev) async {
    final titleC = TextEditingController(text: ev.title);
    final memoC = TextEditingController(text: ev.memo);

    DateTime start = DateTime.parse(ev.startIso);
    DateTime end = DateTime.parse(ev.endIso);

    final palette = <Color>[
      const Color.fromARGB(255, 255, 169, 169),
      const Color.fromARGB(255, 255, 206, 137),
      const Color.fromARGB(255, 255, 255, 192),
      const Color.fromARGB(255, 214, 255, 194),
      const Color.fromARGB(255, 185, 239, 255),
      const Color.fromARGB(255, 120, 149, 169),
    ];

    Color picked = Color(ev.colorValue);
    if (!palette.any((c) => c.toARGB32() == picked.toARGB32())) {
      palette.insert(0, picked);
    }

    final edited = await showModalBottomSheet<Object?>(
      context: context,
      barrierColor: kDialogBarrierColor,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;

        Widget section({
          required Widget child,
          EdgeInsetsGeometry padding = const EdgeInsets.all(14),
        }) {
          return Container(
            padding: padding,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3EDF7), width: 1),
            ),
            child: child,
          );
        }

        Widget dateTile({
          required String label,
          required String value,
          required VoidCallback onTap,
        }) {
          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE1EAF4), width: 1),
              ),
              child: Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E4A67),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6F88A3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Color(0xFF9BB2C9),
                  ),
                ],
              ),
            ),
          );
        }

        Future<DateTime?> pick(DateTime initial) async {
          final res = await _pickDate(ctx, initial);
          return res == null ? null : DateTime(res.year, res.month, res.day);
        }

        Future<bool?> showDeleteDialog() {
          return showDialog<bool>(
            context: context,
            barrierColor: kDialogBarrierColor,
            builder: (dialogCtx) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 77),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE3EDF7),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6E2EF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '일정 삭제',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F3A56),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '“${ev.title.isEmpty ? '제목 없음' : ev.title}” 일정을 삭제하시겠습니까?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: Color(0xFF6F88A3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: OutlinedButton(
                                onPressed:
                                    () => Navigator.of(dialogCtx).pop(false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF7594BC),
                                  side: const BorderSide(
                                    color: Color(0xFFE1EAF4),
                                    width: 1,
                                  ),
                                  backgroundColor: const Color(0xFFF8FBFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  '취소',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed:
                                    () => Navigator.of(dialogCtx).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    235,
                                    28,
                                    62,
                                    107,
                                  ),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  '삭제',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return StatefulBuilder(
          builder: (ctx2, setSB) {
            String fmt(DateTime d) =>
                '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}.';

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6E2EF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        const Text(
                          '일정 편집',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F3A56),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx2),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF7594BC),
                          ),
                          child: const Text(
                            '닫기',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    section(
                      child: TextField(
                        controller: titleC,
                        decoration: const InputDecoration(
                          hintText: '제목 입력',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 157, 177, 198),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F3A56),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    section(
                      child: Column(
                        children: [
                          dateTile(
                            label: '시작일',
                            value: fmt(start),
                            onTap: () async {
                              final pickedD = await pick(start);
                              if (pickedD == null) return;
                              setSB(() {
                                start = DateTime(
                                  pickedD.year,
                                  pickedD.month,
                                  pickedD.day,
                                );
                                if (end.isBefore(start)) end = start;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          dateTile(
                            label: '종료일',
                            value: fmt(end),
                            onTap: () async {
                              final pickedD = await pick(end);
                              if (pickedD == null) return;
                              setSB(() {
                                end = DateTime(
                                  pickedD.year,
                                  pickedD.month,
                                  pickedD.day,
                                );
                                if (end.isBefore(start)) end = start;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 2, bottom: 10),
                          child: Text(
                            '색상',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5F7D9B),
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final c in palette)
                              InkWell(
                                onTap: () => setSB(() => picked = c),
                                borderRadius: BorderRadius.circular(999),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 140),
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: c,
                                    border: Border.all(
                                      color:
                                          picked.toARGB32() == c.toARGB32()
                                              ? const Color(0xFF1F3A56)
                                              : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    boxShadow:
                                        picked.toARGB32() == c.toARGB32()
                                            ? [
                                              BoxShadow(
                                                color: c.withValues(
                                                  alpha: 0.28,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                            : null,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    section(
                      child: TextField(
                        controller: memoC,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: '메모 입력',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 157, 177, 198),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.4,
                          color: Color.fromARGB(255, 39, 50, 60),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            235,
                            28,
                            62,
                            107,
                          ),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          final title = titleC.text.trim();

                          Navigator.pop(
                            ctx2,
                            RangeEvent(
                              id: ev.id,
                              title: title,
                              memo: memoC.text.trim(),
                              startIso: _ymd(start),
                              endIso: _ymd(end),
                              colorValue: picked.toARGB32(),
                            ),
                          );
                        },
                        child: const Text(
                          '저장',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () async {
                          final ok = await showDeleteDialog();
                          if (!ctx2.mounted) return;
                          if (ok == true) {
                            Navigator.of(ctx2).pop('__delete__');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1F3A56),
                          side: const BorderSide(
                            color: Color(0xFFE1EAF4),
                            width: 1,
                          ),
                          backgroundColor: const Color(0xFFF8FBFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          '일정 삭제',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return edited;
  }

  Future<void> _loadRangeEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsRangeEventsKey());
    _rangeEvents.clear();

    if (raw == null || raw.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        for (final e in decoded) {
          if (e is Map) {
            _rangeEvents.add(RangeEvent.fromMap(Map<String, dynamic>.from(e)));
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _saveRangeEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _rangeEvents.map((e) => e.toMap()).toList();
    await prefs.setString(_prefsRangeEventsKey(), jsonEncode(list));
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime initial) {
    const primaryBlue = Color(0xFF7594BC);
    const deepBlue = Color(0xFF1F3A56);
    const softBg = Color(0xFFF8FBFF);
    const softBorder = Color(0xFFE3EDF7);
    const mutedText = Color(0xFF6F88A3);

    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      barrierColor: kDialogBarrierColor,
      helpText: '날짜 선택',
      cancelText: '취소',
      confirmText: '확인',
      builder: (ctx, child) {
        final base = Theme.of(ctx);

        return Theme(
          data: base.copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: deepBlue,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              headerBackgroundColor: softBg,
              headerForegroundColor: deepBlue,
              headerHeadlineStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: deepBlue,
              ),
              headerHelpStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: mutedText,
              ),
              weekdayStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: mutedText,
              ),
              dayStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: deepBlue,
              ),
              yearStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: deepBlue,
              ),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primaryBlue;
                }
                return Colors.transparent;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                if (states.contains(WidgetState.disabled)) {
                  return mutedText.withValues(alpha: 0.45);
                }
                return deepBlue;
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return primaryBlue;
              }),
              todayBorder: const BorderSide(color: primaryBlue, width: 1),
              yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primaryBlue.withValues(alpha: 0.14);
                }
                return Colors.transparent;
              }),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primaryBlue;
                }
                return deepBlue;
              }),
              dividerColor: softBorder,
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: mutedText,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: primaryBlue,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedDate = _stripTime(widget.initialDate ?? DateTime.now());
    _monthCursor = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _bootstrap();
  }

  Future<void> _openAddRangeEventSheet() async {
    final titleC = TextEditingController();
    final memoC = TextEditingController();

    DateTime start = _selectedDate;
    DateTime end = _selectedDate;

    final palette = <Color>[
      const Color.fromARGB(255, 255, 169, 169),
      const Color.fromARGB(255, 255, 206, 137),
      const Color.fromARGB(255, 255, 255, 192),
      const Color.fromARGB(255, 214, 255, 194),
      const Color.fromARGB(255, 185, 239, 255),
      const Color.fromARGB(255, 120, 149, 169),
    ];

    Color picked = palette.first;

    final created = await showModalBottomSheet<RangeEvent>(
      context: context,
      barrierColor: kDialogBarrierColor,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;

        Widget section({
          required Widget child,
          EdgeInsetsGeometry padding = const EdgeInsets.all(14),
        }) {
          return Container(
            padding: padding,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3EDF7), width: 1),
            ),
            child: child,
          );
        }

        Widget dateTile({
          required String label,
          required String value,
          required VoidCallback onTap,
        }) {
          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE1EAF4), width: 1),
              ),
              child: Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E4A67),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6F88A3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Color(0xFF9BB2C9),
                  ),
                ],
              ),
            ),
          );
        }

        return StatefulBuilder(
          builder: (ctx2, setSB) {
            String fmt(DateTime d) =>
                '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}.';

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6E2EF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        const Text(
                          '신규 일정',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F3A56),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx2),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF7594BC),
                          ),
                          child: const Text(
                            '닫기',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    section(
                      child: TextField(
                        controller: titleC,
                        decoration: const InputDecoration(
                          hintText: '제목 입력',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 157, 177, 198),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F3A56),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    section(
                      child: Column(
                        children: [
                          dateTile(
                            label: '시작일',
                            value: fmt(start),
                            onTap: () async {
                              final pickedD = await _pickDate(ctx2, start);
                              if (pickedD == null) return;
                              setSB(() {
                                start = DateTime(
                                  pickedD.year,
                                  pickedD.month,
                                  pickedD.day,
                                );
                                if (end.isBefore(start)) end = start;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          dateTile(
                            label: '종료일',
                            value: fmt(end),
                            onTap: () async {
                              final pickedD = await _pickDate(ctx2, end);
                              if (pickedD == null) return;
                              setSB(() {
                                end = DateTime(
                                  pickedD.year,
                                  pickedD.month,
                                  pickedD.day,
                                );
                                if (end.isBefore(start)) end = start;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 2, bottom: 10),
                          child: Text(
                            '색상',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5F7D9B),
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final c in palette)
                              InkWell(
                                onTap: () => setSB(() => picked = c),
                                borderRadius: BorderRadius.circular(999),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 140),
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: c,
                                    border: Border.all(
                                      color:
                                          picked.toARGB32() == c.toARGB32()
                                              ? const Color(0xFF1F3A56)
                                              : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    boxShadow:
                                        picked.toARGB32() == c.toARGB32()
                                            ? [
                                              BoxShadow(
                                                color: c.withValues(
                                                  alpha: 0.28,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                            : null,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    section(
                      child: TextField(
                        controller: memoC,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: '메모 입력',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 157, 177, 198),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.4,
                          color: Color.fromARGB(255, 39, 50, 60),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            235,
                            28,
                            62,
                            107,
                          ),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          final title = titleC.text.trim();

                          final ev = RangeEvent(
                            id:
                                DateTime.now().microsecondsSinceEpoch
                                    .toString(),
                            title: title,
                            memo: memoC.text.trim(),
                            startIso: _ymd(start),
                            endIso: _ymd(end),
                            colorValue: picked.toARGB32(),
                          );

                          Navigator.pop(ctx2, ev);
                        },
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (created == null) return;

    setState(() {
      _rangeEvents.add(created);
    });
    await _saveRangeEvents();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    await _loadMonthIntoCache(_monthCursor);
    await _loadRangeEvents();
    _log = _monthCache[_keyOf(_selectedDate)] ?? DayLog.empty();
    setState(() => _loading = false);
  }

  String _keyOf(DateTime d) {
    final x = _stripTime(d);
    final y = x.year.toString().padLeft(4, '0');
    final m = x.month.toString().padLeft(2, '0');
    final day = x.day.toString().padLeft(2, '0');
    return '$y$m$day';
  }

  String _prefsKeyForDay(String yyyymmdd) =>
      'calendar_day_${widget.genre.name}_$yyyymmdd';

  String _prefsMonthIndexKey(int year, int month) =>
      'calendar_month_index_${widget.genre.name}_${year.toString().padLeft(4, '0')}${month.toString().padLeft(2, '0')}';

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  String _formatYMD(DateTime dt) {
    final l = dt.toLocal();
    return '${l.year}.${l.month.toString().padLeft(2, '0')}.${l.day.toString().padLeft(2, '0')}.';
  }

  String _formatYM(DateTime dt) {
    final l = dt.toLocal();
    return '${l.year}.${l.month.toString().padLeft(2, '0')}';
  }

  Future<void> _loadMonthIntoCache(DateTime monthFirstDay) async {
    final prefs = await SharedPreferences.getInstance();
    _monthCache.clear();

    if (widget.genre != Genre.main) {
      final ymKey = _prefsMonthIndexKey(
        monthFirstDay.year,
        monthFirstDay.month,
      );
      final daysJson = prefs.getString(ymKey);
      final Set<String> dayKeys = {};

      if (daysJson != null && daysJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(daysJson);
          if (decoded is List) {
            for (final e in decoded) {
              if (e is String && e.length == 8) dayKeys.add(e);
            }
          }
        } catch (_) {}
      }

      for (final dayKey in dayKeys) {
        final raw = prefs.getString(_prefsKeyForDay(dayKey));
        if (raw == null || raw.isEmpty) continue;
        try {
          final decoded = jsonDecode(raw);
          final log = DayLog.fromMap(Map<String, dynamic>.from(decoded));
          _monthCache[dayKey] = log;
        } catch (_) {}
      }
      return;
    }

    // Genre.main => 모든 장르 합산
    for (final g in Genre.values.where((e) => e != Genre.main)) {
      final ymKey =
          'calendar_month_index_${g.name}_${monthFirstDay.year.toString().padLeft(4, '0')}${monthFirstDay.month.toString().padLeft(2, '0')}';

      final daysJson = prefs.getString(ymKey);
      if (daysJson == null || daysJson.isEmpty) continue;

      final Set<String> dayKeys = {};
      try {
        final decoded = jsonDecode(daysJson);
        if (decoded is List) {
          for (final e in decoded) {
            if (e is String && e.length == 8) dayKeys.add(e);
          }
        }
      } catch (_) {}

      for (final dayKey in dayKeys) {
        final raw = prefs.getString('calendar_day_${g.name}_$dayKey');
        if (raw == null || raw.isEmpty) continue;

        try {
          final decoded = jsonDecode(raw);
          final log = DayLog.fromMap(Map<String, dynamic>.from(decoded));
          final prev = _monthCache[dayKey] ?? DayLog.empty();

          _monthCache[dayKey] = DayLog(
            goalChars: prev.goalChars + log.goalChars,
            note: prev.note,
            sessions: [...prev.sessions, ...log.sessions],
            tasks: [...prev.tasks, ...log.tasks],
            releases: [...prev.releases, ...log.releases],
          );
        } catch (_) {}
      }
    }
  }

  Future<void> _saveDayLog(DateTime day, DayLog next) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyOf(day);
    await prefs.setString(_prefsKeyForDay(key), jsonEncode(next.toMap()));

    final ymKey = _prefsMonthIndexKey(day.year, day.month);
    final existing = prefs.getString(ymKey);
    final Set<String> s = {};

    if (existing != null && existing.isNotEmpty) {
      try {
        final decoded = jsonDecode(existing);
        if (decoded is List) {
          for (final e in decoded) {
            if (e is String && e.length == 8) s.add(e);
          }
        }
      } catch (_) {}
    }

    if (next.isEffectivelyEmpty) {
      s.remove(key);
      await prefs.remove(_prefsKeyForDay(key));
    } else {
      s.add(key);
    }

    await prefs.setString(ymKey, jsonEncode(s.toList()..sort()));

    if (next.isEffectivelyEmpty) {
      _monthCache.remove(key);
    } else {
      _monthCache[key] = next;
    }
  }

  MonthStats _calcMonthStats(DateTime monthFirstDay) {
    final year = monthFirstDay.year;
    final month = monthFirstDay.month;
    int totalChars = 0;
    int writingDays = 0;
    int bestChars = 0;
    String bestDayKey = '';

    for (final entry in _monthCache.entries) {
      final key = entry.key;
      if (key.length != 8) continue;

      final y = int.tryParse(key.substring(0, 4)) ?? 0;
      final m = int.tryParse(key.substring(4, 6)) ?? 0;
      if (y != year || m != month) continue;

      final log = entry.value;
      final w = log.writtenChars;
      if (w > 0) writingDays += 1;
      totalChars += w;
      if (w > bestChars) {
        bestChars = w;
        bestDayKey = key;
      }
    }

    return MonthStats(
      totalChars: totalChars,
      writingDays: writingDays,
      bestChars: bestChars,
      bestDayKey: bestDayKey,
    );
  }

  Future<void> _setDailyGoalDialog() async {
    final c = TextEditingController(
      text: _log.goalChars <= 0 ? '' : '${_log.goalChars}',
    );

    final next = await showDialog<int>(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder: (dialogCtx) {
        const primaryBlue = Color(0xFF7594BC);
        const deepBlue = Color(0xFF1F3A56);
        const softBg = Color(0xFFF8FBFF);
        const softBorder = Color(0xFFE3EDF7);
        const mutedText = Color(0xFF6F88A3);

        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E2EF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  decoration: BoxDecoration(
                    color: softBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: softBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '일일 목표 글자수',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: deepBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatYMD(_selectedDate)} 목표를 입력해주세요.\n비워두거나 0을 입력하면 해당 날짜 목표가 해제됩니다.',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: softBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: softBorder, width: 1),
                  ),
                  child: TextField(
                    controller: c,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: '예: 1500',
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 157, 177, 198),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: deepBlue,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: mutedText,
                            side: const BorderSide(color: softBorder, width: 1),
                            backgroundColor: softBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            final v = int.tryParse(c.text.trim()) ?? 0;
                            Navigator.pop(dialogCtx, v);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '저장',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (next == null) return;

    final updated = _log.copyWith(goalChars: next <= 0 ? 0 : next);

    await _saveDayLog(_selectedDate, updated);

    if (!mounted) return;
    setState(() => _log = updated);
  }

  Widget _sectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 5),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.92),
      ),
      child: child,
    );
  }

  String _formatInt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  double _progress01(int written, int goal) {
    if (goal <= 0) return 0;
    final p = written / goal;
    if (p < 0) return 0;
    if (p > 1) return 1;
    return p;
  }

  Widget _dailyReportCard() {
    final written = _log.writtenChars;
    final goal = _log.goalChars;
    final p = _progress01(written, goal);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatYMD(_selectedDate),
            style: const TextStyle(
              fontSize: 12.5,
              color: Color.fromARGB(221, 83, 129, 159),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _pill(
                icon: Icons.edit_note,
                text: '오늘 작성 ${_formatInt(written)}자',
                fg: Colors.black87,
                bg: const Color.fromARGB(20, 52, 96, 143),
              ),
              const SizedBox(width: 8),
              const SizedBox(height: 15),

              _pill(
                icon: Icons.flag,
                text: goal > 0 ? '오늘 목표 ${_formatInt(goal)}자' : '오늘 목표 없음',
                fg: const Color.fromARGB(255, 117, 148, 188),
                bg: const Color.fromARGB(20, 117, 148, 188),
              ),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: goal > 0 ? p : 0,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            color: const Color(0xFF7594BC),
            backgroundColor: const Color.fromARGB(255, 237, 245, 253),
          ),
          const SizedBox(height: 15),
          Text(
            goal > 0
                ? '진행률 ${(p * 100).toStringAsFixed(0)}% · 남은 ${_formatInt((goal - written).clamp(0, 1 << 30))}자'
                : '일일 목표를 설정하면 진행률이 표시됩니다.',
            style: const TextStyle(
              fontSize: 12.5,
              color: Color.fromARGB(221, 83, 129, 159),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addTaskDialog() async {
    final c = TextEditingController();

    final next = await showDialog<String>(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder: (dialogCtx) {
        const primaryBlue = Color(0xFF7594BC);
        const deepBlue = Color(0xFF1F3A56);
        const softBg = Color(0xFFF8FBFF);
        const softBorder = Color(0xFFE3EDF7);
        const mutedText = Color(0xFF6F88A3);

        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E2EF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  decoration: BoxDecoration(
                    color: softBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: softBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '작업 추가',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: deepBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatYMD(_selectedDate)}에 할 작업을 입력해주세요.',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: softBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: softBorder, width: 1),
                  ),
                  child: TextField(
                    controller: c,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: '예: 12화 수정 / 설정 정리 / 표지 콘티',
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 157, 177, 198),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: deepBlue,
                    ),
                    onSubmitted: (value) {
                      final text = value.trim();
                      Navigator.pop(dialogCtx, text);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: mutedText,
                            side: const BorderSide(color: softBorder, width: 1),
                            backgroundColor: softBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogCtx, c.text.trim());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '추가',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (next == null || next.trim().isEmpty) return;

    final task = DayTask(text: next.trim(), done: false);
    final updated = _log.copyWith(tasks: [..._log.tasks, task]);
    await _saveDayLog(_selectedDate, updated);
    setState(() => _log = updated);
  }

  Future<void> _toggleTaskDone(int index) async {
    if (index < 0 || index >= _log.tasks.length) return;
    final tasks = [..._log.tasks];
    tasks[index] = tasks[index].copyWith(done: !tasks[index].done);
    final updated = _log.copyWith(tasks: tasks);
    await _saveDayLog(_selectedDate, updated);
    setState(() => _log = updated);
  }

  Future<void> _removeTask(int index) async {
    if (index < 0 || index >= _log.tasks.length) return;
    final tasks = [..._log.tasks]..removeAt(index);
    final updated = _log.copyWith(tasks: tasks);
    await _saveDayLog(_selectedDate, updated);
    setState(() => _log = updated);
  }

  Future<void> _addReleaseDialog() async {
    final cTitle = TextEditingController();

    final next = await showDialog<String>(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder: (dialogCtx) {
        const primaryBlue = Color(0xFF7594BC);
        const deepBlue = Color(0xFF1F3A56);
        const softBg = Color(0xFFF8FBFF);
        const softBorder = Color(0xFFE3EDF7);
        const mutedText = Color(0xFF6F88A3);

        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E2EF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  decoration: BoxDecoration(
                    color: softBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: softBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '연재 [업로드] 추가',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: deepBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatYMD(_selectedDate)} 업로드 계획 또는 완료할 회차를 입력해주세요.',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: softBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: softBorder, width: 1),
                  ),
                  child: TextField(
                    controller: cTitle,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: '예: 15화 : 맑은 날',
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 157, 177, 198),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: deepBlue,
                    ),
                    onSubmitted: (value) {
                      Navigator.pop(dialogCtx, value.trim());
                    },
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: mutedText,
                            side: const BorderSide(color: softBorder, width: 1),
                            backgroundColor: softBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogCtx, cTitle.text.trim());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '추가',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (next == null || next.trim().isEmpty) return;

    final item = ReleaseItem(title: next.trim(), status: ReleaseStatus.planned);

    final updated = _log.copyWith(releases: [..._log.releases, item]);

    await _saveDayLog(_selectedDate, updated);
    setState(() => _log = updated);
  }

  Future<void> _toggleReleaseStatus(int index) async {
    if (index < 0 || index >= _log.releases.length) return;
    final releases = [..._log.releases];
    final cur = releases[index];
    final next =
        (cur.status == ReleaseStatus.planned)
            ? ReleaseStatus.published
            : ReleaseStatus.planned;
    releases[index] = cur.copyWith(status: next);
    final updated = _log.copyWith(releases: releases);
    await _saveDayLog(_selectedDate, updated);
    setState(() => _log = updated);
  }

  Future<void> _removeRelease(int index) async {
    if (index < 0 || index >= _log.releases.length) return;
    final releases = [..._log.releases]..removeAt(index);
    final updated = _log.copyWith(releases: releases);
    await _saveDayLog(_selectedDate, updated);
    setState(() => _log = updated);
  }

  Future<void> _changeMonth(int deltaMonths) async {
    final next = DateTime(
      _monthCursor.year,
      _monthCursor.month + deltaMonths,
      1,
    );
    setState(() {
      _loading = true;
      _monthCursor = next;
    });

    await _loadMonthIntoCache(_monthCursor);

    final selKey = _keyOf(_selectedDate);
    final selY = int.tryParse(selKey.substring(0, 4)) ?? _monthCursor.year;
    final selM = int.tryParse(selKey.substring(4, 6)) ?? _monthCursor.month;

    if (selY != _monthCursor.year || selM != _monthCursor.month) {
      _selectedDate = DateTime(_monthCursor.year, _monthCursor.month, 1);
    }

    _log = _monthCache[_keyOf(_selectedDate)] ?? DayLog.empty();

    setState(() => _loading = false);
  }

  Future<void> _openDayEventsSheet(DateTime day, List<RangeEvent> hits) async {
    final d = _stripTime(day);

    await showModalBottomSheet(
      context: context,
      barrierColor: kDialogBarrierColor,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        Widget section({
          required Widget child,
          EdgeInsetsGeometry padding = const EdgeInsets.all(14),
        }) {
          return Container(
            padding: padding,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3EDF7), width: 1),
            ),
            child: child,
          );
        }

        Widget actionIcon({
          required IconData icon,
          required VoidCallback onTap,
          Color iconColor = const Color(0xFF6F88A3),
        }) {
          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE1EAF4), width: 1),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E2EF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Text(
                      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}.',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F3A56),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF7594BC),
                      ),
                      child: const Text(
                        '닫기',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: hits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final ev = hits[i];

                      return section(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            Navigator.pop(ctx);
                            await _openEditRangeEventSheet(ev);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(top: 5),
                                decoration: BoxDecoration(
                                  color: ev.color.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ev.title.isEmpty ? '제목 없음' : ev.title,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F3A56),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${ev.startIso} ~ ${ev.endIso}',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF6F88A3),
                                      ),
                                    ),
                                    if (ev.memo.trim().isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        ev.memo,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          height: 1.4,
                                          color: Color(0xFF5F7D9B),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              Column(
                                children: [
                                  actionIcon(
                                    icon: Icons.edit_outlined,
                                    onTap: () async {
                                      Navigator.pop(ctx);
                                      await _openEditRangeEventSheet(ev);
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  actionIcon(
                                    icon: Icons.close_rounded,
                                    iconColor: const Color(0xFF1F3A56),
                                    onTap: () async {
                                      final sheetNav = Navigator.of(ctx);

                                      final ok = await showDialog<bool>(
                                        context: context,
                                        barrierColor: kDialogBarrierColor,
                                        builder: (dialogCtx) {
                                          return Dialog(
                                            backgroundColor: Colors.transparent,
                                            insetPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 77,
                                                ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    18,
                                                    18,
                                                    18,
                                                    14,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFE3EDF7,
                                                  ),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 42,
                                                    height: 4,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFD6E2EF,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            999,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    '선택 날짜 기록 삭제',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(0xFF1F3A56),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  const Text(
                                                    '해당 날짜의 목표, 메모, 할 일, 연재 기록이 모두 삭제됩니다.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 13.5,
                                                      height: 1.45,
                                                      color: Color(0xFF6F88A3),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 18),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: SizedBox(
                                                          height: 44,
                                                          child: OutlinedButton(
                                                            onPressed:
                                                                () =>
                                                                    Navigator.of(
                                                                      dialogCtx,
                                                                    ).pop(
                                                                      false,
                                                                    ),
                                                            style: OutlinedButton.styleFrom(
                                                              foregroundColor:
                                                                  const Color(
                                                                    0xFF7594BC,
                                                                  ),
                                                              side: const BorderSide(
                                                                color: Color(
                                                                  0xFFE1EAF4,
                                                                ),
                                                                width: 1,
                                                              ),
                                                              backgroundColor:
                                                                  const Color(
                                                                    0xFFF8FBFF,
                                                                  ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      14,
                                                                    ),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              '취소',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: SizedBox(
                                                          height: 44,
                                                          child: ElevatedButton(
                                                            onPressed:
                                                                () =>
                                                                    Navigator.of(
                                                                      dialogCtx,
                                                                    ).pop(true),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  const Color.fromARGB(
                                                                    235,
                                                                    28,
                                                                    62,
                                                                    107,
                                                                  ),
                                                              foregroundColor:
                                                                  Colors.white,
                                                              elevation: 0,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      14,
                                                                    ),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              '삭제',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                      if (!mounted) return;

                                      if (ok == true) {
                                        setState(() {
                                          _rangeEvents.removeWhere(
                                            (x) => x.id == ev.id,
                                          );
                                        });
                                        await _saveRangeEvents();
                                        if (!mounted) return;
                                      }

                                      sheetNav.pop();
                                    },
                                  ),
                                ],
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
      },
    );
  }

  Future<void> _openEditRangeEventSheet(RangeEvent ev) async {
    final result = await _openRangeEventEditor(ev);
    if (result == null) return;

    if (result == '__delete__') {
      setState(() {
        _rangeEvents.removeWhere((x) => x.id == ev.id);
      });
      await _saveRangeEvents();
      return;
    }

    final updated = result as RangeEvent;
    setState(() {
      final idx = _rangeEvents.indexWhere((x) => x.id == ev.id);
      if (idx >= 0) _rangeEvents[idx] = updated;
    });
    await _saveRangeEvents();
  }

  @override
  Widget build(BuildContext context) {
    final monthStats = _calcMonthStats(_monthCursor);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
        title: const Text(
          'calendar',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    _card(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event,
                            size: 18,
                            color: Color.fromARGB(255, 117, 148, 188),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatYMD(_selectedDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: const Color.fromARGB(30, 160, 201, 255),
                            ),
                            child: const Text(
                              'all',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 140, 177, 226),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _sectionTitle(
                      '날짜 선택',
                      trailing: IconButton(
                        onPressed: _openAddRangeEventSheet,
                        icon: const Icon(Icons.add, color: Colors.black),
                      ),
                    ),
                    _card(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color.fromARGB(255, 119, 188, 235),
                            onPrimary: Colors.white,
                            onSurface: Colors.black87,
                          ),

                          textTheme: Theme.of(context).textTheme.copyWith(
                            labelSmall: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 150, 190, 243),
                            ),
                          ),
                        ),
                        child: CalendarDatePickerClone(
                          events: _rangeEvents,
                          displayedMonth: _monthCursor,
                          selectedDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          onMonthChanged: (m) async {
                            setState(() {
                              _loading = true;
                              _monthCursor = DateTime(m.year, m.month, 1);
                            });

                            await _loadMonthIntoCache(_monthCursor);

                            if (_selectedDate.year != _monthCursor.year ||
                                _selectedDate.month != _monthCursor.month) {
                              _selectedDate = DateTime(
                                _monthCursor.year,
                                _monthCursor.month,
                                1,
                              );
                            }

                            _log =
                                _monthCache[_keyOf(_selectedDate)] ??
                                DayLog.empty();
                            setState(() => _loading = false);
                          },
                          onDateSelected: (d) {
                            final next = _stripTime(d);
                            setState(() {
                              _selectedDate = next;
                              _log =
                                  _monthCache[_keyOf(_selectedDate)] ??
                                  DayLog.empty();
                            });
                          },
                          onEventTap: (ev) => _openEditRangeEventSheet(ev),
                          onMoreTap:
                              (day, hits) => _openDayEventsSheet(day, hits),
                        ),
                      ),
                    ),
                    _sectionTitle(
                      '월 통계 [ ${_formatYM(_monthCursor)} ]',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _changeMonth(-1),
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Color.fromARGB(255, 117, 148, 188),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _changeMonth(1),
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Color.fromARGB(255, 117, 148, 188),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statLine(
                            '총 글자수',
                            '${_formatInt(monthStats.totalChars)}자',
                          ),
                          _statLine('집필한 날', '${monthStats.writingDays}일'),
                          _statLine(
                            '최고 기록',
                            monthStats.bestChars > 0
                                ? '${_formatInt(monthStats.bestChars)}자 (${_prettyDayFromKey(monthStats.bestDayKey)})'
                                : '—',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    _sectionTitle(
                      '일일 목표/리포트',
                      trailing: TextButton.icon(
                        onPressed: _setDailyGoalDialog,
                        icon: const Icon(Icons.flag, size: 18),
                        label: const Text('일일목표'),
                      ),
                    ),
                    _dailyReportCard(),
                    const SizedBox(height: 12),

                    _sectionTitle(
                      '오늘 할 일',
                      trailing: TextButton.icon(
                        onPressed: _addTaskDialog,
                        icon: const Icon(Icons.add_task, size: 18),
                        label: const Text('추가'),
                      ),
                    ),
                    _log.tasks.isEmpty
                        ? _card(
                          child: const Text(
                            '오늘 해야 할 작업을 추가해두면, 작업 흐름이 정리됩니다.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(221, 83, 129, 159),
                            ),
                          ),
                        )
                        : _card(
                          child: Column(
                            children: [
                              for (int i = 0; i < _log.tasks.length; i++) ...[
                                _taskRow(
                                  _log.tasks[i],
                                  onToggle: () => _toggleTaskDone(i),
                                  onDelete: () => _removeTask(i),
                                ),
                                if (i != _log.tasks.length - 1)
                                  const Divider(height: 16),
                              ],
                            ],
                          ),
                        ),

                    const SizedBox(height: 12),
                    _sectionTitle(
                      '연재 [업로드]',
                      trailing: TextButton.icon(
                        onPressed: _addReleaseDialog,
                        icon: const Icon(Icons.upload, size: 18),
                        label: const Text('추가'),
                      ),
                    ),
                    _log.releases.isEmpty
                        ? _card(
                          child: const Text(
                            '업로드 계획/완료를 기록해두면, 연재 주기 관리에 도움이 됩니다.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(221, 83, 129, 159),
                            ),
                          ),
                        )
                        : _card(
                          child: Column(
                            children: [
                              for (
                                int i = 0;
                                i < _log.releases.length;
                                i++
                              ) ...[
                                _releaseRow(
                                  _log.releases[i],
                                  onToggle: () => _toggleReleaseStatus(i),
                                  onDelete: () => _removeRelease(i),
                                ),
                                if (i != _log.releases.length - 1)
                                  const Divider(height: 16),
                              ],
                            ],
                          ),
                        ),

                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          barrierColor: kDialogBarrierColor,
                          builder: (_) {
                            return Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.symmetric(
                                horizontal: 77,
                              ),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  18,
                                  18,
                                  14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE3EDF7),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD6E2EF),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      '선택 날짜 기록 삭제',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1F3A56),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      '해당 날짜의 목표, 메모, 할 일, 연재 기록이 모두 삭제됩니다.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        height: 1.45,
                                        color: Color(0xFF6F88A3),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 44,
                                            child: OutlinedButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(
                                                  0xFF7594BC,
                                                ),
                                                side: const BorderSide(
                                                  color: Color(0xFFE1EAF4),
                                                  width: 1,
                                                ),
                                                backgroundColor: const Color(
                                                  0xFFF8FBFF,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                              child: const Text(
                                                '취소',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: SizedBox(
                                            height: 44,
                                            child: ElevatedButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                      235,
                                                      28,
                                                      62,
                                                      107,
                                                    ),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                              child: const Text(
                                                '삭제',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                        if (ok != true) return;

                        final empty = DayLog.empty();
                        await _saveDayLog(_selectedDate, empty);
                        setState(() => _log = empty);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(
                          255,
                          80,
                          105,
                          139,
                        ), // 글자/아이콘
                        side: const BorderSide(
                          color: Color.fromARGB(255, 26, 68, 113), // 테두리
                          width: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text(
                        '이 날짜 기록 삭제',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _statLine(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            left,
            style: const TextStyle(
              fontSize: 13,
              color: Color.fromARGB(221, 83, 129, 159),
            ),
          ),
          const Spacer(),
          Text(
            right,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required String text,
    required Color fg,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: bg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskRow(
    DayTask t, {
    required VoidCallback onToggle,
    required VoidCallback onDelete,
  }) {
    return Row(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              t.done ? Icons.check_box : Icons.check_box_outline_blank,
              color:
                  t.done
                      ? const Color.fromARGB(255, 52, 96, 143)
                      : const Color.fromARGB(255, 117, 148, 188),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            t.text,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.2,
              decoration:
                  t.done ? TextDecoration.lineThrough : TextDecoration.none,
              color:
                  t.done
                      ? const Color.fromARGB(221, 83, 129, 159)
                      : Colors.black87,
            ),
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(
            Icons.close,
            size: 18,
            color: Color.fromARGB(255, 160, 160, 160),
          ),
        ),
      ],
    );
  }

  Widget _releaseRow(
    ReleaseItem r, {
    required VoidCallback onToggle,
    required VoidCallback onDelete,
  }) {
    final isDone = r.status == ReleaseStatus.published;
    return Row(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              isDone ? Icons.cloud_done : Icons.cloud_upload_outlined,
              color:
                  isDone
                      ? const Color.fromARGB(255, 52, 96, 143)
                      : const Color.fromARGB(255, 117, 148, 188),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            r.title,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.2,
              fontWeight: isDone ? FontWeight.w700 : FontWeight.w400,
              color:
                  isDone
                      ? const Color.fromARGB(255, 52, 96, 143)
                      : Colors.black87,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color:
                isDone
                    ? const Color.fromARGB(25, 52, 96, 143)
                    : const Color.fromARGB(20, 117, 148, 188),
          ),
          child: Text(
            isDone ? '완료' : '계획',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color:
                  isDone
                      ? const Color.fromARGB(255, 52, 96, 143)
                      : const Color.fromARGB(255, 117, 148, 188),
            ),
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(
            Icons.close,
            size: 18,
            color: Color.fromARGB(255, 221, 240, 255),
          ),
        ),
      ],
    );
  }

  String _prettyDayFromKey(String key) {
    if (key.length != 8) return '—';
    final y = key.substring(0, 4);
    final m = key.substring(4, 6);
    final d = key.substring(6, 8);
    return '$y.$m.$d.';
  }
}

class DayLog {
  final int goalChars;
  final String note;
  final List<WritingSession> sessions;
  final List<DayTask> tasks;
  final List<ReleaseItem> releases;

  const DayLog({
    required this.goalChars,
    required this.note,
    required this.sessions,
    required this.tasks,
    required this.releases,
  });

  factory DayLog.empty() => const DayLog(
    goalChars: 0,
    note: '',
    sessions: [],
    tasks: [],
    releases: [],
  );

  int get writtenChars {
    int sum = 0;
    for (final s in sessions) {
      sum += s.chars;
    }
    return sum;
  }

  bool get isEffectivelyEmpty =>
      goalChars <= 0 &&
      note.trim().isEmpty &&
      sessions.isEmpty &&
      tasks.isEmpty &&
      releases.isEmpty;

  DayLog copyWith({
    int? goalChars,
    String? note,
    List<WritingSession>? sessions,
    List<DayTask>? tasks,
    List<ReleaseItem>? releases,
  }) {
    return DayLog(
      goalChars: goalChars ?? this.goalChars,
      note: note ?? this.note,
      sessions: sessions ?? this.sessions,
      tasks: tasks ?? this.tasks,
      releases: releases ?? this.releases,
    );
  }

  Map<String, dynamic> toMap() => {
    'goalChars': goalChars,
    'note': note,
    'sessions': sessions.map((e) => e.toMap()).toList(),
    'tasks': tasks.map((e) => e.toMap()).toList(),
    'releases': releases.map((e) => e.toMap()).toList(),
  };

  factory DayLog.fromMap(Map<String, dynamic> m) {
    final goal = (m['goalChars'] as num?)?.toInt() ?? 0;
    final note = (m['note'] as String?) ?? '';

    final sessionsRaw = m['sessions'];
    final tasksRaw = m['tasks'];
    final releasesRaw = m['releases'];

    final sessions = <WritingSession>[];
    if (sessionsRaw is List) {
      for (final e in sessionsRaw) {
        if (e is Map) {
          sessions.add(WritingSession.fromMap(Map<String, dynamic>.from(e)));
        }
      }
    }

    final tasks = <DayTask>[];
    if (tasksRaw is List) {
      for (final e in tasksRaw) {
        if (e is Map) tasks.add(DayTask.fromMap(Map<String, dynamic>.from(e)));
      }
    }

    final releases = <ReleaseItem>[];
    if (releasesRaw is List) {
      for (final e in releasesRaw) {
        if (e is Map) {
          releases.add(ReleaseItem.fromMap(Map<String, dynamic>.from(e)));
        }
      }
    }

    return DayLog(
      goalChars: goal,
      note: note,
      sessions: sessions,
      tasks: tasks,
      releases: releases,
    );
  }
}

class WritingSession {
  final String atIso;
  final int chars;
  final String memo;

  const WritingSession({
    required this.atIso,
    required this.chars,
    required this.memo,
  });

  Map<String, dynamic> toMap() => {
    'atIso': atIso,
    'chars': chars,
    'memo': memo,
  };

  factory WritingSession.fromMap(Map<String, dynamic> m) {
    return WritingSession(
      atIso: (m['atIso'] as String?) ?? DateTime.now().toIso8601String(),
      chars: (m['chars'] as num?)?.toInt() ?? 0,
      memo: (m['memo'] as String?) ?? '',
    );
  }
}

class DayTask {
  final String text;
  final bool done;

  const DayTask({required this.text, required this.done});

  DayTask copyWith({String? text, bool? done}) =>
      DayTask(text: text ?? this.text, done: done ?? this.done);

  Map<String, dynamic> toMap() => {'text': text, 'done': done};

  factory DayTask.fromMap(Map<String, dynamic> m) {
    return DayTask(
      text: (m['text'] as String?) ?? '',
      done: (m['done'] as bool?) ?? false,
    );
  }
}

enum ReleaseStatus { planned, published }

class ReleaseItem {
  final String title;
  final ReleaseStatus status;

  const ReleaseItem({required this.title, required this.status});

  ReleaseItem copyWith({String? title, ReleaseStatus? status}) =>
      ReleaseItem(title: title ?? this.title, status: status ?? this.status);

  Map<String, dynamic> toMap() => {'title': title, 'status': status.name};

  factory ReleaseItem.fromMap(Map<String, dynamic> m) {
    final s = (m['status'] as String?) ?? ReleaseStatus.planned.name;
    final status = ReleaseStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => ReleaseStatus.planned,
    );
    return ReleaseItem(title: (m['title'] as String?) ?? '', status: status);
  }
}

class MonthStats {
  final int totalChars;
  final int writingDays;
  final int bestChars;
  final String bestDayKey;

  const MonthStats({
    required this.totalChars,
    required this.writingDays,
    required this.bestChars,
    required this.bestDayKey,
  });
}

class _RangeBarsOverlay extends StatelessWidget {
  const _RangeBarsOverlay({
    required this.cells,
    required this.events,
    required this.laneByEventId,
    required this.cellSize,
    required this.gapX,
    required this.gapY,
    required this.onEventTap,
    required this.onMoreTap,
  });

  final List<DateTime?> cells;
  final List<RangeEvent> events;
  final Map<String, int> laneByEventId;
  final double gapX;
  final double gapY;
  final double cellSize;
  final void Function(RangeEvent ev) onEventTap;
  final void Function(DateTime day, List<RangeEvent> hits) onMoreTap;

  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  int _indexOf(DateTime d) {
    final target = _day(d);
    for (int i = 0; i < cells.length; i++) {
      final c = cells[i];
      if (c == null) continue;
      final cc = _day(c);
      if (cc.year == target.year &&
          cc.month == target.month &&
          cc.day == target.day) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    const int maxShownLanes = 2;
    const double barH = 14;
    const double barRadius = 999;
    const double barsTopOffset = 24;
    const double laneVGap = 3;

    final first = cells.firstWhere((x) => x != null, orElse: () => null);
    final last = cells.lastWhere((x) => x != null, orElse: () => null);
    if (first == null || last == null) return const SizedBox.shrink();

    final gridStart = _day(first);
    final gridEnd = _day(last);

    final Map<String, int> hiddenCountByCell = {};
    final Map<String, List<RangeEvent>> hiddenHitsByCell = {};

    for (final ev in events) {
      final lane = laneByEventId[ev.id] ?? 0;
      if (lane < maxShownLanes) continue;

      final s = _day(ev.start);
      final e = _day(ev.end);

      final clampedStart = s.isBefore(gridStart) ? gridStart : s;
      final clampedEnd = e.isAfter(gridEnd) ? gridEnd : e;

      final si = _indexOf(clampedStart);
      final ei = _indexOf(clampedEnd);
      if (si < 0 || ei < 0 || ei < si) continue;

      for (int idx = si; idx <= ei; idx++) {
        final row = idx ~/ 7;
        final col = idx % 7;
        final key = '$row-$col';
        hiddenCountByCell[key] = (hiddenCountByCell[key] ?? 0) + 1;
        (hiddenHitsByCell[key] ??= []).add(ev);
      }
    }

    final barWidgets = <Widget>[];

    for (final ev in events) {
      final lane = laneByEventId[ev.id] ?? 0;
      if (lane >= maxShownLanes) continue;

      final s = _day(ev.start);
      final e = _day(ev.end);

      final clampedStart = s.isBefore(gridStart) ? gridStart : s;
      final clampedEnd = e.isAfter(gridEnd) ? gridEnd : e;

      int si = _indexOf(clampedStart);
      int ei = _indexOf(clampedEnd);
      if (si < 0 || ei < 0 || ei < si) continue;

      int cur = si;
      while (cur <= ei) {
        final row = cur ~/ 7;
        final rowEnd = row * 7 + 6;

        final segStart = cur;
        final segEnd = (ei < rowEnd) ? ei : rowEnd;

        final startCol = segStart % 7;
        final endCol = segEnd % 7;
        final left = startCol * (cellSize + gapX);

        final width =
            (endCol - startCol + 1) * cellSize + (endCol - startCol) * gapX;

        final top =
            row * (cellSize + gapY) + barsTopOffset + lane * (barH + laneVGap);

        final realStartVisible = !_day(ev.start).isBefore(gridStart);
        final realEndVisible = !_day(ev.end).isAfter(gridEnd);

        final isFirstSeg = (segStart == si);
        final isLastSeg = (segEnd == ei);

        final capLeft = isFirstSeg && realStartVisible;
        final capRight = isLastSeg && realEndVisible;
        const r = Radius.circular(barRadius);

        barWidgets.add(
          Positioned(
            left: left,
            top: top,
            width: width,
            height: barH,
            child: InkWell(
              borderRadius: BorderRadius.only(
                topLeft: capLeft ? r : Radius.zero,
                bottomLeft: capLeft ? r : Radius.zero,
                topRight: capRight ? r : Radius.zero,
                bottomRight: capRight ? r : Radius.zero,
              ),
              onTap: () => onEventTap(ev),
              child: Container(
                decoration: BoxDecoration(
                  color: ev.color.withValues(alpha: 0.40),
                  borderRadius: BorderRadius.only(
                    topLeft: capLeft ? r : Radius.zero,
                    bottomLeft: capLeft ? r : Radius.zero,
                    topRight: capRight ? r : Radius.zero,
                    bottomRight: capRight ? r : Radius.zero,
                  ),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child:
                    (segStart == si)
                        ? Text(
                          ev.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 14, 40, 55),
                            height: 1.0,
                          ),
                        )
                        : null,
              ),
            ),
          ),
        );

        cur = rowEnd + 1;
      }
    }

    for (int idx = 0; idx < 42; idx++) {
      final d0 = cells[idx];
      if (d0 == null) continue;

      final row = idx ~/ 7;
      final col = idx % 7;
      final key = '$row-$col';

      final hiddenN = hiddenCountByCell[key] ?? 0;
      if (hiddenN <= 0) continue;

      final top =
          row * (cellSize + gapY) +
          barsTopOffset +
          maxShownLanes * (barH + laneVGap) -
          2;

      final left = col * (cellSize + gapX);

      final hits = hiddenHitsByCell[key] ?? const <RangeEvent>[];
      final day = _day(d0);

      barWidgets.add(
        Positioned(
          left: left,
          top: top,
          width: cellSize,
          height: 10,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onMoreTap(day, hits),
            child: Center(
              child: Text(
                '+$hiddenN',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(251, 89, 112, 122),
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Stack(clipBehavior: Clip.none, children: barWidgets);
  }
}

class CalendarDatePickerClone extends StatelessWidget {
  const CalendarDatePickerClone({
    super.key,
    required this.events,
    required this.displayedMonth,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onMonthChanged,
    required this.onDateSelected,
    required this.onMoreTap,
    required this.onEventTap,
  });

  final List<RangeEvent> events;
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;

  final void Function(DateTime day, List<RangeEvent> hits) onMoreTap;
  final void Function(RangeEvent event) onEventTap;

  DateTime _strip(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _inRange(DateTime d) {
    final x = _strip(d);
    return !x.isBefore(_strip(firstDate)) && !x.isAfter(_strip(lastDate));
  }

  Color _resolveColor(
    WidgetStateProperty<Color?>? prop,
    Set<WidgetState> states,
    Color fallback,
  ) {
    final c = prop?.resolve(states);
    return c ?? fallback;
  }

  TextStyle _mergeOrFallback(TextStyle? a, TextStyle b) {
    if (a == null) return b;
    return b.merge(a);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dp = theme.datePickerTheme;
    final loc = MaterialLocalizations.of(context);

    final month = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final monthTitle = loc.formatMonthYear(month);
    final firstDayOfWeekIndex = loc.firstDayOfWeekIndex;
    final narrowWeekdays = loc.narrowWeekdays;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leading = DateUtils.firstDayOffset(month.year, month.month, loc);

    final cells = List<DateTime?>.generate(42, (i) {
      final dayNum = i - leading + 1;
      if (dayNum < 1 || dayNum > daysInMonth) return null;
      return DateTime(month.year, month.month, dayNum);
    });

    final fallbackWeekday =
        theme.textTheme.labelSmall ??
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
    final weekdayStyle = _mergeOrFallback(
      dp.weekdayStyle,
      fallbackWeekday,
    ).copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      height: 1.0,
      letterSpacing: 0,
    );

    final fallbackDay =
        theme.textTheme.bodyLarge ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
    final dayStyle = _mergeOrFallback(dp.dayStyle, fallbackDay);

    final fallbackHeader =
        theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
    final headerStyle = _mergeOrFallback(
      dp.headerHeadlineStyle,
      fallbackHeader,
    );

    const double cellSize = 36;
    const double gridGapX = 4;
    const double gridGapY = 8;
    const double sidePad = 10;

    Color selectedBgFallback = cs.primary.withValues(alpha: 0.12);
    Color selectedFgFallback = cs.primary;
    Color disabledFgFallback = theme.disabledColor;

    DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);

    final stableEvents = [...events]..sort((a, b) {
      final c1 = a.start.compareTo(b.start);
      if (c1 != 0) return c1;
      final c2 = b.end.compareTo(a.end);
      if (c2 != 0) return c2;
      final c3 = a.colorValue.compareTo(b.colorValue);
      if (c3 != 0) return c3;
      return a.id.compareTo(b.id);
    });

    bool intersectsGrid(RangeEvent e) {
      final first = cells.firstWhere((x) => x != null, orElse: () => null);
      final last = cells.lastWhere((x) => x != null, orElse: () => null);
      if (first == null || last == null) return true;

      final gridStart = day(first);
      final gridEnd = day(last);

      final s = day(e.start);
      final t = day(e.end);

      return !t.isBefore(gridStart) && !s.isAfter(gridEnd);
    }

    final visibleEvents = stableEvents.where(intersectsGrid).toList();
    int indexOf(DateTime d) {
      final target = DateTime(d.year, d.month, d.day);
      for (int i = 0; i < cells.length; i++) {
        final c = cells[i];
        if (c == null) continue;
        final cc = DateTime(c.year, c.month, c.day);
        if (cc == target) return i;
      }
      return -1;
    }

    final gridFirst = cells.firstWhere((x) => x != null, orElse: () => null);
    final gridLast = cells.lastWhere((x) => x != null, orElse: () => null);

    final laneByEventId = <String, int>{};

    if (gridFirst != null && gridLast != null) {
      final gridStart = DateTime(
        gridFirst.year,
        gridFirst.month,
        gridFirst.day,
      );
      final gridEnd = DateTime(gridLast.year, gridLast.month, gridLast.day);

      for (int row = 0; row < 6; row++) {
        final rowStart = row * 7;
        final rowEnd = rowStart + 6;
        final laneEnds = <int>[];
        final rowEvents =
            visibleEvents.where((ev) {
                final s = DateTime(ev.start.year, ev.start.month, ev.start.day);
                final e = DateTime(ev.end.year, ev.end.month, ev.end.day);
                final cs = s.isBefore(gridStart) ? gridStart : s;
                final ce = e.isAfter(gridEnd) ? gridEnd : e;

                final si = indexOf(cs);
                final ei = indexOf(ce);
                if (si < 0 || ei < 0) return false;
                return !(ei < rowStart || si > rowEnd);
              }).toList()
              ..sort((a, b) {
                final sa = indexOf(
                  DateTime(a.start.year, a.start.month, a.start.day),
                );
                final sb = indexOf(
                  DateTime(b.start.year, b.start.month, b.start.day),
                );
                return sa.compareTo(sb);
              });

        for (final ev in rowEvents) {
          final s = DateTime(ev.start.year, ev.start.month, ev.start.day);
          final e = DateTime(ev.end.year, ev.end.month, ev.end.day);
          final cs = s.isBefore(gridStart) ? gridStart : s;
          final ce = e.isAfter(gridEnd) ? gridEnd : e;

          final si = indexOf(cs);
          final ei = indexOf(ce);

          final segStart = si.clamp(rowStart, rowEnd);
          final segEnd = ei.clamp(rowStart, rowEnd);
          final already = laneByEventId[ev.id];
          if (already != null) {
            while (laneEnds.length <= already) {
              laneEnds.add(rowStart - 1);
            }
            laneEnds[already] =
                laneEnds[already] < segEnd ? segEnd : laneEnds[already];
            continue;
          }

          int lane = 0;
          while (true) {
            if (lane >= laneEnds.length) {
              laneEnds.add(segEnd);
              break;
            }
            if (laneEnds[lane] < segStart) {
              laneEnds[lane] = segEnd;
              break;
            }
            lane++;
          }
          laneByEventId[ev.id] = lane;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 21, right: 10, top: 0),
          child: Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final picked = await _pickMonthYearBottomSheet(
                    context,
                    month,
                  );
                  if (picked != null) {
                    onMonthChanged(DateTime(picked.year, picked.month, 1));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(monthTitle, style: headerStyle),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: headerStyle.color ?? theme.iconTheme.color,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed:
                    () => onMonthChanged(
                      DateTime(month.year, month.month - 1, 1),
                    ),
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed:
                    () => onMonthChanged(
                      DateTime(month.year, month.month + 1, 1),
                    ),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: sidePad),
          child: Row(
            children: [
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Builder(
                      builder: (_) {
                        final idx = (firstDayOfWeekIndex + i) % 7;
                        final label = narrowWeekdays[idx];
                        final isSunday = idx == (DateTime.sunday % 7);

                        final color =
                            isSunday
                                ? const Color.fromARGB(255, 255, 115, 0)
                                : const Color.fromARGB(255, 110, 195, 255);

                        return Text(
                          label,
                          style: weekdayStyle.copyWith(color: color),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: sidePad),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              const gapX = gridGapX;
              const gapY = gridGapY;
              final cellW = (constraints.maxWidth - gapX * 6) / 7;
              final gridH = (cellW * 6) + (gapY * 5);

              return SizedBox(
                height: gridH,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GridView.builder(
                      clipBehavior: Clip.none,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 42,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: gridGapY,
                            crossAxisSpacing: gridGapX,
                          ),
                      itemBuilder: (context, index) {
                        final d0 = cells[index];
                        if (d0 == null) return const SizedBox.shrink();
                        final d = day(d0);

                        final enabled = _inRange(d);
                        final isSelected = _sameDay(d, selectedDate);
                        final isToday = _sameDay(d, DateTime.now());

                        final states = <WidgetState>{
                          if (!enabled) WidgetState.disabled,
                          if (isSelected) WidgetState.selected,
                        };

                        final bg =
                            isSelected
                                ? _resolveColor(
                                  dp.dayBackgroundColor,
                                  states,
                                  selectedBgFallback,
                                )
                                : Colors.transparent;

                        Color fg;
                        if (!enabled) {
                          fg = _resolveColor(
                            dp.dayForegroundColor,
                            states,
                            disabledFgFallback,
                          );
                        } else if (isSelected) {
                          fg = _resolveColor(
                            dp.dayForegroundColor,
                            states,
                            selectedFgFallback,
                          );
                        } else if (isToday) {
                          fg = const Color.fromARGB(255, 92, 182, 255);
                        } else {
                          fg = _resolveColor(
                            dp.dayForegroundColor,
                            states,
                            dayStyle.color ?? cs.onSurface,
                          );
                        }

                        final baseWeight =
                            dayStyle.fontWeight ?? FontWeight.w400;
                        final ts = dayStyle.copyWith(
                          color: fg,
                          fontWeight:
                              (isToday && !isSelected)
                                  ? FontWeight.w500
                                  : baseWeight,
                        );

                        return Center(
                          child: SizedBox(
                            width: cellSize,
                            height: cellSize,
                            child: Material(
                              color: Colors.transparent,
                              child: InkResponse(
                                onTap:
                                    enabled
                                        ? () => onDateSelected(_strip(d))
                                        : null,
                                highlightShape: BoxShape.circle,
                                containedInkWell: true,
                                radius: cellSize / 2,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: bg,
                                  ),
                                  child: Center(
                                    child: Text('${d.day}', style: ts),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned.fill(
                      child: _RangeBarsOverlay(
                        cells: cells,
                        events: visibleEvents,
                        laneByEventId: laneByEventId,
                        cellSize: cellW,
                        gapX: gapX,
                        gapY: gapY,
                        onEventTap: onEventTap,
                        onMoreTap: onMoreTap,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<DateTime?> _pickMonthYearBottomSheet(
    BuildContext context,
    DateTime current,
  ) async {
    final loc = MaterialLocalizations.of(context);
    int y = current.year;
    int m = current.month;

    return showModalBottomSheet<DateTime>(
      context: context,
      barrierColor: kDialogBarrierColor,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setSB) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Select month',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx2),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => setSB(() => y -= 1),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        '$y',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setSB(() => y += 1),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (int i = 1; i <= 12; i++)
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => setSB(() => m = i),
                          child: Container(
                            width: 72,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color:
                                  (m == i)
                                      ? Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.12)
                                      : const Color(0xFFF0F5FA),
                            ),
                            child: Center(
                              child: Text(
                                loc
                                    .formatMonthYear(DateTime(2000, i, 1))
                                    .split(' ')
                                    .first
                                    .substring(0, 3),
                                style: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      (m == i)
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx2, DateTime(y, m, 1)),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class RangeEvent {
  final String id;
  final String title;
  final String memo;
  final String startIso;
  final String endIso;
  final int colorValue;

  const RangeEvent({
    required this.id,
    required this.title,
    required this.memo,
    required this.startIso,
    required this.endIso,
    required this.colorValue,
  });

  DateTime get start => DateTime.parse(startIso);
  DateTime get end => DateTime.parse(endIso);
  Color get color => Color(colorValue);

  bool includes(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  bool isStartDay(DateTime day) {
    return day.year == start.year &&
        day.month == start.month &&
        day.day == start.day;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'memo': memo,
    'startIso': startIso,
    'endIso': endIso,
    'colorValue': colorValue,
  };

  factory RangeEvent.fromMap(Map<String, dynamic> m) {
    return RangeEvent(
      id:
          (m['id'] as String?) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: (m['title'] as String?) ?? '',
      memo: (m['memo'] as String?) ?? '',
      startIso:
          (m['startIso'] as String?) ??
          DateTime.now().toIso8601String().substring(0, 10),
      endIso:
          (m['endIso'] as String?) ??
          DateTime.now().toIso8601String().substring(0, 10),
      colorValue: (m['colorValue'] as num?)?.toInt() ?? Colors.blue.toARGB32(),
    );
  }
}
