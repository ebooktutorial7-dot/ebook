// world.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'dart:io';

enum KeywordInputMode { hashtag, phrase }

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
  const WorldPage({super.key, this.initialCharacter});

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

    final parts = <String>[input];

    final toAdd = <String>[];
    for (final p in parts) {
      final t = _sanitize(p);
      if (t.isNotEmpty) toAdd.add(t);
    }
    if (toAdd.isEmpty) return;

    setState(() {
      for (final t in toAdd) {
        if (!_keywords.contains(t)) _keywords.add(t);
      }
    });

    _keywordInputCtrl.clear();
    _emit();
  }

  void _removeKeyword(String k) {
    setState(() => _keywords.remove(k));
    _emit();
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
                  children: _keywords.map((k) => _buildChip(k)).toList(),
                );
              }

              return Wrap(
                spacing: 5,
                runSpacing: 5,
                children: _keywords.map((k) => _buildChip(k)).toList(),
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
  late Character _character;
  late final TextEditingController _bloodTypeCtrl;
  late final TextEditingController _specialNoteCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _aliasCtrl;
  late final TextEditingController _birthdayCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _speciesCtrl;
  late final TextEditingController _heightCtrl;

  String? _coverPath;

  late final List<TextEditingController> _personalityCtrls;
  late final List<TextEditingController> _likeCtrls;
  late final List<TextEditingController> _dislikeCtrls;
  late final List<TextEditingController> _physicalNoteCtrls;
  late final List<DetailPairCtrls> _detailCtrls;

  @override
  void initState() {
    super.initState();

    _character = widget.initialCharacter ?? Character.empty();

    _nameCtrl = TextEditingController(text: _character.name);
    _aliasCtrl = TextEditingController(text: _character.alias);
    _birthdayCtrl = TextEditingController(text: _character.birthday);
    _genderCtrl = TextEditingController(text: _character.gender);
    _speciesCtrl = TextEditingController(text: _character.species);
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

    _detailCtrls =
        _character.detailNotes.map((p) => DetailPairCtrls.from(p)).toList();
    _coverPath = _character.coverPath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _aliasCtrl.dispose();
    _birthdayCtrl.dispose();
    _genderCtrl.dispose();
    _speciesCtrl.dispose();
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
    for (final c in _detailCtrls) {
      c.dispose();
    }

    super.dispose();
  }

  Character _buildCharacterFromControllers() {
    return _character.copyWith(
      name: _nameCtrl.text.trim(),
      alias: _aliasCtrl.text.trim(),
      birthday: _birthdayCtrl.text.trim(),
      gender: _genderCtrl.text.trim(),
      species: _speciesCtrl.text.trim(),
      height: _heightCtrl.text.trim(),
      bloodType: _bloodTypeCtrl.text.trim(),
      specialNote: _specialNoteCtrl.text.trim(),
      coverPath: _coverPath,
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
      detailNotes:
          _detailCtrls
              .map((c) => c.toDetailPair())
              .where(
                (p) =>
                    p.title.trim().isNotEmpty ||
                    p.description.trim().isNotEmpty,
              )
              .toList(),
    );
  }

  void _syncState() {
    setState(() {
      _character = _buildCharacterFromControllers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: '저장(닫기)',
            icon: const Icon(Icons.check),
            onPressed: () {
              final result = _buildCharacterFromControllers();
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
                            '탭: 추가/변경 · 길게: 미리보기',
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
                            label: '특이사항',
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

              const SizedBox(height: 20),

              const _SectionTitle(title: '성격'),
              const SizedBox(height: 8),
              _FrostedKeywordBox(
                enableGlass: true,
                title: '성격 키워드',
                helper: '#로맨스 #성장물 #판타지 처럼 자유롭게 추가하세요.',
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
              const _SectionTitle(title: '신체/외형'),
              const SizedBox(height: 8),
              _FrostedKeywordBox(
                enableGlass: true,
                title: '신체/외형 메모',
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

// ================== 모델 + JSON ==================

extension _ColorJson on Color {
  int toArgbInt() => toARGB32();
  static Color fromArgbInt(int v) => Color(v);
}

@immutable
class Character {
  final String id;

  final String name;
  final String alias;
  final String birthday;
  final String gender;
  final String species;
  final String height;
  final String bloodType;
  final String specialNote;
  final String? coverPath;

  final List<String> personalityKeywords;
  final List<String> likes;
  final List<String> dislikes;

  final List<String> physicalNotes;
  final List<DetailPair> detailNotes;

  final List<PaletteGroup> palette;
  final List<CharacterImage> images;
  final String? sheetAssetPath;

  const Character({
    required this.id,
    required this.name,
    required this.alias,
    required this.birthday,
    required this.gender,
    required this.species,
    required this.height,
    required this.personalityKeywords,
    required this.likes,
    required this.dislikes,
    required this.physicalNotes,
    required this.detailNotes,
    required this.palette,
    required this.images,
    required this.bloodType,
    required this.specialNote,
    this.coverPath,
    this.sheetAssetPath,
  });

  Character copyWith({
    String? name,
    String? alias,
    String? birthday,
    String? gender,
    String? species,
    String? height,
    List<String>? personalityKeywords,
    List<String>? likes,
    List<String>? dislikes,
    List<String>? physicalNotes,
    List<DetailPair>? detailNotes,
    List<PaletteGroup>? palette,
    List<CharacterImage>? images,
    String? sheetAssetPath,
    String? bloodType,
    String? specialNote,
    String? coverPath,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      alias: alias ?? this.alias,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      species: species ?? this.species,
      height: height ?? this.height,
      personalityKeywords: personalityKeywords ?? this.personalityKeywords,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      physicalNotes: physicalNotes ?? this.physicalNotes,
      detailNotes: detailNotes ?? this.detailNotes,
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
    'name': name,
    'alias': alias,
    'birthday': birthday,
    'gender': gender,
    'species': species,
    'height': height,
    'personalityKeywords': personalityKeywords,
    'likes': likes,
    'dislikes': dislikes,
    'physicalNotes': physicalNotes,
    'detailNotes': detailNotes.map((e) => e.toJson()).toList(),
    'palette': palette.map((e) => e.toJson()).toList(),
    'images': images.map((e) => e.toJson()).toList(),
    'bloodType': bloodType,
    'specialNote': specialNote,
    'coverPath': coverPath,
    'sheetAssetPath': sheetAssetPath,
  };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
    id: (json['id'] ?? 'mumu').toString(),
    name: (json['name'] ?? '').toString(),
    alias: (json['alias'] ?? '').toString(),
    birthday: (json['birthday'] ?? '').toString(),
    gender: (json['gender'] ?? '').toString(),
    species: (json['species'] ?? '').toString(),
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
            ? (json['physicalNotes'] as List).map((e) => e.toString()).toList()
            : const <String>[],
    detailNotes:
        (json['detailNotes'] is List)
            ? (json['detailNotes'] as List)
                .whereType<Map>()
                .map((m) => DetailPair.fromJson(Map<String, dynamic>.from(m)))
                .toList()
            : const <DetailPair>[],
    palette:
        (json['palette'] is List)
            ? (json['palette'] as List)
                .whereType<Map>()
                .map((m) => PaletteGroup.fromJson(Map<String, dynamic>.from(m)))
                .toList()
            : const <PaletteGroup>[],
    images:
        (json['images'] is List)
            ? (json['images'] as List)
                .whereType<Map>()
                .map(
                  (m) => CharacterImage.fromJson(Map<String, dynamic>.from(m)),
                )
                .toList()
            : const <CharacterImage>[],
    bloodType: (json['bloodType'] ?? '').toString(),
    specialNote: (json['specialNote'] ?? '').toString(),
    coverPath: json['coverPath']?.toString(),
    sheetAssetPath: json['sheetAssetPath']?.toString(),
  );
  factory Character.empty() {
    return const Character(
      id: 'new',
      name: '',
      alias: '',
      birthday: '',
      gender: '',
      species: '',
      height: '',
      personalityKeywords: [],
      likes: [],
      dislikes: [],
      physicalNotes: [],
      detailNotes: [],
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

// ================== UI ==================

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
