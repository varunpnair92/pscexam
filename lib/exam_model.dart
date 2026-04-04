class Exam {
  final int id;
  final String category;
  final String specialization;
  final bool locked;
  final int totalQuestions;
  final String accessType; // 🔥 ADD THIS

  Exam({
    required this.id,
    required this.category,
    required this.specialization,
    required this.locked,
    required this.totalQuestions,
    required this.accessType, // 🔥 ADD THIS
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    // Calculate total from qid list if available
    int total = 0;
    if (json['qid'] != null && json['qid'] is List) {
      total = (json['qid'] as List).length;
    }

    return Exam(
      id: json['id'],
      category: json['category'],
      specialization: json['specialization'],
      locked: json['locked'] ?? false,
      totalQuestions: total,
      accessType: (json['access_type'] ?? json['accessType'] ?? "free").toString().toLowerCase(),
    );
  }
}