import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'auth_controller.dart';
import 'exam_model.dart';

class ExamMenuController extends GetxController {
  String lastEndpoint = "";

  var fullTree = [].obs;
  var items = [].obs;
  var searchQuery = "".obs;

  List<dynamic> get displayedItems {
    if (searchQuery.value.isEmpty) return items;
    return items
        .where((e) => (e["name"] ?? "")
            .toString()
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  /// BACK STACK
  var stack = <dynamic>[].obs;

  /// BREADCRUMB
  var keys = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // 🔄 RE-FETCH ON COURSE CHANGE
    ever(AuthController.instance.selectedCourseName, (_) {
      fetchTree();
      stack.clear();
      keys.clear();
    });

    fetchTree();
  }

  /// LOAD TREE
  Future<void> fetchTree() async {
    final res = await http.get(Uri.parse(AppConfig.nodeall));

    final data = jsonDecode(res.body);

    fullTree.value = data;
    
    // 🎯 1. FIND THE SELECTED COURSE NODE
    final auth = AuthController.instance;
    final String selectedCourse = auth.selectedCourseName.value;
    
    var courseNode = data.firstWhere(
      (e) => e["name"] == selectedCourse,
      orElse: () => null,
    );

    // 🎯 2. LOOK FOR "EXAM" CHILD WITHIN COURSE (exact match first, then fallback)
    dynamic targetExamNode;
    if (courseNode != null && courseNode["children"] != null) {
      final children = courseNode["children"] as List;
      // Exact match first
      targetExamNode = children.firstWhereOrNull(
        (c) => (c["name"] ?? "").toString().toUpperCase() == "EXAM",
      );
      // Fallback: starts-with match (avoids liveexam false positive)
      targetExamNode ??= children.firstWhereOrNull(
        (c) => (c["name"] ?? "").toString().toUpperCase().startsWith("EXAM"),
      );
    }

    // 🎯 3. FALLBACK TO GLOBAL "EXAM"
    if (targetExamNode == null) {
      targetExamNode = data.firstWhere(
        (e) => e["name"] == "EXAM",
        orElse: () => null,
      );
    }

    if (targetExamNode != null) {
      items.value = targetExamNode["children"] ?? [];
      keys.clear();
      keys.add(targetExamNode["name"] ?? "Exams");
    }
  }

  /// TILE CLICK
  void onTileTap(dynamic item) {
    final auth = AuthController.instance;

    // 🌟 CENTRALIZED ACCESS CHECK
    if (!auth.canAccess(item)) {
      auth.showPremiumAlert();
      return;
    }

    final name = item["name"];
    lastEndpoint = item["url"] ?? lastEndpoint;

    final nav = item["navigation"]?.toString() ?? "";
    final route = nav.startsWith('/') ? nav : '/$nav';

    if (nav == 'examSplash' || nav == '/examSplash') {
      List<String> keywords = [];
      if (item["keywords"] != null) {
        keywords = List<String>.from(item["keywords"]);
      } else if (item["keyword"] != null) {
        keywords = [item["keyword"].toString()];
      }
      
      int examId = 0;
      if (keywords.isNotEmpty) {
        examId = int.tryParse(keywords.first) ?? 0;
      }
      if (examId == 0 && item["id"] != null) {
        examId = int.tryParse(item["id"].toString()) ?? 0;
      }
      
      _fetchAndNavigateSplash(examId, item, name);
      return;
    }

    /// ACTION → OPEN EXAM LIST
    if (item["url"] != null && item["url"] != "") {
      Get.toNamed(item["navigation"], arguments: {"endpoint": item["url"]});
      return;
    }

    /// NODE → GO DEEPER
    if (item["children"] != null && item["children"].length > 0) {
      stack.add(items);
      items.value = item["children"];
      keys.add(name);
      searchQuery.value = ""; // 🔥 Reset search on navigation
      return;
    }

    /// LEAF
    //  print("Leaf clicked: $name");
  }

  /// BACK
  void goBack() {
    if (stack.isNotEmpty) {
      items.value = stack.removeLast();
      keys.removeLast();
      searchQuery.value = ""; // 🔥 Reset search on back
    }
  }

  void clearSearch() {
    searchQuery.value = "";
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

