import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'auth_controller.dart';
import 'study_controller.dart';
import 'test_controller.dart';
import 'story_controller.dart';
import 'exam_model.dart';

class DynamicMenuController extends GetxController {
  var items = [].obs;
  var stack = <dynamic>[].obs;
  var keys = <String>[].obs;
  
  var navStack = <String>[];
  var slideStack = <bool>[].obs; // 🔥 Track slide state for back navigation
  var isSlideView = false.obs; // 🔥 Track if current level is slide
  String currentNav = "";

  String currentUrl = "";

  @override
  void onInit() {
    final args = Get.arguments ?? {};

    currentUrl = args['endpoint'] ?? "";
    String title = args['title'] ?? "Menu";
    final initialItems = args['items'];
    currentNav = args['parentNavigation'] ?? "";

    navStack.clear();
    navStack.add(currentNav);

    keys.clear();
    keys.add(title);

    if (currentUrl.isNotEmpty) {
      fetchData(currentUrl);
    } else if (initialItems != null) {
      items.value = initialItems;
    }

    super.onInit();
  }

  /// FETCH DATA FROM API
  Future<void> fetchData(String url) async {
    final fullUrl = AppConfig.baseUrl + url;

    final res = await http.get(Uri.parse(fullUrl));
    final data = jsonDecode(res.body);

    /// 🔥 NORMAL MENU
    items.value = data;
  }

  /// GET DISPLAY TITLE
  String getTitle(dynamic item) {
    String name = (item["name"] ?? "").toString().trim();
    if (name.isNotEmpty) return name;

    if (item["keywords"] != null && item["keywords"].isNotEmpty) {
      return item["keywords"].last.toString();
    }

    if (item["keyword"] != null) {
      return item["keyword"].toString();
    }

    if (item["url"] != null) {
      return item["url"].toString().replaceAll("/", "");
    }

    return "Menu";
  }

  /// TILE CLICK
  Future<void> onTileTap(dynamic item) async {
    final auth = AuthController.instance;

    // 🌟 CENTRALIZED ACCESS CHECK
    if (!auth.canAccess(item)) {
      auth.showPremiumAlert();
      return;
    }

    final String title = getTitle(item);

    final String navStr = item["navigation"]?.toString().trim() ?? '';
    final String urlStr = item["url"]?.toString().trim() ?? '';

    /// 0️⃣ EXPLICIT NAVIGATION TARGETS (RE-ORDERED TO TAKE PRIORITY)
    if (navStr.isNotEmpty) {
      // Handle navigationSlide specifically to pass items
      if (navStr == 'navigationSlide' || navStr == '/navigationSlide') {
        Get.toNamed('/navigationSlide', arguments: {
          'items': item["children"],
          'endpoint': urlStr,
          'title': title,
        });
        return;
      }

      if ((navStr == 'dynamicExamList' || navStr == 'examstorypage') && urlStr.isNotEmpty) {
        Get.toNamed('/$navStr', arguments: {'endpoint': urlStr});
        return;
      }

      // Other explicit routes
      String nav = navStr;
      if (!nav.startsWith('/')) nav = '/$nav';

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
        "items": item["children"],
      };
      if (item["id"] != null) {
        routeArgs["id"] = int.tryParse(item["id"].toString()) ?? 0;
      }

      if (nav == '/studyFull') Get.delete<StudyController>();
      if (nav == '/story') Get.delete<StoryController>();

      if (nav == '/examSplash') {
        int examId = routeArgs["id"] ?? 0;
        _fetchAndNavigateSplash(examId, item, title);
        return;
      }

      Get.toNamed(nav, arguments: routeArgs);
      return;
    }

    /// 1️⃣ CHILDREN → SUBMENU (Now fallback if no explicit nav)
    if (item["children"] != null && item["children"].isNotEmpty) {
      stack.add(items.toList());
      slideStack.add(isSlideView.value); // Save current
      
      items.value = item["children"];
      keys.add(title);
      isSlideView.value = false; // Reset for children generally
      
      navStack.add(currentNav);
      return;
    }

    /// 2️⃣ URL → CALL API
    if (item["url"] != null && item["url"] != "") {
      stack.add(items.toList());
      keys.add(title);

      navStack.add(currentNav);
      if (item["navigation"] != null && item["navigation"].toString().trim().isNotEmpty) {
        currentNav = item["navigation"].toString().trim();
      }

      fetchData(item["url"]);
      return;
    }

