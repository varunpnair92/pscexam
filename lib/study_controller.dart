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

  var showQuestions = false.obs;

  var examIndex = 0.obs;
  var examAnswers = <int, String>{}.obs;

  @override
  void onInit() {
    fetchTree();
    super.onInit();
  }

  /// LOAD TREE
  /// LOAD TREE
  Future<void> fetchTree() async {
    final res = await http.get(Uri.parse(AppConfig.nodeall));

    final data = jsonDecode(res.body);

    fullTree.value = data;

    /// 🔎 Find LDC node
    final ldcNode = data.firstWhere(
      (e) => e["name"] == "LDC",
      orElse: () => null,
    );

    if (ldcNode != null) {
      items.value = ldcNode["children"] ?? [];
    } else {
      items.value = [];
    }

    /// Breadcrumb start
    keys.clear();
    keys.add("LDC");
  }

  /// TILE CLICK
  void onTileTap(dynamic item) {
    final name = item["name"];

    /// ACTION API
    if (item["url"] != null && item["url"] != "") {
      // print("Call API ${item["url"]}");
      return;
    }

    /// HAS CHILDREN
    if (item["children"] != null && item["children"].isNotEmpty) {
      // 🔥 PUSH COPY (important)
      stack.add(items.toList());

      // 🔥 UPDATE ITEMS
      items.assignAll(item["children"]);

      keys.add(name);

      return;
    }

    /// LEAF
    final navigation = item["navigation"];

    /// 🔥 KEYWORD LIST FROM JSON
    List<String> keywords = List<String>.from(item["keywords"] ?? []);

    /// 🔥 LAST KEYWORD FOR DESCRIPTION
    String lastKeyword = keywords.isNotEmpty ? keywords.last : name;

    /// IF NO KEYWORDS FOUND
    if (keywords.isEmpty) {
      keywords = [name];
    }

    if (navigation == "studyQuestion") {
      fetchQuestionsByKeyword(keywords);
      fetchKeywordDescription(lastKeyword);

      Get.toNamed("/studyQuestion");

      return;
    }

    /// studyFull
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

      keys.removeLast();

      return;
    }

    if (stack.isNotEmpty) {
      // 🔥 RESTORE FROM STACK
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
