// glass_container.dart

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ebook_tutorial_app/theme/glass_theme.dart';

class GlassContainer extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final GlassTheme theme;
  final EdgeInsets padding;
  final bool solidFallback;

  const GlassContainer({
    super.key,
    required this.child,
    required this.theme,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(12),
    this.solidFallback = false,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    final theme = widget.theme;

    final Color baseColor =
        widget.solidFallback
            ? Colors.white
            : Colors.white.withValues(alpha: theme.surfaceOpacity);

    final boxShadow =
        widget.solidFallback
            ? const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ]
            : const <BoxShadow>[];

    final content = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: boxShadow,
      ),
      child: widget.child,
    );

    if (theme.blurSigma <= 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          children: [
            content,
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GradientBorderPainter(
                    radius: widget.borderRadius,
                    strokeWidth: 1.0,
                    opacity: theme.borderOpacity,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _InnerEdgePainter(
                    radius: widget.borderRadius,
                    opacity: theme.innerEdgeOpacity,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: theme.blurSigma,
              sigmaY: theme.blurSigma,
            ),
            child: content,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  final align = Alignment(-0.8 + 1.6 * t, -0.8 + 1.6 * (1 - t));
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      gradient: RadialGradient(
                        center: align,
                        radius: 1.1,
                        colors: [
                          Colors.white.withValues(
                            alpha: theme.highlightOpacity,
                          ),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  if (theme.sweepOpacity <= 0) {
                    return const SizedBox.shrink();
                  }
                  final t = Curves.easeInOut.transform(_controller.value);
                  return Transform.rotate(
                    angle: -math.pi / 4,
                    child: FractionalTranslation(
                      translation: Offset(-1 + 2 * t, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(
                                  alpha: theme.sweepOpacity,
                                ),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              stops: const [0.46, 0.50, 0.54],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _NoisePainter(
                    opacity: theme.noiseOpacity,
                    step: 4,
                    seed: 11,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GradientBorderPainter(
                  radius: widget.borderRadius,
                  strokeWidth: 1.0,
                  opacity: widget.theme.borderOpacity,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _InnerEdgePainter(
                  radius: widget.borderRadius,
                  opacity: theme.innerEdgeOpacity,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _buildContent();
}

class _GradientBorderPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final double opacity;

  _GradientBorderPainter({
    required this.radius,
    required this.strokeWidth,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: opacity),
        Colors.white.withValues(alpha: opacity * 0.6),
        Colors.white.withValues(alpha: opacity * 0.35),
      ],
      stops: const [0.0, 0.55, 1.0],
    );

    final paint =
        Paint()
          ..shader = gradient.createShader(Offset.zero & size)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth ||
        opacity != oldDelegate.opacity;
  }
}

class _NoisePainter extends CustomPainter {
  final double opacity;
  final double step;
  final math.Random _rnd;

  _NoisePainter({required this.opacity, this.step = 4, int seed = 7})
    : _rnd = math.Random(seed);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        if (_rnd.nextDouble() < 0.18) {
          canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter old) =>
      opacity != old.opacity || step != old.step;
}

class _InnerEdgePainter extends CustomPainter {
  final double radius;
  final double opacity;

  _InnerEdgePainter({required this.radius, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius - 0.5),
    );
    final paint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: opacity * 0.35),
              Colors.black.withValues(alpha: opacity * 0.45),
            ],
            stops: const [0.0, 1.0],
          ).createShader(Offset.zero & size)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _InnerEdgePainter oldDelegate) {
    return radius != oldDelegate.radius || opacity != oldDelegate.opacity;
  }
}
