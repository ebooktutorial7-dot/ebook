// character.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

enum KeywordInputMode { hashtag, phrase }

enum CharacterKind { protagonist, supporting }

extension CharacterKindX on CharacterKind {
  String get key => switch (this) {
    CharacterKind.protagonist => 'protagonist',
    CharacterKind.supporting => 'supporting',
  };

  static CharacterKind fromKey(String? v) {
    if (v == 'supporting') return CharacterKind.supporting;
    return CharacterKind.protagonist;
  }
}

class _ColorSheetResult {
  final int kind;
  final Color? color;

  const _ColorSheetResult._(this.kind, this.color);

  const _ColorSheetResult.cancel() : this._(0, null);
  const _ColorSheetResult.clear() : this._(1, null);
  const _ColorSheetResult.apply(Color c) : this._(2, c);
}

Future<_ColorSheetResult> _showPrettyWheelBottomSheet(
  BuildContext context, {
  required String title,
  required GlassTheme theme,
  required Color initial,
  double wheelSize = 190,
  bool forBackground = false,
}) async {
  Color current = initial;

  return showModalBottomSheet<_ColorSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder: (ctx) {
      final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
      final sheetBorder = Colors.white.withValues(alpha: theme.borderOpacity);

      Widget handle() => Center(
        child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      );

      Widget inputCard(StateSetter setState) => Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: current,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12, width: 1),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _hexFromColor(current),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );

      Widget alphaCard(StateSetter setState) {
        final v = (current.a).clamp(0.0, 1.0);

        const double sliderW = 350;
        const double thumbR = 6;

        return Center(
          child: SizedBox(
            width: sliderW,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: thumbR),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '투명도',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text('${(v * 100).round()}%'),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 1.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: thumbR,
                    ),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: v,
                    onChanged: (nv) {
                      final a = (nv * 255).round().clamp(0, 255);
                      setState(() => current = current.withAlpha(a));
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }

      Widget wheelCard(StateSetter setState) => Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: SizedBox(
            width: wheelSize,
            height: wheelSize,
            child: ColorWheelPicker(
              color: current,
              onWheel: (_) {},
              onChanged: (c) => setState(() => current = c),
              wheelWidth: 18,
              wheelSquarePadding: 20,
              wheelSquareBorderRadius: 999,
              hasBorder: true,
              borderColor: Colors.black12,
            ),
          ),
        ),
      );

      Widget actions() => Row(
        children: [
          TextButton.icon(
            onPressed:
                () => Navigator.pop(ctx, const _ColorSheetResult.clear()),
            icon: const Icon(Icons.block),
            label: const Text('해제'),
          ),
          const Spacer(),
          TextButton(
            onPressed:
                () => Navigator.pop(ctx, const _ColorSheetResult.cancel()),
            child: const Text('취소'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1F3A56),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed:
                () => Navigator.pop(ctx, _ColorSheetResult.apply(current)),
            child: const Text(
              '적용',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              decoration: BoxDecoration(
                color: const ui.Color.fromARGB(70, 207, 232, 255),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                border: Border.all(color: sheetBorder, width: 1),
              ),
              child: StatefulBuilder(
                builder: (ctx, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      handle(),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F3A56),
                        ),
                      ),
                      const SizedBox(height: 10),
                      inputCard(setState),
                      const SizedBox(height: 10),
                      wheelCard(setState),
                      if (forBackground) ...[
                        const SizedBox(height: 15),
                        alphaCard(setState),
                      ],
                      const SizedBox(height: 15),
                      actions(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  ).then((v) => v ?? const _ColorSheetResult.cancel());
}

String _hexFromColor(Color c) {
  final int r = ((c.r) * 255.0).round() & 0xff;
  final int g = ((c.g) * 255.0).round() & 0xff;
  final int b = ((c.b) * 255.0).round() & 0xff;

  return '#'
      '${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
}

@immutable
class GlassTheme {
  final double borderOpacity;
  const GlassTheme({this.borderOpacity = 0.28});
}

const double kCoverRadius = 13;

double scaledCoverRadius(double w) {
  final t = (w / 180.0).clamp(0.75, 1.15);
  return (kCoverRadius * t).clamp(10.0, 18.0);
}

class _CoverThumb extends StatelessWidget {
  final String? coverPath;
  final VoidCallback onTap;
  final VoidCallback? onLongPressPreview;

  const _CoverThumb({
    required this.coverPath,
    required this.onTap,
    this.onLongPressPreview,
  });

  static const double _ratio2to3 = 1.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth;

        final cardW = maxW.clamp(120.0, 190.0);
        final cardH = cardW * _ratio2to3;
        final cardRadius = scaledCoverRadius(cardW);

        File? coverFile;
        if (coverPath != null && coverPath!.isNotEmpty) {
          final f = File(coverPath!);
          if (f.existsSync()) coverFile = f;
        }

        const placeholder = Center(
          child: Text(
            '+ 사진',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 171, 193, 217),
              fontWeight: FontWeight.w500,
            ),
          ),
        );

        return SizedBox(
          width: cardW,
          height: cardH,
          child: GestureDetector(
            onTap: onTap,
            onLongPress: coverFile != null ? onLongPressPreview : null,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cardRadius),
                color:
                    coverFile != null
                        ? Colors.transparent
                        : const Color(0xFFFFFFFF).withValues(alpha: 0.04),
                border:
                    coverFile != null
                        ? null
                        : Border.all(
                          color: const Color.fromARGB(255, 170, 193, 216),
                          width: 0.5,
                        ),
              ),
              clipBehavior: Clip.hardEdge,
              child:
                  coverFile != null
                      ? Image.file(
                        coverFile,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => placeholder,
                      )
                      : placeholder,
            ),
          ),
        );
      },
    );
  }
}

