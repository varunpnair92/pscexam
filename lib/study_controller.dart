import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'home_controller.dart';
import 'test_controller.dart';
import 'question_model.dart';
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
    final args = Get.arguments;
    if (args != null && (args["keywords"] != null || args["title"] != null)) {
      loadArguments(args);
    } else {
      fetchTree();
    }
    super.onInit();
  }

  void loadArguments(dynamic args) {
    if (args == null) return;
    
    final String title = args["title"] ?? "Study";
    List<String> kws = [];
    
    if (args["keywords"] != null) {
      kws = List<String>.from(args["keywords"]);
    } else {
      kws = [title];
    }
    
    keys.clear();
    keys.add(title);
    showQuestions.value = true;
    fetchQuestionsByKeyword(kws);
    
    if (kws.length > 1) {
      // The description endpoint doesn't support multiple comma-separated keywords well.
      description.value = "No data available for multiple keywords.";
      descriptionPages.value = splitDescription(description.value);
      currentPage.value = 0;
    } else {
      fetchKeywordDescription(kws.isNotEmpty ? kws.last : title);
    }
  }

  /// 🔥 SPLIT DESCRIPTION INTO PAGES USING NEWLINES
  List<String> splitDescription(String text) {
    const int linesPerPage = 8;
    final cleaned = text.trim();
    if (cleaned.isEmpty) return [];

    final lines = cleaned
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    List<String> pages = [];
    for (int i = 0; i < lines.length; i += linesPerPage) {
      final chunk = lines.sublist(i, (i + linesPerPage).clamp(0, lines.length));
      pages.add(chunk.join('\n'));
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

    final navigation = (item["navigation"] ?? "").toString().trim();

    List<String> keywords = [];
    if (item["keywords"] != null) {
      keywords = List<String>.from(item["keywords"]);
    } else if (item["keyword"] != null) {
      keywords = [item["keyword"].toString()];
    }
    String lastKeyword = keywords.isNotEmpty ? keywords.last : name;

    if (keywords.isEmpty) {
      keywords = [name];
    }

    fetchQuestionsByKeyword(keywords);
    fetchKeywordDescription(lastKeyword);

    // Route based on navigation metadata from hierarchy
    if (navigation.isNotEmpty) {
      if (navigation == "studyFull") {
        // internal in-page rendering for study mode
        showQuestions.value = true;
        keys.add(name);
        return;
      }

      final routeName = navigation.startsWith("/")
          ? navigation
          : "/$navigation";

      keys.add(name);

      if (routeName == "/studyExam") {
        // pass data for exam route
        Get.toNamed(routeName, arguments: questions.toList());
      } else {
        // fully dynamic API-driven route
        Get.toNamed(routeName, arguments: {
          "title": name,
          "keywords": keywords,
        });
      }
      return;
    }

    // default leaf behavior: fallback to full study view when no navigation is provided
    showQuestions.value = true;
    keys.add(name);
  }

  /// BACK
  void goBack() {
    if (showQuestions.value) {
      showQuestions.value = false;
      questions.clear();
      descriptionPages.clear(); // 🔥 clear pages
      if (keys.isNotEmpty) keys.removeLast();
      return;
    }

    if (stack.isNotEmpty) {
      items.assignAll(stack.removeLast());
      if (keys.isNotEmpty) keys.removeLast();
    }
  }

  /// QUESTIONS
  Future<void> fetchQuestionsByKeyword(List<String> keywords) async {
    // 🔥 NEW: Check for Live Exam EXACT Match (prioritize full live exams over fuzzy keywords)
    if (keywords.length == 1) {
      final homeCtrl = Get.find<HomeController>();
      final liveExam = homeCtrl.findExamByName(keywords.first);
      
      if (liveExam != null && liveExam['id'] != null) {
        final testCtrl = Get.find<TestController>();
        await testCtrl.loadQuestionsOnly(liveExam['id']);
        
        // Convert test_controller questions (ObsList<Question>) to study_controller expected format (ObsList<dynamic>)
        questions.assignAll(testCtrl.questions.map((q) => {
          "id": q.id,
          "question": q.question,
          "options": q.options,
          "answer": q.answer,
          "description": q.description,
        }).toList());
        return;
      }
    }

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
        descriptionPages.value = splitDescription(description.value);

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
