import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'summary_card_model.dart';

class KeywordSummaryController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = "".obs;

  // ─── Data State ───
  var keywordId = 0.obs;
  var currentKeyword = "".obs;
  var description = "".obs;
  var summary = "".obs;
  var summaryLines = <String>[].obs;
  var summaryCards = <SummaryCardModel>[].obs;

  // Backwards-compatible observables
  var summaryData = <String>[].obs;
  var responseType = "unknown".obs; // 'success', 'parent', 'empty', 'error', 'unknown'
  var childrenList = <String>[].obs;

  // ─── History Management ───
  var searchHistory = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      if (args is Map) {
        String? kw = args["keyword"]?.toString();
        int? kid = args["kid"] != null ? int.tryParse(args["kid"].toString()) : null;
        if (kw != null && kw.trim().isNotEmpty) {
          searchHistory.add(kw.trim());
          currentKeyword.value = kw.trim();
          fetchSummary(kw.trim(), kid: kid);
        } else if (kid != null) {
          fetchSummary("", kid: kid);
        }
      } else if (args is String && args.trim().isNotEmpty) {
        searchHistory.add(args.trim());
        currentKeyword.value = args.trim();
        fetchSummary(args.trim());
      }
    }
  }

  Future<void> fetchSummary(String keyword, {int? kid}) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty && kid == null) return;

    isLoading.value = true;
    errorMessage.value = "";
    if (trimmed.isNotEmpty) {
      currentKeyword.value = trimmed;
    }

    try {
      final String url;
      if (kid != null && kid > 0) {
        url = "${AppConfig.keywordSearchSummary}?kid=$kid";
      } else {
        url = "${AppConfig.keywordSearchSummary}?keyword=${Uri.encodeComponent(trimmed)}";
      }

      final res = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));

        if (decoded is Map) {
          if (decoded.containsKey('error')) {
            errorMessage.value = decoded['error'].toString();
            responseType.value = 'error';
            return;
          }

          keywordId.value = (decoded['id'] is int)
              ? decoded['id']
              : int.tryParse(decoded['id']?.toString() ?? '0') ?? 0;

          if (decoded['keyword'] != null && decoded['keyword'].toString().trim().isNotEmpty) {
            currentKeyword.value = decoded['keyword'].toString().trim();
          }

          description.value = (decoded['description'] ?? "").toString().trim();
          summary.value = (decoded['summary'] ?? "").toString().trim();

          final rawLines = (decoded['summary_lines'] != null && decoded['summary_lines'] is List)
              ? (decoded['summary_lines'] as List)
              : (decoded['summary'] != null && decoded['summary'] is List ? (decoded['summary'] as List) : null);

          // Parse into separate card entries if enclosed in # to #
          final parsedCards = SummaryCardModel.parse(summary.value, rawLines: rawLines);
          summaryCards.value = parsedCards;

          List<String> parsedLines = [];
          if (parsedCards.isNotEmpty) {
            // Flatten all clean items across all cards without any '#' markers
            parsedLines = parsedCards.expand((c) => c.items.map((i) => i.rawText)).toList();
          } else if (rawLines != null) {
            parsedLines = List<dynamic>.from(rawLines)
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty && e != '#')
                .toList();
          } else if (summary.value.isNotEmpty) {
            parsedLines = summary.value
                .split('\n')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty && e != '#')
                .toList();
          }

          summaryLines.value = parsedLines;
          summaryData.value = parsedLines;

          // Legacy parent check fallback (if ever returned)
          if (decoded['type'] == 'parent' ||
              (decoded.containsKey('children') &&
                  decoded['children'] is List &&
                  (decoded['children'] as List).isNotEmpty)) {
            responseType.value = 'parent';
            var rawChildren = decoded['children'] ?? decoded['data'] ?? [];
            childrenList.value = List<dynamic>.from(rawChildren).map((e) => _extractName(e)).toList();
          } else {
            childrenList.clear();
            if (description.value.isEmpty && summaryLines.isEmpty && summaryCards.isEmpty && summary.value.isEmpty) {
              responseType.value = 'empty';
            } else {
              responseType.value = 'success';
            }
          }
        } else {
          responseType.value = 'empty';
        }
      } else if (res.statusCode == 404) {
        try {
          final decoded = jsonDecode(utf8.decode(res.bodyBytes));
          errorMessage.value = decoded['error'] ?? "Keyword not found";
        } catch (_) {
          errorMessage.value = "Keyword not found";
        }
        responseType.value = 'error';
      } else {
        try {
          final decoded = jsonDecode(utf8.decode(res.bodyBytes));
          errorMessage.value = decoded['error'] ?? "Failed to load summary (${res.statusCode})";
        } catch (_) {
          errorMessage.value = "Failed to load summary (${res.statusCode})";
        }
        responseType.value = 'error';
      }
    } catch (e) {
      errorMessage.value = "Network error: Unable to fetch summary. Please check your connection.";
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
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;
    if (currentKeyword.value == trimmed && responseType.value != 'error') return;

    if (searchHistory.isEmpty || searchHistory.last != trimmed) {
      searchHistory.add(trimmed);
    }
    fetchSummary(trimmed);
  }

  void onSearchSubmit(String keyword) {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;
    if (currentKeyword.value == trimmed && responseType.value != 'error') return;

    if (searchHistory.isEmpty || searchHistory.last != trimmed) {
      searchHistory.add(trimmed);
    }
    fetchSummary(trimmed);
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
