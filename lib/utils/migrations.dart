import 'package:shared_preferences/shared_preferences.dart';

/// v1 마이그레이션: documentId 네임스페이스 도입 전 남은 공용 키 정리
Future<void> migrateLegacyPrefsV1() async {
  final prefs = await SharedPreferences.getInstance();
  const flagKey = 'legacy_cleanup_v1_done';

  // 이미 한 번 정리했다면 재실행 안 함
  final done = prefs.getBool(flagKey) ?? false;
  if (done) return;

  // 기존 공용 키 제거
  await prefs.remove('book_title');
  await prefs.remove('book_pen');
  await prefs.remove('book_chapters');
  await prefs.remove('book_sort');

  // 완료 표시
  await prefs.setBool(flagKey, true);
}
