import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:psc_exam/app_config.dart';
import 'dart:convert';

import 'package:psc_exam/question_model.dart';

enum QuestionStatus { unseen, answered, review }

class TestController extends GetxController {
  var questions = <Question>[].obs;
  var current = 0.obs;

  var answers = <int, String>{}.obs;
  var status = <int, QuestionStatus>{}.obs;

  // 🔥 LOAD QUESTIONS FROM API
  Future<void> loadQuestions(int examId) async {
    final res = await http.get(
      Uri.parse("${AppConfig.testExam}$examId/"),
    );

    if (res.statusCode == 200) {
      List data = json.decode(res.body);
      questions.value =
          data.map((e) => Question.fromJson(e)).toList();
    }
  }

  // Select answer
  void selectAnswer(String ans) {
  answers[current.value] = ans;
  status[current.value] = QuestionStatus.answered;

  // 🔥 AUTO MOVE TO NEXT QUESTION
  if (current.value < questions.length - 1) {
    current.value++;
  }
}

  // Mark for review ⭐
  void markReview() {
    status[current.value] = QuestionStatus.review;
  }

  // Next question
  void next() {
    if (current.value < questions.length - 1) {
      current.value++;
    }
  }

  // Previous question
  void previous() {
    if (current.value > 0) {
      current.value--;
    }
  }

  // Jump from palette
  void jumpTo(int index) {
    current.value = index;
  }
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
}