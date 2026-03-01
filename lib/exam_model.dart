class Exam {
  final int id;
  final String category;
  final String specialization;
  final bool locked;   // 🔒 ADD THIS

  Exam({
    required this.id,
    required this.category,
    required this.specialization,
    required this.locked,   // 🔒 ADD
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      category: json['category'],
      specialization: json['specialization'],
      locked: json['locked'] ?? false,   // 🔒 SAFE DEFAULT
    );
  }
}