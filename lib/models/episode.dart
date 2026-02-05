// models/episode.dart

class Episode {
  final String title;
  final DateTime updatedAt;

  Episode(this.title, this.updatedAt);

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      json['title'] as String,
      DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'updatedAt': updatedAt.toIso8601String(),
  };
}
