// lib/widgets/common/app_toast.dart
import 'package:flutter/material.dart';

/// 앱 전체에서 동일한 디자인으로 표시되는 토스트 (중복 방지 포함)
class AppToast {
  static OverlayEntry? _currentToast; // 🔹 현재 표시 중인 토스트를 저장

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1200),
    Alignment alignment = Alignment.center,
    double bottomOffset = 100,
  }) {
    // 🔸 기존 토스트 제거 (중복 방지)
    _currentToast?.remove();
    _currentToast = null;

    final overlay =
        Overlay.maybeOf(context, rootOverlay: true) ??
        Navigator.of(context, rootNavigator: true).overlay;
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

    // 🔹 일정 시간 후 자동 제거
    Future.delayed(duration, () {
      entry.remove();
      if (_currentToast == entry) _currentToast = null;
    });
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
    // 🔸 살짝 fade-in 효과
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1.0);
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
            color: Colors.blue.withValues(alpha: 0.30), // 💙 반투명 파란색
            borderRadius: BorderRadius.circular(25), // 🔵 알약형
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9), // ✅ 흰색 테두리
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