class _MiniLabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int? maxLines;
  final VoidCallback onChanged;

  const _MiniLabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    const fieldStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w300,
      color: const Color.fromARGB(221, 83, 129, 159),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label :', style: labelStyle),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: (_) => onChanged(),
          style: fieldStyle,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: hintStyle,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class WorldPage extends StatefulWidget {
  final Character? initialCharacter;
  final CharacterKind? initialKind;

  const WorldPage({super.key, this.initialCharacter, this.initialKind});

  @override
  State<WorldPage> createState() => _WorldPageState();
}

class _FrostedKeywordBox extends StatefulWidget {
  final bool enableGlass;
  final String title;
  final String? helper;
  final String hintText;
  final KeywordInputMode mode;

  final List<String> initialKeywords;
  final ValueChanged<List<String>> onChanged;

  const _FrostedKeywordBox({
    required this.enableGlass,
    required this.title,
    this.helper,
    this.hintText = '입력 후 Enter',
    this.mode = KeywordInputMode.phrase,
    required this.initialKeywords,
    required this.onChanged,
  });

  @override
  State<_FrostedKeywordBox> createState() => _FrostedKeywordBoxState();
}

class FrostedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool enableGlass;
  final double blurSigma;
  final Color? backgroundColor;
  final BoxConstraints? constraints;
  final bool showBorder;
  final Color? borderColor;

  const FrostedContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    required this.enableGlass,
    this.blurSigma = 16,
    this.backgroundColor,
    this.constraints,
    this.showBorder = true,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        backgroundColor ??
        (isDark
            ? Colors.white.withValues(alpha: enableGlass ? 0.06 : 0.10)
            : Colors.white.withValues(alpha: enableGlass ? 0.70 : 0.90));
    final silver = (borderColor ?? const Color.fromARGB(255, 147, 162, 181))
        .withValues(alpha: 0.65);

    final content = Container(
      constraints: constraints,
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder ? Border.all(color: silver, width: 1) : null,
      ),
      child: child,
    );

    if (!enableGlass) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );
  }
}

