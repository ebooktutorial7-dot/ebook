// services/ebook_service.dart

import '../data/ebook_storage.dart';
import '../data/memo_storage.dart';
import '../data/episode_storage.dart';

import '../models/memo.dart';
import '../models/episode.dart';
import '../models/genre.dart';

class EbookService {
  // =========================
  // 📚 Ebook
  // =========================

  Future<List<Map<String, dynamic>>> loadEbooks() async {
    return await EbookStorage.load();
  }

  Future<void> saveEbooks(List<Map<String, dynamic>> ebooks) async {
    await EbookStorage.save(ebooks);
  }

  // =========================
  // 📝 Memo (장르별)
  // =========================

  Future<List<Memo>> loadMemos({required Genre genre}) async {
    return await MemoStorage.load(key: 'memo_${genre.name}');
  }

  Future<void> saveMemos(List<Memo> memos, {required Genre genre}) async {
    await MemoStorage.save(memos, key: 'memo_${genre.name}');
  }

  // =========================
  // 📖 Episodes (장르별)
  // =========================

  Future<List<Episode>> loadEpisodes({required Genre genre}) async {
    return await EpisodeStorage.load(genreName: genre.name);
  }

  Future<void> saveEpisodes(
    List<Episode> episodes, {
    required Genre genre,
  }) async {
    await EpisodeStorage.save(episodes, genreName: genre.name);
  }
}
