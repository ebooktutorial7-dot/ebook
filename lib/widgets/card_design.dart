// widgets/card_design.dart

import 'dart:io';
import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

class A4MiniCard extends StatelessWidget {
  const A4MiniCard({
    super.key,
    required this.title,
    required this.preview,
    this.selected = false,
    required this.selectionMode,
    this.coverPath,
    this.genreText,
  });

  final String title;
  final String preview;
  final bool selected;
  final bool selectionMode;
  final String? coverPath;
  final String? genreText;

  static const Color border = Color.fromARGB(221, 159, 188, 208);

  static const double a4Height = 150;
  static const double a4AspectWH = 2 / 3;
  static const double a4Width = a4Height * a4AspectWH;

  static const double captionGap = 7;
  static const double captionHeight = 70;
  static const double genreBadgeTopSpace = 18;

  Widget _genreBadge(double scale) {
    final text = genreText?.trim();
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11 * scale,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 156, 194, 231),
          height: 1.0,
        ),
      ),
    );
  }

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
        final badgeTopSpace = genreBadgeTopSpace * scale;
        final hasBadge = genreText?.trim().isNotEmpty ?? false;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(top: hasBadge ? badgeTopSpace : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    height: cardH,
                    width: cardW,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      border:
                          (selectionMode && selected)
                              ? Border.all(
                                color: const Color.fromARGB(255, 91, 179, 255),
                                width: 1.7,
                              )
                              : hasCover
                              ? null
                              : Border.all(color: border, width: 0.5),
                    ),
                    child:
                        hasCover
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(radius),
                              clipBehavior: Clip.antiAlias,
                              child: Image.file(
                                File(coverPath!),
                                fit: BoxFit.cover,
                              ),
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
              ),
            ),

            if (hasBadge)
              Positioned(left: 5 * scale, top: 0, child: _genreBadge(scale)),
          ],
        );
      },
    );
  }
}

enum AddSquareCardBorderStyle { solid, dashed, none }

enum AddSquareCardContentPosition {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

class AddSquareCard extends StatelessWidget {
  const AddSquareCard({
    super.key,
    required this.onTap,
    this.onCustomizeTap,
    this.title = '새 작품 만들기',
    this.subtitle,
    this.icon = Icons.add,
    this.showIcon = true,
    this.iconSize = 36,
    this.iconThinness = 50,
    this.titleFontSize = 16,
    this.subtitleFontSize = 12,
    this.contentScale = 1.0,
    this.backgroundColor = Colors.white,
    this.backgroundGradient,
    this.glassEffect = false,
    this.translucentEffect = false,
    this.threeDGlassMode = false,
    this.backgroundImagePath,
    this.backgroundImageTransparency = 0,
    this.backgroundImageScale = 1,
    this.backgroundImageOffsetX = 0,
    this.backgroundImageOffsetY = 0,
    this.textPosition = AddSquareCardContentPosition.center,
    this.iconPosition = AddSquareCardContentPosition.center,
    this.useLightContentOnImage = false,
    this.borderColor = const Color.fromARGB(221, 170, 214, 244),
    this.iconColor = const Color.fromARGB(221, 83, 129, 159),
    this.titleColor = const Color.fromARGB(221, 12, 24, 46),
    this.subtitleColor = const Color.fromARGB(221, 83, 129, 159),
    this.borderWidth = 1,
    this.borderStyle = AddSquareCardBorderStyle.solid,
    this.showCustomizeButton = true,
  });

  final VoidCallback onTap;
  final VoidCallback? onCustomizeTap;
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool showIcon;
  final double iconSize;
  final double iconThinness;
  final double titleFontSize;
  final double subtitleFontSize;
  final double contentScale;
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final bool glassEffect;
  final bool translucentEffect;

  final bool threeDGlassMode;

  final String? backgroundImagePath;
  final double backgroundImageTransparency;
  final double backgroundImageScale;
  final double backgroundImageOffsetX;
  final double backgroundImageOffsetY;
  final AddSquareCardContentPosition textPosition;
  final AddSquareCardContentPosition iconPosition;
  final bool useLightContentOnImage;
  final Color borderColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final double borderWidth;
  final AddSquareCardBorderStyle borderStyle;
  final bool showCustomizeButton;

