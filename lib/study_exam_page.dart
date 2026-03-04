import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exam_page.dart';

class StudyExamPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final List questions = Get.arguments ?? [];

    return ExamPage();
  }
}