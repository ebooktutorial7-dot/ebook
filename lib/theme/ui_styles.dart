// lib/theme/ui_styles.dart

import 'package:flutter/material.dart';
import 'package:ebook_tutorial_app/l10n/generated/app_localizations.dart';

class UIStyles {
  // Colors
  static const Color pastelBlue = Color(0xFF9AD0F5);
  static const Color pastelPink = Color(0xFFF8BBD0);
  static const Color border = Color(0xFFE5E7EB);

  // Text
  static const TextStyle thinText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: .2,
    color: Colors.black87,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.black45,
  );

  static const TextStyle hint = TextStyle(fontSize: 15, color: Colors.black54);

  static const TextStyle pageIndicator = TextStyle(
    fontSize: 16,
    color: Colors.black54,
  );

  // Buttons
  static ButtonStyle frameButtonStyle() => OutlinedButton.styleFrom(
    side: const BorderSide(color: border, width: 1),
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    foregroundColor: Colors.black87,
    textStyle: thinText,
  );

  // Cards / Containers
  static BoxDecoration roundedPanel({
    double radius = 18,
    Color color = Colors.white,
  }) => BoxDecoration(
    color: color,
    border: Border.all(color: border, width: 1),
    borderRadius: BorderRadius.circular(radius),
  );

  // AppBar
  static AppBar buildAppBar({
    required BuildContext context,
    required String title,
    VoidCallback? onBack,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        tooltip: AppLocalizations.of(context).back,
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        onPressed: onBack ?? () => Navigator.maybePop(context),
      ),
      centerTitle: true,
      title: Text(title, style: const TextStyle(color: Colors.black)),
    );
  }

  // Common paddings
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 24);
}
