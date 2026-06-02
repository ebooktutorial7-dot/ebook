// app_locale_controller.dart

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appLocaleController = AppLocaleController();

class AppLocaleController extends ChangeNotifier {
  static const String _storageKey = 'app_language_code';

  Locale _locale = const Locale('ko');

  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);

    switch (code) {
      case 'ko':
        _locale = const Locale('ko');
        break;
      case 'en':
        _locale = const Locale('en');
        break;
      case 'ja':
        _locale = const Locale('ja');
        break;
      default:
        _locale = const Locale('ko');
        break;
    }

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;

    _locale = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, locale.languageCode);

    notifyListeners();
  }
}
