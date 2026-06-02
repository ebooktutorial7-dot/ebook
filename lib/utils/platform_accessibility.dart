// platform_accessibility.dart

import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import 'package:flutter/widgets.dart';

class PlatformAccessibility {
  static const MethodChannel _accessibility = MethodChannel(
    'app.accessibility',
  );

  static Future<bool> getReduceTransparencyFlag() async {
    bool reduce = false;

    if (Platform.isIOS) {
      try {
        final result = await _accessibility.invokeMethod<bool>(
          'isReduceTransparency',
        );

        if (result != null) reduce = result;
      } catch (_) {}
    }

    final features =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures;

    final fallbackReduce =
        features.highContrast ||
        features.disableAnimations ||
        features.accessibleNavigation;

    return reduce || fallbackReduce;
  }
}
