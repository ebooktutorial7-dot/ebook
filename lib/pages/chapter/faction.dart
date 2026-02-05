// faction.dart

import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'dart:ui' as ui;
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:ebook_tutorial_app/theme/glass_theme.dart';

import 'package:ebook_tutorial_app/utils/iterable_extensions.dart';
import 'package:isar/isar.dart';
import 'package:ebook_tutorial_app/pages/chapter/world_seat_isar.dart';

class _GlassTextEditDialog extends StatefulWidget {
  final String title;
  final String initial;
  final String hint;
  final int maxLines;

  const _GlassTextEditDialog({
    required this.title,
    required this.initial,
    required this.hint,
    required this.maxLines,
  });

  @override
  State<_GlassTextEditDialog> createState() => _GlassTextEditDialogState();
}

class _GlassTextEditDialogState extends State<_GlassTextEditDialog> {
  late final TextEditingController _c;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initial);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool multiline = widget.maxLines > 1;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: 230,
              padding: const EdgeInsets.fromLTRB(26, 24, 26, 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 33, 58, 83),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _c,
                    focusNode: _focus,
                    autofocus: false,
                    maxLines: widget.maxLines,
                    minLines: multiline ? 3 : 1,
                    textAlign: TextAlign.center,
                    textInputAction:
                        multiline
                            ? TextInputAction.newline
                            : TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 114, 142, 169),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(
                        0,
                        12,
                        0,
                        multiline ? 12 : 15,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 169, 215, 255),
                          width: 1,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 90, 183, 255),
                          width: 1.0,
                        ),
                      ),
                    ),
                    onSubmitted:
                        multiline
                            ? null
                            : (_) => Navigator.pop(context, _c.text.trim()),
                  ),

                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color.fromARGB(255, 90, 183, 255),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              '취소',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 70, 175, 255),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => Navigator.pop(context, _c.text.trim()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F3A56),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              '저장',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
  }
}

class _MinimalEdgeLabelDialog extends StatefulWidget {
  final String title;
  final String initial;
  final String hint;

  const _MinimalEdgeLabelDialog({
    required this.title,
    required this.initial,
    required this.hint,
  });

  @override
  State<_MinimalEdgeLabelDialog> createState() =>
      _MinimalEdgeLabelDialogState();
}

class _MinimalEdgeLabelDialogState extends State<_MinimalEdgeLabelDialog> {
  late final TextEditingController _c;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initial);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: 230,
              padding: const EdgeInsets.fromLTRB(26, 24, 26, 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 33, 58, 83),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _c,
                    focusNode: _focus,
                    maxLines: 1,
                    minLines: 1,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 114, 142, 169),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 15),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 169, 215, 255),
                          width: 1,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 90, 183, 255),
                          width: 1.0,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => Navigator.pop(context, _c.text.trim()),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color.fromARGB(255, 90, 183, 255),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              '취소',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 70, 175, 255),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => Navigator.pop(context, _c.text.trim()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F3A56),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              '저장',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
  }
}

SliderThemeData _blueThinSlider(BuildContext context) {
  return SliderTheme.of(context).copyWith(
    trackHeight: 2.0,
    activeTrackColor: const Color(0xFF169AFF),
    inactiveTrackColor: const Color(0xFF169AFF).withValues(alpha: 0.25),
    thumbColor: const Color(0xFF169AFF),
    overlayShape: SliderComponentShape.noOverlay,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),

    valueIndicatorColor: const Color.fromARGB(255, 90, 184, 255),
    valueIndicatorTextStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),
  );
}

const Color barrierBaseColor = Color(0xFF0F2238);

Future<T?> showDialogNoAnim<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierBaseColor.withValues(alpha: 0.21),
    transitionDuration: Duration.zero,
    pageBuilder: (ctx, a1, a2) => Builder(builder: builder),
    transitionBuilder: (ctx, a1, a2, child) => child,
  );
}

class ColorSheetResult {
  final int kind;
  final Color? color;

  const ColorSheetResult._(this.kind, this.color);
  const ColorSheetResult.cancel() : this._(0, null);
  const ColorSheetResult.apply(Color c) : this._(1, c);
}

String _hexFromColorRgb(Color c) {
  final int r = ((c.r) * 255.0).round() & 0xff;
  final int g = ((c.g) * 255.0).round() & 0xff;
  final int b = ((c.b) * 255.0).round() & 0xff;

  return '#'
      '${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
}

Future<ColorSheetResult> showPrettyWheelBottomSheet(
  BuildContext context, {
  required String title,
  required GlassTheme theme,
  required Color initial,
  double wheelSize = 190,
  bool showAlpha = false,
}) async {
  Color current = initial;

  return showModalBottomSheet<ColorSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder: (ctx) {
      final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
      final sheetBorder = Colors.white.withValues(alpha: theme.borderOpacity);

      Widget handle() => Center(
        child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      );

      Widget inputCard(StateSetter setState) => Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: current,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12, width: 1),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _hexFromColorRgb(current),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );

      Widget alphaCard(StateSetter setState) {
        final v = (current.a).clamp(0.0, 1.0);
        const double sliderW = 350;
        const double thumbR = 6;

        return Center(
          child: SizedBox(
            width: sliderW,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: thumbR),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '투명도',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text('${(v * 100).round()}%'),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 1.0,
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

      Widget wheelCard(StateSetter setState) => Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
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
              borderColor: Colors.black12,
            ),
          ),
        ),
      );

      Widget actions() => Row(
        children: [
          const Spacer(),
          TextButton(
            onPressed:
                () => Navigator.pop(ctx, const ColorSheetResult.cancel()),
            child: const Text('취소'),
          ),
          const SizedBox(width: 10),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 48, 79, 111),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed:
                () => Navigator.pop(ctx, ColorSheetResult.apply(current)),
            child: const Text(
              '적용',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              decoration: BoxDecoration(
                color: const ui.Color.fromARGB(70, 207, 232, 255),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                border: Border.all(color: sheetBorder, width: 1),
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
                          color: Color(0xFF1F3A56),
                        ),
                      ),
                      const SizedBox(height: 10),
                      inputCard(setState),
                      const SizedBox(height: 10),
                      wheelCard(setState),
                      if (showAlpha) ...[
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
      );
    },
  ).then((v) => v ?? const ColorSheetResult.cancel());
}

class DiagramDoc {
  final double canvasW;
  final double canvasH;
  final List<DiagramModel> diagrams;
  final List<EdgeModel> edges;

  DiagramDoc({
    required this.canvasW,
    required this.canvasH,
    required this.diagrams,
    required this.edges,
  });
}

class EdgeGeom {
  final Offset p1;
  final Offset p2;
  final Offset cp;
  const EdgeGeom(this.p1, this.p2, this.cp);
}

EdgeGeom computeEdgeGeom({
  required DiagramModel a,
  required DiagramModel b,
  required EdgeModel e,
}) {
  final aHint = e.fromFree ?? _anchorPointForDiagram(a, e.fromAnchor);
  final bHint = e.toFree ?? _anchorPointForDiagram(b, e.toAnchor);

  final a0 = _boundaryPointToward(a, aHint);
  final b0 = _boundaryPointToward(b, bHint);

  final arrowSize = 10.0 + e.style.width * 0.8;
  final arrowPad = arrowSize + 2.0;

  Offset p1 = a0;
  Offset p2 = b0;

  final dirA = (a0 - Offset(a.x, a.y));
  final dirB = (b0 - Offset(b.x, b.y));

  Offset unit(Offset v) {
    final len = v.distance;
    if (len <= 1e-9) return const Offset(1, 0);
    return Offset(v.dx / len, v.dy / len);
  }

  final fromIsAnchor = e.fromFree == null;
  final toIsAnchor = e.toFree == null;

  if (fromIsAnchor &&
      (e.style.arrowMode == ArrowMode.start ||
          e.style.arrowMode == ArrowMode.both)) {
    p1 = a0 + unit(dirA) * arrowPad;
  }
  if (toIsAnchor &&
      (e.style.arrowMode == ArrowMode.end ||
          e.style.arrowMode == ArrowMode.both)) {
    p2 = b0 + unit(dirB) * arrowPad;
  }

  final safeCurv = clampCurvatureForEdge(a: a, b: b, curvature: e.curvature);
  final cp = controlPointFromCurvature(p1, p2, safeCurv);
  return EdgeGeom(p1, p2, cp);
}

class DiagramModel {
  final String id;
  String name;
  double x;
  double y;
  double r;
  bool locked;
  String? imageUrl;
  DiagramShape shape;
  int? fillColor;
  String insideText;
  bool showInsideText;
  int? insideTextColor;

  DiagramModel({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.r,
    required this.locked,
    this.imageUrl,
    this.shape = DiagramShape.circle,
    this.fillColor,
    this.insideText = "",
    this.showInsideText = false,
    this.insideTextColor,
  });
}

enum DiagramShape { circle, roundedRect, rect, pentagon, hexagon }

IconData _shapeIcon(DiagramShape s) {
  switch (s) {
    case DiagramShape.circle:
      return Icons.circle_outlined;
    case DiagramShape.roundedRect:
      return Icons.rounded_corner;
    case DiagramShape.rect:
      return Icons.crop_square;
    case DiagramShape.pentagon:
      return Icons.change_history;
    case DiagramShape.hexagon:
      return Icons.hexagon_outlined;
  }
}

double _cross(Offset a, Offset b) => a.dx * b.dy - a.dy * b.dx;

Offset? _raySegmentIntersection({
  required Offset o,
  required Offset d,
  required Offset a,
  required Offset b,
}) {
  final s = b - a;
  final denom = _cross(d, s);
  if (denom.abs() < 1e-9) return null;

  final ao = a - o;
  final t = _cross(ao, s) / denom;
  final u = _cross(ao, d) / denom;

  if (t >= 0 && u >= 0 && u <= 1) {
    return o + d * t;
  }
  return null;
}

Offset _rayRectIntersection({
  required Offset center,
  required Offset dirUnit,
  required double halfW,
  required double halfH,
}) {
  final dx = dirUnit.dx;
  final dy = dirUnit.dy;

  double tx = double.infinity;
  double ty = double.infinity;

  if (dx.abs() > 1e-9) tx = halfW / dx.abs();
  if (dy.abs() > 1e-9) ty = halfH / dy.abs();

  final t = math.min(tx, ty);
  return center + dirUnit * t;
}

Offset _boundaryPointToward(DiagramModel n, Offset hint) {
  final center = Offset(n.x, n.y);
  final v = hint - center;

  Offset dir;
  final len = v.distance;
  if (len <= 1e-9) {
    dir = const Offset(1, 0);
  } else {
    dir = Offset(v.dx / len, v.dy / len);
  }

  switch (n.shape) {
    case DiagramShape.circle:
      return center + dir * n.r;

    case DiagramShape.rect:
    case DiagramShape.roundedRect:
      return _rayRectIntersection(
        center: center,
        dirUnit: dir,
        halfW: n.r,
        halfH: n.r,
      );

    case DiagramShape.pentagon:
    case DiagramShape.hexagon:
      final sides = (n.shape == DiagramShape.pentagon) ? 5 : 6;
      final poly = _regularPolygonVertices(
        center: center,
        radius: n.r,
        sides: sides,
      );

      Offset? best;
      double bestDist2 = double.infinity;

      for (int i = 0; i < poly.length; i++) {
        final a = poly[i];
        final b = poly[(i + 1) % poly.length];
        final hit = _raySegmentIntersection(o: center, d: dir, a: a, b: b);
        if (hit == null) continue;
        final d2 = (hit - center).distanceSquared;
        if (d2 < bestDist2) {
          bestDist2 = d2;
          best = hit;
        }
      }
      return best ?? (center + dir * n.r);
  }
}

Offset _anchorPointForDiagram(DiagramModel n, int anchorIndex) {
  final center = Offset(n.x, n.y);
  final a = anchorAngle(anchorIndex % kAnchorCount);
  final dir = Offset(math.cos(a), math.sin(a));

  switch (n.shape) {
    case DiagramShape.circle:
      return center + dir * n.r;

    case DiagramShape.rect:
    case DiagramShape.roundedRect:
      return _rayRectIntersection(
        center: center,
        dirUnit: dir,
        halfW: n.r,
        halfH: n.r,
      );

    case DiagramShape.pentagon:
    case DiagramShape.hexagon:
      final sides = (n.shape == DiagramShape.pentagon) ? 5 : 6;
      final poly = _regularPolygonVertices(
        center: center,
        radius: n.r,
        sides: sides,
      );

      Offset? best;
      double bestDist2 = double.infinity;

      for (int i = 0; i < poly.length; i++) {
        final a = poly[i];
        final b = poly[(i + 1) % poly.length];
        final hit = _raySegmentIntersection(o: center, d: dir, a: a, b: b);
        if (hit == null) continue;
        final d2 = (hit - center).distanceSquared;
        if (d2 < bestDist2) {
          bestDist2 = d2;
          best = hit;
        }
      }
      return best ?? (center + dir * n.r);
  }
}

