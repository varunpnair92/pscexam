import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class KeywordDetailsController extends GetxController {
  var isLoading = false.obs;
  var keywordData = {}.obs;
  
  // ─── History Management ───
  var searchHistory = <String>[].obs;
  var currentKeyword = "".obs;
  var dynamicEndpoint = "keyword-full-details/".obs; // Default fallback

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      if (args["endpoint"] != null && args["endpoint"].toString().isNotEmpty) {
        dynamicEndpoint.value = args["endpoint"].toString();
      } else if (args["url"] != null && args["url"].toString().isNotEmpty) {
        dynamicEndpoint.value = args["url"].toString();
      }

      String kw = "";
      if (args["keyword"] != null) {
        kw = args["keyword"].toString();
      } else if (args["keywords"] != null && (args["keywords"] as List).isNotEmpty) {
        kw = (args["keywords"] as List).first.toString();
      } else if (args["title"] != null) {
        kw = args["title"].toString();
      }

      if (kw.isNotEmpty) {
        searchHistory.add(kw);
        currentKeyword.value = kw;
        fetchKeywordDetails(kw);
      }
    }
  }

  Future<void> fetchKeywordDetails(String keyword) async {
    isLoading.value = true;
    currentKeyword.value = keyword;
    
    try {
      String endpoint = dynamicEndpoint.value;
      String url = "";
      
      // Check if it's already a full URL or just an endpoint
      String baseUrl = endpoint.startsWith("http") ? endpoint : "${AppConfig.baseUrl}$endpoint";
      
      // Append keyword parameter correctly
      if (baseUrl.contains("?")) {
        url = "$baseUrl&keyword=${Uri.encodeComponent(keyword)}";
      } else {
        url = "$baseUrl?keyword=${Uri.encodeComponent(keyword)}";
      }

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data.isNotEmpty) {
          keywordData.value = data[0];
        } else {
          keywordData.clear();
        }
      } else {
        keywordData.clear();
        Get.snackbar("Error", "Failed to load results (${res.statusCode})");
      }
    } catch (e) {
      keywordData.clear();
      Get.snackbar("Error", "Check your internet connection");
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchSubmit(String keyword) {
    if (keyword.trim().isEmpty) return;
    
    // If it's already the current keyword, do nothing
    if (currentKeyword.value == keyword) return;

    searchHistory.add(keyword);
    fetchKeywordDetails(keyword);
  }

  void handleBack() {
    if (searchHistory.length > 1) {
      searchHistory.removeLast();
      fetchKeywordDetails(searchHistory.last);
    } else {
      Get.back();
    }
  }
}