  String? get _cleanSubtitle {
    final raw = subtitle?.trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final cleanTitle = title.trim().isEmpty ? '새 작품 만들기' : title.trim();
    final cleanSubtitle = _cleanSubtitle;
    final canCustomize = showCustomizeButton && onCustomizeTap != null;
    final safeContentScale = contentScale.clamp(0.55, 1.0).toDouble();
    final safeIconSize =
        (iconSize * safeContentScale).clamp(14.0, 72.0).toDouble();
    final safeIconThinness = iconThinness.clamp(0.0, 100.0).toDouble();
    final safeTitleFontSize = titleFontSize.clamp(10.0, 28.0).toDouble();
    final safeSubtitleFontSize = subtitleFontSize.clamp(8.0, 22.0).toDouble();
    final resolvedIconStrokeWidth =
        ((4.2 - (safeIconThinness * 0.03)) * safeContentScale)
            .clamp(0.55, 4.2)
            .toDouble();
    final resolvedIconWeight =
        (700 - (safeIconThinness * 6)).clamp(100.0, 700.0).toDouble();
    final thinIconKind = _thinIconKindForIcon(icon);
    final hasCenterIcon = showIcon && safeIconSize > 0;
    final isLiquidGlass = threeDGlassMode;
    final radiusValue = isLiquidGlass ? 26.0 : 15.0;
    final radius = BorderRadius.circular(radiusValue);
    final materialRadius = BorderRadius.circular(isLiquidGlass ? 28 : 18);
    final hasSolidBorder =
        borderStyle == AddSquareCardBorderStyle.solid && borderWidth > 0;
    final hasDashedBorder =
        borderStyle == AddSquareCardBorderStyle.dashed && borderWidth > 0;

    final imagePath = backgroundImagePath?.trim();
    final imageFile =
        imagePath == null || imagePath.isEmpty ? null : File(imagePath);
    final hasBackgroundImage = imageFile != null && imageFile.existsSync();

    final shouldUseLightContent = useLightContentOnImage && hasBackgroundImage;

    final resolvedIconColor =
        shouldUseLightContent
            ? Colors.white.withValues(alpha: 0.92)
            : isLiquidGlass
            ? iconColor.withValues(alpha: 0.94)
            : iconColor;

    final resolvedTitleColor =
        shouldUseLightContent
            ? Colors.white.withValues(alpha: 0.94)
            : isLiquidGlass
            ? titleColor.withValues(alpha: 0.95)
            : titleColor;

    final resolvedSubtitleColor =
        shouldUseLightContent
            ? Colors.white.withValues(alpha: 0.80)
            : isLiquidGlass
            ? subtitleColor.withValues(alpha: 0.84)
            : subtitleColor;

    final decoration = BoxDecoration(
      color: backgroundGradient == null ? backgroundColor : null,
      gradient: backgroundGradient,
      borderRadius: radius,
    );

    Alignment alignmentForPosition(AddSquareCardContentPosition position) {
      switch (position) {
        case AddSquareCardContentPosition.topLeft:
          return Alignment.topLeft;
        case AddSquareCardContentPosition.topCenter:
          return Alignment.topCenter;
        case AddSquareCardContentPosition.topRight:
          return Alignment.topRight;
        case AddSquareCardContentPosition.centerLeft:
          return Alignment.centerLeft;
        case AddSquareCardContentPosition.center:
          return Alignment.center;
        case AddSquareCardContentPosition.centerRight:
          return Alignment.centerRight;
        case AddSquareCardContentPosition.bottomLeft:
          return Alignment.bottomLeft;
        case AddSquareCardContentPosition.bottomCenter:
          return Alignment.bottomCenter;
        case AddSquareCardContentPosition.bottomRight:
          return Alignment.bottomRight;
      }
    }

    CrossAxisAlignment crossAxisForPosition(
      AddSquareCardContentPosition position,
    ) {
      switch (position) {
        case AddSquareCardContentPosition.topLeft:
        case AddSquareCardContentPosition.centerLeft:
        case AddSquareCardContentPosition.bottomLeft:
          return CrossAxisAlignment.start;
        case AddSquareCardContentPosition.topRight:
        case AddSquareCardContentPosition.centerRight:
        case AddSquareCardContentPosition.bottomRight:
          return CrossAxisAlignment.end;
        case AddSquareCardContentPosition.topCenter:
        case AddSquareCardContentPosition.center:
        case AddSquareCardContentPosition.bottomCenter:
          return CrossAxisAlignment.center;
      }
    }

    TextAlign textAlignForPosition(AddSquareCardContentPosition position) {
      switch (position) {
        case AddSquareCardContentPosition.topLeft:
        case AddSquareCardContentPosition.centerLeft:
        case AddSquareCardContentPosition.bottomLeft:
          return TextAlign.left;
        case AddSquareCardContentPosition.topRight:
        case AddSquareCardContentPosition.centerRight:
        case AddSquareCardContentPosition.bottomRight:
          return TextAlign.right;
        case AddSquareCardContentPosition.topCenter:
        case AddSquareCardContentPosition.center:
        case AddSquareCardContentPosition.bottomCenter:
          return TextAlign.center;
      }
    }

    Widget positionedElement({
      required AddSquareCardContentPosition position,
      required Widget child,
    }) {
      return Positioned.fill(
        child: IgnorePointer(
          ignoring: true,
          child: Align(
            alignment: alignmentForPosition(position),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 22 * safeContentScale,
                vertical: 20 * safeContentScale,
              ),
              child: child,
            ),
          ),
        ),
      );
    }

