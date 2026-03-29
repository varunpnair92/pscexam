class CharacteristicQuestion {
  final int id;
  final String question;
  final String questionManglish;
  final String category;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final String answer;
  final String description;

  CharacteristicQuestion({
    required this.id,
    required this.question,
    required this.questionManglish,
    required this.category,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.answer,
    required this.description,
  });

  factory CharacteristicQuestion.fromJson(Map<String, dynamic> json) {
    return CharacteristicQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      questionManglish: json['questionmanglish'] ?? '',
      category: json['category'] ?? '',
      option1: json['option1'] ?? '',
      option2: json['option2'] ?? '',
      option3: json['option3'] ?? '',
      option4: json['option4'] ?? '',
      answer: json['answer'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
