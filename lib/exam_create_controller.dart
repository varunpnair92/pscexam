import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'exam_model.dart';
import 'question_model.dart';

class ExamCreateController extends GetxController {
  final TextEditingController keywordController = TextEditingController();

  var currentKeyword = "".obs;
  var selectedCount = 10.obs;
  var isLoading = false.obs;
  var errorMessage = "".obs;

  String customEndpoint = "";
  var pageTitle = "Create Custom Exam".obs;

  final List<int> presetCounts = [5, 10, 15, 20, 25, 30];

  final List<String> suggestedKeywords = [
    "ഗാന്ധി",
    "കേരളം",
    "ഭരണഘടന",
    "നവോത്ഥാനം",
    "ചരിത്രം",
    "ശാസ്ത്രം",
    "സാഹിത്യം",
    "ഭൂമിശാസ്ത്രം",
  ];

  @override
  void onInit() {
    super.onInit();
    _handleArguments(Get.arguments);

    keywordController.addListener(() {
      currentKeyword.value = keywordController.text;
    });
  }

  void _handleArguments(dynamic args) {
    if (args == null) return;

    if (args is Map<String, dynamic>) {
      if (args['endpoint'] != null && args['endpoint'].toString().isNotEmpty) {
        customEndpoint = args['endpoint'].toString().trim();
      } else if (args['url'] != null && args['url'].toString().isNotEmpty) {
        customEndpoint = args['url'].toString().trim();
      }

      if (args['title'] != null && args['title'].toString().isNotEmpty) {
        pageTitle.value = args['title'].toString();
      }

      String kw = "";
      if (args['keyword'] != null && args['keyword'].toString().isNotEmpty) {
        kw = args['keyword'].toString().trim();
      } else if (args['keywords'] != null && args['keywords'] is List && (args['keywords'] as List).isNotEmpty) {
        kw = (args['keywords'] as List).last.toString().trim();
      }

      if (kw.isNotEmpty && kw.toLowerCase() != 'examcreate' && kw.toLowerCase() != '/examcreate') {
        keywordController.text = kw;
        currentKeyword.value = kw;
      }

      if (args['count'] != null) {
        final parsed = int.tryParse(args['count'].toString());
        if (parsed != null && parsed > 0) {
          selectedCount.value = parsed;
        }
      }
    }
  }

  void selectKeyword(String kw) {
    keywordController.text = kw;
    currentKeyword.value = kw;
  }

  void setCount(int count) {
    selectedCount.value = count;
  }

  void incrementCount() {
    if (selectedCount.value < 50) {
      selectedCount.value += (selectedCount.value % 5 == 0 ? 5 : 1);
    }
  }

  void decrementCount() {
    if (selectedCount.value > 5) {
      selectedCount.value -= (selectedCount.value % 5 == 0 ? 5 : 1);
    }
  }

  Future<void> generateExam() async {
    final keyword = currentKeyword.value.trim();
    if (keyword.isEmpty) {
      Get.snackbar(
        "Keyword Required",
        "Please enter or select a keyword to generate exam / ഒരു കീവേഡ് നൽകുക",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;
    errorMessage.value = "";

    try {
      String url = customEndpoint.isNotEmpty ? customEndpoint : AppConfig.createExamByKeyword;
      if (!url.startsWith('http')) {
        url = "${AppConfig.baseUrl}$url";
      }

      // Ensure URL path ends with trailing slash to satisfy Django APPEND_SLASH requirements on POST
      Uri uri = Uri.parse(url);
      if (!uri.path.endsWith('/')) {
        uri = uri.replace(path: '${uri.path}/');
      }
      url = uri.toString();

      final payload = jsonEncode({
        "keyword": keyword,
        "count": selectedCount.value,
      });

      final response = await http
          .post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: payload,
          )
          .timeout(const Duration(seconds: 25));

      Map<String, dynamic> data = {};
      try {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}

      if (response.statusCode == 200 || response.statusCode == 201) {
        final examMap = (data['exam'] is Map<String, dynamic>)
            ? Map<String, dynamic>.from(data['exam'])
            : <String, dynamic>{};

        final int examId = data['exam_id'] ?? examMap['id'] ?? 0;
        final String cat = data['category'] ?? examMap['category'] ?? keyword;
        final String spec = (examMap['specialization'] != null && examMap['specialization'].toString().isNotEmpty)
            ? examMap['specialization'].toString()
            : (data['keyword'] != null ? "Exam: ${data['keyword']}" : "Exam: $keyword");

        final int count = (data['qid'] is List)
            ? (data['qid'] as List).length
            : (data['question_count'] ?? (data['questions'] is List ? (data['questions'] as List).length : selectedCount.value));

        final Exam exam = Exam(
          id: examId,
          category: cat,
          specialization: spec,
          locked: examMap['locked'] == true || examMap['locked'] == "true" || examMap['locked'] == 1,
          totalQuestions: count,
          accessType: (examMap['access_type'] ?? examMap['accessType'] ?? "free").toString(),
          instructions: examMap['instructions']?.toString() ?? "Exam generated for keyword: $keyword",
          description: examMap['description']?.toString() ?? "Exam covering keyword '$keyword' with $count questions.",
          plans: examMap['plans'] ?? [],
        );

        List<Question> questions = [];
        if (data['questions'] != null && data['questions'] is List) {
          questions = (data['questions'] as List).map((q) => Question.fromJson(q)).toList();
        }

        // Navigate to the standard Exam Splash / Instruction page
        Get.toNamed('/examSplash', arguments: {
          'exam': exam,
          'questions': questions,
        });
      } else {
        final errorMsg = data['error'] ?? data['message'] ?? "Request failed with status ${response.statusCode}";
        errorMessage.value = errorMsg.toString();
        Get.snackbar(
          "Notice",
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      errorMessage.value = "Failed to connect to server. Please check your internet connection.";
      Get.snackbar(
        "Connection Error",
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    keywordController.dispose();
    super.onClose();
  }
}
