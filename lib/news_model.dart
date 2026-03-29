class NewsItem {
  final int id;
  final String title;
  final String content;
  final bool active;
  final DateTime date;

  NewsItem({
    required this.id,
    required this.title,
    required this.content,
    required this.active,
    required this.date,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      active: json['active'] ?? false,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
