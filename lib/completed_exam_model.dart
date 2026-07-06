class CompletedExam {
  final int examids;
  final String examName;
  final String category;
  final String type;
  final int mark;
  final int attempt;
  final int totalTime;

  CompletedExam({
    required this.examids,
    required this.examName,
    required this.category,
    required this.type,
    required this.mark,
    required this.attempt,
    required this.totalTime,
  });

  factory CompletedExam.fromJson(Map<String, dynamic> json) {
    int parsedTime = 0;
    if (json['time_taken'] != null) {
      if (json['time_taken'] is Map) {
        parsedTime = json['time_taken']['Total'] ?? 0;
      } else if (json['time_taken'] is int) {
        parsedTime = json['time_taken'];
      }
    } else if (json['total_time'] != null) {
      parsedTime = json['total_time'];
    }

    return CompletedExam(
      examids: json['exam_id'],   // 🔥 FIX
      examName: json['exam_name'] ?? "",
      category: json['category'] ?? "",
      type: json['type'] ?? "",
      mark: json['mark'] ?? 0,
      attempt: json['attempt'] ?? 0,
      totalTime: parsedTime,
    );
  }
}