class Exam {
  final int id;
  final String category;
  final String specialization;
  final bool locked;
  final int totalQuestions;
  final String accessType; // 🔥 ADD THIS
  final String? instructions;
  final String? description;
  final List<dynamic> plans; // 💎 Subscription Plans
  final String type;
  final DateTime? startTime;
  final bool resultPublished;

  Exam({
    required this.id,
    required this.category,
    required this.specialization,
    required this.locked,
    required this.totalQuestions,
    required this.accessType, // 🔥 ADD THIS
    this.instructions,
    this.description,
    this.plans = const [],
    this.type = "mock",
    this.startTime,
    this.resultPublished = false,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    // Calculate total from qid list or questions if available
    int total = 0;
    if (json['qid'] != null && json['qid'] is List) {
      total = (json['qid'] as List).length;
    } else if (json['questions'] != null && json['questions'] is List) {
      total = (json['questions'] as List).length;
    } else if (json['question_count'] != null) {
      total = int.tryParse(json['question_count'].toString()) ?? 0;
    }

    String categoryStr = (json['category'] ?? "Exam").toString();
    String spec = (json['specialization'] ?? "").toString().trim();
    if (spec.isEmpty) {
      spec = categoryStr.isNotEmpty ? categoryStr : "Exam";
    }

    DateTime? parsedStartTime;
    if (json['start_time'] != null && json['start_time'].toString().isNotEmpty) {
      try {
        parsedStartTime = DateTime.parse(json['start_time'].toString());
      } catch (_) {}
    } else if (json['startTime'] != null && json['startTime'].toString().isNotEmpty) {
      try {
        parsedStartTime = DateTime.parse(json['startTime'].toString());
      } catch (_) {}
    }

    return Exam(
      id: json['id'] ?? json['exam_id'] ?? 0,
      category: categoryStr,
      specialization: spec,
      locked: json['locked'] == true || json['locked'] == "true" || json['locked'] == 1,
      totalQuestions: total,
      accessType: (json['access_type'] ?? json['accessType'] ?? "free").toString().toLowerCase(),
      instructions: json['instructions']?.toString(),
      description: json['description']?.toString(),
      plans: json['plans'] ?? [],
      type: (json['type'] ?? 'mock').toString(),
      startTime: parsedStartTime,
      resultPublished: json['result_published'] == true || json['result_published'] == "true" || json['result_published'] == 1,
    );
  }
}