import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psc_exam/auth_controller.dart';
import 'app_config.dart';
import 'study_controller.dart';
import 'news_controller.dart';
import 'test_controller.dart';

class HomeController extends GetxController {
  // ─── Node tree data ───────────────────────────────────────────
  var examCategories = [].obs;   // children of the EXAM node
  var attemptCategories = [].obs; // children of the GUI1 node
  var studyTopics = [].obs;      // top-level children of the first study root
  var boosterTopics = [].obs;    // children of the BOOSTER node
  var isLoading = true.obs;

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

  var statsLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    Get.put(NewsController()); 
    fetchHomeData();
    loadLocalStats();
    fetchUserStats();
  }

  Future<void> fetchHomeData() async {
    isLoading.value = true;
    try {
      final res = await http.get(Uri.parse(AppConfig.nodeall));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);

        // Find EXAM node
        final examNode = data.firstWhereOrNull((e) => e['name'] == 'EXAM');
        if (examNode != null) examCategories.value = examNode['children'] ?? [];

        // Find GUI1 node
        final gui1Node = data.firstWhereOrNull((e) => e['name'] == 'GUI1');
        if (gui1Node != null) attemptCategories.value = gui1Node['children'] ?? [];

        // Find BOOSTER node
        final boosterNode = findNodeByName('booster', data);
        if (boosterNode != null) boosterTopics.value = boosterNode['children'] ?? [];

        // Find NEWS node ───── (Recursive check)
        final newsNode = findNodeByName('NEWS', data);
        if (newsNode != null && newsNode['url'] != null) {
          String newsUrl = newsNode['url'].toString();
          // Ensure it's a full URL
          if (!newsUrl.startsWith('http')) {
            newsUrl = "${AppConfig.baseUrl}$newsUrl";
          }
          // Ensure it has a trailing slash (common in your Django backend)
          if (!newsUrl.endsWith('/')) {
            newsUrl = "$newsUrl/";
          }
          
          Get.find<NewsController>().fetchNews(newsUrl);
        }

        // Use the first root node's top-level children as study topics
        final studyRoot = data.firstWhereOrNull((e) => e['name'] != 'EXAM');
        if (studyRoot != null) {
          studyTopics.value = studyRoot['children'] ?? [];
        }
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

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
      final res = await http.get(Uri.parse('${AppConfig.userExamStats}$userId/'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        userName.value = data['fullname'] ?? data['username'] ?? '';
        totalExams.value = data['total_exams'] ?? 0;
        attemptedExams.value = data['attempted_exams'] ?? 0;
        remainingExams.value = data['remaining_exams'] ?? 0;
        successRatio.value = (data['success_ratio'] ?? 0.0).toDouble();
        totalQuestionsAttended.value = data['total_questions_attended'] ?? 0;
        totalCorrectAnswers.value = data['total_correct_answers'] ?? 0;
        questionSuccessRatio.value = (data['question_success_ratio'] ?? 0.0).toDouble();
      }
    } catch (_) {} finally {
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
    final nav = item['navigation'] ?? '';
    final url = item['url'] ?? '';
    final children = item['children'];
    final name = item['name'] ?? 'Attempt';

    if (nav == 'dynamicExamList' && url.isNotEmpty) {
      Get.toNamed('/dynamicExamList', arguments: {'endpoint': url});
      return;
    }

    if (url.isNotEmpty) {
      Get.toNamed('/dynamicMenu', arguments: {
        'endpoint': url,
        'title': name,
        'parentNavigation': nav,
      });
    } else if (children != null && (children as List).isNotEmpty) {
      Get.toNamed('/dynamicMenu', arguments: {
        'items': children,
        'title': name,
        'parentNavigation': nav,
      });
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

      Get.toNamed(routeName, arguments: {
        "title": name,
        "keywords": keywords,
      });
    }
  }

  void navigateExamCategory(dynamic item) {
    final nav = item['navigation'] ?? '';
    final url = item['url'] ?? '';
    if (nav == 'dynamicExamList' && url.isNotEmpty) {
      Get.toNamed('/dynamicExamList', arguments: {'endpoint': url});
    } else if (item['children'] != null && (item['children'] as List).isNotEmpty) {
      Get.toNamed('/home', arguments: {'tab': 1});
    }
  }

  void navigateStudy(dynamic item) {
    Get.toNamed('/home', arguments: {'tab': 2});
  }

  Map<String, dynamic>? findExamByName(String name, [List? list]) {
    final searchList = list ?? examCategories;
    for (var item in searchList) {
      String itemName = (item['specialization'] ?? item['name'] ?? "").toString().toLowerCase();
      if (itemName == name.toLowerCase()) return Map<String, dynamic>.from(item);
      if (item['children'] != null && item['children'] is List) {
        final found = findExamByName(name, item['children']);
        if (found != null) return found;
      }
    }
    return null;
  }
}
