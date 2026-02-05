// data/episode_storage.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/episode.dart';

class EpisodeStorage {
  static String _key(String genreName) => 'episodes_$genreName';

  static Future<List<Episode>> load({required String genreName}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(genreName));
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List).map((e) => Episode.fromJson(e)).toList();
  }

  static Future<void> save(
    List<Episode> episodes, {
    required String genreName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(episodes.map((e) => e.toJson()).toList());
    await prefs.setString(_key(genreName), raw);
  }
}
