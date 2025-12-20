// delta_utils.dart

/// 텍스트 → Delta
List<Map<String, dynamic>> deltaFromPlain(String text) {
  final normalized = text.endsWith('\n') ? text : '$text\n';
  return [
    {'insert': normalized},
  ];
}

/// Delta → 텍스트(미리보기용)
String plainFromDelta(List<Map<String, dynamic>> delta, {int maxLen = 80}) {
  final buffer = StringBuffer();
  for (final op in delta) {
    final ins = op['insert'];
    if (ins is String) buffer.write(ins);
  }
  final txt = buffer.toString().replaceAll('\n', ' ').trim();
  if (txt.length <= maxLen) return txt;
  return '${txt.substring(0, maxLen)}…';
}