    final iconWidget =
        hasCenterIcon
            ? SizedBox(
              width: safeIconSize,
              height: safeIconSize,
              child:
                  thinIconKind != null
                      ? CustomPaint(
                        painter: _ThinLineIconPainter(
                          kind: thinIconKind,
                          color: resolvedIconColor,
                          strokeWidth: resolvedIconStrokeWidth,
                        ),
                      )
                      : Center(
                        child: Icon(
                          icon,
                          size: safeIconSize,
                          color: resolvedIconColor,
                          weight: resolvedIconWeight,
                        ),
                      ),
            )
            : null;

    final titleTextAlign = textAlignForPosition(textPosition);
    final titleBlock = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisForPosition(textPosition),
        children: [
          Text(
            cleanTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: titleTextAlign,
            style: TextStyle(
              fontSize: safeTitleFontSize * safeContentScale,
              fontWeight: FontWeight.w700,
              color: resolvedTitleColor,
              shadows:
                  shouldUseLightContent
                      ? [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ]
                      : null,
            ),
          ),
          if (cleanSubtitle != null) ...[
            SizedBox(height: 5 * safeContentScale),
            Text(
              cleanSubtitle,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: titleTextAlign,
              style: TextStyle(
                fontSize: safeSubtitleFontSize * safeContentScale,
                fontWeight: FontWeight.w400,
                color: resolvedSubtitleColor,
                height: 1.2,
                shadows:
                    shouldUseLightContent
                        ? [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                        : null,
              ),
            ),
          ],
        ],
      ),
    );

    final contentChildren = <Widget>[];
    final shouldCombineIconAndText =
        iconWidget != null && iconPosition == textPosition;

    if (shouldCombineIconAndText) {
      contentChildren.add(
        positionedElement(
          position: textPosition,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: crossAxisForPosition(textPosition),
            children: [
              iconWidget,
              SizedBox(height: 6 * safeContentScale),
              titleBlock,
            ],
          ),
        ),
      );
    } else {
      if (iconWidget != null) {
        contentChildren.add(
          positionedElement(position: iconPosition, child: iconWidget),
        );
      }
      contentChildren.add(
        positionedElement(position: textPosition, child: titleBlock),
      );
    }

    final content = Stack(
      clipBehavior: Clip.none,
      children: [
        ...contentChildren,
        if (canCustomize)
          Positioned(
            top: 10,
            right: 10,
            child: Semantics(
              button: true,
              label: '메인 카드 꾸미기',
              child: _GlassIconButton(
                liquid: isLiquidGlass,
                iconColor: resolvedIconColor,
                onTap: onCustomizeTap!,
              ),
            ),
          ),
      ],
    );

    final imageOpacity =
        (1 - backgroundImageTransparency.clamp(0.0, 1.0)).toDouble();

    Widget backgroundImageLayer() {
      if (!hasBackgroundImage) return const SizedBox.shrink();

      final resolvedImageOpacity =
          isLiquidGlass
              ? imageOpacity.clamp(0.92, 1.0).toDouble()
              : imageOpacity;

      final resolvedScale = backgroundImageScale.clamp(1.0, 4.0).toDouble();
      final resolvedOffsetX =
          backgroundImageOffsetX.clamp(-0.5, 0.5).toDouble();
      final resolvedOffsetY =
          backgroundImageOffsetY.clamp(-0.5, 0.5).toDouble();

      final imageAlignment = Alignment(
        (resolvedOffsetX * 2).clamp(-1.0, 1.0).toDouble(),
        (resolvedOffsetY * 2).clamp(-1.0, 1.0).toDouble(),
      );

      final image = ClipRect(
        child: Transform.scale(
          scale: resolvedScale,
          child: Image.file(
            imageFile,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: imageAlignment,
          ),
        ),
      );

      return Positioned.fill(
        child:
            resolvedImageOpacity >= 0.999
                ? image
                : Opacity(opacity: resolvedImageOpacity, child: image),
      );
    }

    final decoratedContent = Container(
      decoration: decoration,
      child: Stack(
        children: [
          backgroundImageLayer(),
          if (translucentEffect && !glassEffect)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          content,
        ],
      ),
    );

    final normalClippedContent = ClipRRect(
      borderRadius: radius,
      child:
          glassEffect
              ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: decoratedContent,
              )
              : decoratedContent,
    );

    final liquidGlassContent = Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(decoration: BoxDecoration(borderRadius: radius)),
        ),
        ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasBackgroundImage)
                backgroundImageLayer()
              else
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient:
                          backgroundGradient ??
                          const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFDFEFF),
                              Color(0xFFF9F2FF),
                              Color(0xFFF5FFF9),
                            ],
                            stops: [0.0, 0.54, 1.0],
                          ),
                    ),
                  ),
                ),

              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: hasBackgroundImage ? 1.8 : 7.5,
                  sigmaY: hasBackgroundImage ? 1.8 : 7.5,
                ),
                child: const SizedBox.expand(),
              ),

              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: hasBackgroundImage ? 0.010 : 0.115,
                  ),
                ),
              ),

              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(
                        alpha: hasBackgroundImage ? 0.10 : 0.40,
                      ),
                      Colors.white.withValues(
                        alpha: hasBackgroundImage ? 0.018 : 0.095,
                      ),
                      Colors.white.withValues(
                        alpha: hasBackgroundImage ? 0.004 : 0.028,
                      ),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                ),
              ),

              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.78, -0.74),
                    radius: 1.05,
                    colors: [
                      Colors.white.withValues(
                        alpha: hasBackgroundImage ? 0.07 : 0.30,
                      ),
                      Colors.white.withValues(
                        alpha: hasBackgroundImage ? 0.012 : 0.060,
                      ),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                ),
              ),

              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.92, 0.96),
                    radius: 1.10,
                    colors: [
                      const Color(
                        0xFF97E4FF,
                      ).withValues(alpha: hasBackgroundImage ? 0.035 : 0.18),
                      const Color(
                        0xFFFFE1F2,
                      ).withValues(alpha: hasBackgroundImage ? 0.015 : 0.075),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.46, 1.0],
                  ),
                ),
              ),
              content,
            ],
          ),
        ),
      ],
    );

    final cardBody = Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        isLiquidGlass ? liquidGlassContent : normalClippedContent,
        if (!isLiquidGlass && (hasSolidBorder || hasDashedBorder))
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                foregroundPainter: _VisibleRoundedRectBorderPainter(
                  color: borderColor,
                  strokeWidth: borderWidth,
                  radius: radiusValue,
                  dashed: hasDashedBorder,
                ),
              ),
            ),
          ),
        if (isLiquidGlass && (hasSolidBorder || hasDashedBorder))
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                foregroundPainter: _VisibleRoundedRectBorderPainter(
                  color:
                      hasBackgroundImage
                          ? Colors.white.withValues(alpha: 0.34)
                          : Colors.white.withValues(alpha: 0.52),
                  strokeWidth: borderWidth.clamp(0.6, 1.0).toDouble(),
                  radius: radiusValue,
                  dashed: hasDashedBorder,
                ),
              ),
            ),
          ),
      ],
    );

    return Material(
      color: Colors.transparent,
      borderRadius: materialRadius,
      child: InkWell(
        onTap: onTap,
        onLongPress: onCustomizeTap,
        borderRadius: materialRadius,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: cardBody,
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.liquid,
    required this.iconColor,
    required this.onTap,
  });

  final bool liquid;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.all(8),
      child: Icon(Icons.palette_outlined, size: 19, color: iconColor),
    );

    if (!liquid) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: child,
        ),
      );
    }

    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.white.withValues(alpha: 0.10),
          child: InkWell(
            onTap: onTap,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.36),
                  width: 0.8,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _VisibleRoundedRectBorderPainter extends CustomPainter {
  const _VisibleRoundedRectBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashed,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    if (strokeWidth <= 0 || size.isEmpty) return;

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true;

    final halfStroke = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      halfStroke,
      halfStroke,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final safeRadius = (radius - halfStroke).clamp(0.0, radius).toDouble();
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(safeRadius));

    if (!dashed) {
      canvas.drawRRect(rrect, paint);
      return;
    }

    final path = Path()..addRRect(rrect);

    const dashLength = 7.0;
    const gapLength = 5.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(
            distance,
            next.clamp(0.0, metric.length).toDouble(),
          ),
          paint,
        );
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VisibleRoundedRectBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        radius != oldDelegate.radius ||
        dashed != oldDelegate.dashed;
  }
}

