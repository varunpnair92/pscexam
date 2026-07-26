class TimelineEvent {
  final int kid;
  final String keyword;
  final String description;
  final String summary;
  final String category;

  TimelineEvent({
    required this.kid,
    required this.keyword,
    required this.description,
    required this.summary,
    required this.category,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      kid: json['kid'] is int
          ? json['kid']
          : int.tryParse(json['kid']?.toString() ?? "0") ?? 0,
      keyword: (json['keyword'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
      summary: (json['summary'] ?? '').toString().trim(),
      category: (json['category'] ?? '').toString().trim(),
    );
  }
}

class TimelineYear {
  final String year;
  final List<TimelineEvent> events;

  TimelineYear({
    required this.year,
    required this.events,
  });

  factory TimelineYear.fromJson(Map<String, dynamic> json) {
    List<TimelineEvent> evList = [];
    if (json['events'] != null && json['events'] is List) {
      evList = (json['events'] as List)
          .map((e) => TimelineEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return TimelineYear(
      year: (json['year'] ?? 'Unknown').toString().trim(),
      events: evList,
    );
  }
}
