// lib/widgets/common/app_toast.dart
import 'dart:async';

import 'package:flutter/material.dart';

/// 앱 전체에서 동일한 디자인으로 표시되는 토스트 (중복 방지 포함)
class AppToast {
  static OverlayEntry? _currentToast;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1200),
    Alignment alignment = Alignment.center,
    double bottomOffset = 100,
  }) {
    // 기존 자동 제거 예약 취소
    _timer?.cancel();
    _timer = null;

    // 기존 토스트 안전 제거
    _removeCurrentToast();

    final overlay =
        Overlay.maybeOf(context, rootOverlay: true) ??
        Navigator.maybeOf(context, rootNavigator: true)?.overlay;

    if (overlay == null) return;

    final entry = OverlayEntry(
      builder:
          (_) => IgnorePointer(
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
          ),
    );

    overlay.insert(entry);
    _currentToast = entry;

    // 일정 시간 후 자동 제거
    _timer = Timer(duration, () {
      if (_currentToast == entry) {
        _removeCurrentToast();
      } else {
        _safeRemove(entry);
      }
    });
  }

  static void _removeCurrentToast() {
    final entry = _currentToast;
    _currentToast = null;

    if (entry == null) return;
    _safeRemove(entry);
  }

  static void _safeRemove(OverlayEntry entry) {
    try {
      if (entry.mounted) {
        entry.remove();
      }
    } catch (_) {
      // 이미 제거된 OverlayEntry면 무시
    }
  }
}

/// 내부용 위젯: 알약형 반투명 토스트 버블
class _ToastBubble extends StatefulWidget {
  final String message;
  const _ToastBubble({required this.message});

  @override
  State<_ToastBubble> createState() => _ToastBubbleState();
}

class _ToastBubbleState extends State<_ToastBubble>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _opacity = 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 200),
      child: Material(
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
            widget.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
