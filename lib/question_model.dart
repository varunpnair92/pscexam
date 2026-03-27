class Question {
  final int id;
  final String question;
  final List options;
  final String answer;
  final String description;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    required this.description,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> opts = [];

    // 1. Try options array
    if (json['options'] != null && json['options'] is List) {
      opts = List<String>.from(json['options'].map((e) => e.toString()));
    }

    // 2. Try option1-4 fields if list is empty
    if (opts.isEmpty) {
      final fields = [json['option1'], json['option2'], json['option3'], json['option4']];
      opts = fields
          .where((o) => o != null && o.toString().trim().isNotEmpty)
          .map((o) => o.toString())
          .toList();
    }

    // 3. Fallback for correct answer if still empty
    if (opts.isEmpty) {
      String correct = (json['answer'] ?? "").toString().trim();
      if (correct.isNotEmpty) opts.add(correct);
    }

    // 4. Pad to 4 options
    int dummy = 1;
    while (opts.length < 4) {
      opts.add("Option $dummy");
      dummy++;
    }

    return Question(
      id: json['id'] ?? 0,
      question: (json['question'] ?? "No Question Text").toString(),
      options: opts,
      answer: (json['answer'] ?? "").toString(),
      description: (json["description"] ?? "").toString(),
    );
  }
}