// lib/services/ebook_service.dart
import '../data/ebook_storage.dart';
import '../data/memo_storage.dart';
import '../models/memo.dart';

class EbookService {
  Future<List<Map<String, dynamic>>> loadEbooks() async {
    return await EbookStorage.load();
  }

  Future<void> saveEbooks(List<Map<String, dynamic>> ebooks) async {
    await EbookStorage.save(ebooks);
  }

  Future<List<Memo>> loadMemos() async {
    return List<Memo>.from(await MemoStorage.load());
  }

  Future<void> saveMemos(List<Memo> memos) async {
    await MemoStorage.save(memos);
  }
}
