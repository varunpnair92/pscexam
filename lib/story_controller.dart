import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'auth_controller.dart';

class StoryItemData {
  final String type; // 'description'
  final dynamic data;

  StoryItemData({required this.type, required this.data});
}

class StoryController extends GetxController {
  var isLoading = true.obs;
  var items = <StoryItemData>[].obs;
  var currentIndex = 0.obs;
  
  var title = "Story".obs;
  var questions = [].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      // 🔥 Centralized Access Check
      final auth = AuthController.instance;
      if (!auth.canAccess(args)) {
        auth.showPremiumAlert();
        Get.back();
        return;
      }

      final t = args["title"] ?? "Story";
      title.value = t;
      List<String> kws = [];
      if (args["keywords"] != null) {
        kws = List<String>.from(args["keywords"]);
      } else {
        kws = [t];
      }
      final endpoint = args["endpoint"] ?? "";
      _fetchData(kws, endpoint);
    } else {
      // Fallback
      items.add(StoryItemData(type: 'description', data: 'No content available.'));
      isLoading.value = false;
    }
  }

  Future<void> _fetchData(List<String> keywords, String endpoint) async {
    isLoading.value = true;
    items.clear();

    String lastKeyword = keywords.isNotEmpty ? keywords.last : title.value;

    String fetchUrl = "";

    // If the API provided a specific URL, use it.
    if (endpoint.isNotEmpty && endpoint.trim() != "") {
      if (endpoint.startsWith("http")) {
        fetchUrl = endpoint;
      } else {
        fetchUrl = "${AppConfig.baseUrl}$endpoint";
      }
    } else {
      // If no URL was provided (only keyword and navigation), use the keyword description endpoint
      String encodedPath = Uri.encodeComponent(lastKeyword);
      fetchUrl = "${AppConfig.keywordDesc}$encodedPath/";
    }

    try {
      final res = await http.get(Uri.parse(fetchUrl));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        String desc = "";
        if (data is List && data.isNotEmpty) {
           desc = data[0]["description"]?.toString() ?? "";
        } else if (data is Map) {
           desc = data["description"]?.toString() ?? "";
        }
        
        final pages = _splitDescription(desc);
        if (pages.isNotEmpty) {
          for (var p in pages) {
            items.add(StoryItemData(type: 'description', data: p));
          }
        } else {
          items.add(StoryItemData(type: 'description', data: 'No text content available in description.'));
        }
      } else {
         items.add(StoryItemData(type: 'description', data: 'API returned ${res.statusCode} for $fetchUrl'));
      }
    } catch (e) {
      items.add(StoryItemData(type: 'description', data: 'Exception fetching story: $e'));
    }
//============disable this for now no need question================
    // try {
      
    //   print("Fetching questions for keyword: $keywords");
    //   final res = await http.post(
    //     Uri.parse(AppConfig.keywordQuestions),
    //     headers: {"Content-Type": "application/json"},
    //     body: jsonEncode({"keywords": keywords}),
    //   );

    //   print("Questions response status: ${res.statusCode}");
    //   print("Questions response body: ${res.body}");

    //   if (res.statusCode == 200) {
    //     questions.value = jsonDecode(res.body);
    //     for (var q in questions) {
    //       items.add(StoryItemData(type: 'question', data: q));
    //     }
    //   } else {
    //      items.add(StoryItemData(type: 'description', data: 'Questions API error: ${res.statusCode}'));
    //   }
    // } catch (e) {
    //   print("Exception in questions fetch: $e");
    //   items.add(StoryItemData(type: 'description', data: 'Exception in questions: $e'));
    // }

    if (questions.isNotEmpty) {
      items.add(StoryItemData(type: 'exam', data: null));
    }

    if (items.isEmpty) {
      items.add(StoryItemData(type: 'description', data: 'No content available for params: end=$endpoint / key=$lastKeyword'));
    }

    currentIndex.value = 0;
    isLoading.value = false;
  }

  List<String> _splitDescription(String text) {
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
      pages.add(chunk.join('\n\n'));
    }

    return pages;
  }

  void nextStory() {
    if (currentIndex.value < items.length - 1) {
      currentIndex.value++;
    } else {
      Get.back(); // Go back when finished
    }
  }

  void previousStory() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    } else {
      Get.back(); // Go back if tapping back on first story
    }
  }

  void startExam() {
    Get.offNamed("/studyExam", arguments: questions.toList());
  }
}
