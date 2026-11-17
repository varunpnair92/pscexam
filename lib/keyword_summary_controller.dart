import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class KeywordHistoryEntry {
  final String keyword;
  final int? kid;

  KeywordHistoryEntry({required this.keyword, this.kid});
}

class KeywordChildItem {
  final int? id;
  final String name;

  KeywordChildItem({this.id, required this.name});

  factory KeywordChildItem.fromDynamic(dynamic item) {
    if (item is Map) {
      int? id;
      if (item['id'] != null) {
        id = int.tryParse(item['id'].toString());
      }
      String name = (item['name'] ?? item['keyword'] ?? '').toString();
      return KeywordChildItem(id: id, name: name);
    }
    return KeywordChildItem(name: item.toString());
  }

  @override
  String toString() => name;
}

class SummaryCapsuleItem {
  final String title;
  final String content;
  final int index;
  final int total;

  SummaryCapsuleItem({
    required this.title,
    required this.content,
    required this.index,
    required this.total,
  });
}

class KeywordSummaryController extends GetxController {
  var isLoading = false.obs;

  // ─── Data State ───
  var currentKeyword = "".obs;
  var currentKid = Rxn<int>();
  var responseType = "unknown".obs; // 'parent', 'child', 'both', 'empty', or 'error'
  var childrenList = <KeywordChildItem>[].obs;
  var capsuleCards = <SummaryCapsuleItem>[].obs;
  var summaryData = <String>[].obs;
  var activeTab = 0.obs; // 0: Capsule Cards, 1: Sub-topics
  var errorMessage = "".obs;

