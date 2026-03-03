import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:psc_exam/app_config.dart';
import 'dart:convert';

import 'package:psc_exam/exam_model.dart';

class ExamController extends GetxController {
  var exams = <Exam>[].obs;

  @override
  void onInit() {
    fetchExams();
    super.onInit();
  }

  void fetchExams() async {
    final res = await http.get(
      Uri.parse(AppConfig.listExams), // 🔥 USE SHARED URL
    );

    if (res.statusCode == 200) {
      List data = json.decode(res.body);
      exams.value = data.map((e) => Exam.fromJson(e)).toList();
    }
  }

  Future<void> loadFromEndpoint(String endpoint) async {
  exams.clear();

  final res = await http.get(
    Uri.parse(AppConfig.baseUrl + endpoint),
  );

  if (res.statusCode == 200) {
    List data = jsonDecode(res.body);
    exams.value = data.map((e) => Exam.fromJson(e)).toList();
  }
}
}