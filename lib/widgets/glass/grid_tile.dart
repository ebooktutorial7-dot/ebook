// grid_tile.dart
import 'package:flutter/material.dart';
import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_container.dart';

class GridTileGlass extends StatelessWidget {
  final GlassTheme theme;
  final String title;
  final String preview;
  final bool selected;
  final bool dragging;
  final bool dragTargetHighlight;

  const GridTileGlass({
    super.key,
    required this.theme,
    required this.title,
    required this.preview,
    required this.selected,
    required this.dragging,
    required this.dragTargetHighlight,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      theme: theme,
      borderRadius: 18,
      solidFallback: selected || dragTargetHighlight,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: dragging ? 0.95 : 1.0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: dragging ? 1.03 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border:
                  dragTargetHighlight
                      ? Border.all(color: Colors.blueAccent, width: 2)
                      : null,
            ),
            child: Column(
              children: [
                if (selected)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 20,
                      color: Colors.blue,
                    ),
                  )
                else
                  const Icon(Icons.book, size: 50, color: Color(0xFF2874A6)),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.blue.shade800 : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    preview,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(
                      color: selected ? Colors.blueGrey : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!selected && dragTargetHighlight)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.place,
                      size: 16,
                      color: Colors.blueAccent,
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
