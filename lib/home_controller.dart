import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psc_exam/auth_controller.dart';
import 'app_config.dart';
import 'study_controller.dart';
import 'news_controller.dart';
import 'test_controller.dart';
import 'exam_model.dart';
import 'tree_service.dart'; // 🔥 Import TreeService

class HomeController extends GetxController {
  // ─── Node tree data ───────────────────────────────────────────
  var examCategories = [].obs;
  var examSectionName = "Exam Categories".obs; // 🎯 Dynamic
  var attemptCategories = [].obs;
  var attemptSectionName = "Attempts".obs; // 🎯 Dynamic
  var studyTopics = [].obs;
  var boosterTopics = [].obs;
  var boosterSectionName = "Booster".obs; // 🎯 Dynamic
  var isLoading = true.obs;

  var liveExamsNode = {}.obs;

  // ─── Stats (from shared_prefs) ────────────────────────────────
  var totalAttempts = 0.obs;
  var lastExamName = ''.obs;
  var lastExamId = ''.obs;

  // ─── User Exam Stats (from API) ───────────────────────────────
  var userName = ''.obs;
  var totalExams = 0.obs;
  var attemptedExams = 0.obs;
  var remainingExams = 0.obs;
  var successRatio = 0.0.obs;

  var totalQuestionsAttended = 0.obs;
  var totalCorrectAnswers = 0.obs;
  var questionSuccessRatio = 0.0.obs;
  
  var cumulativeTime = {}.obs;

  var statsLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    Get.put(NewsController());
    
    // 🔄 RE-FETCH ON COURSE CHANGE
    ever(AuthController.instance.selectedCourseName, (_) {
      fetchHomeData();
      fetchUserStats();
    });

    fetchHomeData();
    loadLocalStats();
    
