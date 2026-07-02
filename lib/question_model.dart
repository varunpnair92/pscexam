class Question {
  final int id;
  final String category;
  final String question;
  final String? questionImage;
  final List<String> options;
  final List<String?> optionImages;
  final String answer;
  final String description;

  Question({
    required this.id,
    this.category = "Unknown",
    required this.question,
    this.questionImage,
    required this.options,
    required this.optionImages,
    required this.answer,
    required this.description,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> opts = [];
    List<String?> optImages = [
      json['option1_image']?.toString(),
      json['option2_image']?.toString(),
      json['option3_image']?.toString(),
      json['option4_image']?.toString(),
    ];

    // 1. Try options array
    if (json['options'] != null && json['options'] is List) {
      opts = List<String>.from(json['options'].map((e) => e.toString()));
    }

    // 2. Try option1-4 fields if list is empty
    if (opts.isEmpty) {
      final fields = [json['option1'], json['option2'], json['option3'], json['option4']];
      for (int i = 0; i < fields.length; i++) {
        if (fields[i] != null && fields[i].toString().trim().isNotEmpty) {
          opts.add(fields[i].toString());
        } else {
          opts.add("Option ${i + 1}");
        }
      }
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
      category: (json['category'] ?? "Unknown").toString(),
      question: (json['question'] ?? "No Question Text").toString(),
      questionImage: json['question_image']?.toString(),
      options: opts,
      optionImages: optImages,
      answer: (json['answer'] ?? "").toString(),
      description: (json["description"] ?? "").toString(),
    );
  }
}