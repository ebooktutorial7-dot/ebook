import 'package:flutter/material.dart';

enum PenKind { pen, marker, highlighter, pencil }

enum EraserMode { drawOnly, coverAll }

class Stroke {
  final List<Offset> points;
  final double width;
  final Color color;
  final bool erasing;
  final PenKind kind;
  final bool eraseCoversAll;
  Path? _cachedPath;

  Stroke({
    required this.points,
    required this.width,
    required this.color,
    required this.erasing,
    required this.kind,
    required this.eraseCoversAll,
  });

  void addPoint(Offset p) {
    points.add(p);
    _cachedPath = null;
  }

  Path get path {
    final cached = _cachedPath;
    if (cached != null) return cached;
    final p = Path();
    if (points.isEmpty) return p;
    p.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final pt = points[i];
      p.lineTo(pt.dx, pt.dy);
    }
    _cachedPath = p;
    return p;
  }

  static int _packColor(Color c) {
    final ai = (c.a * 255.0).round() & 0xff;
    final ri = (c.r * 255.0).round() & 0xff;
    final gi = (c.g * 255.0).round() & 0xff;
    final bi = (c.b * 255.0).round() & 0xff;
    return (ai << 24) | (ri << 16) | (gi << 8) | bi;
  }

  Map<String, dynamic> toJson() {
    return {
      'pts': points.map((o) => [o.dx, o.dy]).toList(growable: false),
      'w': width,
      'c': _packColor(color),
      'e': erasing,
      'k': kind.index,
      'ca': eraseCoversAll,
    };
  }

  static Stroke fromJson(Map<String, dynamic> m) {
    final pts = (m['pts'] as List)
        .map((e) => Offset((e as List)[0] as double, (e)[1] as double))
        .toList(growable: true);
    return Stroke(
      points: pts,
      width: (m['w'] as num).toDouble(),
      color: Color(m['c'] as int),
      erasing: m['e'] as bool,
      kind: PenKind.values[(m['k'] as int)],
      eraseCoversAll: m['ca'] as bool,
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final double scrollOffset;

  const DrawingPainter({
    required this.strokes,
    required this.scrollOffset,
    super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.translate(0, -scrollOffset);
    for (final s in strokes) {
      final paint =
          Paint()
            ..color = s.color
            ..strokeWidth = s.width
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round;
      if (s.erasing) {
        if (s.eraseCoversAll) {
          paint.blendMode = BlendMode.srcOver;
          paint.color = Colors.white;
        } else {
          paint.blendMode = BlendMode.clear;
        }
      } else {
        if (s.kind == PenKind.pencil) {
          paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
        }
      }
      canvas.drawPath(s.path, paint);
    }
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) =>
      oldDelegate.strokes != strokes ||
      oldDelegate.scrollOffset != scrollOffset;
}
