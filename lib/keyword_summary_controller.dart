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

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args["keyword"] != null) {
      String kw = args["keyword"].toString();
      searchHistory.add(kw);
      currentKeyword.value = kw;
      fetchSummary(kw);
    }
  }

  Future<void> fetchSummary(String keyword) async {
    isLoading.value = true;
    currentKeyword.value = keyword;

    try {
      final baseUri = Uri.parse(AppConfig.keywordSearchSummary);
      final uri = baseUri.replace(queryParameters: {'keyword': keyword.trim()});

      final res = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));

        if (decoded is! Map) {
          responseType.value = 'error';
          return;
        }

        if (decoded['keyword'] != null && decoded['keyword'].toString().trim().isNotEmpty) {
          currentKeyword.value = decoded['keyword'].toString().trim();
        }

        // Parse children if present
        var rawChildren = decoded['children'] ?? (decoded['type'] == 'parent' ? decoded['data'] : null);
        if (rawChildren is List) {
          childrenList.value = List<dynamic>.from(rawChildren).map((e) => _extractName(e)).toList();
        } else {
          childrenList.clear();
        }

        // Parse summary lines
        List<String> lines = [];
        if (decoded['summary_lines'] is List) {
          lines = List<dynamic>.from(decoded['summary_lines'])
              .map((e) => e.toString().trim())
              .where((s) => s.isNotEmpty && s != '#')
              .toList();
        } else if (decoded['summary'] is String) {
          lines = (decoded['summary'] as String)
              .split('\n')
              .map((e) => e.trim())
              .where((s) => s.isNotEmpty && s != '#')
              .toList();
        } else if (decoded['data'] is List && decoded['type'] != 'parent') {
          lines = List<dynamic>.from(decoded['data'])
              .map((e) => e.toString().trim())
              .where((s) => s.isNotEmpty && s != '#')
              .toList();
        }
        summaryData.value = lines;

        // Determine view state
        String detectedType = decoded['type'] ?? '';
        if (summaryData.isNotEmpty) {
          responseType.value = 'child';
        } else if (detectedType == 'parent' || childrenList.isNotEmpty) {
          responseType.value = 'parent';
        } else {
          responseType.value = 'child';
        }
      } else {
        responseType.value = 'error';
      }
    } catch (e) {
      responseType.value = 'error';
    } finally {
      isLoading.value = false;
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
