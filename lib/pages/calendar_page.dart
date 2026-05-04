// calendar_page.dart

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Color kDialogBarrierColor = const Color(
  0xFF0F2238,
).withValues(alpha: 0.13);

const kRepeatOnColor = Color(0xFFFF75A3);
const kRepeatOffColor = Color(0xFF34608F);

final WidgetStateProperty<Color?> kTransparentOverlay = WidgetStateProperty.all(
  Colors.transparent,
);

final ButtonStyle kNoShadowIconButtonStyle = ButtonStyle(
  overlayColor: kTransparentOverlay,
  splashFactory: NoSplash.splashFactory,
  shadowColor: kTransparentOverlay,
  surfaceTintColor: kTransparentOverlay,
  elevation: WidgetStateProperty.all(0),
);

class CalendarPage extends StatefulWidget {
  final DateTime? initialDate;

  const CalendarPage({super.key, this.initialDate});

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

  final List<RecurringDailyTask> _dailyRepeatSeeds = [];
  final Set<String> _editingTaskIds = {};
  final Map<String, TextEditingController> _taskEditControllers = {};
  final Map<String, FocusNode> _taskEditFocusNodes = {};

  final List<RecurringReleaseSeed> _releaseRepeatSeeds = [];
  final Set<String> _editingReleaseIds = {};
  final Map<String, TextEditingController> _releaseEditControllers = {};
  final Map<String, FocusNode> _releaseEditFocusNodes = {};

  String _prefsReleaseRepeatKey() => 'calendar_release_repeat_common';

