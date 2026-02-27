import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:psc_exam/result_model.dart';
import 'dart:convert';

import 'app_config.dart';
import 'question_model.dart';

enum QuestionStatus { unseen, answered, review }

class TestController extends GetxController {
  var questions = <Question>[].obs;
  var current = 0.obs;

  var answers = <int, String>{}.obs;
  var status = <int, QuestionStatus>{}.obs;

  int examId = 0; // 🔥 STORE CURRENT EXAM ID
  final String userId = "varun@gmail.com";
  var result = Rxn<TestResult>(); // nullable reactive

  // ================= LOAD QUESTIONS =================

  Future<void> loadQuestions(int id) async {
    examId = id;

    answers.clear();
    status.clear();
    current.value = 0;

    final res = await http.get(Uri.parse("${AppConfig.testExam}$examId/"));

    if (res.statusCode == 200) {
      List data = json.decode(res.body);
      questions.value = data.map((e) => Question.fromJson(e)).toList();
    }
  }

  // ================= RESULT CALCULATIONS =================

  int get total => questions.length;

  int get attempted => answers.length;

  int get notAttempted => total - attempted;

  int get correct {
    int c = 0;
    for (int i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i].answer) {
        c++;
      }
    }
    return c;
  }

  int get wrong => attempted - correct;

  double get percentage => total == 0 ? 0 : (correct / total) * 100;

  // ================= SUBMIT RESULT =================

  Future<void> submitResult() async {
    int score = correct;

    // 🔥 CONVERT RxMap → Normal Map<String,String>
    final normalMap = answers.value.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}jsoninsertapi"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userid": userId,
        "examids": examId,
        "qresponse": normalMap, // ✅ NOW SAFE
        "mark": score,
      }),
    );

    print(response.body);
  }
  // ================= FETCH RESULT FOR REVIEW =================

  Future<void> fetchResult() async {
    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}getresultapi"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userid": userId, "examids": examId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      result.value = TestResult.fromJson(data);

      // 🔥 Also convert answers for review page
      answers.value = result.value!.qresponse.map(
        (key, value) => MapEntry(int.parse(key), value),
      );

      print("Result fetched");
    } else {
      print("Error fetching result");
    }
  }

  // ================= EXAM ACTIONS =================

  void selectAnswer(String ans) {
    answers[current.value] = ans;
    status[current.value] = QuestionStatus.answered;

    // 🔥 AUTO NEXT
    if (current.value < questions.length - 1) {
      current.value++;
    }
  }

  void markReview() {
    status[current.value] = QuestionStatus.review;
  }

  void next() {
    if (current.value < questions.length - 1) {
      current.value++;
    }
  }

  void previous() {
    if (current.value > 0) {
      current.value--;
    }
  }

  void jumpTo(int index) {
    current.value = index;
  }

  // ================= PALETTE COLOR =================

  Color getColor(int index) {
    switch (status[index]) {
      case QuestionStatus.answered:
        return Colors.blue;

      case QuestionStatus.review:
        return Colors.orange;

      case QuestionStatus.unseen:
        return Colors.grey.shade300;

      default:
        return Colors.grey;
    }
  }

  // ================= REVIEW COLOR LOGIC =================

  Color getReviewColor(int index, String option) {
    var q = questions[index];
    var userAns = answers[index];

    // 🟩 Correct answer
    if (option == q.answer) {
      return Colors.green;
    }

    // 🟥 Wrong selected answer
    if (option == userAns && userAns != q.answer) {
      return Colors.red;
    }

    return Colors.grey.shade200;
  }
}