class _FrostedKeywordBoxState extends State<_FrostedKeywordBox> {
  late final TextEditingController _keywordInputCtrl;
  late List<String> _keywords;

  @override
  void initState() {
    super.initState();
    _keywordInputCtrl = TextEditingController();
    _keywords =
        widget.initialKeywords
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
  }

  @override
  void dispose() {
    _keywordInputCtrl.dispose();
    super.dispose();
  }

  void _emit() => widget.onChanged(_keywords.toList(growable: false));

  String _sanitize(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return '';

    if (widget.mode == KeywordInputMode.hashtag) {
      if (s.startsWith('#')) s = s.substring(1);
      s = s.replaceAll(RegExp(r'[^0-9A-Za-z가-힣_ ]+'), '');
      s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
      return s;
    }
    return s;
  }

  void _addKeyword(String raw) {
    final input = raw.trim();
    if (input.isEmpty) return;

    final toAdd = <String>[];
    final t = _sanitize(input);
    if (t.isNotEmpty) toAdd.add(t);
    if (toAdd.isEmpty) return;

    setState(() {
      for (final x in toAdd) {
        if (!_keywords.contains(x)) _keywords.add(x);
      }
    });

    _keywordInputCtrl.clear();
    _emit();
  }

  void _removeKeyword(String k) {
    setState(() => _keywords.remove(k));
    _emit();
  }

  Widget _buildChip(String k) {
    final isHash = widget.mode == KeywordInputMode.hashtag;
    final text = isHash ? '#$k' : k;

    return Padding(
      padding: EdgeInsets.only(bottom: isHash ? 0 : 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(101, 193, 229, 247),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  text,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _removeKeyword(k),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 16, color: Colors.black54),
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
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    return FrostedContainer(
      enableGlass: widget.enableGlass,
      borderRadius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: Colors.white.withValues(
        alpha: widget.enableGlass ? 0.96 : 1.0,
      ),
      showBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: labelStyle),
          if (widget.helper != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.helper!,
              style: const TextStyle(
                fontSize: 12,
                color: Color.fromARGB(221, 83, 129, 159),
              ),
            ),
          ],
          const SizedBox(height: 7),
          Builder(
            builder: (context) {
              final isSingleLine = widget.mode == KeywordInputMode.phrase;

              if (_keywords.isEmpty) {
                return const Text(
                  '아직 등록된 항목이 없습니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(184, 132, 166, 191),
                  ),
                );
              }

              if (isSingleLine) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _keywords.map(_buildChip).toList(),
                );
              }

              return Wrap(
                spacing: 5,
                runSpacing: 5,
                children: _keywords.map(_buildChip).toList(),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keywordInputCtrl,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _addKeyword,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  style: const TextStyle(fontSize: 13.5),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => _addKeyword(_keywordInputCtrl.text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineLabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;

  const _InlineLabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    const fieldStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    const hintStyle = TextStyle(
      fontSize: 11,
      color: Color.fromARGB(221, 83, 129, 159),
      fontWeight: FontWeight.w300,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$label :', style: labelStyle),
        const SizedBox(width: 5),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            style: fieldStyle,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
            ).copyWith(hintText: hint, hintStyle: hintStyle),
          ),
        ),
      ],
    );
  }
}

class _WorldPageState extends State<WorldPage> {
  static const Color _defaultCharacterColor = ui.Color.fromARGB(
    182,
    255,
    247,
    180,
  );

  late Character _character;

  late final TextEditingController _bloodTypeCtrl;
  late final TextEditingController _specialNoteCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _birthdayCtrl;
  late final TextEditingController _heightCtrl;

  String? _coverPath;

  late Color _charColor;

