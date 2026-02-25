class Exam {
  final int id;
  final String category;
  final String specialization;

  Exam({
    required this.id,
    required this.category,
    required this.specialization,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      category: json['category'],
      specialization: json['specialization'],
    );
  }
}