List<Offset> _regularPolygonVertices({
  required Offset center,
  required double radius,
  required int sides,
}) {
  final pts = <Offset>[];
  const a0 = -math.pi / 2;
  for (int i = 0; i < sides; i++) {
    final a = a0 + (2 * math.pi) * (i / sides);
    pts.add(
      Offset(
        center.dx + math.cos(a) * radius,
        center.dy + math.sin(a) * radius,
      ),
    );
  }
  return pts;
}

Path _diagramShapePath(DiagramModel n) {
  final center = Offset(n.x, n.y);
  final r = n.r;

  switch (n.shape) {
    case DiagramShape.circle:
      return Path()..addOval(Rect.fromCircle(center: center, radius: r));

    case DiagramShape.rect:
      return Path()
        ..addRect(Rect.fromCenter(center: center, width: 2 * r, height: 2 * r));

    case DiagramShape.roundedRect:
      return Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 2 * r, height: 2 * r),
          const Radius.circular(14),
        ),
      );
    case DiagramShape.pentagon:
      return _regularPolygonPath(center: center, radius: r, sides: 5);

    case DiagramShape.hexagon:
      return _regularPolygonPath(center: center, radius: r, sides: 6);
  }
}

Path _regularPolygonPath({
  required Offset center,
  required double radius,
  required int sides,
}) {
  final path = Path();
  const a0 = -math.pi / 2;
  for (int i = 0; i < sides; i++) {
    final a = a0 + (2 * math.pi) * (i / sides);
    final p = Offset(
      center.dx + math.cos(a) * radius,
      center.dy + math.sin(a) * radius,
    );
    if (i == 0) {
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  path.close();
  return path;
}

enum ArrowMode { none, start, end, both }

class EdgeStyle {
  int color;
  double width;
  bool dashed;
  ArrowMode arrowMode;

  EdgeStyle({
    required this.color,
    required this.width,
    required this.dashed,
    required this.arrowMode,
  });
}

class EdgeLabelPlacement {
  double t;
  double dx;
  double dy;

  EdgeLabelPlacement({required this.t, required this.dx, required this.dy});

  Offset get offset => Offset(dx, dy);
}

class EdgeModel {
  final String id;
  final String from;
  final String to;

  int fromAnchor;
  int toAnchor;

  Offset? fromFree;
  Offset? toFree;

  String label;
  double curvature;
  EdgeStyle style;
  EdgeLabelPlacement labelPlacement;

  EdgeModel({
    required this.id,
    required this.from,
    required this.to,
    required this.fromAnchor,
    required this.toAnchor,
    this.fromFree,
    this.toFree,
    required this.label,
    required this.curvature,
    required this.style,
    required this.labelPlacement,
  });
}

class TempLink {
  final String fromDiagramId;
  final int fromAnchorIndex;
  Offset toPoint;

  TempLink({
    required this.fromDiagramId,
    required this.fromAnchorIndex,
    required this.toPoint,
  });
}

const int kAnchorCount = 8;

double anchorAngle(int i) => (2 * math.pi) * (i / kAnchorCount);

int anchorIndexFromPoint({required Offset center, required Offset point}) {
  final dx = point.dx - center.dx;
  final dy = point.dy - center.dy;

  var angle = math.atan2(dy, dx);
  if (angle < 0) angle += math.pi * 2;

  const unit = (math.pi * 2) / kAnchorCount;
  final idx = (angle / unit).round() % kAnchorCount;
  return idx;
}

Offset anchorPoint(Offset center, double r, int anchorIndex) {
  final a = anchorAngle(anchorIndex % kAnchorCount);
  return Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r);
}

double _diagramSafeRadius(DiagramModel n) {
  switch (n.shape) {
    case DiagramShape.circle:
      return n.r;
    case DiagramShape.rect:
    case DiagramShape.roundedRect:
    case DiagramShape.pentagon:
    case DiagramShape.hexagon:
      return n.r * 0.9;
  }
}

double clampCurvatureForEdge({
  required DiagramModel a,
  required DiagramModel b,
  required double curvature,
}) {
  final p1 = Offset(a.x, a.y);
  final p2 = Offset(b.x, b.y);

  final dist = (p2 - p1).distance.clamp(1.0, 999999.0);

  final ra = _diagramSafeRadius(a);
  final rb = _diagramSafeRadius(b);

  final snapDist = ra + rb + 28.0;

  if (dist <= snapDist) return 0.0;

  final minSpan = ra + rb + 24.0;
  final usable = math.max(0.0, dist - minSpan);
  final maxCurv = (usable / dist) * 2.7;
  return curvature.clamp(-maxCurv, maxCurv);
}

Offset quadBezierPoint(Offset p0, Offset p1, Offset p2, double t) {
  final mt = 1 - t;
  final x = mt * mt * p0.dx + 2 * mt * t * p1.dx + t * t * p2.dx;
  final y = mt * mt * p0.dy + 2 * mt * t * p1.dy + t * t * p2.dy;
  return Offset(x, y);
}

Offset quadBezierTangent(Offset p0, Offset p1, Offset p2, double t) {
  final mt = 1 - t;
  return (p1 - p0) * (2 * mt) + (p2 - p1) * (2 * t);
}

Offset normalFromTangent(Offset tangent) {
  final len = tangent.distance;
  if (len <= 1e-6) return const Offset(0, -1);
  final tx = tangent.dx / len;
  final ty = tangent.dy / len;
  return Offset(-ty, tx);
}

Offset quadBezierTangentAtStart(Offset p0, Offset p1) => (p1 - p0) * 2.0;
Offset quadBezierTangentAtEnd(Offset p1, Offset p2) => (p2 - p1) * 2.0;

Offset controlPointFromCurvature(Offset p1, Offset p2, double curvature) {
  final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
  final vx = p2.dx - p1.dx;
  final vy = p2.dy - p1.dy;
  final len = math.sqrt(vx * vx + vy * vy).clamp(1.0, 999999.0);
  final nx = -vy / len;
  final ny = vx / len;
  final controlDist = (len * 0.55) * curvature;
  return Offset(mid.dx + nx * controlDist, mid.dy + ny * controlDist);
}

double getScaleFromMatrix(Matrix4 m) => m.storage[0];

double _distPointToSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final ap = p - a;
  final ab2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (ab2 <= 1e-9) return (p - a).distance;
  final t = ((ap.dx * ab.dx) + (ap.dy * ab.dy)) / ab2;
  final tt = t.clamp(0.0, 1.0);
  final proj = Offset(a.dx + ab.dx * tt, a.dy + ab.dy * tt);
  return (p - proj).distance;
}

class FactionPage extends StatefulWidget {
  final Isar isar;
  final String documentId;

  const FactionPage({super.key, required this.isar, required this.documentId});

  @override
  State<FactionPage> createState() => _FactionPageState();
}

class _GlassActionDialog extends StatelessWidget {
  final List<_GlassActionItem> items;

