// glass_app_bar.dart

import 'package:flutter/material.dart';
import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_container.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final Widget? leading;
  final GlassTheme theme;

  const GlassAppBar({
    super.key,
    required this.title,
    required this.actions,
    required this.theme,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: GlassContainer(
        theme: theme,
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            if (leading != null) leading!,
            if (leading != null) const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  height: 1.1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}
