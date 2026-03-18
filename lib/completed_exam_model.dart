class CompletedExam {
  final int examids;
  final String examName;
  final String category;
  final String type;
  final int mark;
  final int attempt;

  CompletedExam({
    required this.examids,
    required this.examName,
    required this.category,
    required this.type,
    required this.mark,
    required this.attempt,
  });

  factory CompletedExam.fromJson(Map<String, dynamic> json) {
    return CompletedExam(
      examids: json['exam_id'],   // 🔥 FIX
      examName: json['exam_name'] ?? "",
      category: json['category'] ?? "",
      type: json['type'] ?? "",
      mark: json['mark'],
      attempt: json['attempt'],
    );
  }
}