enum _ThinIconKind { add, editNote, book, draw, star, heart }

bool _sameIcon(IconData a, IconData b) {
  return a.codePoint == b.codePoint && a.fontFamily == b.fontFamily;
}

_ThinIconKind? _thinIconKindForIcon(IconData icon) {
  if (_sameIcon(icon, Icons.add)) return _ThinIconKind.add;
  if (_sameIcon(icon, Icons.edit_note)) return _ThinIconKind.editNote;
  if (_sameIcon(icon, Icons.auto_stories) ||
      _sameIcon(icon, Icons.menu_book_outlined)) {
    return _ThinIconKind.book;
  }
  if (_sameIcon(icon, Icons.draw_outlined)) return _ThinIconKind.draw;
  if (_sameIcon(icon, Icons.star_border)) return _ThinIconKind.star;
  if (_sameIcon(icon, Icons.favorite_border)) return _ThinIconKind.heart;
  return null;
}

class _ThinLineIconPainter extends CustomPainter {
  const _ThinLineIconPainter({
    required this.kind,
    required this.color,
    required this.strokeWidth,
  });

  final _ThinIconKind kind;
  final Color color;
  final double strokeWidth;

  Paint _paint() {
    return Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
  }

  Offset _p(Size size, double x, double y) {
    return Offset(size.width * x, size.height * y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || strokeWidth <= 0) return;

    final paint = _paint();

    switch (kind) {
      case _ThinIconKind.add:
        _paintAdd(canvas, size, paint);
        return;
      case _ThinIconKind.editNote:
        _paintEditNote(canvas, size, paint);
        return;
      case _ThinIconKind.book:
        _paintBook(canvas, size, paint);
        return;
      case _ThinIconKind.draw:
        _paintDraw(canvas, size, paint);
        return;
      case _ThinIconKind.star:
        _paintStar(canvas, size, paint);
        return;
      case _ThinIconKind.heart:
        _paintHeart(canvas, size, paint);
        return;
    }
  }

