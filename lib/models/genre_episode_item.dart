// genre_episode_item.dart

class GenreEpisodeItem {
  final String bookId;
  final String bookTitle;
  final String chapterTitle;
  final int chapterIndex;
  final DateTime? updatedAt;

  GenreEpisodeItem({
    required this.bookId,
    required this.bookTitle,
    required this.chapterTitle,
    required this.chapterIndex,
    required this.updatedAt,
  });
}
