// controllers/ebook_list_controller.dart

import 'package:ebook_tutorial_app/models/genre.dart';

import '../models/memo.dart';
import '../services/ebook_service.dart';
import '../utils/delta_utils.dart';

class EbookListController {
  EbookListController({required this.service});

  final EbookService service;

  final List<Map<String, dynamic>> ebooks = [];
  int nextId = 1;

  bool selectionMode = false;
  final Set<int> selectedIndices = {};

  final Map<Genre, List<Memo>> allMemosCacheByGenre = {};
  final Map<Genre, List<MemoPreviewItem>> memoPreviewByGenre = {};

  static const int previewMaxLen = 30;

  Future<void> init() async {
    await reloadEbooks();

    for (final g in Genre.values) {
      await reloadMemos(genre: g);
    }
  }

  Future<void> reloadEbooks() async {
    final loaded = await service.loadEbooks();
    ebooks
      ..clear()
      ..addAll(loaded.map((e) => Map<String, dynamic>.from(e)));

    nextId = ebooks.fold<int>(1, (prev, e) {
      final id = (e['id'] ?? 0) as int;
      return id >= prev ? id + 1 : prev;
    });
  }

  Future<void> persistEbooks() async => service.saveEbooks(ebooks);

  Future<void> reloadMemos({required Genre genre}) async {
    final loaded = await service.loadMemos(genre: genre);
    allMemosCacheByGenre[genre] = loaded;

    final items = <MemoPreviewItem>[];
    for (var i = 0; i < loaded.length; i++) {
      items.add(MemoPreviewItem(index: i, memo: loaded[i]));
    }
    items.sort((a, b) => b.memo.updatedAt.compareTo(a.memo.updatedAt));
    memoPreviewByGenre[genre] = items;
  }

  List<MemoPreviewItem> memoPreview(Genre genre) {
    return memoPreviewByGenre[genre] ?? const <MemoPreviewItem>[];
  }

  String deltaToPreview(Map<String, dynamic> ebook) {
    final delta = (ebook['delta'] as List).cast<Map<String, dynamic>>();
    return plainFromDelta(delta, maxLen: previewMaxLen);
  }

  void enterPickMode() {
    selectionMode = true;
    selectedIndices.clear();
  }

  void exitSelectionMode() {
    selectionMode = false;
    selectedIndices.clear();
  }

  Future<void> deleteSelected() async {
    final sorted = selectedIndices.toList()..sort((a, b) => b - a);
    for (final i in sorted) {
      if (i >= 0 && i < ebooks.length) {
        ebooks.removeAt(i);
      }
    }
    exitSelectionMode();
    await persistEbooks();
  }

  Future<void> onReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = ebooks.removeAt(oldIndex);
    ebooks.insert(newIndex, item);
    await persistEbooks();
  }

  Future<void> addFreeForm({
    required String title,
    required List<dynamic> delta,
    required List<Map<String, dynamic>> drawings,
  }) async {
    ebooks.add({
      'id': nextId++,
      'title': title,
      'delta': delta,
      'drawings': drawings,
    });
    await persistEbooks();
  }

  Future<void> editEbookAt({
    required int index,
    required String title,
    required List<dynamic> delta,
    required List<Map<String, dynamic>> drawings,
  }) async {
    if (index < 0 || index >= ebooks.length) return;
    ebooks[index] = {
      'id': ebooks[index]['id'],
      'title': title,
      'delta': delta,
      'drawings': drawings,
    };
    await persistEbooks();
  }

  Future<bool> editMemoInlineAt({
    required Genre genre,
    required int previewIndex,
    required String newText,
  }) async {
    final previewList = memoPreviewByGenre[genre] ?? const <MemoPreviewItem>[];
    final cache = allMemosCacheByGenre[genre] ?? <Memo>[];

    if (previewIndex < 0 || previewIndex >= previewList.length) return false;

    final target = previewList[previewIndex];
    final idx = target.index;

    if (idx < 0 || idx >= cache.length) {
      await reloadMemos(genre: genre);
      return false;
    }

    cache[idx] = Memo(newText, DateTime.now());
    allMemosCacheByGenre[genre] = cache;

    await service.saveMemos(cache, genre: genre);
    await reloadMemos(genre: genre);
    return true;
  }
}

class MemoPreviewItem {
  final int index;
  final Memo memo;
  const MemoPreviewItem({required this.index, required this.memo});
}
