import 'dart:async';
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
  Timer? timer; // 🔥 nullable for safety

  var remainingSeconds = 0.obs;
  var totalSeconds = 0;

  bool isLocalExam = false;

  // ================= LOAD QUESTIONS (NEW EXAM) =================

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

    remainingSeconds.value = 0;
    startTimer();
  }

  // ================= LOAD QUESTIONS ONLY (RESUME) =================

  Future<void> loadQuestionsOnly(int id) async {
    examId = id;

    final res = await http.get(Uri.parse("${AppConfig.testExam}$examId/"));

    if (res.statusCode == 200) {
      List data = json.decode(res.body);
      questions.value = data.map((e) => Question.fromJson(e)).toList();
    }
  }

  // ================= TIMER =================

  void startTimer() {
    // 🔥 Cancel previous timer if exists
    timer?.cancel();

    // If resumed exam → remainingSeconds already loaded
    if (remainingSeconds.value == 0) {
      totalSeconds = questions.length * 45;
      remainingSeconds.value = totalSeconds;
    }

    timer = Timer.periodic(Duration(seconds: 1), (t) async {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;

        // ⭐ KEEP YOUR FEATURE — save every second
        saveProgress();
      } else {
        timer?.cancel();

        await submitResult();
        await clearProgress(examId);

        Get.offAllNamed('/analysis');
        Get.snackbar("Time Up", "Exam auto submitted");
      }
    });
  }

  // ================= RESULT CALCULATIONS =================

  int get total => questions.length;
  int get attempted => answers.length;
  int get notAttempted => total - attempted;

  int get correct {
    int c = 0;
    for (int i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i].answer) c++;
    }
    return c;
  }

  int get wrong => attempted - correct;
  double get percentage => total == 0 ? 0 : (correct / total) * 100;

  // ================= SELECT ANSWER =================

  Future<void> selectAnswer(String ans) async {
    answers[current.value] = ans;
    status[current.value] = QuestionStatus.answered;

    saveProgress();

    // 🕒 WAIT 400 ms so user sees selection
    await Future.delayed(Duration(milliseconds: 400));

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
    if (!status.containsKey(index)) return Colors.grey.shade300;

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
    if (option == userAns && userAns != q.answer) return Colors.red;

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

  snapshot.value = snap;

  // 🔥 Send to server only for real exam
  if (!isLocalExam) {

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

    await clearProgress(examId);
  }

  Get.offAllNamed('/review');
}

  // ================= FETCH RESULT =================

  Future<void> fetchResult() async {
    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}getresultapi"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userid": userId, "examids": examId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      snapshot.value = Map<String, dynamic>.from(data['qresponse']);
    }
  }

  // ================= SAVE PROGRESS (PER EXAM) =================

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt("exam_${examId}_current", current.value);

    prefs.setString(
      "exam_${examId}_answers",
      jsonEncode(answers.map((k, v) => MapEntry(k.toString(), v))),
    );

    prefs.setString(
      "exam_${examId}_status",
      jsonEncode(status.map((k, v) => MapEntry(k.toString(), v.index))),
    );

    prefs.setInt("exam_${examId}_remainingSeconds", remainingSeconds.value);
  }

  // ================= LOAD PROGRESS =================

  Future<bool> loadProgress(int id) async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("exam_${id}_current")) return false;

    examId = id;

    current.value = prefs.getInt("exam_${id}_current") ?? 0;
    remainingSeconds.value = prefs.getInt("exam_${id}_remainingSeconds") ?? 0;

    // restore answers
    String? ansStr = prefs.getString("exam_${id}_answers");
    if (ansStr != null) {
      Map<String, dynamic> map = jsonDecode(ansStr);
      answers.value = map.map((k, v) => MapEntry(int.parse(k), v));
    }

    // restore status
    String? statStr = prefs.getString("exam_${id}_status");
    if (statStr != null) {
      Map<String, dynamic> map = jsonDecode(statStr);
      status.value = map.map(
        (k, v) => MapEntry(int.parse(k), QuestionStatus.values[v]),
      );
    }

    await loadQuestionsOnly(id);
    startTimer();

    return true;
  }

  Future<bool> hasProgressForExam(int id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("exam_${id}_current");
  }

  // ================= CLEAR PROGRESS =================

  Future<void> clearProgress(int id) async {
    timer?.cancel();

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("exam_${id}_current");
    await prefs.remove("exam_${id}_answers");
    await prefs.remove("exam_${id}_status");
    await prefs.remove("exam_${id}_remainingSeconds");
  }

//=================local exam=================
void loadLocalQuestions(List qlist) {

  isLocalExam = true;

  answers.clear();
  status.clear();
  current.value = 0;

  questions.value = qlist.map((q) {

    List<String> opts = [];

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

      opts.shuffle();
    }

    return Question(
      id: q["id"] ?? qlist.indexOf(q),
      question: q["question"],
      options: opts,
      answer: q["answer"],
    );

  }).toList();

  remainingSeconds.value = questions.length * 45;

  startTimer();
}
}
