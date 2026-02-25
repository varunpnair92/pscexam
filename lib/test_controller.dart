import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:psc_exam/app_config.dart';
import 'dart:convert';

import 'package:psc_exam/question_model.dart';

class TestController extends GetxController {
  var questions = <Question>[].obs;
  var current = 0.obs;
  var answers = <int, String>{}.obs;

  void loadQuestions(int examId) async {
    final res = await http.get(
      Uri.parse("${AppConfig.testExam}$examId/"), // 🔥 DYNAMIC URL
    );

    if (res.statusCode == 200) {
      List data = json.decode(res.body);
      questions.value = data.map((e) => Question.fromJson(e)).toList();
    }
  }

  void selectAnswer(String ans) {
    answers[current.value] = ans;
  }

  void next() {
    if (current.value < questions.length - 1) current.value++;
  }

  void previous() {
    if (current.value > 0) current.value--;
  }
}