// dialogs/dialogs.dart

import 'package:flutter/material.dart';
import 'package:ebook_tutorial_app/l10n/generated/app_localizations.dart';

import '../theme/glass_theme.dart';
import '../widgets/glass/glass_container.dart';
import '../widgets/glass/glass_action_button.dart';

typedef GenreTap = Future<void> Function(String);

ThemeData fixedLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1F3A56),
      surface: Colors.white,
      onSurface: Color(0xFF111111),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF111111),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF1F3A56),
        overlayColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Color.fromARGB(255, 201, 220, 234),
        ),
        foregroundColor: WidgetStatePropertyAll(Color(0xFF1F3A56)),
        elevation: WidgetStatePropertyAll(0.0),
        shadowColor: WidgetStatePropertyAll(Colors.transparent),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
      ),
    ),
  );
}

Future<void> showGenreDialog(
  BuildContext context, {
  required GlassTheme theme,
  required GenreTap onTap,
}) {
  final l10n = AppLocalizations.of(context);

  final genres = [
    l10n.genreWebNovel,
    l10n.genreNovel,
    l10n.genrePoetry,
    l10n.genreFreeForm,
    l10n.genreSelfImprovement,
    l10n.genreScienceBook,
  ];

  return showDialog(
    context: context,
    barrierColor: const Color(0xFF0F2238).withValues(alpha: 0.21),
    builder:
        (_) => Theme(
          data: fixedLightTheme(),
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE6ECF3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.genreSelect,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 14),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.6,
                        children:
                            genres.map((genre) {
                              return ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: const WidgetStatePropertyAll(
                                    Color.fromARGB(214, 239, 251, 255),
                                  ),
                                  foregroundColor: const WidgetStatePropertyAll(
                                    Color(0xFF1F3A56),
                                  ),
                                  elevation: const WidgetStatePropertyAll(0.0),
                                  shadowColor: const WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),
                                  surfaceTintColor:
                                      const WidgetStatePropertyAll(
                                        Colors.transparent,
                                      ),
                                  overlayColor: const WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                      side: const BorderSide(
                                        color: Color(0xFFD6E3F0),
                                        width: 0.8,
                                      ),
                                    ),
                                  ),
                                  padding: const WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  onTap(genre);
                                },
                                child: Text(
                                  genre,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          overlayColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: Text(
                          l10n.close,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F3A56),
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
  );
}

Future<void> showMoreDialog({
  required BuildContext context,
  required GlassTheme theme,
  required VoidCallback onPickMode,
  required VoidCallback onSettings,
  required VoidCallback onLogout,
}) {
  final l10n = AppLocalizations.of(context);

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
                  Text(
                    l10n.more,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassActionButton(
                    theme: buttonTheme,
                    icon: Icons.settings_outlined,
                    label: l10n.settings,
                    onPressed: () {
                      Navigator.pop(context);
                      onSettings();
                    },
                  ),
                  const SizedBox(height: 8),
                  GlassActionButton(
                    theme: buttonTheme,
                    icon: Icons.logout,
                    label: l10n.logout,
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
                      l10n.close,
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
