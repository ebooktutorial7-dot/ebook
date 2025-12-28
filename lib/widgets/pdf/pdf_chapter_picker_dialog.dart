// lib/widgets/pdf/pdf_chapter_picker_dialog.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:ebook_tutorial_app/pages/book_builder_page.dart'
    show ChapterItem;
import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_container.dart';
import 'package:ebook_tutorial_app/widgets/common/app_toast.dart';

const _primaryBlue = ui.Color.fromARGB(255, 79, 164, 255);

class ChapterPickResult {
  const ChapterPickResult({required this.useAll, required this.selected});
  final bool useAll;
  final Set<int> selected;
}

Future<ChapterPickResult?> showPdfChapterPickerDialog({
  required BuildContext context,
  required List<ChapterItem> chapters,
  required GlassTheme glassTheme,
  Color barrierColor = Colors.transparent, // ✅ 배경(딤) 제거 기본값
  // ✅ 미리보기/내보내기 공용으로 쓰기 위한 옵션
  String dialogTitle = 'PDF 미리보기',
  String confirmLabel = '미리보기',
}) async {
  if (chapters.isEmpty) {
    AppToast.show(context, '목차가 없습니다');
    return null;
  }

  final tmpSelected = <int>{};
  var useAll = true;

  return showDialog<ChapterPickResult>(
    context: context,
    barrierColor: barrierColor,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          void applyAndClose() {
            if (!useAll && tmpSelected.isEmpty) {
              AppToast.show(context, '회차를 선택해 주세요');
              return;
            }
            Navigator.pop(
              context,
              ChapterPickResult(useAll: useAll, selected: tmpSelected),
            );
          }

          return Material(
            type: MaterialType.transparency,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: GlassContainer(
                  theme: glassTheme,
                  borderRadius: 20,
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 10,
                    right: 10,
                    bottom: 10,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 230),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ✅ 타이틀을 파라미터로
                        Text(
                          dialogTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7EFF8),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () => setModalState(() => useAll = true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          useAll
                                              ? Colors.white
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '모든 회차',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            useAll
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                        color:
                                            useAll
                                                ? const Color(0xFF1F3A56)
                                                : const Color(0xFF607D8B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () => setModalState(() => useAll = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          !useAll
                                              ? Colors.white
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '선택 회차',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            !useAll
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                        color:
                                            !useAll
                                                ? const Color(0xFF1F3A56)
                                                : const Color(0xFF607D8B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (!useAll)
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              itemCount: chapters.length,
                              itemBuilder: (context, i) {
                                final c = chapters[i];
                                final checked = tmpSelected.contains(i);

                                return CheckboxListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  value: checked,
                                  activeColor: _primaryBlue,
                                  checkColor: Colors.white,
                                  title: Text(
                                    c.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13.5),
                                  ),
                                  onChanged: (v) {
                                    setModalState(() {
                                      if (v == true) {
                                        tmpSelected.add(i);
                                      } else {
                                        tmpSelected.remove(i);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  '닫기',
                                  style: TextStyle(color: Color(0xFF1F3A56)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const ui.Color.fromARGB(
                                    255,
                                    233,
                                    247,
                                    255,
                                  ),
                                  foregroundColor: const Color(0xFF1F3A56),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: applyAndClose,
                                // ✅ 버튼 라벨도 파라미터로
                                child: Text(confirmLabel),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