    // ⏳ Stagger non-critical stats loading
    Future.delayed(const Duration(seconds: 2), () {
      fetchUserStats();
    });
  }

  Future<void> fetchHomeData({bool force = false}) async {
    isLoading.value = true;
    try {
      await TreeService.instance.fetchTree(force: force);
      if (TreeService.instance.fullTree.isNotEmpty) {
        final List<dynamic> data = TreeService.instance.fullTree;

        // 🎯 SAVE LIVE EXAMS NODE IF PRESENT
        final foundLiveExamNode = findNodeByName('LIVEEXAM', data) ?? findNodeByName('LIVE EXAMS', data);
        if (foundLiveExamNode != null) {
          liveExamsNode.value = foundLiveExamNode;
        } else {
          liveExamsNode.value = {};
        }

        // 🎯 1. FIND THE SELECTED COURSE NODE
        final auth = AuthController.instance;
        final String selectedCourse = auth.selectedCourseName.value;
        final courseNode = findNodeByName(selectedCourse, data);

        if (courseNode != null && courseNode['children'] != null) {
          final List<dynamic> children = courseNode['children'];

          // 🎯 2. MAP CHILDREN TO CATEGORIES
          // Reset previous
          examCategories.clear();
          attemptCategories.clear();
          boosterTopics.clear();
          studyTopics.clear();

          for (var child in children) {
            final String cName = (child['name'] ?? "").toString().toUpperCase();

            if (cName.contains("EXAM")) {
              examCategories.value = child['children'] ?? [];
              examSectionName.value = child['name'] ?? "Exam Categories";
            } else if (cName.contains("GUI1") || cName.contains("ATTEMPT")) {
              attemptCategories.value = child['children'] ?? [];
              attemptSectionName.value = child['name'] ?? "Attempts";
            } else if (cName.contains("BOOSTER")) {
              boosterTopics.value = child['children'] ?? [];
              boosterSectionName.value = child['name'] ?? "Booster";
            } else if (cName.contains("STUDY")) {
              studyTopics.value = child['children'] ?? [];
            } else if (cName.contains("NEWS") || cName.contains("NEWSFEEDER")) {
              _handleNewsNode(child);
            }
          }
        } else {
          // ─── FALLBACK TO GLOBAL SEARCH (PREVIOUS LOGIC) ───
          final examNode = data.firstWhereOrNull((e) => e['name'] == 'EXAM');
          if (examNode != null) examCategories.value = examNode['children'] ?? [];

          final gui1Node = data.firstWhereOrNull((e) => e['name'] == 'GUI1');
          if (gui1Node != null) attemptCategories.value = gui1Node['children'] ?? [];

          final boosterNode = findNodeByName('booster', data);
          if (boosterNode != null) boosterTopics.value = boosterNode['children'] ?? [];

          final newsNode = findNodeByName('NEWS', data);
          if (newsNode != null) _handleNewsNode(newsNode);

          final studyRoot = data.firstWhereOrNull((e) => e['name'] != 'EXAM');
          if (studyRoot != null) studyTopics.value = studyRoot['children'] ?? [];
        }
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  // Removed fetchLiveExams since node handles it dynamically!

  Future<void> loadLocalStats() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    int count = 0;
    for (final k in keys) {
      if (k.startsWith('attempts_')) count += (prefs.getInt(k) ?? 0);
    }
    totalAttempts.value = count;
    lastExamId.value = prefs.getString('last_exam_id') ?? '';
    lastExamName.value = prefs.getString('last_exam_name') ?? '';

    // 🔥 Sync with TestController's detailed resume state
    if (Get.isRegistered<TestController>()) {
      Get.find<TestController>().checkResume();
    }
  }

  Future<void> fetchUserStats() async {
    final int userId = Get.find<AuthController>().userId.value;
    statsLoading.value = true;
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.userExamStats}$userId/'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        userName.value = data['fullname'] ?? data['username'] ?? '';
        totalExams.value = data['total_exams'] ?? 0;
        attemptedExams.value = data['attempted_exams'] ?? 0;
        remainingExams.value = data['remaining_exams'] ?? 0;
        successRatio.value = (data['success_ratio'] ?? 0.0).toDouble();
        totalQuestionsAttended.value = data['total_questions_attended'] ?? 0;
        totalCorrectAnswers.value = data['total_correct_answers'] ?? 0;
        questionSuccessRatio.value = (data['question_success_ratio'] ?? 0.0)
            .toDouble();
            
        if (data['cumulative_time'] != null && data['cumulative_time'] is Map) {
          cumulativeTime.value = data['cumulative_time'];
        } else {
          cumulativeTime.clear();
        }
      }
    } catch (_) {
    } finally {
      statsLoading.value = false;
    }
  }

  /// 🔍 RECURSIVE SEARCH FOR ANY NODE BY NAME
  Map<String, dynamic>? findNodeByName(String name, List list) {
    for (var item in list) {
      String itemName = (item['name'] ?? "").toString().toUpperCase();
      if (itemName == name.toUpperCase()) {
        return Map<String, dynamic>.from(item);
      }
      if (item['children'] != null && item['children'] is List) {
        final found = findNodeByName(name, item['children']);
        if (found != null) return found;
      }
    }
    return null;
  }

  void navigateAttemptCategory(dynamic item) {
    // 🌟 CENTRALIZED ACCESS CHECK
    final auth = AuthController.instance;
    if (!auth.canAccess(item)) {
      auth.showPremiumAlert();
      return;
    }

    final nav = (item['navigation'] ?? '').toString().trim();
    final url = (item['url'] ?? '').toString().trim();
    final children = item['children'];
    final name = (item['name'] ?? 'Browse').toString();

    // 0. EXPLICIT NAVIGATION TARGETS (Priority)
    if (nav == 'navigationSlide' || nav == '/navigationSlide') {
      Get.toNamed('/navigationSlide', arguments: {
        'items': children,
        'title': name,
        'endpoint': url,
      });
      return;
    }

    if (nav == 'dynamicExamList' && url.isNotEmpty) {
      Get.toNamed('/dynamicExamList', arguments: {'endpoint': url});
      return;
    }

    if (nav == 'examstorypage' && url.isNotEmpty) {
      Get.toNamed('/examstorypage', arguments: {'endpoint': url});
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
      if (keywords.isNotEmpty) {
        examId = int.tryParse(keywords.first) ?? 0;
      }
      if (examId == 0 && item["id"] != null) {
        examId = int.tryParse(item["id"].toString()) ?? 0;
      }
      
      _fetchAndNavigateSplash(examId, item, name);
      return;
    }

    // 1. DEFAULT CHILDREN SUBMENU (Fallback)
    if (url.isNotEmpty) {
      Get.toNamed(
        '/dynamicMenu',
        arguments: {'endpoint': url, 'title': name, 'parentNavigation': nav},
      );
    } else if (children != null && (children as List).isNotEmpty) {
      Get.toNamed(
        '/dynamicMenu',
        arguments: {'items': children, 'title': name, 'parentNavigation': nav},
      );
    } else {
      // It's a leaf node. We need to pass keywords if any.
      List<String> keywords = [];
      if (item["keywords"] != null) {
        keywords = List<String>.from(item["keywords"]);
      } else if (item["keyword"] != null) {
        keywords = [item["keyword"].toString()];
      }
      if (keywords.isEmpty) {
        keywords = [name];
      }

      Get.delete<StudyController>();

      String routeName = nav.isNotEmpty ? nav : '/studyFull';
      if (!routeName.startsWith('/')) {
        routeName = '/$routeName';
      }

      Get.toNamed(routeName, arguments: {"title": name, "keywords": keywords});
    }
  }

  void navigateExamCategory(dynamic item) {
    // 🌟 CENTRALIZED ACCESS CHECK
    final auth = AuthController.instance;
    if (!auth.canAccess(item)) {
      auth.showPremiumAlert();
      return;
    }

    final nav = item['navigation'] ?? '';
    final url = item['url'] ?? '';
    if (nav == 'dynamicExamList' && url.isNotEmpty) {
      Get.toNamed('/dynamicExamList', arguments: {'endpoint': url});
    } else if (nav == 'examstorypage' && url.isNotEmpty) {
      Get.toNamed('/examstorypage', arguments: {'endpoint': url});
    } else if (item['children'] != null &&
        (item['children'] as List).isNotEmpty) {
      Get.toNamed('/home', arguments: {'tab': 1});
    }
  }

  void navigateStudy(dynamic item) {
    Get.toNamed('/home', arguments: {'tab': 2});
  }

  void _handleNewsNode(dynamic newsNode) {
    if (newsNode != null && newsNode['url'] != null) {
      String newsUrl = newsNode['url'].toString();
      if (!newsUrl.startsWith('http')) {
        newsUrl = "${AppConfig.baseUrl}$newsUrl";
      }
      if (!newsUrl.endsWith('/')) {
        newsUrl = "$newsUrl/";
      }
      Get.find<NewsController>().fetchNews(newsUrl);
    }
  }

  Map<String, dynamic>? findExamByName(String name, [List? list]) {
    final searchList = list ?? examCategories;
    for (var item in searchList) {
      String itemName = (item['specialization'] ?? item['name'] ?? "")
          .toString()
          .toLowerCase();
      if (itemName == name.toLowerCase())
        return Map<String, dynamic>.from(item);
      if (item['children'] != null && item['children'] is List) {
        final found = findExamByName(name, item['children']);
        if (found != null) return found;
      }
    }
    return null;
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