  // ─── History Management ───
  var searchHistory = <KeywordHistoryEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      String kw = "";
      int? kid;
      if (args is Map) {
        if (args["keyword"] != null) kw = args["keyword"].toString();
        if (args["kid"] != null) kid = int.tryParse(args["kid"].toString());
      } else if (args is String) {
        kw = args;
      }
      if (kw.isNotEmpty || kid != null) {
        searchHistory.add(KeywordHistoryEntry(keyword: kw, kid: kid));
        currentKeyword.value = kw;
        fetchSummary(kw, kid: kid);
      }
    }
  }

  Future<void> fetchSummary(String keyword, {int? kid}) async {
    isLoading.value = true;
    errorMessage.value = "";
    if (keyword.isNotEmpty) {
      currentKeyword.value = keyword;
    }
    currentKid.value = kid;

    try {
      final baseUri = Uri.parse(AppConfig.keywordSearchSummary);
      final queryParams = <String, String>{};
      if (keyword.trim().isNotEmpty) {
        queryParams['keyword'] = keyword.trim();
      }
      if (kid != null) {
        queryParams['kid'] = kid.toString();
      }
      final uri = baseUri.replace(queryParameters: queryParams);

      final res = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is! Map) {
          responseType.value = 'error';
          errorMessage.value = "Unexpected server response format.";
          return;
        }

        // Update keyword name if provided
        if (decoded['keyword'] != null && decoded['keyword'].toString().trim().isNotEmpty) {
          currentKeyword.value = decoded['keyword'].toString().trim();
        }
        if (decoded['id'] != null) {
          currentKid.value = int.tryParse(decoded['id'].toString());
        }

        // 1. Parse children
        List<KeywordChildItem> parsedChildren = [];
        var rawChildren = decoded['children'] ?? (decoded['type'] == 'parent' ? decoded['data'] : null);
        if (rawChildren is List) {
          for (var item in rawChildren) {
            parsedChildren.add(KeywordChildItem.fromDynamic(item));
          }
        }
        childrenList.value = parsedChildren;

        // 2. Parse summary text and lines
        String rawSummaryText = "";
        List<String> lines = [];

        if (decoded['summary'] != null && decoded['summary'] is String) {
          rawSummaryText = decoded['summary'] as String;
        }

        if (decoded['summary_lines'] is List) {
          lines = List<dynamic>.from(decoded['summary_lines'])
              .map((e) => e.toString().trim())
              .where((s) => s.isNotEmpty && s != '#')
              .toList();
        } else if (rawSummaryText.isNotEmpty) {
          lines = rawSummaryText
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

        // 3. Parse Capsule Cards (swiping cards matching Knowledge Capsule UI)
        List<SummaryCapsuleItem> generatedCards = [];

        if (rawSummaryText.contains('#')) {
          final parts = rawSummaryText.split('#');
          List<Map<String, String>> blockList = [];
          for (final part in parts) {
            final blockLines = part
                .split('\n')
                .map((l) => l.trim())
                .where((l) => l.isNotEmpty && l != '#')
                .toList();
            if (blockLines.isEmpty) continue;

            final title = blockLines.first;
            final content = blockLines.length > 1
                ? blockLines.sublist(1).join('\n\n')
                : blockLines.first;
            blockList.add({'title': title, 'content': content});
          }

          for (int i = 0; i < blockList.length; i++) {
            generatedCards.add(SummaryCapsuleItem(
              title: blockList[i]['title']!,
              content: blockList[i]['content']!,
              index: i + 1,
              total: blockList.length,
            ));
          }
        }

        if (generatedCards.isEmpty && rawSummaryText.trim().isNotEmpty) {
          generatedCards.add(SummaryCapsuleItem(
            title: currentKeyword.value.isNotEmpty ? currentKeyword.value : "Summary",
            content: rawSummaryText.trim(),
            index: 1,
            total: 1,
          ));
        } else if (generatedCards.isEmpty && lines.isNotEmpty) {
          generatedCards.add(SummaryCapsuleItem(
            title: currentKeyword.value.isNotEmpty ? currentKeyword.value : "Summary",
            content: lines.join('\n\n'),
            index: 1,
            total: 1,
          ));
        }

        capsuleCards.value = generatedCards;

        // 4. Determine response type & active tab
        bool hasChildren = childrenList.isNotEmpty;
        bool hasSummary = capsuleCards.isNotEmpty;

        String detectedType = (decoded['type'] ?? '').toString();

        if (detectedType == 'both' || (hasChildren && hasSummary)) {
          responseType.value = 'both';
          activeTab.value = 0; // Default to Capsule Cards
        } else if (detectedType == 'parent' || (hasChildren && !hasSummary)) {
          responseType.value = 'parent';
          activeTab.value = 1;
        } else if (detectedType == 'child' || (hasSummary && !hasChildren)) {
          responseType.value = 'child';
          activeTab.value = 0;
        } else if (hasChildren) {
          responseType.value = 'parent';
          activeTab.value = 1;
        } else if (hasSummary) {
          responseType.value = 'child';
          activeTab.value = 0;
        } else {
          responseType.value = 'empty';
        }
      } else if (res.statusCode == 404) {
        responseType.value = 'empty';
        errorMessage.value = "വിവരം ലഭ്യമല്ല (No summary found for this keyword).";
      } else {
        responseType.value = 'error';
        errorMessage.value = "Failed to load results (${res.statusCode})";
      }
    } catch (e) {
      responseType.value = 'error';
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void onKeywordTap(String keyword, {int? kid}) {
    if (keyword.trim().isEmpty) return;
    if (currentKeyword.value == keyword && (kid == null || currentKid.value == kid)) return;

    searchHistory.add(KeywordHistoryEntry(keyword: keyword, kid: kid));
    activeTab.value = 0; // Switch to card view on keyword tap
    fetchSummary(keyword, kid: kid);
  }

  void onSearchSubmit(String keyword) {
    if (keyword.trim().isEmpty) return;
    if (currentKeyword.value == keyword) return;

    searchHistory.add(KeywordHistoryEntry(keyword: keyword));
    activeTab.value = 0;
    fetchSummary(keyword);
  }

  void handleBack() {
    if (searchHistory.length > 1) {
      searchHistory.removeLast();
      final prev = searchHistory.last;
      activeTab.value = 0;
      fetchSummary(prev.keyword, kid: prev.kid);
    } else {
      Get.back();
    }
  }
}