  String _prefsDailyRepeatKey() => 'calendar_daily_repeat_common';

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _prefsRangeEventsKey() => 'calendar_range_events_common';

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    for (final c in _taskEditControllers.values) {
      c.dispose();
    }
    for (final f in _taskEditFocusNodes.values) {
      f.dispose();
    }
    for (final c in _releaseEditControllers.values) {
      c.dispose();
    }
    for (final f in _releaseEditFocusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bootstrap();
    }
  }

  DateTime? _dateFromKey(String key) {
    if (key.length != 8) return null;

    final y = int.tryParse(key.substring(0, 4));
    final m = int.tryParse(key.substring(4, 6));
    final d = int.tryParse(key.substring(6, 8));

    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  Future<void> _disableRepeatEverywhereExceptSelected({
    required String seedId,
    required String keepDayKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final dayKeys =
        prefs
            .getKeys()
            .where((k) => k.startsWith('calendar_day_'))
            .map((k) => k.substring('calendar_day_'.length))
            .where((k) => k.length == 8)
            .toList();

    for (final dayKey in dayKeys) {
      if (dayKey == keepDayKey) continue;

      final raw = prefs.getString(_prefsKeyForDay(dayKey));
      if (raw == null || raw.isEmpty) continue;

      try {
        final decoded = jsonDecode(raw);
        final log = DayLog.fromMap(Map<String, dynamic>.from(decoded));

        bool changed = false;
        final nextTasks = <DayTask>[];

        for (final task in log.tasks) {
          if (task.repeatSourceId == seedId) {
            changed = true;
            continue;
          }
          if (task.id == seedId && task.repeatEveryDays != null) {
            nextTasks.add(
              task.copyWith(
                generatedRepeat: false,
                clearRepeatSourceId: true,
                clearRepeatEveryDays: true,
              ),
            );
            changed = true;
            continue;
          }

          nextTasks.add(task);
        }

        final nextSkips =
            log.skippedRepeatIds.where((id) => id != seedId).toList();

        if (nextSkips.length != log.skippedRepeatIds.length) {
          changed = true;
        }

        if (!changed) continue;

        final date = _dateFromKey(dayKey);
        if (date == null) continue;

        await _saveDayLog(
          date,
          log.copyWith(tasks: nextTasks, skippedRepeatIds: nextSkips),
        );
      } catch (_) {}
    }
  }

  Future<void> _disableReleaseRepeatEverywhereExceptSelected({
    required String seedId,
    required String keepDayKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final dayKeys =
        prefs
            .getKeys()
            .where((k) => k.startsWith('calendar_day_'))
            .map((k) => k.substring('calendar_day_'.length))
            .where((k) => k.length == 8)
            .toList();

    for (final dayKey in dayKeys) {
      if (dayKey == keepDayKey) continue;

      final raw = prefs.getString(_prefsKeyForDay(dayKey));
      if (raw == null || raw.isEmpty) continue;

      try {
        final decoded = jsonDecode(raw);
        final log = DayLog.fromMap(Map<String, dynamic>.from(decoded));

        bool changed = false;
        final nextReleases = <ReleaseItem>[];

        for (final item in log.releases) {
          if (item.repeatSourceId == seedId) {
            changed = true;
            continue;
          }

          if (item.id == seedId && item.repeatEveryDays != null) {
            nextReleases.add(
              item.copyWith(
                generatedRepeat: false,
                clearRepeatSourceId: true,
                clearRepeatEveryDays: true,
              ),
            );
            changed = true;
            continue;
          }

          nextReleases.add(item);
        }

        final nextSkipped =
            log.skippedReleaseRepeatIds.where((id) => id != seedId).toList();

        if (nextSkipped.length != log.skippedReleaseRepeatIds.length) {
          changed = true;
        }

        if (!changed) continue;

        final date = _dateFromKey(dayKey);
        if (date == null) continue;

        await _saveDayLog(
          date,
          log.copyWith(
            releases: nextReleases,
            skippedReleaseRepeatIds: nextSkipped,
          ),
        );
      } catch (_) {}
    }
  }

  Future<Object?> _openRangeEventEditor(RangeEvent ev) async {
    final titleC = TextEditingController(text: ev.title);
    final memoC = TextEditingController(text: ev.memo);

    DateTime start = DateTime.parse(ev.startIso);
    DateTime end = DateTime.parse(ev.endIso);

    final palette = <Color>[
      const Color.fromARGB(255, 255, 183, 197),
      const Color.fromARGB(255, 255, 210, 163),
      const Color.fromARGB(255, 255, 236, 179),
      const Color.fromARGB(255, 219, 245, 196),
      const Color.fromARGB(255, 175, 234, 255),
      const Color.fromARGB(255, 201, 223, 255),
      const Color.fromARGB(255, 221, 209, 255),
      const Color.fromARGB(255, 205, 240, 228),
      const Color.fromARGB(255, 196, 206, 223),
    ];

    Color picked = Color(ev.colorValue);

    if (!palette.any((c) => c.toARGB32() == picked.toARGB32())) {
      palette.insert(0, picked);
    }

    final edited = await showDialog<Object?>(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder: (ctx) {
        String fmt(DateTime d) =>
            '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}.';

        InputDecoration inputDeco(String hint) {
          return InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color.fromARGB(255, 157, 177, 198),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE1EAF4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE1EAF4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 117, 148, 188),
              ),
            ),
          );
        }

        Widget dateField({
          required String label,
          required String value,
          required VoidCallback onTap,
        }) {
          return Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              overlayColor: kTransparentOverlay,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE1EAF4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5F7D9B),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F3A56),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return StatefulBuilder(
          builder: (ctx2, setSB) {
            final bottom = MediaQuery.of(ctx2).viewInsets.bottom;

            return Dialog(
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 120),
                padding: EdgeInsets.only(bottom: bottom),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 520,
                    maxHeight: 720,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Center(
                                child: Text(
                                  '일정 편집',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1F3A56),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  onPressed: () => Navigator.pop(ctx2),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  icon: const Icon(Icons.close),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: titleC,
                          decoration: inputDeco('제목 입력'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F3A56),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            dateField(
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

                                  if (end.isBefore(start)) {
                                    end = start;
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            dateField(
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

                                  if (end.isBefore(start)) {
                                    end = start;
                                  }
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          '색상',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5F7D9B),
                          ),
                        ),

                        const SizedBox(height: 10),

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
                                  width: 30,
                                  height: 30,
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
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          controller: memoC,
                          maxLines: 3,
                          decoration: inputDeco('메모 입력'),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Color.fromARGB(255, 39, 50, 60),
                          ),
                        ),

                        const SizedBox(height: 18),

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
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              overlayColor: Colors.transparent,
                              splashFactory: NoSplash.splashFactory,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(
                                ctx2,
                                RangeEvent(
                                  id: ev.id,
                                  title: titleC.text.trim(),
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
                              final ok = await _showRangeEventDeleteDialog(ev);
                              if (!ctx2.mounted) return;

                              if (ok) {
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

  Future<bool> _showRangeEventDeleteDialog(RangeEvent ev) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder: (dialogCtx) {
        return Dialog(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            '일정 삭제',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F3A56),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            onPressed: () => Navigator.pop(dialogCtx, false),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF1F3A56),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    '“${ev.title.isEmpty ? '제목 없음' : ev.title}” 일정을 삭제하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF6F88A3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogCtx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(235, 28, 62, 107),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        overlayColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '삭제',
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
          ),
        );
      },
    );

    return ok == true;
  }

  Future<void> _saveRangeEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _rangeEvents.map((e) => e.toMap()).toList();
    await prefs.setString(_prefsRangeEventsKey(), jsonEncode(list));
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime initial) {
    DateTime picked = DateTime(initial.year, initial.month, initial.day);
    DateTime displayedMonth = DateTime(initial.year, initial.month, 1);

    return showDialog<DateTime>(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setSB) {
            return Dialog(
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 520,
                  maxHeight: 720,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Center(
                              child: Text(
                                '날짜 선택',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1F3A56),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                onPressed: () => Navigator.pop(ctx2),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(0xFF1F3A56),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      Theme(
                        data: Theme.of(ctx2).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color.fromARGB(255, 119, 188, 235),
                            onPrimary: Colors.white,
                            onSurface: Colors.black87,
                          ),
                          textTheme: Theme.of(ctx2).textTheme.copyWith(
                            labelSmall: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 150, 190, 243),
                            ),
                          ),
                        ),
                        child: CalendarDatePickerClone(
                          events: const [],
                          displayedMonth: displayedMonth,
                          selectedDate: picked,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          onMonthChanged: (m) {
                            setSB(() {
                              displayedMonth = DateTime(m.year, m.month, 1);
                            });
                          },
                          onDateSelected: (d) {
                            setSB(() {
                              picked = DateTime(d.year, d.month, d.day);
                              displayedMonth = DateTime(d.year, d.month, 1);
                            });
                          },
                          onEventTap: (_) {},
                          onMoreTap: (_, __) {},
                        ),
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              ctx2,
                              DateTime(picked.year, picked.month, picked.day),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              235,
                              28,
                              62,
                              107,
                            ),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            overlayColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '확인',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<int> _calcDailyWrittenChars(DateTime monthFirstDay) {
    final year = monthFirstDay.year;
    final month = monthFirstDay.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    final result = List<int>.filled(daysInMonth, 0);

    for (int day = 1; day <= daysInMonth; day++) {
      final key = _keyOf(DateTime(year, month, day));
      final log = _monthCache[key];
      result[day - 1] = log?.writtenChars ?? 0;
    }

    return result;
  }

  Widget _monthlyStatsGraphCard(MonthStats monthStats) {
    final values = _calcDailyWrittenChars(_monthCursor);

    final maxValue = values.fold<int>(0, (prev, v) => v > prev ? v : prev);

    final selectedIndex =
        (_selectedDate.year == _monthCursor.year &&
                _selectedDate.month == _monthCursor.month)
            ? _selectedDate.day - 1
            : -1;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  if (values.isEmpty) return;

                  final dx = details.localPosition.dx.clamp(0.0, width);
                  final ratio = width == 0 ? 0.0 : dx / width;
                  final index = ((values.length - 1) * ratio).round().clamp(
                    0,
                    values.length - 1,
                  );

                  final tapped = DateTime(
                    _monthCursor.year,
                    _monthCursor.month,
                    index + 1,
                  );

                  setState(() {
                    _selectedDate = tapped;
                    _log = _resolveDayLog(_selectedDate);
                  });
                },
                child: SizedBox(
                  height: 150,
                  child: CustomPaint(
                    painter: _MonthlyCurvePainter(
                      values: values,
                      maxValue: maxValue,
                      selectedIndex: selectedIndex,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Column(
                        children: [
                          const Spacer(),
                          Row(
                            children: [
                              for (int i = 0; i < values.length; i++)
                                if (i == 0 ||
                                    (i + 1) % 5 == 0 ||
                                    i == values.length - 1)
                                  Expanded(
                                    child: Text(
                                      '${i + 1}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color.fromARGB(
                                          221,
                                          83,
                                          129,
                                          159,
                                        ),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _statLine('집필한 날', '${monthStats.writingDays}일'),
          _statLine('오늘 작성', '${_formatInt(_log.writtenChars)}자'),
          _statLine('총 글자수', '${_formatInt(monthStats.totalChars)}자'),
          _statLine(
            '최고 기록',
            monthStats.bestChars > 0
                ? '${_formatInt(monthStats.bestChars)}자 (${_prettyDayFromKey(monthStats.bestDayKey)})'
                : '—',
          ),
        ],
      ),
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
      const Color.fromARGB(255, 255, 183, 197),
      const Color.fromARGB(255, 255, 210, 163),
      const Color.fromARGB(255, 255, 236, 179),
      const Color.fromARGB(255, 219, 245, 196),
      const Color.fromARGB(255, 175, 234, 255),
      const Color.fromARGB(255, 201, 223, 255),
      const Color.fromARGB(255, 221, 209, 255),
      const Color.fromARGB(255, 205, 240, 228),
      const Color.fromARGB(255, 196, 206, 223),
    ];

    Color picked = palette.first;

    final created = await showDialog<RangeEvent>(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder: (ctx) {
        String fmt(DateTime d) =>
            '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}.';

        InputDecoration inputDeco(String hint) {
          return InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color.fromARGB(255, 157, 177, 198),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE1EAF4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE1EAF4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 117, 148, 188),
              ),
            ),
          );
        }

        Widget dateField({
          required String label,
          required String value,
          required VoidCallback onTap,
        }) {
          return Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE1EAF4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5F7D9B),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F3A56),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return StatefulBuilder(
          builder: (ctx2, setSB) {
            final bottom = MediaQuery.of(ctx2).viewInsets.bottom;

            return Dialog(
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 120),
                padding: EdgeInsets.only(bottom: bottom),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 520,
                    maxHeight: 720,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Center(
                                child: Text(
                                  '신규 일정',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1F3A56),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  onPressed: () => Navigator.pop(ctx2),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  icon: const Icon(Icons.close),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: titleC,
                          decoration: inputDeco('제목 입력'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F3A56),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            dateField(
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
                            const SizedBox(width: 8),
                            dateField(
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
                        const SizedBox(height: 14),
                        const Text(
                          '색상',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5F7D9B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final c in palette)
                              InkWell(
                                onTap: () => setSB(() => picked = c),
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  width: 30,
                                  height: 30,
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
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: memoC,
                          maxLines: 3,
                          decoration: inputDeco('메모 입력'),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Color.fromARGB(255, 39, 50, 60),
                          ),
                        ),
                        const SizedBox(height: 18),
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
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              overlayColor: Colors.transparent,
                              splashFactory: NoSplash.splashFactory,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              final ev = RangeEvent(
                                id:
                                    DateTime.now().microsecondsSinceEpoch
                                        .toString(),
                                title: titleC.text.trim(),
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
    await _loadDailyRepeatSeeds();
    await _loadReleaseRepeatSeeds();
    _log = _resolveDayLog(_selectedDate);
    setState(() => _loading = false);
  }

  String _keyOf(DateTime d) {
    final x = _stripTime(d);
    final y = x.year.toString().padLeft(4, '0');
    final m = x.month.toString().padLeft(2, '0');
    final day = x.day.toString().padLeft(2, '0');
    return '$y$m$day';
  }

  String _prefsKeyForDay(String yyyymmdd) => 'calendar_day_$yyyymmdd';

  String _prefsMonthIndexKey(int year, int month) =>
      'calendar_month_index_${year.toString().padLeft(4, '0')}${month.toString().padLeft(2, '0')}';

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  String _formatYMD(DateTime dt) {
    final l = dt.toLocal();
    return '${l.year}.${l.month.toString().padLeft(2, '0')}.${l.day.toString().padLeft(2, '0')}.';
  }

  String _formatYM(DateTime dt) {
    final l = dt.toLocal();
    return '${l.year}.${l.month.toString().padLeft(2, '0')}';
  }

  int? _nextRepeatEveryDays(int? current) {
    if (current == null) return 1;
    if (current == 1) return 7;
    if (current == 7) return 10;
    return null;
  }

  Future<void> _toggleTaskRepeatCycle(int index) async {
    if (index < 0 || index >= _log.tasks.length) return;

    final current = _log.tasks[index];
    final base = _baseDayLog(_selectedDate);
    final tasks = [...base.tasks];
    final skips = [...base.skippedRepeatIds];

    final identity = _taskIdentity(current);
    int savedIndex = tasks.indexWhere((t) => _taskIdentity(t) == identity);

    if (savedIndex < 0) {
      tasks.add(_materializeGeneratedTask(current));
      savedIndex = tasks.length - 1;
    }

    final currentRepeatEveryDays = tasks[savedIndex].repeatEveryDays;
    final nextRepeatEveryDays = _nextRepeatEveryDays(currentRepeatEveryDays);
    final seedId = current.repeatSourceId ?? tasks[savedIndex].id;

    if (nextRepeatEveryDays != null) {
      tasks[savedIndex] = tasks[savedIndex].copyWith(
        repeatEveryDays: nextRepeatEveryDays,
        repeatSourceId: current.repeatSourceId,
        generatedRepeat: false,
      );

      skips.remove(seedId);

      final seed = RecurringDailyTask(
        id: seedId,
        text: tasks[savedIndex].text,
        startDayKey: _keyOf(_selectedDate),
        intervalDays: nextRepeatEveryDays,
      );

      final seedIndex = _dailyRepeatSeeds.indexWhere((e) => e.id == seedId);
      if (seedIndex >= 0) {
        _dailyRepeatSeeds[seedIndex] = seed;
      } else {
        _dailyRepeatSeeds.add(seed);
      }
    } else {
      tasks[savedIndex] = tasks[savedIndex].copyWith(
        generatedRepeat: false,
        clearRepeatSourceId: true,
        clearRepeatEveryDays: true,
      );

      _dailyRepeatSeeds.removeWhere((e) => e.id == seedId);
      skips.remove(seedId);

      await _disableRepeatEverywhereExceptSelected(
        seedId: seedId,
        keepDayKey: _keyOf(_selectedDate),
      );
    }

    final updated = base.copyWith(tasks: tasks, skippedRepeatIds: skips);

    await _saveDayLog(_selectedDate, updated);
    await _saveDailyRepeatSeeds();

    if (!mounted) return;
    setState(() => _log = _resolveDayLog(_selectedDate));
  }

  Future<void> _loadDailyRepeatSeeds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsDailyRepeatKey());
    _dailyRepeatSeeds.clear();

    if (raw == null || raw.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        for (final e in decoded) {
          if (e is Map) {
            _dailyRepeatSeeds.add(
              RecurringDailyTask.fromMap(Map<String, dynamic>.from(e)),
            );
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _saveDailyRepeatSeeds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _dailyRepeatSeeds.map((e) => e.toMap()).toList();
    await prefs.setString(_prefsDailyRepeatKey(), jsonEncode(list));
  }

  Future<void> _loadReleaseRepeatSeeds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsReleaseRepeatKey());
    _releaseRepeatSeeds.clear();

    if (raw == null || raw.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        for (final e in decoded) {
          if (e is Map) {
            _releaseRepeatSeeds.add(
              RecurringReleaseSeed.fromMap(Map<String, dynamic>.from(e)),
            );
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _saveReleaseRepeatSeeds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _releaseRepeatSeeds.map((e) => e.toMap()).toList();
    await prefs.setString(_prefsReleaseRepeatKey(), jsonEncode(list));
  }

  DayLog _baseDayLog(DateTime day) {
    return _monthCache[_keyOf(day)] ?? DayLog.empty();
  }

  String _taskIdentity(DayTask task) => task.repeatSourceId ?? task.id;

  DayTask _materializeGeneratedTask(DayTask task) {
    if (!task.generatedRepeat) return task;

    return task.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      generatedRepeat: false,
    );
  }

  String _releaseIdentity(ReleaseItem item) => item.repeatSourceId ?? item.id;

  ReleaseItem _materializeGeneratedRelease(ReleaseItem item) {
    if (!item.generatedRepeat) return item;

    return item.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      generatedRepeat: false,
    );
  }

  DayLog _resolveDayLog(DateTime day) {
    final base = _baseDayLog(day);
    final dayKey = _keyOf(day);

    final existingTaskIds = base.tasks.map(_taskIdentity).toSet();
    final skippedTaskIds = base.skippedRepeatIds.toSet();
    final generatedTasks = <DayTask>[];

    for (final seed in _dailyRepeatSeeds) {
      final seedStart = _dateFromKey(seed.startDayKey);
      if (seedStart == null) continue;

      final diffDays = _stripTime(day).difference(_stripTime(seedStart)).inDays;
      if (diffDays < 0) continue;
      if (diffDays % seed.intervalDays != 0) continue;
      if (skippedTaskIds.contains(seed.id)) continue;
      if (existingTaskIds.contains(seed.id)) continue;

      generatedTasks.add(
        DayTask(
          id: 'virtual_${seed.id}_$dayKey',
          text: seed.text,
          done: false,
          repeatEveryDays: seed.intervalDays,
          repeatSourceId: seed.id,
          generatedRepeat: true,
        ),
      );
    }

    final existingReleaseIds = base.releases.map(_releaseIdentity).toSet();
    final skippedReleaseIds = base.skippedReleaseRepeatIds.toSet();
    final generatedReleases = <ReleaseItem>[];

    for (final seed in _releaseRepeatSeeds) {
      final seedStart = _dateFromKey(seed.startDayKey);
      if (seedStart == null) continue;

      final diffDays = _stripTime(day).difference(_stripTime(seedStart)).inDays;
      if (diffDays < 0) continue;
      if (diffDays % seed.intervalDays != 0) continue;
      if (skippedReleaseIds.contains(seed.id)) continue;
      if (existingReleaseIds.contains(seed.id)) continue;

      generatedReleases.add(
        ReleaseItem(
          id: 'virtual_release_${seed.id}_$dayKey',
          title: seed.title,
          status: ReleaseStatus.planned,
          repeatEveryDays: seed.intervalDays,
          repeatSourceId: seed.id,
          generatedRepeat: true,
        ),
      );
    }

    return base.copyWith(
      tasks: [...base.tasks, ...generatedTasks],
      releases: [...base.releases, ...generatedReleases],
    );
  }

  Future<void> _loadMonthIntoCache(DateTime monthFirstDay) async {
    final prefs = await SharedPreferences.getInstance();
    _monthCache.clear();

    final ymKey = _prefsMonthIndexKey(monthFirstDay.year, monthFirstDay.month);
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

  Widget _sectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 5),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
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

  Future<void> _reorderTasks(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final base = _baseDayLog(_selectedDate);
    final tasks = _log.tasks.map(_materializeGeneratedTask).toList();

    final item = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, item);

    final updated = base.copyWith(
      tasks: tasks,
      skippedRepeatIds: base.skippedRepeatIds,
    );

    await _saveDayLog(_selectedDate, updated);

    if (!mounted) return;
    setState(() => _log = _resolveDayLog(_selectedDate));
  }

  TextEditingController _taskControllerFor(DayTask task) {
    return _taskEditControllers.putIfAbsent(
      task.id,
      () => TextEditingController(text: task.text),
    );
  }

  FocusNode _taskFocusNodeFor(DayTask task) {
    return _taskEditFocusNodes.putIfAbsent(task.id, () => FocusNode());
  }

  void _disposeTaskEditor(String taskId) {
    _taskEditControllers.remove(taskId)?.dispose();
    _taskEditFocusNodes.remove(taskId)?.dispose();
  }

  TextEditingController _releaseControllerFor(ReleaseItem item) {
    return _releaseEditControllers.putIfAbsent(
      item.id,
      () => TextEditingController(text: item.title),
    );
  }

  FocusNode _releaseFocusNodeFor(ReleaseItem item) {
    return _releaseEditFocusNodes.putIfAbsent(item.id, () => FocusNode());
  }

  void _disposeReleaseEditor(String releaseId) {
    _releaseEditControllers.remove(releaseId)?.dispose();
    _releaseEditFocusNodes.remove(releaseId)?.dispose();
  }

  Future<void> _addTaskInline() async {
    final task = DayTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: '',
      done: false,
    );

    final base = _baseDayLog(_selectedDate);
    final updated = base.copyWith(tasks: [...base.tasks, task]);

    await _saveDayLog(_selectedDate, updated);

    if (!mounted) return;

    setState(() {
      _log = _resolveDayLog(_selectedDate);
      _editingTaskIds.add(task.id);
      _taskControllerFor(task).text = '';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _taskFocusNodeFor(task).requestFocus();
    });
  }

  Future<void> _startEditTask(int index) async {
    if (index < 0 || index >= _log.tasks.length) return;

    final current = _log.tasks[index];
    final base = _baseDayLog(_selectedDate);
    final tasks = [...base.tasks];

    final identity = _taskIdentity(current);
    int savedIndex = tasks.indexWhere((t) => _taskIdentity(t) == identity);

    DayTask editableTask = current;

    if (savedIndex < 0) {
      editableTask = _materializeGeneratedTask(current);
      tasks.add(editableTask);

      final updated = base.copyWith(tasks: tasks);
      await _saveDayLog(_selectedDate, updated);

      if (!mounted) return;
      setState(() {
        _log = _resolveDayLog(_selectedDate);
      });
    } else {
      editableTask = tasks[savedIndex];
    }

    if (!mounted) return;

    setState(() {
      _editingTaskIds.add(editableTask.id);
      _taskControllerFor(editableTask).text = editableTask.text;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _taskFocusNodeFor(editableTask).requestFocus();
    });
  }

  Future<void> _commitTaskEdit(DayTask task, String rawText) async {
    final text = rawText.trim();

    final base = _baseDayLog(_selectedDate);
    final tasks = [...base.tasks];

    final identity = _taskIdentity(task);
    final savedIndex = tasks.indexWhere((t) => _taskIdentity(t) == identity);

    if (savedIndex < 0) {
      if (text.isEmpty) {
        setState(() {
          _editingTaskIds.remove(task.id);
        });
        _disposeTaskEditor(task.id);
        return;
      }

      tasks.add(
        _materializeGeneratedTask(
          task,
        ).copyWith(text: text, generatedRepeat: false),
      );
    } else {
      if (text.isEmpty) {
        tasks.removeAt(savedIndex);
      } else {
        tasks[savedIndex] = tasks[savedIndex].copyWith(
          text: text,
          generatedRepeat: false,
        );

        final edited = tasks[savedIndex];

        if (edited.repeatEveryDays != null && edited.repeatSourceId == null) {
          final seedIndex = _dailyRepeatSeeds.indexWhere(
            (e) => e.id == edited.id,
          );
          if (seedIndex >= 0) {
            _dailyRepeatSeeds[seedIndex] = RecurringDailyTask(
              id: edited.id,
              text: edited.text,
              startDayKey: _dailyRepeatSeeds[seedIndex].startDayKey,
              intervalDays: edited.repeatEveryDays!,
            );
            await _saveDailyRepeatSeeds();
          }
        }
      }
    }

    final updated = base.copyWith(tasks: tasks);
    await _saveDayLog(_selectedDate, updated);

    if (!mounted) return;

    setState(() {
      _editingTaskIds.remove(task.id);
      _log = _resolveDayLog(_selectedDate);
    });

    _disposeTaskEditor(task.id);
  }

  Future<void> _toggleTaskDone(int index) async {
    if (index < 0 || index >= _log.tasks.length) return;

    final current = _log.tasks[index];
    final base = _baseDayLog(_selectedDate);
    final tasks = [...base.tasks];

    final identity = _taskIdentity(current);
    int savedIndex = tasks.indexWhere((t) => _taskIdentity(t) == identity);

    if (savedIndex < 0) {
      tasks.add(_materializeGeneratedTask(current));
      savedIndex = tasks.length - 1;
    }

    tasks[savedIndex] = tasks[savedIndex].copyWith(
      done: !tasks[savedIndex].done,
      generatedRepeat: false,
    );

    final updated = base.copyWith(tasks: tasks);

    await _saveDayLog(_selectedDate, updated);

    if (!mounted) return;
    setState(() => _log = _resolveDayLog(_selectedDate));
  }

  Future<void> _removeTask(int index) async {
    if (index < 0 || index >= _log.tasks.length) return;

    final current = _log.tasks[index];
    final base = _baseDayLog(_selectedDate);
    final tasks = [...base.tasks];
    final skips = [...base.skippedRepeatIds];

    final identity = _taskIdentity(current);
    final savedIndex = tasks.indexWhere((t) => _taskIdentity(t) == identity);

    if (savedIndex >= 0) {
      tasks.removeAt(savedIndex);
    }

    if (current.repeatSourceId != null) {
      if (!skips.contains(current.repeatSourceId!)) {
        skips.add(current.repeatSourceId!);
      }
    }

    if (current.repeatEveryDays != null && current.repeatSourceId == null) {
      _dailyRepeatSeeds.removeWhere((e) => e.id == current.id);
    }

    final updated = base.copyWith(tasks: tasks, skippedRepeatIds: skips);

    await _saveDayLog(_selectedDate, updated);
    await _saveDailyRepeatSeeds();

    if (!mounted) return;
    setState(() => _log = _resolveDayLog(_selectedDate));
  }

  Future<void> _startEditRelease(int index) async {
    if (index < 0 || index >= _log.releases.length) return;

    final current = _log.releases[index];
    final base = _baseDayLog(_selectedDate);
    final releases = [...base.releases];

    final identity = _releaseIdentity(current);
    int savedIndex = releases.indexWhere(
      (r) => _releaseIdentity(r) == identity,
    );

    ReleaseItem editable = current;

    if (savedIndex < 0) {
      editable = _materializeGeneratedRelease(current);
      releases.add(editable);

      await _saveDayLog(_selectedDate, base.copyWith(releases: releases));

      if (!mounted) return;
      setState(() {
        _log = _resolveDayLog(_selectedDate);
      });
    } else {
      editable = releases[savedIndex];
    }

    if (!mounted) return;

    setState(() {
      _editingReleaseIds.add(editable.id);
      _releaseControllerFor(editable).text = editable.title;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _releaseFocusNodeFor(editable).requestFocus();
    });
  }

  Future<void> _commitReleaseEdit(ReleaseItem item, String rawText) async {
    final text = rawText.trim();

    final base = _baseDayLog(_selectedDate);
    final releases = [...base.releases];

    final identity = _releaseIdentity(item);
    final savedIndex = releases.indexWhere(
      (r) => _releaseIdentity(r) == identity,
    );

    if (savedIndex < 0) {
      if (text.isEmpty) {
        setState(() {
          _editingReleaseIds.remove(item.id);
        });
        _disposeReleaseEditor(item.id);
        return;
      }

      releases.add(
        _materializeGeneratedRelease(
          item,
        ).copyWith(title: text, generatedRepeat: false),
      );
    } else {
      if (text.isEmpty) {
        releases.removeAt(savedIndex);
      } else {
        releases[savedIndex] = releases[savedIndex].copyWith(
          title: text,
          generatedRepeat: false,
        );

        final edited = releases[savedIndex];

        if (edited.repeatEveryDays != null && edited.repeatSourceId == null) {
          final seedIndex = _releaseRepeatSeeds.indexWhere(
            (e) => e.id == edited.id,
          );
          if (seedIndex >= 0) {
            _releaseRepeatSeeds[seedIndex] = RecurringReleaseSeed(
              id: edited.id,
              title: edited.title,
              startDayKey: _releaseRepeatSeeds[seedIndex].startDayKey,
              intervalDays: edited.repeatEveryDays!,
            );
            await _saveReleaseRepeatSeeds();
          }
        }
      }
    }

    await _saveDayLog(_selectedDate, base.copyWith(releases: releases));

    if (!mounted) return;

    setState(() {
      _editingReleaseIds.remove(item.id);
      _log = _resolveDayLog(_selectedDate);
    });

    _disposeReleaseEditor(item.id);
  }

  Future<void> _toggleReleaseRepeatCycle(int index) async {
    if (index < 0 || index >= _log.releases.length) return;

    final current = _log.releases[index];
    final base = _baseDayLog(_selectedDate);
    final releases = [...base.releases];
    final skips = [...base.skippedReleaseRepeatIds];

    final identity = _releaseIdentity(current);
    int savedIndex = releases.indexWhere(
      (r) => _releaseIdentity(r) == identity,
    );

    if (savedIndex < 0) {
      releases.add(_materializeGeneratedRelease(current));
      savedIndex = releases.length - 1;
    }

    final currentRepeat = releases[savedIndex].repeatEveryDays;
    final nextRepeat = _nextRepeatEveryDays(currentRepeat);
    final seedId = current.repeatSourceId ?? releases[savedIndex].id;

    if (nextRepeat != null) {
      releases[savedIndex] = releases[savedIndex].copyWith(
        repeatEveryDays: nextRepeat,
        repeatSourceId: current.repeatSourceId,
        generatedRepeat: false,
      );

      skips.remove(seedId);

      final seed = RecurringReleaseSeed(
        id: seedId,
        title: releases[savedIndex].title,
        startDayKey: _keyOf(_selectedDate),
        intervalDays: nextRepeat,
      );

      final seedIndex = _releaseRepeatSeeds.indexWhere((e) => e.id == seedId);
      if (seedIndex >= 0) {
        _releaseRepeatSeeds[seedIndex] = seed;
      } else {
        _releaseRepeatSeeds.add(seed);
      }
    } else {
      releases[savedIndex] = releases[savedIndex].copyWith(
        generatedRepeat: false,
        clearRepeatSourceId: true,
        clearRepeatEveryDays: true,
      );

      _releaseRepeatSeeds.removeWhere((e) => e.id == seedId);
      skips.remove(seedId);

      await _disableReleaseRepeatEverywhereExceptSelected(
        seedId: seedId,
        keepDayKey: _keyOf(_selectedDate),
      );
    }

    await _saveDayLog(
      _selectedDate,
      base.copyWith(releases: releases, skippedReleaseRepeatIds: skips),
    );
    await _saveReleaseRepeatSeeds();

    if (!mounted) return;
    setState(() => _log = _resolveDayLog(_selectedDate));
  }

  Future<void> _reorderReleases(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final base = _baseDayLog(_selectedDate);
    final releases = _log.releases.map(_materializeGeneratedRelease).toList();

    final item = releases.removeAt(oldIndex);
    releases.insert(newIndex, item);

    await _saveDayLog(
      _selectedDate,
      base.copyWith(
        releases: releases,
        skippedReleaseRepeatIds: base.skippedReleaseRepeatIds,
      ),
    );

    if (!mounted) return;
    setState(() => _log = _resolveDayLog(_selectedDate));
  }

  Future<void> _removeRelease(int index) async {
    if (index < 0 || index >= _log.releases.length) return;

    final current = _log.releases[index];
    final base = _baseDayLog(_selectedDate);
    final releases = [...base.releases];
    final skips = [...base.skippedReleaseRepeatIds];

    final identity = _releaseIdentity(current);
    final savedIndex = releases.indexWhere(
      (r) => _releaseIdentity(r) == identity,
    );

    if (savedIndex >= 0) {
      releases.removeAt(savedIndex);
    }

    if (current.repeatSourceId != null) {
      if (!skips.contains(current.repeatSourceId!)) {
        skips.add(current.repeatSourceId!);
      }
    }

    if (current.repeatEveryDays != null && current.repeatSourceId == null) {
      _releaseRepeatSeeds.removeWhere((e) => e.id == current.id);
    }

    await _saveDayLog(
      _selectedDate,
      base.copyWith(releases: releases, skippedReleaseRepeatIds: skips),
    );
    await _saveReleaseRepeatSeeds();

    if (!mounted) return;
    setState(() => _log = _resolveDayLog(_selectedDate));
  }

  Future<bool> _showAllDataResetDialog() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder: (dialogCtx) {
        return Dialog(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 64,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            '전체 초기화',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F3A56),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            onPressed: () => Navigator.pop(dialogCtx, false),
                            style: kNoShadowIconButtonStyle,
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF1F3A56),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    '모든 캘린더 데이터를 삭제하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF6F88A3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    '일정 / 오늘 할 일 / 연재 / 반복 설정 / 집필 기록이 모두 삭제됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: Color(0xFF6F88A3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogCtx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(235, 28, 62, 107),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        overlayColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '전체 삭제',
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
          ),
        );
      },
    );

    return ok == true;
  }

  Future<void> _resetAllCalendarData() async {
    final ok = await _showAllDataResetDialog();
    if (!ok) return;

    final prefs = await SharedPreferences.getInstance();

    final keysToRemove =
        prefs.getKeys().where((key) {
          return key.startsWith('calendar_day_') ||
              key.startsWith('calendar_month_index_') ||
              key == _prefsRangeEventsKey() ||
              key == _prefsDailyRepeatKey() ||
              key == _prefsReleaseRepeatKey();
        }).toList();

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }

    _monthCache.clear();
    _rangeEvents.clear();
    _dailyRepeatSeeds.clear();
    _releaseRepeatSeeds.clear();
    _editingTaskIds.clear();
    _editingReleaseIds.clear();

    for (final c in _taskEditControllers.values) {
      c.dispose();
    }
    _taskEditControllers.clear();

    for (final f in _taskEditFocusNodes.values) {
      f.dispose();
    }
    _taskEditFocusNodes.clear();

    for (final c in _releaseEditControllers.values) {
      c.dispose();
    }
    _releaseEditControllers.clear();

    for (final f in _releaseEditFocusNodes.values) {
      f.dispose();
    }
    _releaseEditFocusNodes.clear();

    if (!mounted) return;

    setState(() {
      _selectedDate = _stripTime(DateTime.now());
      _monthCursor = DateTime(_selectedDate.year, _selectedDate.month, 1);
      _log = DayLog.empty();
      _loading = false;
    });
  }

  Future<bool> _showDayLogResetDialog(DateTime day) async {
    String fmt(DateTime d) =>
        '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}.';

    final ok = await showDialog<bool>(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder: (dialogCtx) {
        return Dialog(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 64,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            '기록 초기화',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F3A56),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            onPressed: () => Navigator.pop(dialogCtx, false),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF1F3A56),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    '${fmt(day)} 기록을 삭제하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF6F88A3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    '오늘 할 일 / 연재 / 집필 기록이 모두 삭제됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: Color(0xFF6F88A3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogCtx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(235, 28, 62, 107),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        overlayColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '삭제',
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
          ),
        );
      },
    );

    return ok == true;
  }

  Future<void> _addReleaseInline() async {
    final item = ReleaseItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: '',
      status: ReleaseStatus.planned,
    );

    final base = _baseDayLog(_selectedDate);
    final updated = base.copyWith(releases: [...base.releases, item]);

    await _saveDayLog(_selectedDate, updated);

    if (!mounted) return;

    setState(() {
      _log = _resolveDayLog(_selectedDate);
      _editingReleaseIds.add(item.id);
      _releaseControllerFor(item).text = '';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _releaseFocusNodeFor(item).requestFocus();
    });
  }

  Future<void> _toggleReleaseStatus(int index) async {
    if (index < 0 || index >= _log.releases.length) return;

    final current = _log.releases[index];
    final base = _baseDayLog(_selectedDate);
    final releases = [...base.releases];

    final identity = _releaseIdentity(current);
    int savedIndex = releases.indexWhere(
      (r) => _releaseIdentity(r) == identity,
    );

    if (savedIndex < 0) {
      releases.add(_materializeGeneratedRelease(current));
      savedIndex = releases.length - 1;
    }

    final cur = releases[savedIndex];
    final next =
        cur.status == ReleaseStatus.planned
            ? ReleaseStatus.published
            : ReleaseStatus.planned;

    releases[savedIndex] = cur.copyWith(status: next, generatedRepeat: false);

    await _saveDayLog(_selectedDate, base.copyWith(releases: releases));

    if (!mounted) return;
    setState(() => _log = _resolveDayLog(_selectedDate));
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

    _log = _resolveDayLog(_selectedDate);

    setState(() => _loading = false);
  }

  Future<void> _openDayEventsSheet(DateTime day, List<RangeEvent> _) async {
    final d = _stripTime(day);

    final dayEvents =
        _rangeEvents.where((ev) => ev.includes(d)).toList()..sort((a, b) {
          final c1 = a.start.compareTo(b.start);
          if (c1 != 0) return c1;

          final c2 = a.end.compareTo(b.end);
          if (c2 != 0) return c2;

          return a.id.compareTo(b.id);
        });

    String fmt(DateTime date) =>
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}.';
    await showDialog<void>(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder: (ctx) {
        Widget eventCard(RangeEvent ev) {
          return Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE1EAF4), width: 1),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F3A56),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          '${ev.startIso} ~ ${ev.endIso}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6F88A3),
                          ),
                        ),

                        if (ev.memo.trim().isNotEmpty) ...[
                          const SizedBox(height: 7),
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
                  const SizedBox(width: 8),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _openEditRangeEventSheet(ev);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 19,
                          color: Color(0xFF6F88A3),
                        ),
                      ),

                      IconButton(
                        onPressed: () async {
                          final dialogNav = Navigator.of(ctx);

                          final ok = await _showRangeEventDeleteDialog(ev);

                          if (!mounted || !dialogNav.mounted) return;
                          if (!ok) return;

                          setState(() {
                            _rangeEvents.removeWhere((x) => x.id == ev.id);
                          });

                          await _saveRangeEvents();

                          if (!mounted || !dialogNav.mounted) return;

                          dialogNav.pop();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Color(0xFF1F3A56),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return Dialog(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            fmt(d),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F3A56),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF1F3A56),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (dayEvents.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        '등록된 일정이 없습니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: Color(0xFF6F88A3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: dayEvents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          return eventCard(dayEvents[i]);
                        },
                      ),
                    ),
                ],
              ),
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

    final noShadowButtonStyle = ButtonStyle(
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(0),
    );

    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,

        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),

        dialogTheme: const DialogThemeData(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),

        iconButtonTheme: IconButtonThemeData(style: noShadowButtonStyle),

        textButtonTheme: TextButtonThemeData(style: noShadowButtonStyle),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: noShadowButtonStyle,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: noShadowButtonStyle,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),

          leading: IconButton(
            onPressed: () => Navigator.maybePop(context),
            style: kNoShadowIconButtonStyle,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
              size: 20,
            ),
          ),

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
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.event,
                                  size: 18,
                                  color: Color.fromARGB(255, 117, 148, 188),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatYMD(_selectedDate),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
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

                              _log = _resolveDayLog(_selectedDate);
                              setState(() => _loading = false);
                            },
                            onDateSelected: (d) {
                              final next = _stripTime(d);
                              setState(() {
                                _selectedDate = next;
                                _log = _resolveDayLog(_selectedDate);
                              });
                            },
                            onEventTap: (ev) => _openEditRangeEventSheet(ev),
                            onMoreTap:
                                (day, hits) => _openDayEventsSheet(day, hits),
                          ),
                        ),
                      ),

                      _sectionTitle(
                        '오늘 할 일',
                        trailing: TextButton.icon(
                          onPressed: _addTaskInline,
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            overlayColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                          ),
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
                            child: ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              buildDefaultDragHandles: true,
                              itemCount: _log.tasks.length,
                              onReorder: _reorderTasks,

                              proxyDecorator: (child, index, animation) {
                                return AnimatedBuilder(
                                  animation: animation,
                                  child: child,
                                  builder: (context, child) {
                                    final t = Curves.easeOut.transform(
                                      animation.value,
                                    );
                                    final scale = 1.0 + (0.08 * t);

                                    return Transform.scale(
                                      scale: scale,
                                      child: Material(
                                        type: MaterialType.transparency,
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        surfaceTintColor: Colors.transparent,
                                        child: child,
                                      ),
                                    );
                                  },
                                );
                              },

                              itemBuilder: (context, i) {
                                final task = _log.tasks[i];

                                return Container(
                                  key: ValueKey(task.id),
                                  margin: EdgeInsets.only(
                                    bottom: i == _log.tasks.length - 1 ? 0 : 8,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TaskSwipeRow(
                                        key: ValueKey(task.id),
                                        task: task,
                                        isEditing: _editingTaskIds.contains(
                                          task.id,
                                        ),
                                        editController: _taskControllerFor(
                                          task,
                                        ),
                                        editFocusNode: _taskFocusNodeFor(task),
                                        onStartEdit: () => _startEditTask(i),
                                        onSubmitEdit:
                                            (text) =>
                                                _commitTaskEdit(task, text),
                                        onToggleDone: () => _toggleTaskDone(i),
                                        onDelete: () => _removeTask(i),
                                        onToggleRepeatDaily:
                                            () => _toggleTaskRepeatCycle(i),
                                      ),
                                      if (i != _log.tasks.length - 1)
                                        const Divider(height: 16),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                      const SizedBox(height: 25),

                      _sectionTitle(
                        '연재 [ 업로드 ]',
                        trailing: TextButton.icon(
                          onPressed: _addReleaseInline,
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            overlayColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                          ),
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
                            child: ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              buildDefaultDragHandles: true,
                              itemCount: _log.releases.length,
                              onReorder: _reorderReleases,
                              proxyDecorator: (child, index, animation) {
                                return AnimatedBuilder(
                                  animation: animation,
                                  child: child,
                                  builder: (context, child) {
                                    final t = Curves.easeOut.transform(
                                      animation.value,
                                    );
                                    final scale = 1.0 + (0.08 * t);

                                    return Transform.scale(
                                      scale: scale,
                                      child: Material(
                                        type: MaterialType.transparency,
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        surfaceTintColor: Colors.transparent,
                                        child: child,
                                      ),
                                    );
                                  },
                                );
                              },
                              itemBuilder: (context, i) {
                                final release = _log.releases[i];

                                return Container(
                                  key: ValueKey(release.id),
                                  margin: EdgeInsets.only(
                                    bottom:
                                        i == _log.releases.length - 1 ? 0 : 8,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ReleaseSwipeRow(
                                        key: ValueKey(release.id),
                                        release: release,
                                        isEditing: _editingReleaseIds.contains(
                                          release.id,
                                        ),
                                        editController: _releaseControllerFor(
                                          release,
                                        ),
                                        editFocusNode: _releaseFocusNodeFor(
                                          release,
                                        ),
                                        onStartEdit: () => _startEditRelease(i),
                                        onSubmitEdit:
                                            (text) => _commitReleaseEdit(
                                              release,
                                              text,
                                            ),
                                        onToggleStatus:
                                            () => _toggleReleaseStatus(i),
                                        onDelete: () => _removeRelease(i),
                                        onToggleRepeat:
                                            () => _toggleReleaseRepeatCycle(i),
                                      ),
                                      if (i != _log.releases.length - 1)
                                        const Divider(height: 16),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                      const SizedBox(height: 25),
                      _sectionTitle(
                        '월 통계 [ ${_formatYM(_monthCursor)} ]',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _changeMonth(-1),
                              style: kNoShadowIconButtonStyle,
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Color.fromARGB(255, 117, 148, 188),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _changeMonth(1),
                              style: kNoShadowIconButtonStyle,
                              icon: const Icon(
                                Icons.chevron_right,
                                color: Color.fromARGB(255, 117, 148, 188),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _monthlyStatsGraphCard(monthStats),

                      const SizedBox(height: 25),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final ok = await _showDayLogResetDialog(
                            _selectedDate,
                          );
                          if (!mounted) return;

                          if (!ok) return;

                          final skippedTaskRepeatIds =
                              _log.tasks
                                  .where(
                                    (task) =>
                                        task.repeatEveryDays != null ||
                                        task.repeatSourceId != null ||
                                        task.generatedRepeat,
                                  )
                                  .map((task) => task.repeatSourceId ?? task.id)
                                  .toSet()
                                  .toList();

                          final skippedReleaseRepeatIds =
                              _log.releases
                                  .where(
                                    (item) =>
                                        item.repeatEveryDays != null ||
                                        item.repeatSourceId != null ||
                                        item.generatedRepeat,
                                  )
                                  .map((item) => item.repeatSourceId ?? item.id)
                                  .toSet()
                                  .toList();

                          final empty = DayLog.empty().copyWith(
                            skippedRepeatIds: skippedTaskRepeatIds,
                            skippedReleaseRepeatIds: skippedReleaseRepeatIds,
                          );

                          await _saveDayLog(_selectedDate, empty);

                          if (!mounted) return;
                          setState(() => _log = _resolveDayLog(_selectedDate));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(
                            255,
                            80,
                            105,
                            139,
                          ),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 26, 68, 113),
                            width: 0.5,
                          ),
                          backgroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          overlayColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text(
                          '이 날짜 기록 초기화',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 10),

                      OutlinedButton.icon(
                        onPressed: _resetAllCalendarData,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(
                            255,
                            80,
                            105,
                            139,
                          ),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 26, 68, 113),
                            width: 0.5,
                          ),
                          backgroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          overlayColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.delete_sweep_outlined),
                        label: const Text(
                          '전체 데이터 초기화',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
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
              fontSize: 13.5,
              color: Color.fromARGB(221, 64, 126, 170),
            ),
          ),
          const Spacer(),
          Text(
            right,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
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
  final List<String> skippedRepeatIds;
  final List<String> skippedReleaseRepeatIds;

  const DayLog({
    required this.goalChars,
    required this.note,
    required this.sessions,
    required this.tasks,
    required this.releases,
    required this.skippedRepeatIds,
    required this.skippedReleaseRepeatIds,
  });

  factory DayLog.empty() => const DayLog(
    goalChars: 0,
    note: '',
    sessions: [],
    tasks: [],
    releases: [],
    skippedRepeatIds: [],
    skippedReleaseRepeatIds: [],
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
      releases.isEmpty &&
      skippedRepeatIds.isEmpty &&
      skippedReleaseRepeatIds.isEmpty;

  DayLog copyWith({
    int? goalChars,
    String? note,
    List<WritingSession>? sessions,
    List<DayTask>? tasks,
    List<ReleaseItem>? releases,
    List<String>? skippedRepeatIds,
    List<String>? skippedReleaseRepeatIds,
  }) {
    return DayLog(
      goalChars: goalChars ?? this.goalChars,
      note: note ?? this.note,
      sessions: sessions ?? this.sessions,
      tasks: tasks ?? this.tasks,
      releases: releases ?? this.releases,
      skippedRepeatIds: skippedRepeatIds ?? this.skippedRepeatIds,
      skippedReleaseRepeatIds:
          skippedReleaseRepeatIds ?? this.skippedReleaseRepeatIds,
    );
  }

  Map<String, dynamic> toMap() => {
    'goalChars': goalChars,
    'note': note,
    'sessions': sessions.map((e) => e.toMap()).toList(),
    'tasks': tasks.map((e) => e.toMap()).toList(),
    'releases': releases.map((e) => e.toMap()).toList(),
    'skippedRepeatIds': skippedRepeatIds,
    'skippedReleaseRepeatIds': skippedReleaseRepeatIds,
  };

  factory DayLog.fromMap(Map<String, dynamic> m) {
    final goal = (m['goalChars'] as num?)?.toInt() ?? 0;
    final note = (m['note'] as String?) ?? '';

    final sessionsRaw = m['sessions'];
    final tasksRaw = m['tasks'];
    final releasesRaw = m['releases'];
    final skippedRaw = m['skippedRepeatIds'];
    final skippedReleaseRaw = m['skippedReleaseRepeatIds'];

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

    final skippedRepeatIds = <String>[];
    if (skippedRaw is List) {
      for (final e in skippedRaw) {
        if (e is String) skippedRepeatIds.add(e);
      }
    }

    final skippedReleaseRepeatIds = <String>[];
    if (skippedReleaseRaw is List) {
      for (final e in skippedReleaseRaw) {
        if (e is String) skippedReleaseRepeatIds.add(e);
      }
    }

    return DayLog(
      goalChars: goal,
      note: note,
      sessions: sessions,
      tasks: tasks,
      releases: releases,
      skippedRepeatIds: skippedRepeatIds,
      skippedReleaseRepeatIds: skippedReleaseRepeatIds,
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

class TaskSwipeRow extends StatefulWidget {
  final DayTask task;
  final bool isEditing;
  final TextEditingController editController;
  final FocusNode editFocusNode;

  final VoidCallback onStartEdit;
  final ValueChanged<String> onSubmitEdit;

  final VoidCallback onToggleDone;
  final VoidCallback onDelete;
  final VoidCallback onToggleRepeatDaily;

  const TaskSwipeRow({
    super.key,
    required this.task,
    required this.isEditing,
    required this.editController,
    required this.editFocusNode,
    required this.onStartEdit,
    required this.onSubmitEdit,
    required this.onToggleDone,
    required this.onDelete,
    required this.onToggleRepeatDaily,
  });

  @override
  State<TaskSwipeRow> createState() => _TaskSwipeRowState();
}

class _TaskSwipeRowState extends State<TaskSwipeRow> {
  static const double _maxReveal = 58;
  double _offsetX = 0;
  bool _committing = false;

  void _submitEdit() {
    if (_committing) return;
    _committing = true;
    widget.onSubmitEdit(widget.editController.text);
  }

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.editFocusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant TaskSwipeRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEditing && !oldWidget.isEditing) {
      _committing = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.editFocusNode.requestFocus();
      });
    }

    if (!widget.isEditing && oldWidget.isEditing) {
      _committing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRepeat =
        widget.task.repeatEveryDays != null ||
        widget.task.repeatSourceId != null ||
        widget.task.generatedRepeat;

    final repeatLabel =
        widget.task.repeatEveryDays != null
            ? '${widget.task.repeatEveryDays}'
            : null;

    const repeatOnColor = kRepeatOnColor;
    const repeatOffColor = kRepeatOffColor;

    const checkDoneRepeatOnColor = Color.fromARGB(255, 255, 117, 163);
    const checkUndoneRepeatOnColor = Color.fromARGB(255, 255, 117, 163);

    const checkDoneNormalColor = Color.fromARGB(255, 52, 102, 143);
    const checkUndoneNormalColor = Color.fromARGB(255, 117, 148, 188);

    return SizedBox(
      height: 48,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: _offsetX,
                  child: Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        widget.onToggleRepeatDaily();
                      },
                      borderRadius: BorderRadius.circular(12),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        color: Colors.transparent,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.repeat_rounded,
                              size: 24,
                              color: isRepeat ? repeatOnColor : repeatOffColor,
                            ),
                            if (repeatLabel != null)
                              Positioned(
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 1.5,
                                    vertical: 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    repeatLabel,
                                    style: TextStyle(
                                      fontSize:
                                          repeatLabel.length >= 2 ? 6.8 : 7.6,
                                      fontWeight: FontWeight.w800,
                                      height: 1.0,
                                      color:
                                          isRepeat
                                              ? repeatOnColor
                                              : repeatOffColor,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (widget.isEditing) return;

                setState(() {
                  _offsetX = (_offsetX + details.delta.dx).clamp(0, _maxReveal);
                });
              },
              onHorizontalDragEnd: (_) {
                if (widget.isEditing) return;

                setState(() {
                  _offsetX = _offsetX > 20 ? _maxReveal : 0;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(_offsetX, 0, 0),
                child: Material(
                  color: Colors.white,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: widget.onToggleDone,
                        borderRadius: BorderRadius.circular(6),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            widget.task.done
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color:
                                isRepeat
                                    ? (widget.task.done
                                        ? checkDoneRepeatOnColor
                                        : checkUndoneRepeatOnColor)
                                    : (widget.task.done
                                        ? checkDoneNormalColor
                                        : checkUndoneNormalColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      Expanded(
                        child:
                            widget.isEditing
                                ? TextField(
                                  controller: widget.editController,
                                  focusNode: widget.editFocusNode,
                                  textInputAction: TextInputAction.done,
                                  decoration: const InputDecoration(
                                    hintText: '할 일을 입력하세요',
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(255, 157, 177, 198),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1.2,
                                    color: Colors.black87,
                                  ),
                                  onSubmitted: (_) => _submitEdit(),
                                  onTapOutside: (_) => _submitEdit(),
                                )
                                : InkWell(
                                  onTap: widget.onStartEdit,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      widget.task.text,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        height: 1.2,
                                        decoration:
                                            widget.task.done
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                        color:
                                            widget.task.done
                                                ? const Color.fromARGB(
                                                  221,
                                                  83,
                                                  129,
                                                  159,
                                                )
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                      ),

                      IconButton(
                        onPressed: widget.onDelete,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        style: IconButton.styleFrom(
                          overlayColor: Colors.transparent,
                        ),
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Color.fromARGB(255, 160, 160, 160),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DayTask {
  final String id;
  final String text;
  final bool done;
  final int? repeatEveryDays;
  final String? repeatSourceId;
  final bool generatedRepeat;

  const DayTask({
    required this.id,
    required this.text,
    required this.done,
    this.repeatEveryDays,
    this.repeatSourceId,
    this.generatedRepeat = false,
  });

  DayTask copyWith({
    String? id,
    String? text,
    bool? done,
    int? repeatEveryDays,
    String? repeatSourceId,
    bool? generatedRepeat,
    bool clearRepeatSourceId = false,
    bool clearRepeatEveryDays = false,
  }) => DayTask(
    id: id ?? this.id,
    text: text ?? this.text,
    done: done ?? this.done,
    repeatEveryDays:
        clearRepeatEveryDays ? null : (repeatEveryDays ?? this.repeatEveryDays),
    repeatSourceId:
        clearRepeatSourceId ? null : (repeatSourceId ?? this.repeatSourceId),
    generatedRepeat: generatedRepeat ?? this.generatedRepeat,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'done': done,
    'repeatEveryDays': repeatEveryDays,
    'repeatSourceId': repeatSourceId,
    'generatedRepeat': generatedRepeat,
  };

  factory DayTask.fromMap(Map<String, dynamic> m) {
    final legacyRepeatDaily = (m['repeatDaily'] as bool?) ?? false;

    return DayTask(
      id:
          (m['id'] as String?) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      text: (m['text'] as String?) ?? '',
      done: (m['done'] as bool?) ?? false,
      repeatEveryDays:
          (m['repeatEveryDays'] as num?)?.toInt() ??
          (legacyRepeatDaily ? 1 : null),
      repeatSourceId: m['repeatSourceId'] as String?,
      generatedRepeat: (m['generatedRepeat'] as bool?) ?? false,
    );
  }
}

class RecurringDailyTask {
  final String id;
  final String text;
  final String startDayKey;
  final int intervalDays;

  const RecurringDailyTask({
    required this.id,
    required this.text,
    required this.startDayKey,
    required this.intervalDays,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'startDayKey': startDayKey,
    'intervalDays': intervalDays,
  };

  factory RecurringDailyTask.fromMap(Map<String, dynamic> m) {
    final legacyRepeatDaily = (m['repeatDaily'] as bool?) ?? false;

    return RecurringDailyTask(
      id:
          (m['id'] as String?) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      text: (m['text'] as String?) ?? '',
      startDayKey: (m['startDayKey'] as String?) ?? '',
      intervalDays:
          (m['intervalDays'] as num?)?.toInt() ?? (legacyRepeatDaily ? 1 : 1),
    );
  }
}

enum ReleaseStatus { planned, published }

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

class _MonthlyCurvePainter extends CustomPainter {
  final List<int> values;
  final int maxValue;
  final int selectedIndex;

  _MonthlyCurvePainter({
    required this.values,
    required this.maxValue,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const double leftPad = 10;
    const double rightPad = 10;
    const double topPad = 10;
    const double bottomPad = 25;

    final double chartWidth = size.width - leftPad - rightPad;
    final double chartHeight = size.height - topPad - bottomPad;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    final double baseY = topPad + chartHeight;

    final guidePaint =
        Paint()
          ..color = const Color(0xFFEAF1F7)
          ..strokeWidth = 0.8;

    for (int i = 0; i < 4; i++) {
      final y = topPad + (chartHeight / 3) * i;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        guidePaint,
      );
    }

    final List<Offset> points = [];

    for (int i = 0; i < values.length; i++) {
      final x =
          values.length == 1
              ? leftPad + chartWidth / 2
              : leftPad + (chartWidth * i / (values.length - 1));

      double normalized;

      if (maxValue <= 0 || values[i] <= 0) {
        normalized = 0.0;
      } else {
        final ratio = (values[i] / maxValue).clamp(0.0, 1.0);

        normalized = math.pow(ratio, 0.45).toDouble();

        if (normalized < 0.08) {
          normalized = 0.08;
        }
      }

      final y = baseY - (normalized * (chartHeight - 10));
      points.add(Offset(x, y));
    }

    final curvePath = Path()..moveTo(points.first.dx, points.first.dy);

    if (points.length == 2) {
      curvePath.lineTo(points.last.dx, points.last.dy);
    } else {
      const smoothing = 0.18;

      double clampY(double y) => y.clamp(topPad, baseY).toDouble();

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = i == 0 ? points[i] : points[i - 1];
        final p1 = points[i];
        final p2 = points[i + 1];
        final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];

        final cp1 = Offset(
          p1.dx + (p2.dx - p0.dx) * smoothing,
          clampY(p1.dy + (p2.dy - p0.dy) * smoothing),
        );

        final cp2 = Offset(
          p2.dx - (p3.dx - p1.dx) * smoothing,
          clampY(p2.dy - (p3.dy - p1.dy) * smoothing),
        );

        curvePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
      }
    }

    final linePaint =
        Paint()
          ..color = const Color.fromARGB(255, 255, 117, 163)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(curvePath, linePaint);
    final dotPaint =
        Paint()
          ..color = const Color.fromARGB(255, 255, 117, 163)
          ..style = PaintingStyle.fill;

    final dotBorderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      if (values[i] <= 0) continue;

      final p = points[i];

      canvas.drawCircle(p, 3.6, dotBorderPaint);
      canvas.drawCircle(p, 2.4, dotPaint);
    }
    if (selectedIndex >= 0 && selectedIndex < points.length) {
      final selected = points[selectedIndex];

      final guideSelectedPaint =
          Paint()
            ..color = const Color.fromARGB(90, 52, 96, 143)
            ..strokeWidth = 0.9;

      canvas.drawLine(
        Offset(selected.dx, topPad),
        Offset(selected.dx, baseY),
        guideSelectedPaint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: values[selectedIndex] > 0 ? '${values[selectedIndex]}자' : '0자',
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF35516D),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      double labelX = selected.dx - textPainter.width / 2;
      double labelY = selected.dy - 26;

      if (labelX < leftPad) labelX = leftPad;
      if (labelX + textPainter.width > size.width - rightPad) {
        labelX = size.width - rightPad - textPainter.width;
      }
      if (labelY < 0) labelY = 0;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          labelX - 6,
          labelY - 3,
          textPainter.width + 12,
          textPainter.height + 6,
        ),
        const Radius.circular(999),
      );

      final bubblePaint =
          Paint()..color = const Color.fromARGB(255, 255, 255, 255);

      canvas.drawRRect(rrect, bubblePaint);
      textPainter.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant _MonthlyCurvePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.selectedIndex != selectedIndex;
  }
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
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              overlayColor: kTransparentOverlay,
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
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            overlayColor: kTransparentOverlay,
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
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                overlayColor: kTransparentOverlay,
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
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                  shadowColor: WidgetStateProperty.all(Colors.transparent),
                  elevation: WidgetStateProperty.all(0),
                ),
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
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                  shadowColor: WidgetStateProperty.all(Colors.transparent),
                  elevation: WidgetStateProperty.all(0),
                ),
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
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                focusColor: Colors.transparent,
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

    final noEffectIconStyle = ButtonStyle(
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(0),
    );

    return showDialog<DateTime>(
      context: context,
      barrierColor: kDialogBarrierColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setSB) {
            return Dialog(
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              backgroundColor: Theme.of(context).colorScheme.surface,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
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
                            style: kNoShadowIconButtonStyle,
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
                            style: noEffectIconStyle,
                            icon: const Icon(Icons.chevron_left),
                          ),

                          Text(
                            '$y',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),

                          IconButton(
                            onPressed: () => setSB(() => y += 1),
                            style: noEffectIconStyle,
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
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              overlayColor: kTransparentOverlay,
                              onTap: () => setSB(() => m = i),
                              child: Container(
                                width: 72,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color:
                                      (m == i)
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
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
                          onPressed:
                              () => Navigator.pop(ctx2, DateTime(y, m, 1)),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            overlayColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ),
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

class ReleaseItem {
  final String id;
  final String title;
  final ReleaseStatus status;
  final int? repeatEveryDays;
  final String? repeatSourceId;
  final bool generatedRepeat;

  const ReleaseItem({
    required this.id,
    required this.title,
    required this.status,
    this.repeatEveryDays,
    this.repeatSourceId,
    this.generatedRepeat = false,
  });

  ReleaseItem copyWith({
    String? id,
    String? title,
    ReleaseStatus? status,
    int? repeatEveryDays,
    String? repeatSourceId,
    bool? generatedRepeat,
    bool clearRepeatSourceId = false,
    bool clearRepeatEveryDays = false,
  }) => ReleaseItem(
    id: id ?? this.id,
    title: title ?? this.title,
    status: status ?? this.status,
    repeatEveryDays:
        clearRepeatEveryDays ? null : (repeatEveryDays ?? this.repeatEveryDays),
    repeatSourceId:
        clearRepeatSourceId ? null : (repeatSourceId ?? this.repeatSourceId),
    generatedRepeat: generatedRepeat ?? this.generatedRepeat,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'status': status.name,
    'repeatEveryDays': repeatEveryDays,
    'repeatSourceId': repeatSourceId,
    'generatedRepeat': generatedRepeat,
  };

  factory ReleaseItem.fromMap(Map<String, dynamic> m) {
    final s = (m['status'] as String?) ?? ReleaseStatus.planned.name;
    final status = ReleaseStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => ReleaseStatus.planned,
    );

    return ReleaseItem(
      id:
          (m['id'] as String?) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: (m['title'] as String?) ?? '',
      status: status,
      repeatEveryDays: (m['repeatEveryDays'] as num?)?.toInt(),
      repeatSourceId: m['repeatSourceId'] as String?,
      generatedRepeat: (m['generatedRepeat'] as bool?) ?? false,
    );
  }
}

class RecurringReleaseSeed {
  final String id;
  final String title;
  final String startDayKey;
  final int intervalDays;

  const RecurringReleaseSeed({
    required this.id,
    required this.title,
    required this.startDayKey,
    required this.intervalDays,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'startDayKey': startDayKey,
    'intervalDays': intervalDays,
  };

  factory RecurringReleaseSeed.fromMap(Map<String, dynamic> m) {
    return RecurringReleaseSeed(
      id:
          (m['id'] as String?) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: (m['title'] as String?) ?? '',
      startDayKey: (m['startDayKey'] as String?) ?? '',
      intervalDays: (m['intervalDays'] as num?)?.toInt() ?? 1,
    );
  }
}

class ReleaseSwipeRow extends StatefulWidget {
  final ReleaseItem release;
  final bool isEditing;
  final TextEditingController editController;
  final FocusNode editFocusNode;

  final VoidCallback onStartEdit;
  final ValueChanged<String> onSubmitEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;
  final VoidCallback onToggleRepeat;

  const ReleaseSwipeRow({
    super.key,
    required this.release,
    required this.isEditing,
    required this.editController,
    required this.editFocusNode,
    required this.onStartEdit,
    required this.onSubmitEdit,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onToggleRepeat,
  });

  @override
  State<ReleaseSwipeRow> createState() => _ReleaseSwipeRowState();
}

class _ReleaseSwipeRowState extends State<ReleaseSwipeRow> {
  static const double _maxReveal = 58;
  double _offsetX = 0;
  bool _committing = false;

  void _submitEdit() {
    if (_committing) return;
    _committing = true;
    widget.onSubmitEdit(widget.editController.text);
  }

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.editFocusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ReleaseSwipeRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEditing && !oldWidget.isEditing) {
      _committing = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.editFocusNode.requestFocus();
      });
    }

    if (!widget.isEditing && oldWidget.isEditing) {
      _committing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRepeat =
        widget.release.repeatEveryDays != null ||
        widget.release.repeatSourceId != null ||
        widget.release.generatedRepeat;

    final repeatLabel =
        widget.release.repeatEveryDays != null
            ? '${widget.release.repeatEveryDays}'
            : null;

    final isDone = widget.release.status == ReleaseStatus.published;

    const repeatOnColor = kRepeatOnColor;
    const repeatOffColor = kRepeatOffColor;

    const doneRepeatColor = Color.fromARGB(255, 255, 117, 163);
    const undoneRepeatColor = Color.fromARGB(255, 255, 117, 163);

    const doneNormalColor = Color.fromARGB(255, 52, 102, 143);
    const undoneNormalColor = Color.fromARGB(255, 117, 148, 188);

    return SizedBox(
      height: 48,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: _offsetX,
                  child: Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: widget.onToggleRepeat,
                      borderRadius: BorderRadius.circular(12),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        color: Colors.transparent,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.repeat_rounded,
                              size: 24,
                              color: isRepeat ? repeatOnColor : repeatOffColor,
                            ),
                            if (repeatLabel != null)
                              Positioned(
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 1.5,
                                    vertical: 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    repeatLabel,
                                    style: TextStyle(
                                      fontSize:
                                          repeatLabel.length >= 2 ? 6.8 : 7.6,
                                      fontWeight: FontWeight.w800,
                                      height: 1.0,
                                      color:
                                          isRepeat
                                              ? repeatOnColor
                                              : repeatOffColor,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (widget.isEditing) return;
                setState(() {
                  _offsetX = (_offsetX + details.delta.dx).clamp(0, _maxReveal);
                });
              },
              onHorizontalDragEnd: (_) {
                if (widget.isEditing) return;
                setState(() {
                  _offsetX = _offsetX > 20 ? _maxReveal : 0;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(_offsetX, 0, 0),
                child: Material(
                  color: Colors.white,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: widget.onToggleStatus,
                        borderRadius: BorderRadius.circular(6),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            isDone
                                ? Icons.cloud_done
                                : Icons.cloud_upload_outlined,
                            color:
                                isRepeat
                                    ? (isDone
                                        ? doneRepeatColor
                                        : undoneRepeatColor)
                                    : (isDone
                                        ? doneNormalColor
                                        : undoneNormalColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child:
                            widget.isEditing
                                ? TextField(
                                  controller: widget.editController,
                                  focusNode: widget.editFocusNode,
                                  textInputAction: TextInputAction.done,
                                  decoration: const InputDecoration(
                                    hintText: '업로드 제목을 입력하세요',
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(255, 157, 177, 198),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1.2,
                                    color: Colors.black87,
                                  ),
                                  onSubmitted: (_) => _submitEdit(),
                                  onTapOutside: (_) => _submitEdit(),
                                )
                                : InkWell(
                                  onTap: widget.onStartEdit,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      widget.release.title,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        height: 1.2,
                                        fontWeight:
                                            isDone
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                        color:
                                            isDone
                                                ? const Color.fromARGB(
                                                  255,
                                                  52,
                                                  96,
                                                  143,
                                                )
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
                            fontWeight: FontWeight.w500,
                            color:
                                isDone
                                    ? const Color.fromARGB(255, 52, 96, 143)
                                    : const Color.fromARGB(255, 102, 168, 254),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onDelete,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        style: IconButton.styleFrom(
                          overlayColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                        ),
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Color.fromARGB(255, 160, 160, 160),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
