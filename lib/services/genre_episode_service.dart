// genre_episode_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ebook_tutorial_app/models/genre_episode_item.dart';

class GenreEpisodeService {
  static Future<List<GenreEpisodeItem>> loadGenreEpisodes({
    required List<Map<String, dynamic>> genreBooks,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final merged = <GenreEpisodeItem>[];

    for (final b in genreBooks) {
      final bookId = (b['documentId'] as String?) ?? '';
      if (bookId.isEmpty) continue;

      final bookTitle = (b['title'] as String?) ?? '(제목 없음)';
      final key = 'book_chapters_$bookId';
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) continue;

      final decoded = jsonDecode(raw);
      if (decoded is! List) continue;

      for (final e in decoded) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);

        final chapterTitle = (m['title'] as String?) ?? '';
        final chapterIndex = (m['index'] as num?)?.toInt() ?? 0;
        final updatedStr = m['updatedAt'] as String?;
        final updatedAt =
            (updatedStr != null && updatedStr.isNotEmpty)
                ? DateTime.tryParse(updatedStr)
                : null;

        merged.add(
          GenreEpisodeItem(
            bookId: bookId,
            bookTitle: bookTitle,
            chapterTitle: chapterTitle,
            chapterIndex: chapterIndex,
            updatedAt: updatedAt,
          ),
        );
      }
    }

    merged.sort((a, b) {
      final at = a.updatedAt?.millisecondsSinceEpoch ?? 0;
      final bt = b.updatedAt?.millisecondsSinceEpoch ?? 0;
      return bt.compareTo(at);
    });

    return merged;
  }
}
