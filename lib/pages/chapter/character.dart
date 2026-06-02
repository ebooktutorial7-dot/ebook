// character.dart

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:ebook_tutorial_app/l10n/generated/app_localizations.dart';

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
  required String transparencyLabel,
  required String clearLabel,
  required String cancelLabel,
  required String applyLabel,
  double wheelSize = 190,
  bool forBackground = false,
}) async {
  Color current = initial;

  return showModalBottomSheet<_ColorSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    elevation: 0,
    builder: (ctx) {
      final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

      const double glassRadius = 24;

      final Color glassBg = Colors.white.withValues(alpha: 0.38);
      final Color glassBorder = Colors.white.withValues(alpha: 0.68);
      final Color glassSoft = Colors.white.withValues(alpha: 0.24);
      final Color glassSoftBorder = Colors.white.withValues(alpha: 0.42);
      const Color textStrong = ui.Color.fromARGB(255, 16, 34, 50);

      Widget handle() => Center(
        child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 12),
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      );

      Widget inputCard(StateSetter setState) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: glassSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: glassSoftBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: current,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _hexFromColor(current),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: textStrong,
                ),
              ),
            ],
          ),
        ),
      );

      Widget alphaCard(StateSetter setState) {
        final v = (current.a).clamp(0.0, 1.0);

        const double sliderW = 350;
        const double thumbR = 6;

        return Center(
          child: Container(
            width: sliderW,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            decoration: BoxDecoration(
              color: glassSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: glassSoftBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: thumbR),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transparencyLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textStrong,
                        ),
                      ),
                      Text(
                        '${(v * 100).round()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textStrong,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                SliderTheme(
                  data: SliderTheme.of(ctx).copyWith(
                    trackHeight: 1.0,
                    activeTrackColor: textStrong.withValues(alpha: 0.78),
                    inactiveTrackColor: textStrong.withValues(alpha: 0.18),
                    thumbColor: textStrong,
                    overlayColor: Colors.transparent,
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

      Widget wheelCard(StateSetter setState) => Center(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: glassSoft,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: glassSoftBorder, width: 1),
          ),
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
              borderColor: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ),
      );

      Widget actions() => Row(
        children: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: textStrong,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onPressed:
                () => Navigator.pop(ctx, const _ColorSheetResult.clear()),
            icon: const Icon(Icons.block, size: 18),
            label: Text(
              clearLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Spacer(),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: textStrong,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onPressed:
                () => Navigator.pop(ctx, const _ColorSheetResult.cancel()),
            child: Text(
              cancelLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: Colors.white.withValues(alpha: 0.72),
              foregroundColor: textStrong,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.58),
                  width: 1,
                ),
              ),
            ),
            onPressed:
                () => Navigator.pop(ctx, _ColorSheetResult.apply(current)),
            child: Text(
              applyLabel,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      );

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
          child: Material(
            color: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(glassRadius),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  decoration: BoxDecoration(
                    color: glassBg,
                    borderRadius: BorderRadius.circular(glassRadius),
                    border: Border.all(color: glassBorder, width: 1),
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
                              color: textStrong,
                            ),
                          ),
                          const SizedBox(height: 12),
                          inputCard(setState),
                          const SizedBox(height: 12),
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
  final String addPhotoLabel;
  final VoidCallback onTap;
  final VoidCallback? onLongPressPreview;

  const _CoverThumb({
    required this.coverPath,
    required this.addPhotoLabel,
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

        final placeholder = Center(
          child: Text(
            addPhotoLabel,
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 171, 193, 217),
              fontWeight: FontWeight.w500,
            ),
          ),
        );

        return SizedBox(
          width: cardW,
          height: cardH,
          child: FutureBuilder<File?>(
            future: resolveCharacterCoverFile(coverPath),
            builder: (context, snapshot) {
              final coverFile = snapshot.data;

              return GestureDetector(
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
              );
            },
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
  final String emptyText;
  final KeywordInputMode mode;

  final List<String> initialKeywords;
  final ValueChanged<List<String>> onChanged;

  const _FrostedKeywordBox({
    required this.enableGlass,
    required this.title,
    this.helper,
    required this.hintText,
    required this.emptyText,
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
                splashFactory: NoSplash.splashFactory,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
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
                return Text(
                  widget.emptyText,
                  style: const TextStyle(
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

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );

    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();

    final imageDir = Directory(p.join(appDir.path, 'character_covers'));

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final ext =
        p.extension(picked.path).isNotEmpty ? p.extension(picked.path) : '.jpg';

    final characterId =
        _character.id.trim().isNotEmpty
            ? _character.id.trim()
            : DateTime.now().microsecondsSinceEpoch.toString();

    final fileName =
        '${characterId}_${DateTime.now().microsecondsSinceEpoch}$ext';

    final relativePath = p.join('character_covers', fileName);
    final savedPath = p.join(appDir.path, relativePath);

    await File(picked.path).copy(savedPath);

    if (!mounted) return;

    setState(() {
      _coverPath = relativePath;
      _character = _buildCharacterFromControllers();
    });
  }

  Future<void> _pickCharacterColor() async {
    final l10n = AppLocalizations.of(context);

    final result = await _showPrettyWheelBottomSheet(
      context,
      title: l10n.characterColor,
      theme: const GlassTheme(borderOpacity: 0.28),
      initial: _charColor,
      transparencyLabel: l10n.transparency,
      clearLabel: l10n.clear,
      cancelLabel: l10n.cancel,
      applyLabel: l10n.apply,
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
    final l10n = AppLocalizations.of(context);

    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(
            overlayColor: WidgetStatePropertyAll<Color?>(Colors.transparent),
            shadowColor: WidgetStatePropertyAll<Color?>(Colors.transparent),
            surfaceTintColor: WidgetStatePropertyAll<Color?>(
              Colors.transparent,
            ),
            elevation: WidgetStatePropertyAll<double>(0),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.character,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                final result = _finalizeForPop(
                  _buildCharacterFromControllers(),
                );
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
                _SectionTitle(title: l10n.character),
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
                              addPhotoLabel: l10n.addPhoto,
                              onTap: _pickCoverImage,
                              onLongPressPreview: () {},
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.tapToAddOrChange,
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
                              label: l10n.name,
                              controller: _nameCtrl,
                              hint: l10n.exampleName,
                              onChanged: _syncState,
                            ),
                            const SizedBox(height: 10),
                            _InlineLabeledField(
                              label: l10n.birthday,
                              controller: _birthdayCtrl,
                              hint: l10n.exampleBirthday,
                              onChanged: _syncState,
                            ),
                            const SizedBox(height: 10),
                            _InlineLabeledField(
                              label: l10n.height,
                              controller: _heightCtrl,
                              hint: l10n.exampleHeight,
                              onChanged: _syncState,
                            ),
                            const SizedBox(height: 10),
                            _InlineLabeledField(
                              label: l10n.bloodType,
                              controller: _bloodTypeCtrl,
                              hint: l10n.exampleBloodType,
                              onChanged: _syncState,
                            ),
                            const SizedBox(height: 10),
                            _MiniLabeledField(
                              label: l10n.profile,
                              controller: _specialNoteCtrl,
                              hint: l10n.exampleProfile,
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
                _SectionTitle(title: l10n.color),
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
                    splashFactory: NoSplash.splashFactory,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
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
                _SectionTitle(title: l10n.personality),
                const SizedBox(height: 8),
                _FrostedKeywordBox(
                  enableGlass: true,
                  title: l10n.personalityKeywords,
                  hintText: l10n.keywordEnterAfterInput,
                  emptyText: l10n.noRegisteredItems,
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
                _SectionTitle(title: l10n.likesAndDislikes),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _FrostedKeywordBox(
                        enableGlass: true,
                        title: l10n.likes,
                        hintText: l10n.enterAfterInput,
                        emptyText: l10n.noRegisteredItems,
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
                        title: l10n.dislikes,
                        hintText: l10n.enterAfterInput,
                        emptyText: l10n.noRegisteredItems,
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
                _SectionTitle(title: l10n.bodyAppearance),
                const SizedBox(height: 8),
                _FrostedKeywordBox(
                  enableGlass: true,
                  title: l10n.bodyAppearanceMemo,
                  helper: l10n.exampleBodyAppearanceMemo,
                  hintText: l10n.memoEnterAfterInput,
                  emptyText: l10n.noRegisteredItems,
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