    /// 3️⃣ NAVIGATION → OPEN PAGE (EXPLICIT ON THE ITEM)
    if (item["navigation"] != null && item["navigation"].toString().trim().isNotEmpty) {
      String nav = item["navigation"].toString().trim();
      if (!nav.startsWith('/')) nav = '/$nav';

      List<String> keywords = [];
      if (item["keywords"] != null) {
        keywords = List<String>.from(item["keywords"]);
      } else if (item["keyword"] != null) {
        keywords = [item["keyword"].toString()];
      }

      Map<String, dynamic> routeArgs = {
        "keywords": keywords,
        "title": title,
        "endpoint": item["url"] ?? "",
        "items": item["children"], // 🔥 Pass children for NavigationSlide
      };
      if (item["id"] != null) {
        routeArgs["id"] = int.tryParse(item["id"].toString()) ?? 0;
      }

      if (nav == '/studyFull') {
        Get.delete<StudyController>();
      }

      if (nav == '/story') {
        Get.delete<StoryController>();
      }

      if (nav == '/examSplash') {
        int examId = 0;
        if (keywords.isNotEmpty) {
          examId = int.tryParse(keywords.first) ?? 0;
        }
        if (examId == 0) {
          examId = routeArgs["id"] ?? 0;
        }
        
        _fetchAndNavigateSplash(examId, item, title);
        return;
      }

      Get.toNamed(nav, arguments: routeArgs);
      return;
    }

    /// 4️⃣ KEYWORD OR FALLBACK (LEAF NODE PRESERVING CURRENT NAV)
    String targetNav = currentNav.isNotEmpty ? currentNav : '/studyFull';
    if (!targetNav.startsWith('/')) targetNav = '/$targetNav';

    List<String> keywords = [];
    if (item["keywords"] != null) {
      keywords = List<String>.from(item["keywords"]);
    } else if (item["keyword"] != null) {
      keywords = [item["keyword"].toString()];
    }

    Map<String, dynamic> routeArgs = {
      "title": title,
      "keywords": keywords,
      "endpoint": item["url"] ?? "",
    };
    if (item["id"] != null) {
      routeArgs["id"] = int.tryParse(item["id"].toString()) ?? 0;
    }

    // 🌟 EXAM LOGIC INTERCEPTION
    if (targetNav == '/exam' || targetNav == '/exams') {
      int examId = routeArgs["id"] ?? 0;
      await handleExamNavigation(item, examId);
      return; 
    }

    if (targetNav == '/studyFull') {
      Get.delete<StudyController>();
    }

    Get.toNamed(targetNav, arguments: routeArgs);
  }

  Future<void> handleExamNavigation(dynamic item, int examId) async {
    final auth = AuthController.instance;

    // 🌟 CENTRALIZED ACCESS CHECK
    if (!auth.canAccess(item)) {
      auth.showPremiumAlert();
      return;
    }

    final TestController testController = Get.find<TestController>();
    
    bool isLocked = item["locked"] == true || item["locked"] == "true" || item["locked"] == 1;

    if (isLocked) {
      // Allow Trial/Paid users to bypass lock if that's the requirement
      final auth = AuthController.instance;
      final userType = auth.userType.value.toLowerCase();
      if (userType != "trial" && userType != "paid") {
        Get.snackbar(
          "Exam Locked",
          "This exam is currently locked",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
        );
        return;
      }
    }

    bool resume = await testController.hasProgressForExam(examId);

    if (resume) {
      Get.defaultDialog(
        title: "Resume Exam",
        middleText: "You have unfinished progress",
        textCancel: "Restart",
        textConfirm: "Resume",
        confirmTextColor: Colors.white,
        onConfirm: () async {
          Get.back();
          await testController.loadProgress(examId);
          Get.toNamed('/exam', arguments: {'id': examId});
        },
        onCancel: () async {
          Get.back();
          await testController.clearProgress(examId);
          await testController.loadQuestions(examId);
          Get.toNamed('/exam', arguments: {'id': examId});
        },
      );
    } else {
      await testController.loadQuestions(examId);
      Get.toNamed('/exam', arguments: {'id': examId});
    }
  }

  /// BACK
  void goBack() {
    if (stack.isNotEmpty) {
      items.value = stack.removeLast();
      keys.removeLast();
      if (slideStack.isNotEmpty) {
        isSlideView.value = slideStack.removeLast();
      }
      if (navStack.isNotEmpty) {
        currentNav = navStack.removeLast();
      }
    } else {
      Get.back();
    }
  }

  Future<void> _fetchAndNavigateSplash(int examId, dynamic item, String fallbackTitle) async {
    Get.dialog(Center(child: CircularProgressIndicator(color: const Color(0xFF1B8A4E))), barrierDismissible: false);
    try {
      final res = await http.get(Uri.parse('${AppConfig.testExam}$examId/'));
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);
        final exam = Exam(
          id: examId,
          category: data["category"]?.toString() ?? item["category"]?.toString() ?? "Exam",
          specialization: data["specialization"]?.toString() ?? fallbackTitle,
          locked: item["locked"] == true || item["locked"] == "true" || item["locked"] == 1,
          totalQuestions: data["questions"]?.length ?? int.tryParse(item['total_questions']?.toString() ?? "50") ?? 50,
          accessType: item["access_type"]?.toString() ?? "free",
          instructions: data["instructions"]?.toString(),
          description: data["description"]?.toString(),
        );
        Get.back(); // Remove loading dialog
        Get.toNamed('/examSplash', arguments: {'exam': exam});
      } else {
        Get.back();
        Get.snackbar("Notice", "Exam content not available");
      }
    } catch (_) {
      Get.back();
      Get.snackbar("Error", "Network error loading exam");
    }
  }
}