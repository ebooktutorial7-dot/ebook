// lib/widgets/glass/glass_action_button.dart

import 'package:flutter/material.dart';
import 'package:ebook_tutorial_app/theme/glass_theme.dart';

class GlassActionButton extends StatelessWidget {
  final GlassTheme theme;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const GlassActionButton({
    super.key,
    required this.theme,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          backgroundColor:
              theme.reduceTransparency
                  ? Colors.blueGrey.shade50
                  : Colors.white.withValues(alpha: theme.surfaceOpacity),
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.white.withValues(alpha: theme.borderOpacity),
              width: 1,
            ),
          ),
        ).merge(
          // ✅ 눌림 / 그림자 / 오버레이 제거
          ButtonStyle(
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, color: Colors.black87, size: 17),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
