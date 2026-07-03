import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class KeywordSummaryController extends GetxController {
  var isLoading = false.obs;
  
  // ─── Data State ───
  var currentKeyword = "".obs;
  var responseType = "unknown".obs; // 'parent', 'child', or 'error'
  var childrenList = <String>[].obs;
  var summaryData = <String>[].obs;

  // ─── History Management ───
  var searchHistory = <String>[].obs;
  
  // Custom initialization via parameters if needed, though usually Get.arguments is used
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args["keyword"] != null) {
      String kw = args["keyword"];
      searchHistory.add(kw);
      currentKeyword.value = kw;
      fetchSummary(kw);
    }
  }

  Future<void> fetchSummary(String keyword) async {
    isLoading.value = true;
    currentKeyword.value = keyword;
    
    try {
     // print("Fetching summary for keyword: $keyword");
      final res = await http.get(
        Uri.parse("${AppConfig.keywordSearchSummary}?keyword=$keyword"),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10));

    //  print("Response status: ${res.statusCode}");
    //  print("Response body: ${res.body}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        
        // Flexible parsing based on possible backend structures
        String detectedType = decoded['type'] ?? '';
        
        if (detectedType == 'parent' || decoded.containsKey('children')) {
          responseType.value = 'parent';
          var rawChildren = decoded['children'] ?? decoded['data'] ?? [];
          childrenList.value = List<dynamic>.from(rawChildren).map((e) => _extractName(e)).toList();
        } else if (detectedType == 'child' || decoded.containsKey('summary') || decoded.containsKey('data')) {
          responseType.value = 'child';
          var rawSummary = decoded['summary'] ?? decoded['data'] ?? [];
          summaryData.value = List<dynamic>.from(rawSummary).map((e) => e.toString()).toList();
        } else {
          // Fallback
          responseType.value = 'unknown';
          print("Notice: Unknown response format from server");
        }
      } else {
        responseType.value = 'error';
       // print("Error: Failed to load results (${res.statusCode})");
      }
    } catch (e) {
    //  print("Error fetching summary: $e");
      responseType.value = 'error';
    } finally {
      isLoading.value = false;
     // print("isLoading set to false, responseType is ${responseType.value}");
    }
  }

  String _extractName(dynamic item) {
    if (item is String) return item;
    if (item is Map && item.containsKey('name')) return item['name'].toString();
    if (item is Map && item.containsKey('keyword')) return item['keyword'].toString();
    return item.toString();
  }

  void onKeywordTap(String keyword) {
    if (keyword.trim().isEmpty) return;
    
    if (currentKeyword.value == keyword) return;

    searchHistory.add(keyword);
    fetchSummary(keyword);
  }

  void onSearchSubmit(String keyword) {
    if (keyword.trim().isEmpty) return;
    
    if (currentKeyword.value == keyword) return;

    // Reset history if it's a completely new manual search, or just append
    searchHistory.add(keyword);
    fetchSummary(keyword);
  }

  void handleBack() {
    if (searchHistory.length > 1) {
      searchHistory.removeLast();
      fetchSummary(searchHistory.last);
    } else {
      Get.back();
    }
  }
}
