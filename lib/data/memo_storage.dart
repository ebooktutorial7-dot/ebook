// data/memo_storage.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebook_tutorial_app/models/memo.dart';

class MemoStorage {
  static Future<List<Memo>> load({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return <Memo>[];
    final list =
        (jsonDecode(raw) as List)
            .cast<Map<String, dynamic>>()
            .map(Memo.fromJson)
            .toList();
    return list;
  }

  static Future<void> save(List<Memo> memos, {required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(memos.map((m) => m.toJson()).toList());
    await prefs.setString(key, raw);
  }
}
