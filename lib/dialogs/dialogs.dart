// lib/dialogs/dialogs.dart
import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass/glass_container.dart';
import '../widgets/glass/glass_action_button.dart';

typedef GenreTap = Future<void> Function(String);

Future<void> showGenreDialog(
  BuildContext context, {
  required GlassTheme theme,
  required GenreTap onTap,
}) {
  final buttonTheme = theme.copyWith(
    sweepOpacity: 0.0,
    highlightOpacity: 0.0,
    innerEdgeOpacity: 0.02,
  );

  const genres = ['자유 서식', '소설', '시', '자기 계발', '과학 책', '그림 책', '수업 과제'];

  return showDialog(
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
            theme: buttonTheme,
            borderRadius: 20,
            padding: const EdgeInsets.only(
              top: 16,
              left: 12,
              right: 12,
              bottom: 8,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * .6,
              ),
              child: Column(
                children: [
                  const Text(
                    '장르 선택',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 3.1,
                      children:
                          genres.map((g) {
                            final baseStyle = ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  theme.reduceTransparency
                                      ? Colors.blueGrey.shade50
                                      : Colors.white.withValues(
                                        alpha: theme.surfaceOpacity,
                                      ),
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.white.withValues(
                                    alpha: theme.borderOpacity,
                                  ),
                                  width: 1,
                                ),
                              ),
                            );

                            return ElevatedButton(
                              style: baseStyle.merge(
                                ButtonStyle(
                                  splashFactory: NoSplash.splashFactory,
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                onTap(g);
                              },
                              child: Text(
                                g,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: Text(
                      '닫기',
                      style: TextStyle(fontSize: 16, color: theme.accentColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}

Future<void> showMoreDialog({
  required BuildContext context,
  required GlassTheme theme,
  required VoidCallback onPickMode,
  required VoidCallback onLogout,
}) {
  final buttonTheme = theme.copyWith(
    sweepOpacity: 0.0,
    highlightOpacity: 0.0,
    innerEdgeOpacity: 0.02,
  );

  return showDialog(
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
            theme: buttonTheme,
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
                    theme: buttonTheme,
                    icon: Icons.checklist_rtl,
                    label: '책 선택',
                    onPressed: () {
                      Navigator.pop(context);
                      onPickMode();
                    },
                  ),
                  const SizedBox(height: 10),
                  GlassActionButton(
                    theme: buttonTheme,
                    icon: Icons.logout,
                    label: '로그아웃',
                    onPressed: () {
                      Navigator.pop(context);
                      onLogout();
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: Text(
                      '닫기',
                      style: TextStyle(fontSize: 16, color: theme.accentColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}
