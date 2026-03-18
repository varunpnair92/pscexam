import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:psc_exam/completed_exam_model.dart';
import 'app_config.dart';



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
