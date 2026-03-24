import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:psc_exam/completed_exam_model.dart';
import 'app_config.dart';

class ResultController extends GetxController {
  var exams = <CompletedExam>[].obs;
  var isLoading = false.obs;
  var errorMsg = "".obs;

  final int userId = 1; // 🔥 use dynamic later

  Future<void> fetchLatestAttempts() async {
    try {
      isLoading.value = true;
      errorMsg.value = "";

      final res = await http.get(
        Uri.parse(
          "${AppConfig.baseUrl}user-latest-attempts/?userid=$userId",
        ),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        exams.value = List<CompletedExam>.from(
          data.map((e) => CompletedExam.fromJson(e)),
        );
      } else {
        errorMsg.value = "Failed to load results";
      }
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    fetchLatestAttempts(); // 🔥 auto load
    super.onInit();
  }
}