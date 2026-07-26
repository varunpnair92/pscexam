import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:psc_exam/test_controller.dart';
import 'app_config.dart';
import 'auth_controller.dart';
import 'study_controller.dart';
import 'story_controller.dart';
import 'exam_model.dart';
import 'ui_utils.dart';

class NavigationSlideController extends GetxController {
  var items = [].obs;
  var isLoading = false.obs;
  var currentPage = 0.obs;

  String currentUrl = "";
  String currentNav = "";

  @override
  void onInit() {
    final args = Get.arguments ?? {};
    currentUrl = args['endpoint'] ?? "";
    currentNav = args['parentNavigation'] ?? "";
    final initialItems = args['items'];

    if (currentUrl.isNotEmpty) {
      fetchData(currentUrl);
    } else if (initialItems != null) {
      items.assignAll(initialItems);
    }

    super.onInit();
  }

  Future<void> fetchData(String url) async {
    try {
      isLoading(true);
      final fullUrl = AppConfig.baseUrl + url;
      final res = await http.get(Uri.parse(fullUrl));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        items.assignAll(data is List ? data : [data]);
      }
    } catch (e) {
      debugPrint("Error fetching nav items: $e");
    } finally {
      isLoading(false);
    }
  }

  String getTitle(dynamic item) {
    String name = (item["name"] ?? "").toString().trim();
    if (name.isNotEmpty) return name;
    if (item["keyword"] != null) return item["keyword"].toString();
    return "Menu";
  }

  String getImageUrl(dynamic item) {
    if (item["image_url"] != null && item["image_url"].toString().isNotEmpty) {
      return item["image_url"];
    }
    if (item["image"] != null && item["image"].toString().isNotEmpty) {
      return item["image"];
    }
    return "";
  }

  Future<void> onNodeTap(dynamic item) async {
    final auth = AuthController.instance;
    if (!auth.canAccess(item)) {
      auth.showPremiumAlert();
      return;
    }

    final String title = getTitle(item);
    final String navStr = item["navigation"]?.toString().trim() ?? '';
    final String urlStr = item["url"]?.toString().trim() ?? '';

    if (navStr.toLowerCase().contains('timeline') || urlStr.toLowerCase().contains('keywordtimeline')) {
      List<String> keywords = [];
      if (item["keywords"] != null) {
        keywords = List<String>.from(item["keywords"]);
      } else if (item["keyword"] != null) {
        keywords = [item["keyword"].toString()];
      }
      Map<String, dynamic> args = {'title': title, 'endpoint': urlStr};
      if (keywords.isNotEmpty) {
        String kw = keywords.last.trim();
        if (kw.toLowerCase() != 'timeline' && kw.toLowerCase() != '/timeline') {
          args['keyword'] = kw;
        }
      }
      Get.toNamed('/timeline', arguments: args);
      return;
    }

    // 1. Children -> Open another NavigationSlide or DynamicMenu
    if (item["children"] != null && item["children"].isNotEmpty) {
      Get.toNamed('/navigationSlide', arguments: {
        'items': item["children"],
        'title': title,
        'parentNavigation': navStr.isNotEmpty ? navStr : currentNav,
      }, preventDuplicates: false);
      return;
    }

    // 2. URL -> Push to a new view or list
    if (urlStr.isNotEmpty && (navStr == 'dynamicExamList' || navStr == 'examstorypage')) {
      Get.toNamed('/$navStr', arguments: {'endpoint': urlStr, 'title': title});
      return;
    }

    // 3. Specific Routing
    if (navStr.isNotEmpty) {
      String nav = navStr.startsWith('/') ? navStr : '/$navStr';
      
      List<String> keywords = [];
      if (item["keywords"] != null) {
        keywords = List<String>.from(item["keywords"]);
      } else if (item["keyword"] != null) {
        keywords = [item["keyword"].toString()];
      }

      Map<String, dynamic> routeArgs = {
        "keywords": keywords,
        "title": title,
        "endpoint": urlStr,
        "id": int.tryParse(item["id"]?.toString() ?? "0") ?? 0,
      };

      if (nav == '/examSplash') {
        _fetchAndNavigateSplash(routeArgs["id"], item, title);
        return;
      }

      if (nav == '/studyFull') Get.delete<StudyController>();
      if (nav == '/story') Get.delete<StoryController>();

      Get.toNamed(nav, arguments: routeArgs);
      return;
    }

    // 4. Fallback Leaf Node
    String targetNav = currentNav.isNotEmpty ? currentNav : '/studyFull';
    if (!targetNav.startsWith('/')) targetNav = '/$targetNav';

    List<String> keywords = [];
    if (item["keyword"] != null) keywords = [item["keyword"].toString()];

    Get.toNamed(targetNav, arguments: {
      "title": title,
      "keywords": keywords,
      "endpoint": urlStr,
      "id": int.tryParse(item["id"]?.toString() ?? "0") ?? 0,
    });
  }

  Future<void> _fetchAndNavigateSplash(int examId, dynamic item, String fallbackTitle) async {
    Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xFF1B8A4E))), barrierDismissible: false);
    try {
      final res = await http.get(Uri.parse('${AppConfig.testExam}$examId/'));
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);
        final exam = Exam(
          id: examId,
          category: data["category"]?.toString() ?? item["category"]?.toString() ?? "Exam",
          specialization: data["specialization"]?.toString() ?? fallbackTitle,
          locked: item["locked"] == true || item["locked"] == "true" || item["locked"] == 1,
          totalQuestions: data["questions"]?.length ?? 50,
          accessType: item["access_type"]?.toString() ?? "free",
        );
        Get.back();
        Get.toNamed('/examSplash', arguments: {'exam': exam});
      } else {
        Get.back();
        Get.snackbar("Notice", "Exam not available");
      }
    } catch (_) {
      Get.back();
      Get.snackbar("Error", "Network error");
    }
  }
}
