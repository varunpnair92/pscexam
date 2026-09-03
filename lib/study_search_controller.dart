import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'home_controller.dart';
import 'test_controller.dart';

class StudySearchController extends GetxController {
  var isLoading = false.obs;
  var isSearched = false.obs;
  var currentKeyword = "".obs;
  
  var questions = [].obs;
  var description = "".obs;
  var descriptionPages = <String>[].obs;
  var currentPage = 0.obs;

  var searchHistory = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args["keyword"] != null) {
      final String kw = args["keyword"].toString();
      performSearch(kw);
    }
  }

  /// Perform search with Malayalam or English keyword
  Future<void> performSearch(String rawQuery) async {
    final String query = rawQuery.trim();
    if (query.isEmpty) return;

    if (!searchHistory.contains(query)) {
      searchHistory.insert(0, query);
      if (searchHistory.length > 10) {
        searchHistory.removeLast();
      }
    }

    currentKeyword.value = query;
    isSearched.value = true;
    isLoading.value = true;

    List<String> keywords = query
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (keywords.isEmpty) {
      keywords = [query];
    }

    try {
      await Future.wait([
        fetchQuestionsByKeyword(keywords),
        if (keywords.length == 1) fetchKeywordDescription(keywords.first) else fetchKeywordDescription(query),
      ]);
    } catch (e) {
      Get.snackbar("Error", "Could not fetch search details. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch questions using same API as studyFull page
  Future<void> fetchQuestionsByKeyword(List<String> keywords) async {
    // Check for Live Exam exact match if single keyword
    if (keywords.length == 1) {
      try {
        if (Get.isRegistered<HomeController>()) {
          final homeCtrl = Get.find<HomeController>();
          final liveExam = homeCtrl.findExamByName(keywords.first);

          if (liveExam != null && liveExam['id'] != null) {
            if (Get.isRegistered<TestController>()) {
              final testCtrl = Get.find<TestController>();
              await testCtrl.loadQuestionsOnly(liveExam['id']);

              questions.assignAll(
                testCtrl.questions
                    .map(
                      (q) => {
                        "id": q.id,
                        "question": q.question,
                        "options": q.options,
                        "answer": q.answer,
                        "description": q.description,
                      },
                    )
                    .toList(),
              );
              return;
            }
          }
        }
      } catch (_) {}
    }

    final res = await http.post(
      Uri.parse(AppConfig.keywordQuestions),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"keywords": keywords}),
    );

    if (res.statusCode == 200) {
      questions.value = jsonDecode(utf8.decode(res.bodyBytes));
    } else {
      questions.clear();
    }
  }

  /// Fetch keyword description using same API as studyFull page
  Future<void> fetchKeywordDescription(String keyword) async {
    try {
      final res = await http.get(
        Uri.parse("${AppConfig.keywordDesc}$keyword/"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        description.value = data["description"] ?? "";
        descriptionPages.value = splitDescription(description.value);
        currentPage.value = 0;
      } else {
        description.value = "No description available for \"$keyword\".";
        descriptionPages.value = splitDescription(description.value);
        currentPage.value = 0;
      }
    } catch (e) {
      description.value = "Failed to load description.";
      descriptionPages.value = [];
    }
  }

  /// Split description text into paginated chunks (8 lines each)
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

  /// Clear current search results
  void clearSearch() {
    currentKeyword.value = "";
    isSearched.value = false;
    questions.clear();
    description.value = "";
    descriptionPages.clear();
  }

  void handleBack() {
    Get.back();
  }
}
