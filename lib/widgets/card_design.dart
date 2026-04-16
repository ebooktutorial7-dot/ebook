// widgets/card_design.dart

import 'dart:io';
import 'package:flutter/material.dart';

class A4MiniCard extends StatelessWidget {
  const A4MiniCard({
    super.key,
    required this.title,
    required this.preview,
    this.selected = false,
    required this.selectionMode,
    this.coverPath,
  });

  final String title;
  final String preview;
  final bool selected;
  final bool selectionMode;
  final String? coverPath;

  static const Color border = Color.fromARGB(221, 159, 188, 208);

  static const double a4Height = 150;
  static const double a4AspectWH = 2 / 3;
  static const double a4Width = a4Height * a4AspectWH;

  static const double captionGap = 7;
  static const double captionHeight = 70;

  @override
  Widget build(BuildContext context) {
    final bool hasCover =
        coverPath != null &&
        coverPath!.isNotEmpty &&
        File(coverPath!).existsSync();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final cardW = (maxW.isFinite && maxW > 0) ? maxW : a4Width;

        final scale = cardW / a4Width;
        final cardH = a4Height * scale;
        final capH = captionHeight * scale;
        final gap = captionGap * scale;
        final radius = 13 * scale;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: cardH,
              width: cardW,
              clipBehavior: hasCover ? Clip.none : Clip.hardEdge,
              decoration:
                  hasCover
                      ? null
                      : BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        border:
                            (selectionMode && selected)
                                ? Border.all(
                                  color: const Color.fromARGB(
                                    255,
                                    91,
                                    179,
                                    255,
                                  ),
                                  width: 1.7,
                                )
                                : Border.all(color: border, width: 0.5),
                      ),
              child:
                  hasCover
                      ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(radius),
                            clipBehavior: Clip.antiAlias,
                            child: Image.file(
                              File(coverPath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (selectionMode && selected)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(radius),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                        255,
                                        91,
                                        179,
                                        255,
                                      ),
                                      width: 1.7,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                      : const Center(
                        child: Icon(
                          Icons.menu_book_outlined,
                          size: 25,
                          color: Color.fromARGB(221, 111, 159, 192),
                        ),
                      ),
            ),
            SizedBox(height: gap),
            SizedBox(
              width: cardW,
              height: capH,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color.fromARGB(221, 83, 129, 159),
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AddSquareCard extends StatelessWidget {
  const AddSquareCard({super.key, required this.onTap});

  final VoidCallback onTap;
  static const Color _border = Color.fromARGB(221, 170, 214, 244);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _border, width: 1),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  size: 36,
                  color: Color.fromARGB(221, 83, 129, 159),
                ),
                SizedBox(height: 6),
                Text(
                  '새 작품 만들기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(221, 12, 24, 46),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddWideCard extends StatelessWidget {
  const AddWideCard({super.key, required this.onTap});

  final VoidCallback onTap;
  static const Color _border = Color.fromARGB(221, 170, 214, 244);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _border, width: 1),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  size: 36,
                  color: Color.fromARGB(221, 83, 129, 159),
                ),
                SizedBox(height: 6),
                Text(
                  '새 작품 만들기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(221, 12, 24, 46),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MemoSquareCard extends StatelessWidget {
  const MemoSquareCard({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 0.95,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              highlightColor: const Color.fromARGB(221, 12, 24, 46),
              splashColor: const Color.fromARGB(221, 12, 24, 46),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color.fromARGB(221, 159, 188, 208),
                    width: 0.7,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                child: Text(
                  text,
                  maxLines: 7,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color.fromARGB(221, 12, 24, 46),
                    fontWeight: FontWeight.w400,
                    fontSize: 9,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
