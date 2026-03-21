import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';
import 'study_controller.dart';

class HomeController extends GetxController {
  // ─── Node tree data ───────────────────────────────────────────
  var examCategories = [].obs;   // children of the EXAM node
  var attemptCategories = [].obs; // children of the GUI1 node
  var studyTopics = [].obs;      // top-level children of the first study root
  var isLoading = true.obs;

  // ─── Stats (from shared_prefs) ────────────────────────────────
  var totalAttempts = 0.obs;
  var lastExamName = ''.obs;
  var lastExamId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
    _loadLocalStats();
  }

  Future<void> fetchHomeData() async {
    isLoading.value = true;
    try {
      final res = await http.get(Uri.parse(AppConfig.nodeall));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);

        // Find EXAM node → its children become exam categories
        final examNode = data.firstWhereOrNull(
          (e) => e['name'] == 'EXAM',
        );
        if (examNode != null) {
          examCategories.value = examNode['children'] ?? [];
        }

        // Find GUI1 node → its children become attempt categories
        final gui1Node = data.firstWhereOrNull(
          (e) => e['name'] == 'GUI1',
        );
        if (gui1Node != null) {
          attemptCategories.value = gui1Node['children'] ?? [];
        }

        // Use the first root node's top-level children as study topics
        final studyRoot = data.firstWhereOrNull(
          (e) => e['name'] != 'EXAM',
        );
        if (studyRoot != null) {
          studyTopics.value = studyRoot['children'] ?? [];
        }
      }
    } catch (e) {
      // silently fail – UI shows empty state
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadLocalStats() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    // Count keys that look like attempt-count entries
    int count = 0;
    for (final k in keys) {
      if (k.startsWith('attempts_')) count += (prefs.getInt(k) ?? 0);
    }
    totalAttempts.value = count;
    lastExamName.value = prefs.getString('last_exam_name') ?? '';
    lastExamId.value = prefs.getString('last_exam_id') ?? '';
  }

  void navigateAttemptCategory(dynamic item) {
    final nav = item['navigation'] ?? '';
    final url = item['url'] ?? '';
    final children = item['children'];

    if (nav == 'dynamicExamList' && url.isNotEmpty) {
      Get.toNamed('/dynamicExamList', arguments: {'endpoint': url});
      return;
    }

    if (url.isNotEmpty) {
      Get.toNamed('/dynamicMenu', arguments: {
        'endpoint': url,
        'title': item['name'] ?? 'Attempt',
        'parentNavigation': nav,
      });
    } else if (children != null && (children as List).isNotEmpty) {
      Get.toNamed('/dynamicMenu', arguments: {
        'items': children,
        'title': item['name'] ?? 'Attempt',
        'parentNavigation': nav,
      });
    } else if (nav.isNotEmpty) {
      Get.toNamed(nav);
    } else {
      Get.delete<StudyController>();
      Get.toNamed('/studyFull', arguments: {
        "title": item['name'] ?? 'Study',
      });
    }
  }

  void navigateExamCategory(dynamic item) {
    final nav = item['navigation'] ?? '';
    final url = item['url'] ?? '';

    if (nav == 'dynamicExamList' && url.isNotEmpty) {
      Get.toNamed('/dynamicExamList', arguments: {'endpoint': url});
    } else if (item['children'] != null &&
        (item['children'] as List).isNotEmpty) {
      Get.toNamed('/home', arguments: {'tab': 1});
    }
  }

  void navigateStudy(dynamic item) {
    // Navigate to the Study tab (index 2 after we add Home tab)
    Get.toNamed('/home', arguments: {'tab': 2});
  }
}