  void _paintAdd(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final length = size.shortestSide * 0.56;
    final half = length / 2;

    canvas.drawLine(
      Offset(center.dx - half, center.dy),
      Offset(center.dx + half, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - half),
      Offset(center.dx, center.dy + half),
      paint,
    );
  }

  void _paintEditNote(Canvas canvas, Size size, Paint paint) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * 0.22,
        size.width * 0.50,
        size.height * 0.56,
      ),
      Radius.circular(size.shortestSide * 0.08),
    );

    canvas.drawRRect(rect, paint);

    canvas.drawLine(_p(size, 0.32, 0.36), _p(size, 0.60, 0.36), paint);
    canvas.drawLine(_p(size, 0.32, 0.50), _p(size, 0.57, 0.50), paint);
    canvas.drawLine(_p(size, 0.32, 0.64), _p(size, 0.49, 0.64), paint);

    final penPath =
        Path()
          ..moveTo(size.width * 0.66, size.height * 0.65)
          ..lineTo(size.width * 0.82, size.height * 0.49)
          ..lineTo(size.width * 0.75, size.height * 0.42)
          ..lineTo(size.width * 0.59, size.height * 0.58)
          ..lineTo(size.width * 0.56, size.height * 0.70)
          ..close();

    canvas.drawPath(penPath, paint);
  }

  void _paintBook(Canvas canvas, Size size, Paint paint) {
    final path =
        Path()
          ..moveTo(size.width * 0.50, size.height * 0.24)
          ..lineTo(size.width * 0.50, size.height * 0.76)
          ..moveTo(size.width * 0.50, size.height * 0.30)
          ..cubicTo(
            size.width * 0.40,
            size.height * 0.22,
            size.width * 0.28,
            size.height * 0.24,
            size.width * 0.20,
            size.height * 0.30,
          )
          ..lineTo(size.width * 0.20, size.height * 0.72)
          ..cubicTo(
            size.width * 0.30,
            size.height * 0.66,
            size.width * 0.40,
            size.height * 0.66,
            size.width * 0.50,
            size.height * 0.76,
          )
          ..moveTo(size.width * 0.50, size.height * 0.30)
          ..cubicTo(
            size.width * 0.60,
            size.height * 0.22,
            size.width * 0.72,
            size.height * 0.24,
            size.width * 0.80,
            size.height * 0.30,
          )
          ..lineTo(size.width * 0.80, size.height * 0.72)
          ..cubicTo(
            size.width * 0.70,
            size.height * 0.66,
            size.width * 0.60,
            size.height * 0.66,
            size.width * 0.50,
            size.height * 0.76,
          );

    canvas.drawPath(path, paint);
  }

  void _paintDraw(Canvas canvas, Size size, Paint paint) {
    final path =
        Path()
          ..moveTo(size.width * 0.28, size.height * 0.72)
          ..lineTo(size.width * 0.60, size.height * 0.40)
          ..lineTo(size.width * 0.70, size.height * 0.50)
          ..lineTo(size.width * 0.38, size.height * 0.82)
          ..lineTo(size.width * 0.24, size.height * 0.86)
          ..close();

    canvas.drawPath(path, paint);

    canvas.drawLine(_p(size, 0.60, 0.40), _p(size, 0.70, 0.30), paint);
    canvas.drawLine(_p(size, 0.70, 0.50), _p(size, 0.80, 0.40), paint);
    canvas.drawLine(_p(size, 0.70, 0.30), _p(size, 0.80, 0.40), paint);
    canvas.drawLine(_p(size, 0.22, 0.88), _p(size, 0.50, 0.88), paint);
  }

  void _paintStar(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.shortestSide * 0.36;
    final inner = outer * 0.45;

    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -pi / 2 + i * pi / 5;
      final r = i.isEven ? outer : inner;
      final point = Offset(
        center.dx + cos(angle) * r,
        center.dy + sin(angle) * r,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _paintHeart(Canvas canvas, Size size, Paint paint) {
    final path =
        Path()
          ..moveTo(size.width * 0.50, size.height * 0.78)
          ..cubicTo(
            size.width * 0.24,
            size.height * 0.60,
            size.width * 0.18,
            size.height * 0.42,
            size.width * 0.27,
            size.height * 0.31,
          )
          ..cubicTo(
            size.width * 0.36,
            size.height * 0.20,
            size.width * 0.47,
            size.height * 0.28,
            size.width * 0.50,
            size.height * 0.39,
          )
          ..cubicTo(
            size.width * 0.53,
            size.height * 0.28,
            size.width * 0.64,
            size.height * 0.20,
            size.width * 0.73,
            size.height * 0.31,
          )
          ..cubicTo(
            size.width * 0.82,
            size.height * 0.42,
            size.width * 0.76,
            size.height * 0.60,
            size.width * 0.50,
            size.height * 0.78,
          );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ThinLineIconPainter oldDelegate) {
    return kind != oldDelegate.kind ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth;
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