  const _GlassActionDialog({required this.items});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: 200,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final it in items) ...[
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(context);
                        it.onTap();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              it.icon,
                              size: 20,
                              color: const Color(0xFF1F3A56),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                it.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F3A56),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (it != items.last)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: const Color.fromARGB(
                          255,
                          169,
                          215,
                          255,
                        ).withValues(alpha: 0.35),
                      ),
                  ],
                  const SizedBox(height: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color.fromARGB(255, 90, 183, 255),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        '닫기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 70, 175, 255),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassActionItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _GlassActionItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class _FactionPageState extends State<FactionPage> {
  late final FactionRepo _repo;

  late DiagramDoc doc;

  Future<void> _saveChain = Future.value();

  Timer? _saveDebounce;

  Future<void> _queueSave({bool immediate = false}) {
    if (!immediate) {
      _saveDebounce?.cancel();
      _saveDebounce = Timer(const Duration(milliseconds: 250), () {
        _queueSave(immediate: true);
      });
      return _saveChain;
    }

    _saveDebounce?.cancel();
    final snap = _cloneDoc(doc);

    _saveChain = _saveChain.then((_) async {
      try {
        await _repo.save(snap);
      } catch (e, st) {
        debugPrint('Faction save failed: $e\n$st');
      }
    });

    return _saveChain;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        _saveDebounce?.cancel();
        await _queueSave(immediate: true);

        if (context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: _buildScaffold(context),
    );
  }

  DiagramDoc _cloneDoc(DiagramDoc src) {
    return DiagramDoc(
      canvasW: src.canvasW,
      canvasH: src.canvasH,
      diagrams:
          src.diagrams
              .map(
                (n) => DiagramModel(
                  id: n.id,
                  name: n.name,
                  x: n.x,
                  y: n.y,
                  r: n.r,
                  locked: n.locked,
                  imageUrl: n.imageUrl,
                  shape: n.shape,
                  fillColor: n.fillColor,
                  insideText: n.insideText,
                  showInsideText: n.showInsideText,
                  insideTextColor: n.insideTextColor,
                ),
              )
              .toList(),
      edges:
          src.edges
              .map(
                (e) => EdgeModel(
                  id: e.id,
                  from: e.from,
                  to: e.to,
                  fromAnchor: e.fromAnchor,
                  toAnchor: e.toAnchor,
                  fromFree:
                      e.fromFree == null
                          ? null
                          : Offset(e.fromFree!.dx, e.fromFree!.dy),
                  toFree:
                      e.toFree == null
                          ? null
                          : Offset(e.toFree!.dx, e.toFree!.dy),
                  label: e.label,
                  curvature: e.curvature,
                  style: EdgeStyle(
                    color: e.style.color,
                    width: e.style.width,
                    dashed: e.style.dashed,
                    arrowMode: e.style.arrowMode,
                  ),
                  labelPlacement: EdgeLabelPlacement(
                    t: e.labelPlacement.t,
                    dx: e.labelPlacement.dx,
                    dy: e.labelPlacement.dy,
                  ),
                ),
              )
              .toList(),
    );
  }

  @override
  void initState() {
    super.initState();

    _repo = FactionRepo(widget.isar, widget.documentId);

    doc = DiagramDoc(canvasW: 2000, canvasH: 1400, diagrams: [], edges: []);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final loaded = await _repo.loadOrCreate();
      if (!mounted) return;

      setState(() {
        doc = loaded;
        _bumpGeom();
      });

      await _precacheDiagramImages();
    });
  }

  final GlobalKey<_CanvasState> _canvasKey = GlobalKey<_CanvasState>();

  final ImagePicker _picker = ImagePicker();

  void _onDiagramSizeChanged(double v) {
    final n =
        (selectedDiagramId == null) ? null : _getDiagram(selectedDiagramId!);
    if (n == null) return;
    setState(() {
      n.r = v.clamp(20.0, 100.0);
      _bumpGeom();
    });
    _queueSave();
  }

  Future<void> _openEdgeColorWheel(String edgeId) async {
    final e = _getEdge(edgeId);
    if (e == null) return;

    final glass =
        Theme.of(context).extension<GlassTheme>() ??
        GlassTheme.fromFlags(reduceTransparency: false);

    final result = await showPrettyWheelBottomSheet(
      context,
      title: '선 색상',
      theme: glass,
      initial: Color(e.style.color),
      wheelSize: 190,
      showAlpha: false,
    );

    if (!mounted) return;
    if (result.kind != 1) return;

    setState(() {
      e.style.color = result.color!.toARGB32();
      _bumpGeom();
    });
    _queueSave();
  }

  Future<void> _pickDiagramImage(String diagramId) async {
    final n = _getDiagram(diagramId);
    if (n == null) return;

    final XFile? x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1200,
    );
    if (x == null) return;

    setState(() {
      n.imageUrl = x.path;
      _bumpGeom();
    });
    _queueSave();
  }

  Future<void> _openDiagramActionSheet(String diagramId) async {
    final n = _getDiagram(diagramId);
    if (n == null) return;

    final hasImage = (n.imageUrl != null && n.imageUrl!.trim().isNotEmpty);
    final hasColor = (n.fillColor != null);

    final items = <_GlassActionItem>[];

    if (hasImage) {
      items.addAll([
        _GlassActionItem(
          icon: Icons.photo_library_outlined,
          title: "사진 교체",
          onTap: () async => await _pickDiagramImage(diagramId),
        ),
        _GlassActionItem(
          icon: Icons.close,
          title: "사진 삭제",
          onTap: () {
            setState(() {
              n.imageUrl = null;
              _bumpGeom();
            });
            _queueSave();
          },
        ),
      ]);
    } else {
      items.add(
        _GlassActionItem(
          icon: Icons.add_a_photo,
          title: "사진 추가",
          onTap: () async => await _pickDiagramImage(diagramId),
        ),
      );
    }

    if (hasColor) {
      items.addAll([
        _GlassActionItem(
          icon: Icons.palette_outlined,
          title: "색상 교체",
          onTap: () async => await _openDiagramColorSheet(diagramId),
        ),
        _GlassActionItem(
          icon: Icons.close,
          title: "색상 삭제",
          onTap: () {
            setState(() {
              n.fillColor = null;
              _bumpGeom();
            });
            _queueSave();
          },
        ),
      ]);
    } else {
      items.add(
        _GlassActionItem(
          icon: Icons.format_color_fill,
          title: "색상 추가",
          onTap: () async => await _openDiagramColorSheet(diagramId),
        ),
      );
    }

    items.add(
      _GlassActionItem(
        icon: Icons.text_fields,
        title: (n.insideText.trim().isEmpty) ? "텍스트 추가" : "텍스트 교체",
        onTap: () async => await _editDiagramInsideText(diagramId),
      ),
    );
    final hasText = n.insideText.trim().isNotEmpty;

    if (hasText) {
      items.addAll([
        _GlassActionItem(
          icon: Icons.format_color_text,
          title: (n.insideTextColor == null) ? "텍스트 색상 추가" : "텍스트 색상 교체",
          onTap: () async => await _openDiagramInsideTextColorSheet(diagramId),
        ),
        if (n.insideTextColor != null)
          _GlassActionItem(
            icon: Icons.close,
            title: "텍스트 색상 삭제",
            onTap: () {
              setState(() {
                n.insideTextColor = null;
                _bumpGeom();
              });
              _queueSave();
            },
          ),
      ]);
    }

    if (n.insideText.trim().isNotEmpty) {
      items.add(
        _GlassActionItem(
          icon: Icons.close,
          title: "텍스트 삭제",
          onTap: () {
            setState(() {
              n.insideText = "";
              n.showInsideText = false;
              n.insideTextColor = null;
              _bumpGeom();
            });
            _queueSave();
          },
        ),
      );
    }

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierBaseColor.withValues(alpha: 0.21),
      transitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => _GlassActionDialog(items: items),
      transitionBuilder: (_, __, ___, child) => child,
    );
  }

  Future<void> _openDiagramInsideTextColorSheet(String diagramId) async {
    final n = _getDiagram(diagramId);
    if (n == null) return;
    if (n.insideText.trim().isEmpty) return;

    final hasImage = n.imageUrl != null && n.imageUrl!.trim().isNotEmpty;

    final initial =
        (n.insideTextColor != null)
            ? Color(n.insideTextColor!)
            : (hasImage ? Colors.white : Colors.black87);

    final glass =
        Theme.of(context).extension<GlassTheme>() ??
        GlassTheme.fromFlags(reduceTransparency: false);

    final result = await showPrettyWheelBottomSheet(
      context,
      title: '텍스트 색상',
      theme: glass,
      initial: initial,
      wheelSize: 190,
      showAlpha: false,
    );

    if (!mounted) return;
    if (result.kind != 1) return;

    setState(() {
      n.insideTextColor = result.color!.toARGB32();
      _bumpGeom();
    });
    _queueSave();
  }

  Future<void> _openDiagramColorSheet(String diagramId) async {
    final n = _getDiagram(diagramId);
    if (n == null) return;

    final initial =
        (n.fillColor != null) ? Color(n.fillColor!) : const Color(0xFFE3F2FD);

    final glass =
        Theme.of(context).extension<GlassTheme>() ??
        GlassTheme.fromFlags(reduceTransparency: false);

    final result = await showPrettyWheelBottomSheet(
      context,
      title: '도형 색상',
      theme: glass,
      initial: initial,
      wheelSize: 190,
      showAlpha: false,
    );

    if (!mounted) return;
    if (result.kind != 1) return;

    setState(() {
      n.fillColor = result.color!.toARGB32();
      _bumpGeom();
    });
    _queueSave();
  }

  Future<void> _editDiagramInsideText(String diagramId) async {
    final n = _getDiagram(diagramId);
    if (n == null) return;

    final result = await showDialogNoAnim<String>(
      context: context,
      builder:
          (_) => _GlassTextEditDialog(
            title: "텍스트 추가",
            initial: n.insideText,
            hint: "도형 안에 표시할 텍스트",
            maxLines: 1,
          ),
    );

    if (!mounted || result == null) return;

    setState(() {
      n.insideText = result.trim();
      n.showInsideText = n.insideText.isNotEmpty;
      _bumpGeom();
    });
    _queueSave();
  }

  void _cycleSelectedDiagramShape() {
    if (selectedDiagramId == null) return;
    final n = _getDiagram(selectedDiagramId!);
    if (n == null) return;

    setState(() {
      const values = DiagramShape.values;
      final i = values.indexOf(n.shape);
      n.shape = values[(i + 1) % values.length];
      _bumpGeom();
    });
    _queueSave();
  }

  String? selectedDiagramId;
  String? selectedEdgeId;

  TempLink? tempLink;

  bool showGrid = true;

  int _geomRev = 0;

  final _EdgeHitCache _edgeHitCache = _EdgeHitCache();

  void _bumpGeom() {
    _geomRev++;
    _edgeHitCache.clear();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _queueSave(immediate: true);
    super.dispose();
  }

  Future<void> _precacheDiagramImages() async {
    for (final n in doc.diagrams) {
      final p = n.imageUrl;
      if (p == null || p.trim().isEmpty) continue;

      try {
        final provider =
            (p.startsWith("http://") || p.startsWith("https://"))
                ? NetworkImage(p)
                : FileImage(File(p)) as ImageProvider;

        await precacheImage(provider, context);
      } catch (_) {}
    }
  }

  DiagramModel? _getDiagram(String id) {
    for (final n in doc.diagrams) {
      if (n.id == id) return n;
    }
    return null;
  }

  EdgeModel? _getEdge(String id) {
    for (final e in doc.edges) {
      if (e.id == id) return e;
    }
    return null;
  }

  String _newId(String prefix) {
    final ts = DateTime.now().microsecondsSinceEpoch.toString();
    return "$prefix$ts";
  }

  void _addDiagram() {
    final id = _newId("n");
    const r = 35.0;

    Rect view =
        _canvasKey.currentState?.visibleSceneRect() ??
        Rect.fromLTWH(0, 0, doc.canvasW, doc.canvasH);

    view = Rect.fromLTRB(
      view.left.clamp(0.0, doc.canvasW),
      view.top.clamp(0.0, doc.canvasH),
      view.right.clamp(0.0, doc.canvasW),
      view.bottom.clamp(0.0, doc.canvasH),
    );

    if (view.width < r * 2 + 10 || view.height < r * 2 + 10) {
      view = Rect.fromLTWH(0, 0, doc.canvasW, doc.canvasH);
    }

    Offset clampInsideView(Offset p) {
      final x = p.dx.clamp(view.left + r, view.right - r);
      final y = p.dy.clamp(view.top + r, view.bottom - r);
      return Offset(x, y);
    }

    bool collides(Offset p) {
      for (final n in doc.diagrams) {
        final minDist = (n.r + r) + 12.0;
        if ((Offset(n.x, n.y) - p).distanceSquared < minDist * minDist) {
          return true;
        }
      }
      return false;
    }

    Offset base;
    final sel =
        (selectedDiagramId != null) ? _getDiagram(selectedDiagramId!) : null;

    if (sel != null) {
      base = Offset(sel.x + sel.r + r + 18, sel.y - (sel.r * 0.2));
    } else {
      base =
          _canvasKey.currentState?.sceneCenter() ??
          Offset(view.center.dx, view.center.dy);
    }
    base = clampInsideView(base);
    Offset pickSpot() {
      if (!collides(base)) return base;

      const rings = 22;
      const pointsPerRing = 20;
      const step = 20.0;

      for (int ring = 1; ring <= rings; ring++) {
        final radius = (r * 2.2) + step * ring;
        for (int i = 0; i < pointsPerRing; i++) {
          final a = (2 * math.pi) * (i / pointsPerRing);
          final cand = clampInsideView(
            Offset(
              base.dx + math.cos(a) * radius,
              base.dy + math.sin(a) * radius,
            ),
          );
          if (!collides(cand)) return cand;
        }
      }
      final center = clampInsideView(view.center);
      if (!collides(center)) return center;
      return base;
    }

    final spot = pickSpot();

    final n = DiagramModel(
      id: id,
      name: "New",
      x: spot.dx,
      y: spot.dy,
      r: r,
      locked: false,
    );

    setState(() {
      doc.diagrams.add(n);
      selectedDiagramId = id;
      selectedEdgeId = null;
      _bumpGeom();
    });
    _queueSave();
  }

  void _toggleLockSelected() {
    if (selectedDiagramId == null) return;
    final n = _getDiagram(selectedDiagramId!);
    if (n == null) return;
    setState(() {
      n.locked = !n.locked;
      _bumpGeom();
    });
    _queueSave();
  }

  void _deleteSelectedDiagram() {
    if (selectedDiagramId == null) return;
    final id = selectedDiagramId!;
    setState(() {
      doc.diagrams.removeWhere((n) => n.id == id);
      doc.edges.removeWhere((e) => e.from == id || e.to == id);
      selectedDiagramId = null;
      selectedEdgeId = null;
      tempLink = null;
      _bumpGeom();
    });
    _queueSave();
  }

  void _deleteSelectedEdge() {
    if (selectedEdgeId == null) return;
    setState(() {
      doc.edges.removeWhere((e) => e.id == selectedEdgeId);
      selectedEdgeId = null;
      _bumpGeom();
    });
    _queueSave();
  }

  void _onDiagramTapped(DiagramModel diagram) {
    setState(() {
      selectedDiagramId = diagram.id;
      selectedEdgeId = null;
    });

    _openDiagramActionSheet(diagram.id);
  }

  Future<String?> _promptDiagramName({required String initial}) {
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierBaseColor.withValues(alpha: 0.21),

      transitionDuration: Duration.zero,

      pageBuilder: (ctx, a1, a2) {
        return _MinimalEdgeLabelDialog(
          title: "Name",
          initial: initial,
          hint: "이름",
        );
      },

      transitionBuilder: (ctx, anim, sec, child) {
        return child;
      },
    ).then((v) => v?.trim());
  }

  Future<void> _renameDiagram(String diagramId) async {
    final n = _getDiagram(diagramId);
    if (n == null) return;

    final result = await _promptDiagramName(initial: n.name);
    if (!mounted || result == null || result.trim().isEmpty) return;

    setState(() {
      n.name = result.trim();
      selectedDiagramId = diagramId;
      selectedEdgeId = null;
      _bumpGeom();
    });
    _queueSave();
  }

  Future<void> _renameSelectedDiagram() async {
    if (selectedDiagramId == null) return;
    final n = _getDiagram(selectedDiagramId!);
    if (n == null) return;

    final result = await _promptDiagramName(initial: n.name);
    if (!mounted || result == null || result.trim().isEmpty) return;

    setState(() {
      n.name = result.trim();
      _bumpGeom();
    });
    _queueSave();
  }

  void _startLinkDrag({
    required String fromDiagramId,
    required int fromAnchorIndex,
    required Offset sceneStartPoint,
  }) {
    setState(() {
      tempLink = TempLink(
        fromDiagramId: fromDiagramId,
        fromAnchorIndex: fromAnchorIndex,
        toPoint: sceneStartPoint,
      );
      selectedDiagramId = fromDiagramId;
      selectedEdgeId = null;
    });
  }

  void _updateLinkDrag(Offset scenePoint) {
    if (tempLink == null) return;
    setState(() {
      tempLink!.toPoint = scenePoint;
      _bumpGeom();
    });
  }

  Future<void> _endLinkDrag(Offset sceneDropPoint) async {
    if (tempLink == null) return;

    final fromId = tempLink!.fromDiagramId;
    final fromAnchor = tempLink!.fromAnchorIndex;
    final toDiagram = _hitTestDiagramByShape(
      sceneDropPoint,
      excludeDiagramId: fromId,
    );

    if (toDiagram == null) {
      setState(() => tempLink = null);
      return;
    }

    final toAnchor = anchorIndexFromPoint(
      center: Offset(toDiagram.x, toDiagram.y),
      point: sceneDropPoint,
    );

    final newEdge = EdgeModel(
      id: _newId("e"),
      from: fromId,
      to: toDiagram.id,
      fromAnchor: fromAnchor,
      toAnchor: toAnchor,
      label: "관계",
      curvature: 0.0,
      style: EdgeStyle(
        color:
            const Color.fromARGB(
              255,
              255,
              230,
              128,
            ).withValues(alpha: 0.95).toARGB32(),
        width: 1.5,
        dashed: false,
        arrowMode: ArrowMode.end,
      ),
      labelPlacement: EdgeLabelPlacement(t: 0.5, dx: 0.0, dy: -17.0),
    );

    setState(() {
      doc.edges.add(newEdge);
      selectedDiagramId = null;
      selectedEdgeId = newEdge.id;
      tempLink = null;
      _bumpGeom();
    });
    _queueSave();
    final label = await _promptEdgeLabel(initial: newEdge.label);
    if (!mounted) return;

    if (label != null) {
      setState(() {
        newEdge.label = label.trim();
        _bumpGeom();
      });
      _queueSave();
    }
  }

  DiagramModel? _hitTestDiagramByShape(
    Offset scenePoint, {
    required String excludeDiagramId,
  }) {
    for (final n in doc.diagrams) {
      if (n.id == excludeDiagramId) continue;
      final path = _diagramShapePath(n);

      if (path.contains(scenePoint)) return n;
    }
    return null;
  }

  static const Color barrierBaseColor = Color(0xFF0F2238);

  Future<String?> _promptEdgeLabel({required String initial}) {
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierBaseColor.withValues(alpha: 0.21),
      transitionDuration: Duration.zero,
      transitionBuilder: (_, __, ___, child) => child,
      pageBuilder: (ctx, a1, a2) {
        return _MinimalEdgeLabelDialog(
          title: "관계",
          initial: initial,
          hint: "예: 동맹, 적대, 가족",
        );
      },
    ).then((v) => v?.trim());
  }

  void _onCanvasTapScene(Offset scenePoint, {double? scale}) {
    final hitEdgeId = _hitTestEdge(scenePoint, scale: scale ?? 1.0);

    setState(() {
      if (hitEdgeId != null) {
        selectedEdgeId = hitEdgeId;
        selectedDiagramId = null;
      } else {
        selectedEdgeId = null;
        selectedDiagramId = null;
      }
    });
  }

  String? _hitTestEdge(Offset scenePoint, {required double scale}) {
    double bestD = double.infinity;
    String? bestId;
    double thresholdFor(EdgeModel e) =>
        (math.max(12.0, e.style.width * 4.0)) / scale;

    for (final e in doc.edges) {
      final cached = _edgeHitCache.get(e.id, _geomRev);
      _EdgeHitCacheEntry entry;

      if (cached != null) {
        entry = cached;
      } else {
        final a = _getDiagram(e.from);
        final b = _getDiagram(e.to);
        if (a == null || b == null) continue;
        final g = computeEdgeGeom(a: a, b: b, e: e);
        final p1 = g.p1;
        final p2 = g.p2;
        final cp = g.cp;
        const steps = 16;
        final poly = <Offset>[];
        for (int i = 0; i <= steps; i++) {
          final t = i / steps;
          poly.add(quadBezierPoint(p1, cp, p2, t));
        }
        double minX = poly.first.dx, maxX = poly.first.dx;
        double minY = poly.first.dy, maxY = poly.first.dy;

        for (final p in poly.skip(1)) {
          if (p.dx < minX) minX = p.dx;
          if (p.dx > maxX) maxX = p.dx;
          if (p.dy < minY) minY = p.dy;
          if (p.dy > maxY) maxY = p.dy;
        }

        final pad = math.max(18.0, e.style.width * 6.0);
        final bnd = Rect.fromLTRB(minX, minY, maxX, maxY).inflate(pad);

        entry = _EdgeHitCacheEntry(
          id: e.id,
          rev: _geomRev,
          bounds: bnd,
          poly: poly,
          strokeWidth: e.style.width,
        );
        _edgeHitCache.put(entry);
      }
      if (!entry.bounds.contains(scenePoint)) continue;
      for (int i = 1; i < entry.poly.length; i++) {
        final d = _distPointToSegment(
          scenePoint,
          entry.poly[i - 1],
          entry.poly[i],
        );
        if (d < bestD) {
          bestD = d;
          bestId = e.id;
        }
      }
    }

    if (bestId == null) return null;
    final bestEdge = _getEdge(bestId);
    if (bestEdge == null) return null;

    final th = thresholdFor(bestEdge);
    return bestD <= th ? bestId : null;
  }

  Future<void> _editEdgeLabel(String edgeId) async {
    final e = _getEdge(edgeId);
    if (e == null) return;
    final result = await _promptEdgeLabel(initial: e.label);
    if (!mounted) return;
    if (result == null) return;
    setState(() {
      e.label = result.trim();
      _bumpGeom();
    });
    _queueSave();
  }

  void _onLabelLongPressDrag(String edgeId, Offset scenePointer) {
    final e = _getEdge(edgeId);
    if (e == null) return;
    final a = _getDiagram(e.from);
    final b = _getDiagram(e.to);
    if (a == null || b == null) return;
    final g = computeEdgeGeom(a: a, b: b, e: e);
    final p1 = g.p1;
    final p2 = g.p2;
    final cp = g.cp;

    double bestT = e.labelPlacement.t;
    double bestD = double.infinity;
    Offset bestP = quadBezierPoint(p1, cp, p2, bestT);

    const steps = 70;
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final p = quadBezierPoint(p1, cp, p2, t);
      final d = (p - scenePointer).distanceSquared;
      if (d < bestD) {
        bestD = d;
        bestT = t;
        bestP = p;
      }
    }

    final off = scenePointer - bestP;

    setState(() {
      e.labelPlacement.t = bestT;
      e.labelPlacement.dx = off.dx;
      e.labelPlacement.dy = off.dy;
      _bumpGeom();
    });
  }

  void _onCurvatureChanged(double v) {
    final e = (selectedEdgeId == null) ? null : _getEdge(selectedEdgeId!);
    if (e == null) return;
    setState(() {
      e.curvature = v.clamp(-3.5, 3.5);
      _bumpGeom();
    });
    _queueSave();
  }

  void _onWidthChanged(double v) {
    final e = (selectedEdgeId == null) ? null : _getEdge(selectedEdgeId!);
    if (e == null) return;
    setState(() {
      e.style.width = v.clamp(0.3, 10.0);
      _bumpGeom();
    });
    _queueSave();
  }

  void _onDashedChanged(bool v) {
    final e = (selectedEdgeId == null) ? null : _getEdge(selectedEdgeId!);
    if (e == null) return;
    setState(() {
      e.style.dashed = v;
      _bumpGeom();
    });
    _queueSave();
  }

  void _onArrowModeChanged(ArrowMode v) {
    final e = (selectedEdgeId == null) ? null : _getEdge(selectedEdgeId!);
    if (e == null) return;
    setState(() {
      e.style.arrowMode = v;
      _bumpGeom();
    });
    _queueSave();
  }

  void _onColorChanged(int color) {
    final e = (selectedEdgeId == null) ? null : _getEdge(selectedEdgeId!);
    if (e == null) return;
    setState(() {
      e.style.color = color;
      _bumpGeom();
    });
    _queueSave();
  }

  Widget _buildScaffold(BuildContext context) {
    final selectedDiagram =
        (selectedDiagramId != null) ? _getDiagram(selectedDiagramId!) : null;
    final selectedEdge =
        (selectedEdgeId != null) ? _getEdge(selectedEdgeId!) : null;

    return Theme(
      data: Theme.of(context).copyWith(
        tooltipTheme: const TooltipThemeData(
          preferBelow: true,
          verticalOffset: 12,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          margin: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Color.fromARGB(213, 158, 217, 246),
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            height: 1.15,
          ),
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Faction',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _addDiagram,
                      tooltip: '도형 추가',
                      icon: const Icon(
                        Icons.add,
                        size: 22,
                        color: Colors.black87,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                _TopBar(
                  selectedDiagram: selectedDiagram,
                  selectedEdge: selectedEdge,
                  onRenameDiagram: _renameSelectedDiagram,
                  onToggleLock: _toggleLockSelected,
                  onDeleteDiagram: _deleteSelectedDiagram,
                  onDeleteEdge: _deleteSelectedEdge,
                  onEditEdgeLabel: () {
                    if (selectedEdgeId != null) _editEdgeLabel(selectedEdgeId!);
                  },
                  onCurvatureChanged: _onCurvatureChanged,
                  onWidthChanged: _onWidthChanged,
                  onDashedChanged: _onDashedChanged,
                  onArrowModeChanged: _onArrowModeChanged,
                  onColorChanged: _onColorChanged,
                  onCycleShape: _cycleSelectedDiagramShape,
                  onDiagramSizeChanged: _onDiagramSizeChanged,
                  onOpenEdgeColorWheel: () {
                    if (selectedEdgeId != null) {
                      _openEdgeColorWheel(selectedEdgeId!);
                    }
                  },
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: Stack(
                    children: [
                      _Canvas(
                        key: _canvasKey,
                        doc: doc,
                        showGrid: showGrid,
                        geomRev: _geomRev,
                        selectedDiagramId: selectedDiagramId,
                        selectedEdgeId: selectedEdgeId,
                        tempLink: tempLink,
                        blockDiagramDragWhenEdgeSelected:
                            selectedEdgeId != null,
                        onDiagramTapped: _onDiagramTapped,
                        onDiagramDragged: (diagramId, delta) {
                          final n = _getDiagram(diagramId);
                          if (n == null || n.locked) return;

                          setState(() {
                            n.x += delta.dx;
                            n.y += delta.dy;
                            _bumpGeom();
                          });

                          _queueSave();
                        },
                        onDiagramDragEnd: () => _queueSave(immediate: true),
                        onDiagramNameTap:
                            (diagramId) => _renameDiagram(diagramId),
                        onLinkDragStart: _startLinkDrag,
                        onLinkDragUpdate: _updateLinkDrag,
                        onLinkDragEnd: _endLinkDrag,
                        onPickDiagramImage: _pickDiagramImage,
                        onCanvasTapScene: _onCanvasTapScene,
                        onLabelTapEdit: _editEdgeLabel,
                        onLabelLongPressDragScene: _onLabelLongPressDrag,
                        onDeleteSelectedEdge: _deleteSelectedEdge,
                        onEditSelectedEdgeLabel: () {
                          if (selectedEdgeId != null) {
                            _editEdgeLabel(selectedEdgeId!);
                          }
                        },
                        onEdgeEndpointDragged: (edgeId, isStart, scenePoint) {
                          final e = _getEdge(edgeId);
                          if (e == null) return;
                          setState(() {
                            if (isStart) {
                              e.fromFree = scenePoint;
                            } else {
                              e.toFree = scenePoint;
                            }
                            _bumpGeom();
                          });
                        },
                      ),

                      Positioned(
                        right: 10,
                        top: 10,
                        child: _ZoomPill(
                          onMinus: () => _canvasKey.currentState?.zoomOut(),
                          onPlus: () => _canvasKey.currentState?.zoomIn(),
                        ),
                      ),
                    ],
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

class _ZoomPill extends StatelessWidget {
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _ZoomPill({required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onMinus,
          icon: const Icon(Icons.remove, size: 18),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
          tooltip: '축소',
        ),
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add, size: 18),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
          tooltip: '확대',
        ),
      ],
    );
  }
}

class _LabelMeasureCache {
  static final _LabelMeasureCache I = _LabelMeasureCache._();
  _LabelMeasureCache._();

  final Map<String, Size> _cache = {};
  static const int _max = 800;

  Size measure({
    required String text,
    required TextStyle style,
    required TextDirection dir,
  }) {
    final key = "${style.fontSize}|${style.fontWeight}|$text";
    final hit = _cache[key];
    if (hit != null) return hit;

    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: dir,
      maxLines: 1,
    )..layout();

    final sz = tp.size;
    _cache[key] = sz;

    if (_cache.length > _max) _cache.clear();
    return sz;
  }
}

Future<T?> showConstrainedMenu<T>({
  required BuildContext context,
  required RelativeRect position,
  required List<PopupMenuEntry<T>> items,
  double maxWidth = 160,
  double elevation = 0,
  Color? color,
  ShapeBorder? shape,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final screen = Offset.zero & overlay.size;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    pageBuilder: (ctx, a1, a2) {
      final w = maxWidth;
      final rightEdge = screen.width - position.right;
      final baseRight = screen.width - rightEdge;
      const pushRightPx = 14.0;
      final rightGap = (baseRight - pushRightPx).clamp(0.0, screen.width);
      const gapBelowPill = 4.0;
      final dy = (position.top + gapBelowPill).clamp(7.0, screen.height - 7.0);

      return Stack(
        children: [
          Positioned(
            right: rightGap,
            top: dy,
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: w),
                child: Material(
                  elevation: elevation,
                  color: color ?? Colors.white,
                  shape:
                      shape ??
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 169, 215, 255),
                        ),
                      ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                    child: IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children:
                            items
                                .map((e) => _MenuEntryWrapper<T>(entry: e))
                                .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (ctx, anim, sec, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

class _MenuEntryWrapper<T> extends StatelessWidget {
  final PopupMenuEntry<T> entry;
  const _MenuEntryWrapper({required this.entry});

  @override
  Widget build(BuildContext context) {
    if (entry is PopupMenuDivider) return entry;

    if (entry is PopupMenuItem<T>) {
      final item = entry as PopupMenuItem<T>;
      return InkWell(
        onTap: () => Navigator.pop(context, item.value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: item.child,
        ),
      );
    }
    return entry;
  }
}

class _TopBar extends StatelessWidget {
  final DiagramModel? selectedDiagram;
  final EdgeModel? selectedEdge;

  final VoidCallback onCycleShape;

  final Future<void> Function() onRenameDiagram;
  final VoidCallback onToggleLock;
  final VoidCallback onDeleteDiagram;

  final VoidCallback onDeleteEdge;
  final VoidCallback onEditEdgeLabel;
  final VoidCallback onOpenEdgeColorWheel;

  final void Function(double v) onCurvatureChanged;
  final void Function(double v) onWidthChanged;
  final void Function(bool v) onDashedChanged;
  final void Function(ArrowMode v) onArrowModeChanged;
  final void Function(int color) onColorChanged;

  final void Function(double v) onDiagramSizeChanged;

  static const Color _on = Color(0xFF169AFF);

  const _TopBar({
    required this.selectedDiagram,
    required this.selectedEdge,
    required this.onRenameDiagram,
    required this.onToggleLock,
    required this.onDeleteDiagram,
    required this.onDeleteEdge,
    required this.onEditEdgeLabel,
    required this.onCurvatureChanged,
    required this.onWidthChanged,
    required this.onDashedChanged,
    required this.onArrowModeChanged,
    required this.onColorChanged,
    required this.onCycleShape,
    required this.onDiagramSizeChanged,
    required this.onOpenEdgeColorWheel,
  });

  static const double _iconSize = 20;
  static const Color _iconColor = Colors.black87;

  @override
  Widget build(BuildContext context) {
    final info =
        selectedDiagram != null
            ? 'Name : ${selectedDiagram!.name} [${selectedDiagram!.locked ? "이동 잠금" : "이동 가능"}]'
            : (selectedEdge != null
                ? 'Name : ${selectedEdge!.label.isEmpty ? "관계" : selectedEdge!.label}'
                : "도형을 탭하거나, 선을 탭해 선택하세요");

    return _IosSimpleCard(
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
      borderRadius: const BorderRadius.all(Radius.circular(7)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(info)),
              if (selectedDiagram != null) ...[
                Tooltip(
                  message: "도형 변경",
                  child: IconButton(
                    onPressed: onCycleShape,
                    icon: Icon(
                      _shapeIcon(selectedDiagram!.shape),
                      size: _iconSize,
                      color: _iconColor,
                    ),
                  ),
                ),
                Tooltip(
                  message: selectedDiagram!.locked ? "잠금 해제" : "잠금",
                  child: IconButton(
                    onPressed: onToggleLock,
                    icon: Icon(
                      selectedDiagram!.locked ? Icons.lock_open : Icons.lock,
                      size: _iconSize,
                      color: _iconColor,
                    ),
                  ),
                ),
                Tooltip(
                  message: "도형 삭제",
                  child: IconButton(
                    onPressed: onDeleteDiagram,
                    icon: const Icon(
                      Icons.close,
                      size: _iconSize,
                      color: _iconColor,
                    ),
                  ),
                ),
              ],
              if (selectedEdge != null) ...[
                Tooltip(
                  message: "선 삭제",
                  child: IconButton(
                    onPressed: onDeleteEdge,
                    icon: const Icon(
                      Icons.close,
                      size: _iconSize,
                      color: _iconColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (selectedDiagram != null) ...[
            const SizedBox(height: 7),
            Row(
              children: [
                const SizedBox(width: 35, child: Text("크기")),
                Expanded(
                  child: SliderTheme(
                    data: _blueThinSlider(context),
                    child: Slider(
                      value: selectedDiagram!.r.clamp(20.0, 100.0),
                      min: 20.0,
                      max: 100.0,
                      divisions: 98,
                      label: selectedDiagram!.r.toStringAsFixed(0),
                      onChanged: onDiagramSizeChanged,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
          if (selectedEdge != null) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                const SizedBox(width: 48, child: Text("곡률")),
                Expanded(
                  child: SliderTheme(
                    data: _blueThinSlider(context),
                    child: Slider(
                      value: selectedEdge!.curvature.clamp(-3.5, 3.5),
                      min: -3.5,
                      max: 3.5,
                      divisions: 140,
                      label: selectedEdge!.curvature.toStringAsFixed(2),
                      onChanged: onCurvatureChanged,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const SizedBox(width: 49, child: Text("선 얇기")),
                Expanded(
                  child: SliderTheme(
                    data: _blueThinSlider(context),
                    child: Slider(
                      value: selectedEdge!.style.width.clamp(0.3, 10.0),
                      min: 0.3,
                      max: 10.0,
                      divisions: 17,
                      label: selectedEdge!.style.width.toStringAsFixed(1),
                      onChanged: onWidthChanged,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 45, child: Text("선 색상")),
                const SizedBox(width: 10),
                InkWell(
                  onTap: onOpenEdgeColorWheel,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color.fromARGB(255, 169, 215, 255),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Color(selectedEdge!.style.color),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black12),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "색 선택",
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Text("점선", style: TextStyle(fontWeight: FontWeight.w400)),
                const SizedBox(width: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onDashedChanged(!selectedEdge!.style.dashed),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selectedEdge!.style.dashed
                              ? _on.withValues(alpha: 0.15)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color:
                            selectedEdge!.style.dashed
                                ? _on
                                : const Color.fromARGB(255, 169, 215, 255),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.more_horiz,
                      size: 21,
                      color:
                          selectedEdge!.style.dashed
                              ? _on
                              : const Color.fromARGB(255, 131, 195, 255),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Text(
                  "화살표",
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                const SizedBox(width: 10),
                _ArrowModeMenuButton(
                  value: selectedEdge!.style.arrowMode,
                  onChanged: onArrowModeChanged,
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ArrowModeMenuButton extends StatelessWidget {
  final ArrowMode value;
  final ValueChanged<ArrowMode> onChanged;

  const _ArrowModeMenuButton({required this.value, required this.onChanged});

  static const Color _on = Color(0xFF169AFF);
  static const Color _offIcon = Color.fromARGB(255, 131, 195, 255);

  IconData _iconFor(ArrowMode m) {
    switch (m) {
      case ArrowMode.start:
        return Icons.arrow_back;
      case ArrowMode.end:
        return Icons.arrow_forward;
      case ArrowMode.both:
        return Icons.swap_horiz;
      case ArrowMode.none:
        return Icons.horizontal_rule;
    }
  }

  String _labelFor(ArrowMode m) {
    switch (m) {
      case ArrowMode.none:
        return "없음";
      case ArrowMode.start:
        return "시작";
      case ArrowMode.end:
        return "끝";
      case ArrowMode.both:
        return "양끝";
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = (value == ArrowMode.none) ? _offIcon : _on;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTapDown: (d) async {
          final overlayBox =
              Overlay.of(context).context.findRenderObject() as RenderBox;

          final buttonBox = context.findRenderObject() as RenderBox;
          final topLeft = buttonBox.localToGlobal(
            Offset.zero,
            ancestor: overlayBox,
          );
          final size = buttonBox.size;
          const gap = 4.0;

          final rect = Rect.fromLTWH(
            topLeft.dx,
            topLeft.dy + size.height + gap,
            size.width,
            0,
          );

          final pos = RelativeRect.fromRect(
            rect,
            Offset.zero & overlayBox.size,
          );
          final picked = await showConstrainedMenu<ArrowMode>(
            context: context,
            position: pos,
            maxWidth: 140,
            elevation: 0,
            color: Colors.white.withValues(alpha: 0.90),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Color.fromARGB(255, 169, 215, 255),
                width: 1,
              ),
            ),
            items:
                ArrowMode.values.map((m) {
                  final isSel = (m == value);
                  return PopupMenuItem<ArrowMode>(
                    value: m,
                    height: 34,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _iconFor(m),
                          size: 18,
                          color: isSel ? _on : _offIcon,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _labelFor(m),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: isSel ? _on : _offIcon,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          );
          if (picked != null) onChanged(picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color.fromARGB(255, 169, 215, 255),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconFor(value), size: 18, color: selectedColor),
              const SizedBox(width: 6),
              Text(
                _labelFor(value),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: selectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Canvas extends StatefulWidget {
  final DiagramDoc doc;
  final bool showGrid;
  final int geomRev;

  final VoidCallback onDeleteSelectedEdge;
  final VoidCallback onEditSelectedEdgeLabel;
  final VoidCallback onDiagramDragEnd;

  final Future<void> Function(String diagramId) onPickDiagramImage;

  final String? selectedDiagramId;
  final String? selectedEdgeId;

  final bool blockDiagramDragWhenEdgeSelected;

  final TempLink? tempLink;

  final void Function(DiagramModel diagram) onDiagramTapped;
  final void Function(String diagramId, Offset delta) onDiagramDragged;
  final void Function(String diagramId) onDiagramNameTap;
  final void Function(String edgeId, bool isStart, Offset scenePoint)
  onEdgeEndpointDragged;

  final void Function({
    required String fromDiagramId,
    required int fromAnchorIndex,
    required Offset sceneStartPoint,
  })
  onLinkDragStart;

  final void Function(Offset scenePoint) onLinkDragUpdate;
  final Future<void> Function(Offset sceneDropPoint) onLinkDragEnd;

  final void Function(Offset scenePoint, {double? scale}) onCanvasTapScene;

  final Future<void> Function(String edgeId) onLabelTapEdit;
  final void Function(String edgeId, Offset scenePoint)
  onLabelLongPressDragScene;

  const _Canvas({
    super.key,
    required this.doc,
    required this.showGrid,
    required this.geomRev,
    required this.selectedDiagramId,
    required this.selectedEdgeId,
    required this.tempLink,
    required this.onDiagramTapped,
    required this.onDiagramDragged,
    required this.onDiagramDragEnd,
    required this.onLinkDragStart,
    required this.onLinkDragUpdate,
    required this.onLinkDragEnd,
    required this.onCanvasTapScene,
    required this.onLabelTapEdit,
    required this.onLabelLongPressDragScene,
    required this.onDeleteSelectedEdge,
    required this.onEditSelectedEdgeLabel,
    required this.onPickDiagramImage,
    required this.onDiagramNameTap,
    required this.onEdgeEndpointDragged,
    required this.blockDiagramDragWhenEdgeSelected,
  });

  @override
  State<_Canvas> createState() => _CanvasState();
}

class _EdgeEndHandle extends StatelessWidget {
  final void Function(Offset globalPos) onDragGlobal;
  final VoidCallback onDragEnd;

  const _EdgeEndHandle({required this.onDragGlobal, required this.onDragEnd});

  static final _c = const Color.fromARGB(
    255,
    253,
    232,
    129,
  ).withValues(alpha: 0.95);

  static const double _dotR = 6;
  static const double _hit = 26;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(-_hit / 2, -_hit / 2),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (d) => onDragGlobal(d.globalPosition),
        onPanUpdate: (d) => onDragGlobal(d.globalPosition),

        onPanEnd: (_) => onDragEnd(),
        onPanCancel: () => onDragEnd(),

        child: SizedBox(
          width: _hit,
          height: _hit,
          child: Center(
            child: Container(
              width: _dotR * 2,
              height: _dotR * 2,
              decoration: BoxDecoration(color: _c, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}

class _CanvasState extends State<_Canvas> {
  final TransformationController _tc = TransformationController();

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  bool _isPanningDiagram = false;

  static const double _minScale = 0.1;
  static const double _maxScale = 1.5;

  void zoomBy(double factor) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final viewportCenter = Offset(box.size.width / 2, box.size.height / 2);
    final sceneCenter = _tc.toScene(viewportCenter);

    final currentScale = getScaleFromMatrix(_tc.value);
    final newScale = (currentScale * factor).clamp(_minScale, _maxScale);

    final t = viewportCenter - sceneCenter * newScale;

    final m = Matrix4.diagonal3Values(newScale, newScale, 1.0)
      ..setTranslationRaw(t.dx, t.dy, 0.0);

    _tc.value = m;
  }

  Rect _contentBounds() {
    if (widget.doc.diagrams.isEmpty) {
      return Rect.fromLTWH(0, 0, widget.doc.canvasW, widget.doc.canvasH);
    }

    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;

    for (final n in widget.doc.diagrams) {
      minX = math.min(minX, n.x - n.r);
      minY = math.min(minY, n.y - n.r);
      maxX = math.max(maxX, n.x + n.r);
      maxY = math.max(maxY, n.y + n.r);
    }

    const pad = 120.0;
    return Rect.fromLTRB(minX, minY, maxX, maxY).inflate(pad);
  }

  void zoomIn() => zoomBy(1.12);
  void zoomOut() => zoomBy(1 / 1.12);

  void resetZoom() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) {
      _tc.value = Matrix4.identity();
      return;
    }

    final vw = box.size.width;
    final vh = box.size.height;

    final bounds = _contentBounds();
    final cw = bounds.width;
    final ch = bounds.height;

    final fitScale = math.min(vw / cw, vh / ch).clamp(_minScale, _maxScale);

    final viewportCenter = Offset(vw / 2, vh / 2);
    final contentCenter = bounds.center;

    final t = viewportCenter - contentCenter * fitScale;

    final m = Matrix4.identity();
    m.translateByDouble(t.dx, t.dy, 0.0, 1.0);
    m.scaleByDouble(fitScale, fitScale, 1.0, 1.0);

    _tc.value = m;
  }

  void nudgeScene(double dx, double dy) {
    final m = _tc.value.clone();
    m.translateByDouble(-dx, -dy, 0.0, 1.0);
    _tc.value = m;
  }

  Offset? _edgeStartTipScene(EdgeModel e) {
    final a = widget.doc.diagrams.where((n) => n.id == e.from).firstOrNull;
    final b = widget.doc.diagrams.where((n) => n.id == e.to).firstOrNull;
    if (a == null || b == null) return null;

    final g = computeEdgeGeom(a: a, b: b, e: e);
    return g.p1;
  }

  Offset? _edgeEndTipScene(EdgeModel e) {
    final a = widget.doc.diagrams.where((n) => n.id == e.from).firstOrNull;
    final b = widget.doc.diagrams.where((n) => n.id == e.to).firstOrNull;
    if (a == null || b == null) return null;

    final g = computeEdgeGeom(a: a, b: b, e: e);
    return g.p2;
  }

  Offset sceneCenter() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return const Offset(300, 300);

    final size = box.size;
    final viewportCenterLocal = Offset(size.width / 2, size.height / 2);
    return _tc.toScene(viewportCenterLocal);
  }

  Offset _globalToScene(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    final local = box.globalToLocal(globalPosition);
    return _tc.toScene(local);
  }

  Rect visibleSceneRect() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) {
      return Rect.fromLTWH(0, 0, widget.doc.canvasW, widget.doc.canvasH);
    }

    final s = box.size;

    final p1 = _tc.toScene(const Offset(0, 0));
    final p2 = _tc.toScene(Offset(s.width, s.height));

    final left = math.min(p1.dx, p2.dx);
    final top = math.min(p1.dy, p2.dy);
    final right = math.max(p1.dx, p2.dx);
    final bottom = math.max(p1.dy, p2.dy);

    return Rect.fromLTRB(left, top, right, bottom);
  }

  double get _scale => getScaleFromMatrix(_tc.value);

  int anchorIndexFromPoint({required Offset center, required Offset point}) {
    final v = point - center;
    var ang = math.atan2(v.dy, v.dx);
    if (ang < 0) ang += 2 * math.pi;
    const unit = (2 * math.pi) / kAnchorCount;
    final idx = ((ang / unit).round()) % kAnchorCount;
    return idx;
  }

  Offset? _labelScenePosition(EdgeModel e) {
    final a =
        widget.doc.diagrams
            .where((n) => n.id == e.from)
            .cast<DiagramModel?>()
            .firstOrNull;
    final b =
        widget.doc.diagrams
            .where((n) => n.id == e.to)
            .cast<DiagramModel?>()
            .firstOrNull;
    if (a == null || b == null) return null;
    final g = computeEdgeGeom(a: a, b: b, e: e);
    final p1 = g.p1;
    final p2 = g.p2;
    final cp = g.cp;
    final t = e.labelPlacement.t.clamp(0.0, 1.0);
    final base = quadBezierPoint(p1, cp, p2, t);
    return base + e.labelPlacement.offset;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTapUp: (d) {
        if (_isPanningDiagram) setState(() => _isPanningDiagram = false);
        final scene = _globalToScene(d.globalPosition);
        widget.onCanvasTapScene(scene, scale: _scale);
      },
      child: InteractiveViewer(
        transformationController: _tc,
        constrained: false,
        clipBehavior: Clip.none,
        boundaryMargin: const EdgeInsets.all(2000),
        minScale: _minScale,
        maxScale: _maxScale,
        panEnabled:
            widget.tempLink == null &&
            !_isPanningDiagram &&
            widget.selectedEdgeId == null,
        scaleEnabled: widget.tempLink == null && !_isPanningDiagram,
        child: RepaintBoundary(
          child: SizedBox(
            width: widget.doc.canvasW,
            height: widget.doc.canvasH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (widget.showGrid) CustomPaint(painter: _GridPainter()),
                CustomPaint(
                  size: Size(widget.doc.canvasW, widget.doc.canvasH),
                  painter: _EdgePainter(
                    diagrams: widget.doc.diagrams,
                    edges: widget.doc.edges,
                    selectedDiagramId: widget.selectedDiagramId,
                    selectedEdgeId: widget.selectedEdgeId,
                    tempLink: widget.tempLink,
                    repaintKey: widget.geomRev,
                  ),
                ),

                for (final e in widget.doc.edges)
                  if (e.label.trim().isNotEmpty)
                    Builder(
                      builder: (_) {
                        final pos = _labelScenePosition(e);
                        if (pos == null) return const SizedBox.shrink();

                        return Positioned(
                          left: pos.dx,
                          top: pos.dy,
                          child: _EdgeLabelWidget(
                            text: e.label,
                            isSelected: widget.selectedEdgeId == e.id,
                            color: Color(e.style.color),
                            onTapEdit: () => widget.onLabelTapEdit(e.id),
                            onLongPressDragGlobal: (globalPos) {
                              final scene = _globalToScene(globalPos);
                              widget.onLabelLongPressDragScene(e.id, scene);
                            },
                            onDragEnd: widget.onDiagramDragEnd,
                          ),
                        );
                      },
                    ),

                for (final diagram in widget.doc.diagrams)
                  Builder(
                    builder: (_) {
                      final isSelected = diagram.id == widget.selectedDiagramId;
                      final r = diagram.r;

                      return Positioned(
                        left: diagram.x - r,
                        top: diagram.y - r,
                        child: _DiagramWidget(
                          diagram: diagram,
                          selected: isSelected,
                          scale: _scale,
                          blockDrag: widget.blockDiagramDragWhenEdgeSelected,
                          onTap: () => widget.onDiagramTapped(diagram),
                          onLabelDrag: (delta) {
                            if (diagram.locked) return;
                            widget.onDiagramDragged(diagram.id, delta);
                          },
                          onDragEnd: widget.onDiagramDragEnd,
                          onNameTap: () => widget.onDiagramNameTap(diagram.id),
                          onDiagramDragStateChanged: (v) {
                            setState(() => _isPanningDiagram = v);
                          },
                          onPickImage:
                              () => widget.onPickDiagramImage(diagram.id),
                          onLinkDragStart: (globalPos) {
                            final scene = _globalToScene(globalPos);
                            final center = Offset(diagram.x, diagram.y);
                            final idx = anchorIndexFromPoint(
                              center: center,
                              point: scene,
                            );

                            widget.onLinkDragStart(
                              fromDiagramId: diagram.id,
                              fromAnchorIndex: idx,
                              sceneStartPoint: scene,
                            );
                          },
                          onLinkDragUpdate: (globalPos) {
                            final scene = _globalToScene(globalPos);
                            widget.onLinkDragUpdate(scene);
                          },
                          onLinkDragEnd: (globalPos) async {
                            final scene = _globalToScene(globalPos);
                            await widget.onLinkDragEnd(scene);
                          },
                        ),
                      );
                    },
                  ),
                if (widget.selectedEdgeId != null)
                  Builder(
                    builder: (_) {
                      final e =
                          widget.doc.edges
                              .where((x) => x.id == widget.selectedEdgeId)
                              .firstOrNull;
                      if (e == null) return const SizedBox.shrink();

                      final p1 = _edgeStartTipScene(e);
                      final p2 = _edgeEndTipScene(e);
                      if (p1 == null || p2 == null) {
                        return const SizedBox.shrink();
                      }

                      return Stack(
                        children: [
                          Positioned(
                            left: p1.dx,
                            top: p1.dy,
                            child: _EdgeEndHandle(
                              onDragGlobal: (globalPos) {
                                final scene = _globalToScene(globalPos);
                                widget.onEdgeEndpointDragged(e.id, true, scene);
                              },
                              onDragEnd: widget.onDiagramDragEnd,
                            ),
                          ),
                          Positioned(
                            left: p2.dx,
                            top: p2.dy,
                            child: _EdgeEndHandle(
                              onDragGlobal: (globalPos) {
                                final scene = _globalToScene(globalPos);
                                widget.onEdgeEndpointDragged(
                                  e.id,
                                  false,
                                  scene,
                                );
                              },
                              onDragEnd: widget.onDiagramDragEnd,
                            ),
                          ),
                        ],
                      );
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

class _EdgeLabelWidget extends StatefulWidget {
  final String text;
  final bool isSelected;
  final Color color;
  final VoidCallback onTapEdit;
  final void Function(Offset globalPos) onLongPressDragGlobal;
  final VoidCallback onDragEnd;

  const _EdgeLabelWidget({
    required this.text,
    required this.isSelected,
    required this.color,
    required this.onTapEdit,
    required this.onLongPressDragGlobal,
    required this.onDragEnd,
  });

  @override
  State<_EdgeLabelWidget> createState() => _EdgeLabelWidgetState();
}

class _DiagramNameLabel extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _DiagramNameLabel({
    required this.text,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 12,
      color: textColor,
      fontWeight: FontWeight.w400,
    );

    final sz = _LabelMeasureCache.I.measure(
      text: text,
      style: style,
      dir: Directionality.of(context),
    );

    const padding = EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    const double minHitW = 64.0;
    const double minHitH = 32.0;

    final double rawW = sz.width + padding.horizontal;
    final double rawH = sz.height + padding.vertical;

    final double w = rawW.clamp(minHitW, 260.0);
    final double h = rawH.clamp(minHitH, 44.0);

    return Transform.translate(
      offset: Offset(-w / 2, 0),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => onTap(),
        onTap: onTap,
        child: SizedBox(
          width: w,
          height: h,
          child: Center(
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: Text(
                text,
                style: style,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EdgeLabelWidgetState extends State<_EdgeLabelWidget> {
  Size _measureText(BuildContext context) {
    const style = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

    return _LabelMeasureCache.I.measure(
      text: widget.text,
      style: style,
      dir: Directionality.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = _measureText(context);
    const padding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    final w = size.width + padding.horizontal;
    final h = size.height + padding.vertical;

    const bg = Colors.white;
    final border = widget.color;

    return Transform.translate(
      offset: Offset(-w / 2, -h / 2),
      child: GestureDetector(
        onTap: widget.onTapEdit,
        onLongPressStart: (d) => widget.onLongPressDragGlobal(d.globalPosition),
        onLongPressMoveUpdate:
            (d) => widget.onLongPressDragGlobal(d.globalPosition),
        onLongPressEnd: (_) {
          widget.onDragEnd();
        },
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 12,
              color: widget.color,
              fontWeight: FontWeight.w400,
            ),
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}

class _DiagramWidget extends StatefulWidget {
  final DiagramModel diagram;
  final bool selected;
  final double scale;
  final VoidCallback onTap;
  final VoidCallback onNameTap;
  final VoidCallback onDragEnd;

  final void Function(Offset delta) onLabelDrag;
  final void Function(bool dragging) onDiagramDragStateChanged;

  final Future<void> Function() onPickImage;

  final void Function(Offset globalPos) onLinkDragStart;
  final void Function(Offset globalPos) onLinkDragUpdate;
  final void Function(Offset globalPos) onLinkDragEnd;

  final bool blockDrag;

  const _DiagramWidget({
    required this.diagram,
    required this.selected,
    required this.scale,
    required this.onTap,
    required this.onLabelDrag,
    required this.onDiagramDragStateChanged,
    required this.onDragEnd,
    required this.onPickImage,
    required this.onLinkDragStart,
    required this.onLinkDragUpdate,
    required this.onLinkDragEnd,
    required this.onNameTap,
    required this.blockDrag,
  });

  @override
  State<_DiagramWidget> createState() => _DiagramWidgetState();
}

class _DiagramWidgetState extends State<_DiagramWidget> {
  bool _downOnBorder = false;
  bool _isBorderHit(
    Offset localPos,
    double size,
    DiagramShape shape,
    double scale,
  ) {
    final t = (12.0 / scale).clamp(6.0, 16.0);
    final w = size, h = size;

    switch (shape) {
      case DiagramShape.circle:
        {
          final c = Offset(w / 2, h / 2);
          final dist = (localPos - c).distance;
          final r = w / 2;
          return dist >= (r - t) && dist <= (r + t);
        }

      case DiagramShape.rect:
      case DiagramShape.roundedRect:
        {
          final x = localPos.dx;
          final y = localPos.dy;
          if (x < 0 || y < 0 || x > w || y > h) return false;
          return (x <= t) || (x >= w - t) || (y <= t) || (y >= h - t);
        }

      case DiagramShape.pentagon:
      case DiagramShape.hexagon:
        final c = Offset(w / 2, h / 2);
        final dist = (localPos - c).distance;
        final r = w / 2;
        return dist >= (r - t) && dist <= (r + t);
    }
  }

  Widget _buildDiagramImage(String url, int targetPx) {
    final isNet = url.startsWith('http://') || url.startsWith('https://');
    if (isNet) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        cacheWidth: targetPx,
        cacheHeight: targetPx,
        errorBuilder: (_, __, ___) => const SizedBox.expand(),
      );
    }
    return Image.file(
      File(url),
      fit: BoxFit.cover,
      cacheWidth: targetPx,
      cacheHeight: targetPx,
      errorBuilder: (_, __, ___) => const SizedBox.expand(),
    );
  }

  Widget _diagramImageContent() {
    final n = widget.diagram;
    final hasImage = (n.imageUrl != null && n.imageUrl!.trim().isNotEmpty);
    final hasColor = (n.fillColor != null);
    final showText = n.showInsideText && n.insideText.trim().isNotEmpty;
    final bg = hasColor ? Color(n.fillColor!) : Colors.transparent;

    final size = widget.diagram.r * 2;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final targetPx = (size * dpr).round().clamp(96, 512);

    Widget image;
    if (!hasImage) {
      image = const SizedBox.expand();
    } else {
      image = _buildDiagramImage(n.imageUrl!, targetPx);
    }

    final defaultTextColor = hasImage ? Colors.white : Colors.black87;
    final textColor =
        (n.insideTextColor != null)
            ? Color(n.insideTextColor!)
            : defaultTextColor;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: bg),
        image,
        if (showText)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                n.insideText,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  shadows:
                      hasImage
                          ? const [
                            Shadow(
                              blurRadius: 8,
                              offset: Offset(0, 2),
                              color: Colors.black54,
                            ),
                          ]
                          : null,
                ),
              ),
            ),
          ),
        if (!hasImage && !hasColor && !showText)
          const Center(
            child: Icon(
              Icons.add_a_photo,
              size: 15,
              color: Color.fromARGB(255, 148, 176, 200),
            ),
          ),
      ],
    );
  }

  BorderRadius _radius(DiagramShape s) {
    switch (s) {
      case DiagramShape.roundedRect:
        return BorderRadius.circular(14);
      case DiagramShape.rect:
        return BorderRadius.zero;
      default:
        return BorderRadius.zero;
    }
  }

  Widget _clipByShape(Widget child, {required DiagramShape shape}) {
    switch (shape) {
      case DiagramShape.circle:
        return ClipOval(child: child);

      case DiagramShape.roundedRect:
        return ClipRRect(borderRadius: BorderRadius.circular(14), child: child);

      case DiagramShape.rect:
        return ClipRect(child: child);

      case DiagramShape.pentagon:
        return ClipPath(clipper: const _PolygonClipper(5), child: child);

      case DiagramShape.hexagon:
        return ClipPath(clipper: const _PolygonClipper(6), child: child);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.diagram;

    final hasFillColor = n.fillColor != null;
    final fillBase = hasFillColor ? Color(n.fillColor!) : null;

    final nameBorderColor =
        hasFillColor
            ? (widget.selected ? fillBase! : fillBase!.withValues(alpha: 0.25))
            : (widget.selected
                ? const Color.fromARGB(255, 255, 157, 229)
                : const Color.fromARGB(255, 255, 157, 229));

    final nameTextColor =
        hasFillColor ? fillBase! : const Color.fromARGB(255, 255, 157, 229);

    final hasImage = n.imageUrl != null && n.imageUrl!.trim().isNotEmpty;
    final hasColor = n.fillColor != null;

    final hideBorder = hasImage || hasColor;

    final r = widget.diagram.r;
    final size = r * 2;

    final borderColor =
        hideBorder
            ? Colors.transparent
            : (widget.selected
                ? const Color.fromARGB(221, 22, 154, 255)
                : const Color.fromARGB(255, 201, 232, 255));

    final borderWidth = hideBorder ? 0.0 : (widget.selected ? 1.5 : 1.0);

    final s = widget.diagram.shape;
    final isPolygon = (s == DiagramShape.pentagon || s == DiagramShape.hexagon);

    final shapeBody =
        isPolygon
            ? CustomPaint(
              foregroundPainter:
                  hideBorder
                      ? null
                      : _PolygonBorderPainter(
                        sides: (s == DiagramShape.pentagon) ? 5 : 6,
                        color: borderColor,
                        strokeWidth: borderWidth,
                      ),
              child: SizedBox(
                width: size,
                height: size,
                child: _clipByShape(_diagramImageContent(), shape: s),
              ),
            )
            : Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape:
                    (s == DiagramShape.circle)
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                borderRadius: (s == DiagramShape.circle) ? null : _radius(s),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: _clipByShape(_diagramImageContent(), shape: s),
            );

    return SizedBox(
      width: size,
      height: size + 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              onTapDown: (d) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final local = box.globalToLocal(d.globalPosition);
                _downOnBorder = _isBorderHit(local, size, s, widget.scale);
              },
              onPanStart: (_) {
                if (widget.blockDrag) return;
                if (widget.diagram.locked) return;
                widget.onDiagramDragStateChanged(true);
              },

              onPanUpdate: (d) {
                if (widget.blockDrag) return;
                if (widget.diagram.locked) return;
                final s = widget.scale.clamp(0.0001, 9999.0);
                final deltaScene = Offset(d.delta.dx / s, d.delta.dy / s);
                widget.onLabelDrag(deltaScene);
              },
              onTapUp: (_) => widget.onDiagramDragStateChanged(false),
              onTapCancel: () => widget.onDiagramDragStateChanged(false),
              onPanEnd: (_) {
                widget.onDiagramDragStateChanged(false);
                widget.onDragEnd();
              },
              onPanCancel: () {
                widget.onDiagramDragStateChanged(false);
                widget.onDragEnd();
              },
              onLongPressStart: (d) {
                if (widget.blockDrag) return;
                if (widget.diagram.locked) return;
                if (!_downOnBorder) return;
                if (widget.blockDrag) return;
                widget.onDiagramDragStateChanged(true);
                widget.onLinkDragStart(d.globalPosition);
              },
              onLongPressMoveUpdate: (d) {
                if (widget.blockDrag) return;
                if (widget.diagram.locked) return;
                if (!_downOnBorder) return;
                widget.onLinkDragUpdate(d.globalPosition);
              },
              onLongPressEnd: (d) {
                widget.onDiagramDragStateChanged(false);
                if (widget.blockDrag) return;
                if (widget.diagram.locked) return;
                if (!_downOnBorder) return;
                widget.onLinkDragEnd(d.globalPosition);
              },
              child: shapeBody,
            ),
          ),

          if (widget.diagram.locked)
            Positioned(
              left: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
                child: const Icon(Icons.lock, size: 14),
              ),
            ),

          Positioned(
            left: r,
            top: size + 6,
            child: _DiagramNameLabel(
              text: widget.diagram.name,
              borderColor: nameBorderColor,
              textColor: nameTextColor,
              onTap: widget.onNameTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolygonClipper extends CustomClipper<Path> {
  final int sides;
  const _PolygonClipper(this.sides);

  @override
  Path getClip(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy);
    const a0 = -math.pi / 2;

    final path = Path();
    for (int i = 0; i < sides; i++) {
      final a = a0 + (2 * math.pi) * (i / sides);
      final x = cx + math.cos(a) * r;
      final y = cy + math.sin(a) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _PolygonClipper oldClipper) =>
      oldClipper.sides != sides;
}

class _PolygonBorderPainter extends CustomPainter {
  final int sides;
  final Color color;
  final double strokeWidth;

  const _PolygonBorderPainter({
    required this.sides,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - strokeWidth / 2;
    const a0 = -math.pi / 2;

    final path = Path();
    for (int i = 0; i < sides; i++) {
      final a = a0 + (2 * math.pi) * (i / sides);
      final x = cx + math.cos(a) * r;
      final y = cy + math.sin(a) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final p =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _PolygonBorderPainter oldDelegate) {
    return oldDelegate.sides != sides ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeWidth = 1
          ..color = Colors.black.withValues(alpha: 0.06);

    const step = 80.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EdgePainter extends CustomPainter {
  final List<DiagramModel> diagrams;
  final List<EdgeModel> edges;
  final String? selectedDiagramId;
  final String? selectedEdgeId;
  final TempLink? tempLink;
  final int repaintKey;

  _EdgePainter({
    required this.diagrams,
    required this.edges,
    required this.selectedDiagramId,
    required this.selectedEdgeId,
    required this.tempLink,
    required this.repaintKey,
  });

  DiagramModel? _diagramById(String id) {
    for (final n in diagrams) {
      if (n.id == id) return n;
    }
    return null;
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    double dash = 10,
    double gap = 6,
  }) {
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = math.min(dash, metric.length - distance);
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dash + gap;
      }
    }
  }

  Offset _unit(Offset v) {
    final len = v.distance;
    if (len <= 1e-9) return const Offset(1, 0);
    return Offset(v.dx / len, v.dy / len);
  }

  void _drawArrowHeadFilled(
    Canvas canvas,
    Offset tip,
    Offset dirUnit,
    Paint basePaint, {
    required double length,
    required double wing,
  }) {
    final n = Offset(-dirUnit.dy, dirUnit.dx);
    final back = tip - dirUnit * length;
    final p1 = back + n * wing;
    final p2 = back - n * wing;

    final fill =
        Paint()
          ..color = basePaint.color
          ..style = PaintingStyle.fill;

    final path =
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..close();

    canvas.drawPath(path, fill);
  }

  void _drawEdge({
    required Canvas canvas,
    required Offset p1,
    required Offset cp,
    required Offset p2,
    required EdgeStyle style,
    required Color color,
    required bool bold,
  }) {
    final rawPath =
        Path()
          ..moveTo(p1.dx, p1.dy)
          ..quadraticBezierTo(cp.dx, cp.dy, p2.dx, p2.dy);

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = bold ? (style.width + 1.2) : style.width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final headLen = 10.0 + paint.strokeWidth * 1.2;
    final headWing = 6.0 + paint.strokeWidth * 0.8;
    final backoff = headLen * 0.85;

    final ui.PathMetric? metric = rawPath.computeMetrics().firstOrNull;

    Offset? unitTangentAt(double distance) {
      if (metric == null) return null;
      final d = distance.clamp(0.0, metric.length);
      final tg = metric.getTangentForOffset(d);
      if (tg == null) return null;
      return _unit(tg.vector);
    }

    final needsEnd =
        style.arrowMode == ArrowMode.end || style.arrowMode == ArrowMode.both;
    final needsStart =
        style.arrowMode == ArrowMode.start || style.arrowMode == ArrowMode.both;

    final Offset? endDir =
        needsEnd ? unitTangentAt(metric?.length ?? 0.0) : null;
    final Offset? startDir = needsStart ? unitTangentAt(0.0) : null;

    Offset p1Draw = p1;
    Offset p2Draw = p2;

    if (needsEnd && endDir != null) {
      p2Draw = p2 - endDir * backoff;
    }
    if (needsStart && startDir != null) {
      p1Draw = p1 + startDir * backoff;
    }

    final path =
        Path()
          ..moveTo(p1Draw.dx, p1Draw.dy)
          ..quadraticBezierTo(cp.dx, cp.dy, p2Draw.dx, p2Draw.dy);

    if (style.dashed) {
      _drawDashedPath(
        canvas,
        path,
        paint,
        dash: 10 + paint.strokeWidth * 0.5,
        gap: 6 + paint.strokeWidth * 0.4,
      );
    } else {
      canvas.drawPath(path, paint);
    }

    if (needsEnd) {
      final dir = endDir ?? _unit(p2 - cp);
      _drawArrowHeadFilled(
        canvas,
        p2Draw,
        dir,
        paint,
        length: headLen,
        wing: headWing,
      );
    }

    if (needsStart) {
      final dir = startDir ?? _unit(cp - p1);
      _drawArrowHeadFilled(
        canvas,
        p1Draw,
        -dir,
        paint,
        length: headLen,
        wing: headWing,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in edges) {
      final a = _diagramById(e.from);
      final b = _diagramById(e.to);
      if (a == null || b == null) continue;

      final g = computeEdgeGeom(a: a, b: b, e: e);
      final p1 = g.p1;
      final p2 = g.p2;
      final cp = g.cp;

      final isEdgeSelected = (selectedEdgeId != null && e.id == selectedEdgeId);
      final isDiagramHighlight =
          (selectedDiagramId != null) &&
          (e.from == selectedDiagramId || e.to == selectedDiagramId);

      final baseColor = Color(e.style.color);
      final color =
          isEdgeSelected
              ? baseColor.withValues(alpha: 0.98)
              : (isDiagramHighlight
                  ? baseColor.withValues(alpha: 0.9)
                  : baseColor.withValues(alpha: 0.65));

      _drawEdge(
        canvas: canvas,
        p1: p1,
        cp: cp,
        p2: p2,
        style: e.style,
        color: color,
        bold: isEdgeSelected,
      );
    }
    if (tempLink != null) {
      final from = _diagramById(tempLink!.fromDiagramId);
      if (from != null) {
        final a0 = _anchorPointForDiagram(from, tempLink!.fromAnchorIndex);
        final dir = a0 - Offset(from.x, from.y);
        final u = _unit(dir);

        final style = EdgeStyle(
          color: 0xFFFF9800,
          width: 1.5,
          dashed: true,
          arrowMode: ArrowMode.end,
        );

        final arrowSize = 10.0 + style.width * 0.8;
        final arrowPad = arrowSize + 2.0;

        final p1 = a0 + u * arrowPad;
        final p2 = tempLink!.toPoint;

        final safeCurv = (0.0).clamp(-0.8, 0.8);
        final cp = controlPointFromCurvature(p1, p2, safeCurv);

        _drawEdge(
          canvas: canvas,
          p1: p1,
          cp: cp,
          p2: p2,
          style: style,
          color: const Color.fromARGB(
            255,
            253,
            232,
            129,
          ).withValues(alpha: 0.95),
          bold: false,
        );

        canvas.drawCircle(
          p2,
          6,
          Paint()
            ..color = const Color.fromARGB(
              255,
              253,
              232,
              129,
            ).withValues(alpha: 0.95),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EdgePainter oldDelegate) {
    return repaintKey != oldDelegate.repaintKey ||
        selectedDiagramId != oldDelegate.selectedDiagramId ||
        selectedEdgeId != oldDelegate.selectedEdgeId ||
        (tempLink?.toPoint != oldDelegate.tempLink?.toPoint) ||
        (tempLink != null) != (oldDelegate.tempLink != null);
  }
}

class _IosSimpleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const _IosSimpleCard({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.borderRadius = const BorderRadius.all(Radius.circular(7)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
            border: Border.all(
              color: const Color.fromARGB(255, 153, 190, 209),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _EdgeHitCacheEntry {
  final String id;
  final int rev;
  final Rect bounds;
  final List<Offset> poly;
  final double strokeWidth;

  _EdgeHitCacheEntry({
    required this.id,
    required this.rev,
    required this.bounds,
    required this.poly,
    required this.strokeWidth,
  });
}

class _EdgeHitCache {
  final Map<String, _EdgeHitCacheEntry> _m = {};

  _EdgeHitCacheEntry? get(String id, int rev) {
    final e = _m[id];
    if (e == null) return null;
    if (e.rev != rev) return null;
    return e;
  }

  void put(_EdgeHitCacheEntry e) => _m[e.id] = e;

  void clear() => _m.clear();
}

int _shapeToIndex(DiagramShape s) => DiagramShape.values.indexOf(s);
DiagramShape _shapeFromIndex(int i) =>
    DiagramShape.values[i.clamp(0, DiagramShape.values.length - 1)];

int _arrowToIndex(ArrowMode m) => ArrowMode.values.indexOf(m);
ArrowMode _arrowFromIndex(int i) =>
    ArrowMode.values[i.clamp(0, ArrowMode.values.length - 1)];

FactionDiagramE _diagramToE(DiagramModel n) {
  final e =
      FactionDiagramE()
        ..id = n.id
        ..name = n.name
        ..x = n.x
        ..y = n.y
        ..r = n.r
        ..locked = n.locked
        ..imageUrl = n.imageUrl
        ..shapeIndex = _shapeToIndex(n.shape)
        ..fillColor = n.fillColor
        ..insideText = n.insideText
        ..showInsideText = n.showInsideText
        ..insideTextColor = n.insideTextColor;
  return e;
}

DiagramModel _diagramFromE(FactionDiagramE e) {
  return DiagramModel(
    id: e.id,
    name: e.name,
    x: e.x,
    y: e.y,
    r: e.r,
    locked: e.locked,
    imageUrl: e.imageUrl,
    shape: _shapeFromIndex(e.shapeIndex),
    fillColor: e.fillColor,
    insideText: e.insideText,
    showInsideText: e.showInsideText,
    insideTextColor: e.insideTextColor,
  );
}

FactionEdgeStyleE _edgeStyleToE(EdgeStyle s) {
  final e =
      FactionEdgeStyleE()
        ..color = s.color
        ..width = s.width
        ..dashed = s.dashed
        ..arrowModeIndex = _arrowToIndex(s.arrowMode);
  return e;
}

EdgeStyle _edgeStyleFromE(FactionEdgeStyleE e) {
  return EdgeStyle(
    color: e.color,
    width: e.width,
    dashed: e.dashed,
    arrowMode: _arrowFromIndex(e.arrowModeIndex),
  );
}

FactionEdgeLabelPlacementE _placementToE(EdgeLabelPlacement p) {
  final e =
      FactionEdgeLabelPlacementE()
        ..t = p.t
        ..dx = p.dx
        ..dy = p.dy;
  return e;
}

EdgeLabelPlacement _placementFromE(FactionEdgeLabelPlacementE e) {
  return EdgeLabelPlacement(t: e.t, dx: e.dx, dy: e.dy);
}

FactionEdgeE _edgeToE(EdgeModel m) {
  final e =
      FactionEdgeE()
        ..id = m.id
        ..from = m.from
        ..to = m.to
        ..fromAnchor = m.fromAnchor
        ..toAnchor = m.toAnchor
        ..fromFreeX = m.fromFree?.dx
        ..fromFreeY = m.fromFree?.dy
        ..toFreeX = m.toFree?.dx
        ..toFreeY = m.toFree?.dy
        ..label = m.label
        ..curvature = m.curvature
        ..style = _edgeStyleToE(m.style)
        ..labelPlacement = _placementToE(m.labelPlacement);
  return e;
}

EdgeModel _edgeFromE(FactionEdgeE e) {
  return EdgeModel(
    id: e.id,
    from: e.from,
    to: e.to,
    fromAnchor: e.fromAnchor,
    toAnchor: e.toAnchor,
    fromFree:
        (e.fromFreeX == null || e.fromFreeY == null)
            ? null
            : Offset(e.fromFreeX!, e.fromFreeY!),
    toFree:
        (e.toFreeX == null || e.toFreeY == null)
            ? null
            : Offset(e.toFreeX!, e.toFreeY!),
    label: e.label,
    curvature: e.curvature,
    style: _edgeStyleFromE(e.style),
    labelPlacement: _placementFromE(e.labelPlacement),
  );
}

class FactionRepo {
  final Isar isar;
  final String documentId;

  FactionRepo(this.isar, this.documentId);

  IsarCollection<FactionDocEntity> get _col => isar.factionDocEntitys;

  static const int kSchemaVersion = 1;

  int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  DiagramDoc _toUi(FactionDocEntity doc) {
    return DiagramDoc(
      canvasW: doc.canvasW,
      canvasH: doc.canvasH,
      diagrams: doc.diagrams.map(_diagramFromE).toList(),
      edges: doc.edges.map(_edgeFromE).toList(),
    );
  }

  FactionDocEntity _newEntity() {
    return FactionDocEntity()
      ..documentId = documentId
      ..schemaVersion = kSchemaVersion
      ..updatedAt = _nowMs()
      ..canvasW = 2000
      ..canvasH = 1400
      ..diagrams = <FactionDiagramE>[]
      ..edges = <FactionEdgeE>[];
  }

  bool _migrateIfNeeded(FactionDocEntity e) {
    final from = e.schemaVersion;
    if (from >= kSchemaVersion) return false;

    if (e.canvasW <= 0) e.canvasW = 2000;
    if (e.canvasH <= 0) e.canvasH = 1400;

    e.schemaVersion = kSchemaVersion;
    e.updatedAt = _nowMs();
    return true;
  }

  Future<DiagramDoc> loadOrCreate() async {
    final existing =
        await _col.filter().documentIdEqualTo(documentId).findFirst();

    if (existing == null) {
      final created = _newEntity();
      await isar.writeTxn(() async {
        await _col.put(created);
      });
      return _toUi(created);
    }

    final needsSave = _migrateIfNeeded(existing);
    if (needsSave) {
      await isar.writeTxn(() async {
        await _col.put(existing);
      });
    }
    return _toUi(existing);
  }

  Future<void> save(DiagramDoc uiDoc) async {
    await isar.writeTxn(() async {
      final existing =
          await _col.filter().documentIdEqualTo(documentId).findFirst();

      final e = existing ?? _newEntity();

      e
        ..documentId = documentId
        ..schemaVersion = kSchemaVersion
        ..updatedAt = _nowMs()
        ..canvasW = uiDoc.canvasW
        ..canvasH = uiDoc.canvasH
        ..diagrams = uiDoc.diagrams.map(_diagramToE).toList()
        ..edges = uiDoc.edges.map(_edgeToE).toList();

      await _col.put(e);
    });
  }

  Future<void> deleteDoc() async {
    await isar.writeTxn(() async {
      final existing =
          await _col.filter().documentIdEqualTo(documentId).findFirst();
      if (existing == null) return;
      await _col.delete(existing.id);
    });
  }
}
