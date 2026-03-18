import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class StudyController extends GetxController {
  /// FULL TREE
  var fullTree = [].obs;

  /// CURRENT LEVEL
  var items = [].obs;

  /// BREADCRUMB
  var keys = <String>[].obs;

  /// BACK STACK
  var stack = <dynamic>[].obs;

  var questions = [].obs;
  var description = "".obs;

  /// 🔥 NEW
  var descriptionPages = <String>[].obs;
  var currentPage = 0.obs;

  var showQuestions = false.obs;

  var examIndex = 0.obs;
  var examAnswers = <int, String>{}.obs;

  @override
  void onInit() {
    fetchTree();
    super.onInit();
  }

  /// 🔥 SPLIT DESCRIPTION INTO PAGES
  List<String> splitDescription(String text) {
    List<String> pages = [];

    List<String> paragraphs = text.split("\n");

    for (var para in paragraphs) {
      para = para.trim();
      if (para.isEmpty) continue;

      const int maxChars = 150;

      for (int i = 0; i < para.length; i += maxChars) {
        int end =
            (i + maxChars < para.length) ? i + maxChars : para.length;

        pages.add(para.substring(i, end));
      }
    }

    return pages;
  }

  /// LOAD TREE
  Future<void> fetchTree() async {
    final res = await http.get(Uri.parse(AppConfig.nodeall));
    final data = jsonDecode(res.body);

    fullTree.value = data;

    final ldcNode = data.firstWhere(
      (e) => e["name"] == "LDC",
      orElse: () => null,
    );

    if (ldcNode != null) {
      items.value = ldcNode["children"] ?? [];
    } else {
      items.value = [];
    }

    keys.clear();
    keys.add("LDC");
  }

  /// TILE CLICK
  void onTileTap(dynamic item) {
    final name = item["name"];

    if (item["url"] != null && item["url"] != "") {
      return;
    }

    if (item["children"] != null && item["children"].isNotEmpty) {
      stack.add(items.toList());
      items.assignAll(item["children"]);
      keys.add(name);
      return;
    }

    final navigation = item["navigation"];

    List<String> keywords = List<String>.from(item["keywords"] ?? []);
    String lastKeyword = keywords.isNotEmpty ? keywords.last : name;

    if (keywords.isEmpty) {
      keywords = [name];
    }

    fetchQuestionsByKeyword(keywords);
    fetchKeywordDescription(lastKeyword);

    showQuestions.value = true;
    keys.add(name);
  }

  /// BACK
  void goBack() {
    if (showQuestions.value) {
      showQuestions.value = false;
      questions.clear();
      descriptionPages.clear(); // 🔥 clear pages
      keys.removeLast();
      return;
    }

    if (stack.isNotEmpty) {
      items.assignAll(stack.removeLast());
      keys.removeLast();
    }
  }

  /// QUESTIONS
  Future<void> fetchQuestionsByKeyword(List<String> keywords) async {
    final res = await http.post(
      Uri.parse(AppConfig.keywordQuestions),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"keywords": keywords}),
    );

    if (res.statusCode == 200) {
      questions.value = jsonDecode(res.body);
    }
  }

  /// DESCRIPTION
  Future<void> fetchKeywordDescription(String keyword) async {
    try {
      final res = await http.get(
        Uri.parse("${AppConfig.keywordDesc}$keyword/"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        description.value = data["description"] ?? "";

        /// 🔥 SPLIT HERE
        descriptionPages.value =
            splitDescription(description.value);

        currentPage.value = 0;
      } else {
        description.value = "No description available";
      }
    } catch (e) {
      description.value = "Failed to load description";
    }
  }

  /// EXAM
  void selectExamAnswer(String ans) {
    examAnswers[examIndex.value] = ans;
  }

  void nextExam() {
    if (examIndex.value < questions.length - 1) {
      examIndex.value++;
    }
  }

  void previousExam() {
    if (examIndex.value > 0) {
      examIndex.value--;
    }
  }
}