// lib/models/memo.dart
class Memo {
  final String text;
  final DateTime updatedAt;

  const Memo(this.text, this.updatedAt);

  Map<String, dynamic> toJson() => {
    'text': text,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      (json['text'] as String?) ?? '',
      DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
