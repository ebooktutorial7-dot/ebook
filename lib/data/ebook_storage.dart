import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EbookStorage {
  static const _key = 'ebooks_data';

  static Future<void> save(List<Map<String, dynamic>> ebooks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(ebooks);
    await prefs.setString(_key, encoded);
  }

  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }
}
