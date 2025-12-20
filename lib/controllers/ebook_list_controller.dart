// lib/controllers/ebook_list_controller.dart
import '../models/memo.dart';
import '../services/ebook_service.dart';
import '../utils/delta_utils.dart';

class EbookListController {
  EbookListController({required this.service});

  final EbookService service;

  // 상태
  final List<Map<String, dynamic>> ebooks = [];
  int nextId = 1;

  bool selectionMode = false;
  final Set<int> selectedIndices = {};

  List<Memo> allMemosCache = [];
  List<MemoPreviewItem> memoPreview = [];

  static const int previewMaxLen = 30;

  Future<void> init() async {
    await reloadEbooks();
    await reloadMemos();
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

  Future<void> reloadMemos() async {
    allMemosCache = await service.loadMemos();
    final items = <MemoPreviewItem>[];
    for (var i = 0; i < allMemosCache.length; i++) {
      items.add(MemoPreviewItem(index: i, memo: allMemosCache[i]));
    }
    items.sort((a, b) => b.memo.updatedAt.compareTo(a.memo.updatedAt));
    memoPreview = items;
  }

  String deltaToPreview(Map<String, dynamic> ebook) {
    final delta = (ebook['delta'] as List).cast<Map<String, dynamic>>();
    return plainFromDelta(delta, maxLen: previewMaxLen);
  }

  // 선택 모드
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

  Future<bool> editMemoInlineAt(int previewIndex, String newText) async {
    if (previewIndex < 0 || previewIndex >= memoPreview.length) return false;
    final target = memoPreview[previewIndex];
    final idx = target.index;
    if (idx < 0 || idx >= allMemosCache.length) {
      await reloadMemos();
      return false;
    }
    allMemosCache[idx] = Memo(newText, DateTime.now());
    await service.saveMemos(allMemosCache);
    await reloadMemos();
    return true;
  }
}

class MemoPreviewItem {
  final int index;
  final Memo memo;
  const MemoPreviewItem({required this.index, required this.memo});
}
