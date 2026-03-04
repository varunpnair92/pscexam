import 'package:get/get.dart';

class StudyExamController extends GetxController {

  var questions = [].obs;

  var index = 0.obs;

  var answers = <int, String>{}.obs;

  var review = <int>{}.obs;

  void load(List qlist) {
    questions.value = qlist;
    index.value = 0;
    answers.clear();
    review.clear();
  }

  List<dynamic> buildOptions(Map q) {

    List opts = [];

    if (q["options"] != null && q["options"].length >= 4) {
      opts = List<String>.from(q["options"]);
    } else {

      String correct = q["answer"] ?? "";

      opts = [
        correct,
        "Option 1",
        "Option 2",
        "Option 3"
      ];
    }

    opts.shuffle();

    return opts;
  }

  void select(String ans) {
    answers[index.value] = ans;
  }

  void next() {
    if (index.value < questions.length - 1) {
      index.value++;
    }
  }

  void prev() {
    if (index.value > 0) {
      index.value--;
    }
  }

  void markReview() {
    review.add(index.value);
  }

}