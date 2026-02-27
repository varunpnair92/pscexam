import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'question_model.dart';
import 'app_config.dart';

enum QuestionStatus { unseen, answered, review }

class TestController extends GetxController {

  final String userId = "varunpnair92@gmail.com";

  var questions = <Question>[].obs;
  var current = 0.obs;

  var answers = <int, String>{}.obs;
  var status = <int, QuestionStatus>{}.obs;

  var snapshot = <String, dynamic>{}.obs;

  int examId = 0;

  // ================= LOAD QUESTIONS (NEW EXAM) =================

  Future<void> loadQuestions(int id) async {
    examId = id;

    answers.clear();
    status.clear();
    current.value = 0;

    final res = await http.get(
      Uri.parse("${AppConfig.testExam}$examId/"),
    );

    if (res.statusCode == 200) {
      List data = json.decode(res.body);
      questions.value =
          data.map((e) => Question.fromJson(e)).toList();
    }
  }

  // ⭐ LOAD QUESTIONS WITHOUT RESET (FOR RESUME)

  Future<void> loadQuestionsOnly(int id) async {
    examId = id;

    final res = await http.get(
      Uri.parse("${AppConfig.testExam}$examId/"),
    );

    if (res.statusCode == 200) {
      List data = json.decode(res.body);
      questions.value =
          data.map((e) => Question.fromJson(e)).toList();
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

  double get percentage =>
      total == 0 ? 0 : (correct / total) * 100;

  // ================= SELECT ANSWER =================

  void selectAnswer(String ans) {
    answers[current.value] = ans;
    status[current.value] = QuestionStatus.answered;

    saveProgress(); // 🔥 AUTO SAVE

    if (current.value < questions.length - 1) {
      current.value++;
    }
  }

  // ================= MARK REVIEW =================

  void markReview() {
    status[current.value] = QuestionStatus.review;
    saveProgress();
  }

  // ================= NAVIGATION =================

  void next() {
    if (current.value < questions.length - 1) {
      current.value++;
      saveProgress();
    }
  }

  void previous() {
    if (current.value > 0) {
      current.value--;
      saveProgress();
    }
  }

  void jumpTo(int index) {
    current.value = index;
    saveProgress();
  }

  // ================= PALETTE COLORS =================

  Color getColor(int index) {

    if (!status.containsKey(index)) {
      return Colors.grey.shade300; // unseen
    }

    switch (status[index]) {
      case QuestionStatus.answered:
        return Colors.blue;

      case QuestionStatus.review:
        return Colors.orange;

      default:
        return Colors.grey.shade300;
    }
  }

  // ================= REVIEW COLOR =================

  Color getReviewColor(int index, String option) {
    var q = questions[index];
    var userAns = answers[index];

    if (option == q.answer) return Colors.green;

    if (option == userAns && userAns != q.answer) {
      return Colors.red;
    }

    return Colors.grey.shade200;
  }

  // ================= SNAPSHOT =================

  Map<String, dynamic> buildSnapshot() {
    Map<String, dynamic> data = {};

    for (int i = 0; i < questions.length; i++) {
      data[i.toString()] = {
        "question": questions[i].question,
        "options": questions[i].options,
        "selected": answers[i],
        "correct": questions[i].answer,
      };
    }

    return data;
  }

  // ================= SUBMIT RESULT =================

  Future<void> submitResult() async {
    final snap = buildSnapshot();

    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}jsoninsertapi"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userid": userId,
        "examids": examId,
        "qresponse": snap,
        "mark": correct,
      }),
    );

    print(response.body);

    clearProgress(); // 🔥 CLEAR AFTER SUBMIT
  }

  // ================= FETCH RESULT =================

  Future<void> fetchResult() async {
    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}getresultapi"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userid": userId,
        "examids": examId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      snapshot.value =
          Map<String, dynamic>.from(data['qresponse']);
    }
  }

  // ================= RESUME FEATURE =================

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt("examId", examId);
    prefs.setInt("current", current.value);

    prefs.setString("answers", jsonEncode(
      answers.map((k, v) => MapEntry(k.toString(), v))
    ));

    prefs.setString("status", jsonEncode(
      status.map((k, v) => MapEntry(k.toString(), v.index))
    ));
  }

  Future<bool> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("examId")) return false;

    examId = prefs.getInt("examId")!;
    current.value = prefs.getInt("current") ?? 0;

    String? ansStr = prefs.getString("answers");
    if (ansStr != null) {
      Map<String, dynamic> map = jsonDecode(ansStr);
      answers.value = map.map(
        (k, v) => MapEntry(int.parse(k), v),
      );
    }

    String? statStr = prefs.getString("status");
    if (statStr != null) {
      Map<String, dynamic> map = jsonDecode(statStr);
      status.value = map.map(
        (k, v) => MapEntry(
          int.parse(k),
          QuestionStatus.values[v],
        ),
      );
    }

    await loadQuestionsOnly(examId);

    return true;
  }

  Future<bool> hasProgressForExam(int id) async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("examId")) return false;

    int savedExamId = prefs.getInt("examId")!;
    return savedExamId == id;
  }

  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}