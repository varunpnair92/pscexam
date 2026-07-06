import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'auth_controller.dart';
import 'exam_model.dart';
import 'tree_service.dart'; // 🔥 Import TreeService

class ExamMenuController extends GetxController {
  String lastEndpoint = "";

  var fullTree = [].obs;
  var items = [].obs;
  var searchQuery = "".obs;
  var isSlideView = false.obs;
  var slideStack = <bool>[].obs;

  List<dynamic> get displayedItems {
    if (searchQuery.value.isEmpty) return items;
    return items
        .where((e) => (e["name"] ?? "")
            .toString()
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  var stack = <dynamic>[].obs;
  var keys = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever(AuthController.instance.selectedCourseName, (_) {
      fetchTree();
      stack.clear();
      keys.clear();
    });
    fetchTree();
  }

  Future<void> fetchTree({bool force = false}) async {
    try {
      await TreeService.instance.fetchTree(force: force);
      if (TreeService.instance.fullTree.isEmpty) return;
      final data = TreeService.instance.fullTree;
      fullTree.value = data;
      
      final String selectedCourse = AuthController.instance.selectedCourseName.value;
      var courseNode = data.firstWhere((e) => e["name"] == selectedCourse, orElse: () => null);

      dynamic targetExamNode;
      if (courseNode != null && courseNode["children"] != null) {
        final children = courseNode["children"] as List;
        targetExamNode = children.firstWhereOrNull((c) => (c["name"] ?? "").toString().toUpperCase() == "EXAM");
        targetExamNode ??= children.firstWhereOrNull((c) => (c["name"] ?? "").toString().toUpperCase().startsWith("EXAM"));
      }

      targetExamNode ??= data.firstWhere((e) => e["name"] == "EXAM", orElse: () => null);

      if (targetExamNode != null) {
        items.value = targetExamNode["children"] ?? [];
        keys.clear();
        keys.add(targetExamNode["name"] ?? "Exams");
        final String nav = (targetExamNode['navigation'] ?? '').toString().trim();
        isSlideView.value = (nav == 'navigationSlide' || nav == '/navigationSlide');
      }
    } catch (_) {}
  }

  void onTileTap(dynamic item) {
    final auth = AuthController.instance;
    if (!auth.canAccess(item)) {
      auth.showPremiumAlert();
      return;
    }

    final name = (item["name"] ?? "").toString();
    lastEndpoint = item["url"] ?? lastEndpoint;

    final String navStr = (item['navigation'] ?? '').toString().trim();
    final String nav = navStr;

    if (navStr == 'navigationSlide' || navStr == '/navigationSlide') {
      stack.add(items.toList());
      slideStack.add(isSlideView.value);
      items.value = item["children"];
      keys.add(name);
      isSlideView.value = true;
      searchQuery.value = "";
      return;
    }

    if (nav == 'examSplash' || nav == '/examSplash') {
      List<String> keywords = [];
      if (item["keywords"] != null) {
        keywords = List<String>.from(item["keywords"]);
      } else if (item["keyword"] != null) {
        keywords = [item["keyword"].toString()];
      }
      
      int examId = 0;
      if (keywords.isNotEmpty) examId = int.tryParse(keywords.first) ?? 0;
      if (examId == 0 && item["id"] != null) examId = int.tryParse(item["id"].toString()) ?? 0;
      
      _fetchAndNavigateSplash(examId, item, name);
      return;
    }

    if (item["url"] != null && item["url"] != "" && nav.isNotEmpty) {
      Get.toNamed(nav, arguments: {"endpoint": item["url"]});
      return;
    }

    if (item["children"] != null && item["children"].length > 0) {
      stack.add(items.toList());
      slideStack.add(isSlideView.value);
      items.value = item["children"];
      keys.add(name);
      searchQuery.value = "";
      isSlideView.value = false;
      return;
    }
  }

  void goBack() {
    if (stack.isNotEmpty) {
      items.value = stack.removeLast();
      keys.removeLast();
      if (slideStack.isNotEmpty) isSlideView.value = slideStack.removeLast();
      searchQuery.value = "";
    }
  }

  void clearSearch() {
    searchQuery.value = "";
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
          totalQuestions: data["questions"]?.length ?? int.tryParse(item['total_questions']?.toString() ?? "50") ?? 50,
          accessType: item["access_type"]?.toString() ?? "free",
          instructions: data["instructions"]?.toString(),
          description: data["description"]?.toString(),
        );
        Get.back();
        Get.toNamed('/examSplash', arguments: {'exam': exam});
      } else {
        Get.back(); Get.snackbar("Notice", "Exam content not available");
      }
    } catch (_) {
      Get.back(); Get.snackbar("Error", "Network error loading exam");
    }
  }
}
