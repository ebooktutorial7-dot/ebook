// world_prefs.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebook_tutorial_app/pages/chapter/character.dart';

String worldKeyForBook(String documentId) => 'world_character_$documentId';

Future<void> saveWorldCharacterForBook(String documentId, Character c) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(worldKeyForBook(documentId), jsonEncode(c.toJson()));
}

Future<Character?> loadWorldForBook(String documentId) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(worldKeyForBook(documentId));
  if (raw == null) return null;

  try {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return Character.fromJson(map);
  } catch (_) {
    return null;
  }
}

Future<void> clearWorldForBook(String documentId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(worldKeyForBook(documentId));
}