  late final List<TextEditingController> _personalityCtrls;
  late final List<TextEditingController> _likeCtrls;
  late final List<TextEditingController> _dislikeCtrls;
  late final List<TextEditingController> _physicalNoteCtrls;

  @override
  void initState() {
    super.initState();
    final base = widget.initialCharacter ?? Character.empty();
    _character =
        (base.id.trim().isEmpty)
            ? base.copyWith(
              kind: widget.initialKind ?? CharacterKind.protagonist,
            )
            : base;

    _charColor = _character.color ?? _defaultCharacterColor;

    _nameCtrl = TextEditingController(text: _character.name);
    _birthdayCtrl = TextEditingController(text: _character.birthday);
    _heightCtrl = TextEditingController(text: _character.height);
    _bloodTypeCtrl = TextEditingController(text: _character.bloodType);
    _specialNoteCtrl = TextEditingController(text: _character.specialNote);

    _personalityCtrls =
        _character.personalityKeywords
            .map((e) => TextEditingController(text: e))
            .toList();
    _likeCtrls =
        _character.likes.map((e) => TextEditingController(text: e)).toList();
    _dislikeCtrls =
        _character.dislikes.map((e) => TextEditingController(text: e)).toList();
    _physicalNoteCtrls =
        _character.physicalNotes
            .map((e) => TextEditingController(text: e))
            .toList();

    _coverPath = _character.coverPath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthdayCtrl.dispose();
    _heightCtrl.dispose();
    _bloodTypeCtrl.dispose();
    _specialNoteCtrl.dispose();

    for (final c in _personalityCtrls) {
      c.dispose();
    }
    for (final c in _likeCtrls) {
      c.dispose();
    }
    for (final c in _dislikeCtrls) {
      c.dispose();
    }
    for (final c in _physicalNoteCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Character _buildCharacterFromControllers() {
    return _character.copyWith(
      name: _nameCtrl.text.trim(),
      birthday: _birthdayCtrl.text.trim(),
      height: _heightCtrl.text.trim(),
      bloodType: _bloodTypeCtrl.text.trim(),
      specialNote: _specialNoteCtrl.text.trim(),
      coverPath: _coverPath,
      color: _charColor,
      personalityKeywords:
          _personalityCtrls
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .toList(),
      likes:
          _likeCtrls
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .toList(),
      dislikes:
          _dislikeCtrls
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .toList(),
      physicalNotes:
          _physicalNoteCtrls
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .toList(),
    );
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Character _finalizeForPop(Character c) {
    if (c.id.trim().isEmpty) {
      return c.copyWith(id: _newId());
    }
    return c;
  }

  void _syncState() {
    setState(() {
      _character = _buildCharacterFromControllers();
    });
  }

  Future<void> _pickCharacterColor() async {
    final result = await _showPrettyWheelBottomSheet(
      context,
      title: '캐릭터 색상',
      theme: const GlassTheme(borderOpacity: 0.28),
      initial: _charColor,
      wheelSize: 190,
      forBackground: true,
    );

    if (!mounted) return;
    if (result.kind == 0) return;

    setState(() {
      if (result.kind == 1) {
        _charColor = _defaultCharacterColor;
      } else {
        _charColor = result.color ?? _defaultCharacterColor;
      }
      _syncState();
    });
  }

  Widget _colorLine(Color c) {
    return Container(height: 15, decoration: BoxDecoration(color: c));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Character',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final result = _finalizeForPop(_buildCharacterFromControllers());
              Navigator.of(context).pop(result);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: '캐릭터'),
              const SizedBox(height: 8),

              FrostedContainer(
                enableGlass: true,
                borderRadius: 10,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.96),
                showBorder: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 160,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CoverThumb(
                            coverPath: _coverPath,
                            onTap: () async {},
                            onLongPressPreview: () {},
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '탭 : 추가/변경',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: const Color.fromARGB(221, 83, 129, 159),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InlineLabeledField(
                            label: 'Name',
                            controller: _nameCtrl,
                            hint: '예) 무무',
                            onChanged: _syncState,
                          ),
                          const SizedBox(height: 10),
                          _InlineLabeledField(
                            label: 'Birthday',
                            controller: _birthdayCtrl,
                            hint: '예) 2005-01-01',
                            onChanged: _syncState,
                          ),
                          const SizedBox(height: 10),
                          _InlineLabeledField(
                            label: 'Height',
                            controller: _heightCtrl,
                            hint: '예) 159cm',
                            onChanged: _syncState,
                          ),
                          const SizedBox(height: 10),
                          _InlineLabeledField(
                            label: 'Blood type',
                            controller: _bloodTypeCtrl,
                            hint: '예) O+',
                            onChanged: _syncState,
                          ),
                          const SizedBox(height: 10),
                          _MiniLabeledField(
                            label: 'Profile',
                            controller: _specialNoteCtrl,
                            hint: '예) 낮에는 잠이 많음',
                            maxLines: null,
                            onChanged: _syncState,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const _SectionTitle(title: 'color'),
              const SizedBox(height: 8),
              FrostedContainer(
                enableGlass: true,
                borderRadius: 10,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.96),
                showBorder: false,
                child: InkWell(
                  onTap: _pickCharacterColor,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    children: [
                      SizedBox(width: 50, child: _colorLine(_charColor)),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Color.fromARGB(221, 83, 129, 159),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const _SectionTitle(title: '성격'),
              const SizedBox(height: 8),
              _FrostedKeywordBox(
                enableGlass: true,
                title: '성격 키워드',
                hintText: '키워드 입력 후 Enter',
                mode: KeywordInputMode.hashtag,
                initialKeywords:
                    _personalityCtrls
                        .map((c) => c.text)
                        .where((e) => e.trim().isNotEmpty)
                        .toList(),
                onChanged: (list) {
                  for (final c in _personalityCtrls) {
                    c.dispose();
                  }
                  _personalityCtrls
                    ..clear()
                    ..addAll(list.map((e) => TextEditingController(text: e)));
                  _syncState();
                },
              ),

              const SizedBox(height: 20),

              const _SectionTitle(title: '좋아/싫어'),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _FrostedKeywordBox(
                      enableGlass: true,
                      title: '좋아하는 것',
                      hintText: '입력 후 Enter',
                      initialKeywords:
                          _likeCtrls
                              .map((c) => c.text.trim())
                              .where((t) => t.isNotEmpty)
                              .toList(),
                      onChanged: (list) {
                        for (final c in _likeCtrls) {
                          c.dispose();
                        }
                        _likeCtrls
                          ..clear()
                          ..addAll(
                            list.map((e) => TextEditingController(text: e)),
                          );
                        _syncState();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FrostedKeywordBox(
                      enableGlass: true,
                      title: '싫어하는 것',
                      hintText: '입력 후 Enter',
                      initialKeywords:
                          _dislikeCtrls
                              .map((c) => c.text.trim())
                              .where((t) => t.isNotEmpty)
                              .toList(),
                      onChanged: (list) {
                        for (final c in _dislikeCtrls) {
                          c.dispose();
                        }
                        _dislikeCtrls
                          ..clear()
                          ..addAll(
                            list.map((e) => TextEditingController(text: e)),
                          );
                        _syncState();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const _SectionTitle(title: '신체 / 외형'),
              const SizedBox(height: 8),
              _FrostedKeywordBox(
                enableGlass: true,
                title: '신체 / 외형 메모',
                helper: '예) 인간형일 때 투명하게 빛나는 귀와 꼬리',
                hintText: '메모 입력 후 Enter',
                mode: KeywordInputMode.phrase,
                initialKeywords:
                    _physicalNoteCtrls
                        .map((c) => c.text.trim())
                        .where((t) => t.isNotEmpty)
                        .toList(),
                onChanged: (list) {
                  for (final c in _physicalNoteCtrls) {
                    c.dispose();
                  }
                  _physicalNoteCtrls
                    ..clear()
                    ..addAll(list.map((e) => TextEditingController(text: e)));
                  _syncState();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _ColorJson on Color {
  int toArgbInt() => toARGB32();
  static Color fromArgbInt(int v) => Color(v);
}

@immutable
class Character {
  final String id;
  final CharacterKind kind;

  final Color? color;

  final String name;
  final String birthday;
  final String height;
  final String bloodType;
  final String specialNote;
  final String? coverPath;

  final List<String> personalityKeywords;
  final List<String> likes;
  final List<String> dislikes;

  final List<String> physicalNotes;

  final List<PaletteGroup> palette;
  final List<CharacterImage> images;
  final String? sheetAssetPath;

  static String newId() => 'c_${DateTime.now().microsecondsSinceEpoch}';

  const Character({
    required this.id,
    this.kind = CharacterKind.protagonist,
    this.color,
    required this.name,
    required this.birthday,
    required this.height,
    required this.personalityKeywords,
    required this.likes,
    required this.dislikes,
    required this.physicalNotes,
    required this.palette,
    required this.images,
    required this.bloodType,
    required this.specialNote,
    this.coverPath,
    this.sheetAssetPath,
  });

  Character copyWith({
    String? id,
    CharacterKind? kind,
    Color? color,
    String? name,
    String? birthday,
    String? height,
    List<String>? personalityKeywords,
    List<String>? likes,
    List<String>? dislikes,
    List<String>? physicalNotes,
    List<PaletteGroup>? palette,
    List<CharacterImage>? images,
    String? sheetAssetPath,
    String? bloodType,
    String? specialNote,
    String? coverPath,
  }) {
    return Character(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      color: color ?? this.color,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      height: height ?? this.height,
      personalityKeywords: personalityKeywords ?? this.personalityKeywords,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      physicalNotes: physicalNotes ?? this.physicalNotes,
      palette: palette ?? this.palette,
      images: images ?? this.images,
      bloodType: bloodType ?? this.bloodType,
      specialNote: specialNote ?? this.specialNote,
      coverPath: coverPath ?? this.coverPath,
      sheetAssetPath: sheetAssetPath ?? this.sheetAssetPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.key,
    'color': color?.toArgbInt(),
    'name': name,
    'birthday': birthday,
    'height': height,
    'personalityKeywords': personalityKeywords,
    'likes': likes,
    'dislikes': dislikes,
    'physicalNotes': physicalNotes,
    'palette': palette.map((e) => e.toJson()).toList(),
    'images': images.map((e) => e.toJson()).toList(),
    'bloodType': bloodType,
    'specialNote': specialNote,
    'coverPath': coverPath,
    'sheetAssetPath': sheetAssetPath,
  };

  factory Character.fromJson(Map<String, dynamic> json) {
    final rawId = (json['id'] ?? '').toString().trim();

    Color? parsedColor;
    final c = json['color'];
    if (c is int) parsedColor = _ColorJson.fromArgbInt(c);
    if (c is num) parsedColor = _ColorJson.fromArgbInt(c.toInt());

    return Character(
      id: (rawId.isEmpty || rawId == 'new') ? Character.newId() : rawId,
      kind: CharacterKindX.fromKey(json['kind']?.toString()),
      color: parsedColor,
      name: (json['name'] ?? '').toString(),
      birthday: (json['birthday'] ?? '').toString(),
      height: (json['height'] ?? '').toString(),
      personalityKeywords:
          (json['personalityKeywords'] is List)
              ? (json['personalityKeywords'] as List)
                  .map((e) => e.toString())
                  .toList()
              : const <String>[],
      likes:
          (json['likes'] is List)
              ? (json['likes'] as List).map((e) => e.toString()).toList()
              : const <String>[],
      dislikes:
          (json['dislikes'] is List)
              ? (json['dislikes'] as List).map((e) => e.toString()).toList()
              : const <String>[],
      physicalNotes:
          (json['physicalNotes'] is List)
              ? (json['physicalNotes'] as List)
                  .map((e) => e.toString())
                  .toList()
              : const <String>[],
      palette:
          (json['palette'] is List)
              ? (json['palette'] as List)
                  .whereType<Map>()
                  .map(
                    (m) => PaletteGroup.fromJson(Map<String, dynamic>.from(m)),
                  )
                  .toList()
              : const <PaletteGroup>[],
      images:
          (json['images'] is List)
              ? (json['images'] as List)
                  .whereType<Map>()
                  .map(
                    (m) =>
                        CharacterImage.fromJson(Map<String, dynamic>.from(m)),
                  )
                  .toList()
              : const <CharacterImage>[],
      bloodType: (json['bloodType'] ?? '').toString(),
      specialNote: (json['specialNote'] ?? '').toString(),
      coverPath: json['coverPath']?.toString(),
      sheetAssetPath: json['sheetAssetPath']?.toString(),
    );
  }

  factory Character.empty() {
    return const Character(
      id: '',
      kind: CharacterKind.protagonist,
      color: null,
      name: '',
      birthday: '',
      height: '',
      personalityKeywords: [],
      likes: [],
      dislikes: [],
      physicalNotes: [],
      palette: [],
      images: [],
      bloodType: '',
      specialNote: '',
      coverPath: null,
      sheetAssetPath: null,
    );
  }
}

@immutable
class DetailPair {
  final String title;
  final String description;
  const DetailPair({required this.title, required this.description});

  Map<String, dynamic> toJson() => {'title': title, 'description': description};

  factory DetailPair.fromJson(Map<String, dynamic> json) => DetailPair(
    title: (json['title'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
  );
}

class DetailPairCtrls {
  final TextEditingController title;
  final TextEditingController description;

  DetailPairCtrls({required this.title, required this.description});

  factory DetailPairCtrls.from(DetailPair p) {
    return DetailPairCtrls(
      title: TextEditingController(text: p.title),
      description: TextEditingController(text: p.description),
    );
  }

  factory DetailPairCtrls.empty() {
    return DetailPairCtrls(
      title: TextEditingController(),
      description: TextEditingController(),
    );
  }

  DetailPair toDetailPair() =>
      DetailPair(title: title.text, description: description.text);

  void dispose() {
    title.dispose();
    description.dispose();
  }
}

@immutable
class PaletteGroup {
  final String label;
  final List<Color> colors;
  final String? note;
  const PaletteGroup({required this.label, required this.colors, this.note});

  Map<String, dynamic> toJson() => {
    'label': label,
    'colors': colors.map((c) => c.toArgbInt()).toList(),
    'note': note,
  };

  factory PaletteGroup.fromJson(Map<String, dynamic> json) => PaletteGroup(
    label: (json['label'] ?? '').toString(),
    colors:
        (json['colors'] is List)
            ? (json['colors'] as List)
                .whereType<num>()
                .map((n) => _ColorJson.fromArgbInt(n.toInt()))
                .toList()
            : const <Color>[],
    note: json['note']?.toString(),
  );
}

@immutable
class CharacterImage {
  final String label;
  final String assetPath;
  const CharacterImage({required this.label, required this.assetPath});

  Map<String, dynamic> toJson() => {'label': label, 'assetPath': assetPath};

  factory CharacterImage.fromJson(Map<String, dynamic> json) => CharacterImage(
    label: (json['label'] ?? '').toString(),
    assetPath: (json['assetPath'] ?? '').toString(),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
    );
  }
}

class EditableInfoItem {
  final String label;
  final TextEditingController controller;
  final String hint;

  EditableInfoItem({
    required this.label,
    required this.controller,
    required this.hint,
  });
}
