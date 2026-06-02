import 'package:flutter/material.dart';

class GlassTheme {
  final bool reduceTransparency;
  final double blurSigma;
  final double surfaceOpacity;
  final double borderOpacity;
  final double highlightOpacity;
  final double sweepOpacity;
  final double noiseOpacity;
  final double innerEdgeOpacity;

  final Color accentColor;
  final Color textColor;
  final Color cancelColor;

  Color get barrierColor => const Color(0xFF0F2238).withValues(alpha: 0.13);

  const GlassTheme({
    required this.reduceTransparency,
    required this.blurSigma,
    required this.surfaceOpacity,
    required this.borderOpacity,
    required this.highlightOpacity,
    required this.sweepOpacity,
    required this.noiseOpacity,
    required this.innerEdgeOpacity,
    this.accentColor = const Color(0xFF64B5F6),
    this.textColor = Colors.black87,
    this.cancelColor = const Color.fromARGB(255, 78, 98, 120),
  });

  GlassTheme copyWith({
    bool? reduceTransparency,
    double? blurSigma,
    double? surfaceOpacity,
    double? borderOpacity,
    double? highlightOpacity,
    double? sweepOpacity,
    double? noiseOpacity,
    double? innerEdgeOpacity,
    Color? accentColor,
    Color? textColor,
    Color? cancelColor,
  }) {
    return GlassTheme(
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      blurSigma: blurSigma ?? this.blurSigma,
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      borderOpacity: borderOpacity ?? this.borderOpacity,
      highlightOpacity: highlightOpacity ?? this.highlightOpacity,
      sweepOpacity: sweepOpacity ?? this.sweepOpacity,
      noiseOpacity: noiseOpacity ?? this.noiseOpacity,
      innerEdgeOpacity: innerEdgeOpacity ?? this.innerEdgeOpacity,
      accentColor: accentColor ?? this.accentColor,
      textColor: textColor ?? this.textColor,
      cancelColor: cancelColor ?? this.cancelColor,
    );
  }

  factory GlassTheme.fromFlags({required bool reduceTransparency}) {
    if (reduceTransparency) {
      return const GlassTheme(
        reduceTransparency: true,
        blurSigma: 0,
        surfaceOpacity: 0.92,
        borderOpacity: 0.12,
        highlightOpacity: 0.00,
        sweepOpacity: 0.00,
        noiseOpacity: 0.00,
        innerEdgeOpacity: 0.04,
      );
    } else {
      return const GlassTheme(
        reduceTransparency: false,
        blurSigma: 22,
        surfaceOpacity: 0.16,
        borderOpacity: 0.28,
        highlightOpacity: 0.00,
        sweepOpacity: 0.00,
        noiseOpacity: 0.04,
        innerEdgeOpacity: 0.04,
      );
    }
  }
}
