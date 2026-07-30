import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class KeywordSearchController extends GetxController {
  var isLoading = false.obs;
  var questions = [].obs;
  
  // ─── History & Keywords Management ───
  var searchHistory = <String>[].obs;
  var keywordsList = <String>[].obs;
  var selectedKeyword = "".obs; // empty string = combined mode (all keywords)

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args["keyword"] != null) {
      String rawKw = args["keyword"].toString();
      processSearchQuery(rawKw);
    }
  }

  void processSearchQuery(String query) {
    if (query.trim().isEmpty) return;

    List<String> parsedKws = query
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (parsedKws.isEmpty) return;

    for (String kw in parsedKws) {
      if (!keywordsList.any((k) => k.toLowerCase() == kw.toLowerCase())) {
        keywordsList.add(kw);
      }
    }
    
    if (!searchHistory.contains(query)) {
      searchHistory.add(query);
    }
    
    selectedKeyword.value = "";
    fetchQuestions();
  }

  void selectKeywordTile(String keyword) {
    String trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      selectedKeyword.value = "";
    } else if (selectedKeyword.value.toLowerCase() == trimmed.toLowerCase()) {
      // Toggle off to combined mode if tapped again
      selectedKeyword.value = "";
    } else {
      selectedKeyword.value = trimmed;
    }
    fetchQuestions();
  }

  void removeKeywordTile(String keyword) {
    String trimmed = keyword.trim();
    keywordsList.removeWhere((k) => k.toLowerCase() == trimmed.toLowerCase());
    
    if (selectedKeyword.value.toLowerCase() == trimmed.toLowerCase()) {
      selectedKeyword.value = "";
    }

    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    if (keywordsList.isEmpty) {
      questions.clear();
      return;
    }

    isLoading.value = true;
    
    List<String> targetKeywords = selectedKeyword.value.isNotEmpty
        ? [selectedKeyword.value]
        : keywordsList.toList();

    try {
      final res = await http.post(
        Uri.parse(AppConfig.keywordMultipleCombinedSimilarWithKeyword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"keywords": targetKeywords}),
      );

      if (res.statusCode == 200) {
        questions.value = jsonDecode(utf8.decode(res.bodyBytes));
      } else {
        questions.clear();
        Get.snackbar("Error", "Failed to load results (${res.statusCode})");
      }
    } catch (e) {
      questions.clear();
      Get.snackbar("Error", "Check your internet connection");
    } finally {
      isLoading.value = false;
    }
  }

  void onHashtagTap(String keyword) {
    String trimmed = keyword.trim();
    if (trimmed.isEmpty) return;
    
    if (!keywordsList.any((k) => k.toLowerCase() == trimmed.toLowerCase())) {
      keywordsList.add(trimmed);
    }
    selectedKeyword.value = trimmed;
    fetchQuestions();
  }

  void handleBack() {
    Get.back();
  }
}
