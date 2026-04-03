import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class KeywordSearchController extends GetxController {
  var isLoading = false.obs;
  var questions = [].obs;
  
  // ─── History Management ───
  var searchHistory = <String>[].obs;
  var currentKeyword = "".obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args["keyword"] != null) {
      String kw = args["keyword"];
      searchHistory.add(kw);
      currentKeyword.value = kw;
      fetchQuestions(kw);
    }
  }

  Future<void> fetchQuestions(String keyword) async {
    isLoading.value = true;
    currentKeyword.value = keyword;
    
    try {
      final res = await http.post(
        Uri.parse(AppConfig.keywordMultipleCombinedSimilarWithKeyword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"keywords": [keyword]}),
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
    if (keyword.trim().isEmpty) return;
    
    // If it's already the current keyword, do nothing
    if (currentKeyword.value == keyword) return;

    searchHistory.add(keyword);
    fetchQuestions(keyword);
  }

  void handleBack() {
    if (searchHistory.length > 1) {
      searchHistory.removeLast();
      fetchQuestions(searchHistory.last);
    } else {
      Get.back();
    }
  }
}
