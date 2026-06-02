// lib/widgets/common/app_toast.dart

import 'dart:async';

import 'package:flutter/material.dart';

class AppToast {
  static OverlayEntry? _currentToast;
  static Timer? _timer;
  static int _token = 0;

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1200),
    Alignment alignment = Alignment.center,
    double bottomOffset = 100,
  }) {
    _token++;
    final int myToken = _token;

    hide();

    final overlay =
        Overlay.maybeOf(context, rootOverlay: true) ??
        Navigator.maybeOf(context, rootNavigator: true)?.overlay;

    if (overlay == null) return;

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) {
        return IgnorePointer(
          ignoring: true,
          child: Align(
            alignment: alignment,
            child: Padding(
              padding:
                  alignment == Alignment.bottomCenter
                      ? EdgeInsets.only(bottom: bottomOffset)
                      : EdgeInsets.zero,
              child: _ToastBubble(message: message),
            ),
          ),
        );
      },
    );

    _currentToast = entry;
    overlay.insert(entry);

    _timer = Timer(duration, () {
      if (myToken != _token) return;
      hide();
    });
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;

    final entry = _currentToast;
    _currentToast = null;

    if (entry == null) return;

    try {
      entry.remove();
    } catch (_) {}
  }
}

class _ToastBubble extends StatelessWidget {
  final String message;

  const _ToastBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 1.1,
          ),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
