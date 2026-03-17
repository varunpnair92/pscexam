import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class CompletedExam {
  final int ids;
  final int examids;
  final String userid;
  final int mark;
  final int attempt;
  final String examName;

  CompletedExam({
    required this.ids,
    required this.examids,
    required this.userid,
    required this.mark,
    required this.attempt,
    required this.examName,
  });

  factory CompletedExam.fromJson(Map<String, dynamic> json) {
    return CompletedExam(
      ids: json['ids'] ?? 0,
      examids: json['examids'] ?? 0,
      userid: json['userid'] ?? '',
      mark: json['mark'] ?? 0,
      attempt: json['attempt'] ?? 1,
      // API might return exam_name or examname
      examName: json['exam_name'] ?? json['examname'] ?? 'Exam #${json['examids']}',
    );
  }
}

class ResultController extends GetxController {
  var exams = <CompletedExam>[].obs;
  var isLoading = true.obs;
  var errorMsg = ''.obs;

  final String userId = "varunpnair92@gmail.com";

  @override
  void onInit() {
    super.onInit();
    fetchLatestAttempts();
  }

  Future<void> fetchLatestAttempts() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final uri = Uri.parse(
        '${AppConfig.baseUrl}user-latest-attempts/?userid=${Uri.encodeQueryComponent(userId)}',
      );
      final res = await http.get(uri);
      
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        exams.value = data.map((e) => CompletedExam.fromJson(e)).toList();
      } else {
        errorMsg.value = 'Failed to load results. Server returned ${res.statusCode}';
      }
    } catch (e) {
      errorMsg.value = 'Failed to load results. Check connection.';
    } finally {
      isLoading.value = false;
    }
  }
}
