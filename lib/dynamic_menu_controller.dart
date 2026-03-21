import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'study_controller.dart';
import 'test_controller.dart';

class DynamicMenuController extends GetxController {
  var items = [].obs;
  var stack = <dynamic>[].obs;
  var keys = <String>[].obs;
  
  var navStack = <String>[];
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
    final title = getTitle(item);

    /// 1️⃣ CHILDREN → SUBMENU
    if (item["children"] != null && item["children"].isNotEmpty) {
      stack.add(items.toList());
      items.value = item["children"];
      keys.add(title);
      
      navStack.add(currentNav);
      if (item["navigation"] != null && item["navigation"].toString().trim().isNotEmpty) {
        currentNav = item["navigation"].toString().trim();
      }
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

      Map<String, dynamic> routeArgs = {
        "keywords": item["keywords"] ?? [],
        "title": title,
        "endpoint": item["url"] ?? "",
      };
      if (item["id"] != null) {
        routeArgs["id"] = int.tryParse(item["id"].toString()) ?? 0;
      }

      if (nav == '/studyFull') {
        Get.delete<StudyController>();
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
    final TestController testController = Get.find<TestController>();
    
    bool isLocked = item["locked"] == true || item["locked"] == "true" || item["locked"] == 1;

    if (isLocked) {
      Get.snackbar(
        "Exam Locked",
        "This exam is currently locked",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
      );
      return;
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
      if (navStack.isNotEmpty) {
        currentNav = navStack.removeLast();
      }
    } else {
      Get.back();
    }
  }
}