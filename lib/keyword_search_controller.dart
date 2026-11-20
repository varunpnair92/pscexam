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

  // ─── Point by Point Mode State ───
  var isPointByPointMode = false.obs;
  var isPointsLoading = false.obs;
  var pointsList = <Map<String, String>>[].obs;

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
    if (isPointByPointMode.value) {
      fetchPoints();
    }
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
    if (isPointByPointMode.value) {
      fetchPoints();
    }
  }

  void removeKeywordTile(String keyword) {
    String trimmed = keyword.trim();
    keywordsList.removeWhere((k) => k.toLowerCase() == trimmed.toLowerCase());
    
    if (selectedKeyword.value.toLowerCase() == trimmed.toLowerCase()) {
      selectedKeyword.value = "";
    }

    fetchQuestions();
    if (isPointByPointMode.value) {
      fetchPoints();
    }
  }

  void togglePointByPointMode(bool enabled) {
    isPointByPointMode.value = enabled;
    if (enabled && pointsList.isEmpty) {
      fetchPoints();
    }
  }

  Future<void> fetchPoints() async {
    final kw = selectedKeyword.value.isNotEmpty
        ? selectedKeyword.value
        : (keywordsList.isNotEmpty ? keywordsList.first : "");

    if (kw.trim().isEmpty) {
      pointsList.clear();
      return;
    }

    isPointsLoading.value = true;
    final List<Map<String, String>> collected = [];

    try {
      // 1. Fetch child points for master keyword
      final urlMaster = "${AppConfig.masterKeywordPoints}?keyword=${Uri.encodeComponent(kw.trim())}";
      final resMaster = await http.get(Uri.parse(urlMaster)).timeout(const Duration(seconds: 8));
      if (resMaster.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(resMaster.bodyBytes));
        if (decoded is Map && decoded['items'] is List) {
          for (var item in decoded['items']) {
            final k = (item['keyword'] ?? "").toString().trim();
            final p = (item['point'] ?? item['category'] ?? "").toString().trim();
            if (k.isNotEmpty && p.isNotEmpty) {
              collected.add({'keyword': k, 'point': p});
            }
          }
        }
      }
    } catch (_) {}

    try {
      // 2. Fetch summary points
      final urlSum = "${AppConfig.keywordSearchSummary}?keyword=${Uri.encodeComponent(kw.trim())}&point_by_point=true";
      final resSum = await http.get(Uri.parse(urlSum)).timeout(const Duration(seconds: 8));
      if (resSum.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(resSum.bodyBytes));
        if (decoded is Map) {
          final selfPoint = (decoded['point'] ?? "").toString().trim();
          final selfKw = (decoded['keyword'] ?? kw).toString().trim();
          if (selfPoint.isNotEmpty && !collected.any((e) => e['keyword'] == selfKw)) {
            collected.insert(0, {'keyword': selfKw, 'point': selfPoint});
          }

          if (decoded['point_by_point'] is List) {
            for (var item in decoded['point_by_point']) {
              final k = (item['keyword'] ?? "").toString().trim();
              final p = (item['point'] ?? "").toString().trim();
              if (k.isNotEmpty && p.isNotEmpty && !collected.any((e) => e['keyword'] == k)) {
                collected.add({'keyword': k, 'point': p});
              }
            }
          }
        }
      }
    } catch (_) {}

    pointsList.assignAll(collected);
    isPointsLoading.value = false;
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
