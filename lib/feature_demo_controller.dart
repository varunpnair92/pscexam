import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';
import 'feature_demo_model.dart';
import 'feature_demo_dialog.dart';

class FeatureDemoController extends GetxController {
  static FeatureDemoController get instance => Get.find<FeatureDemoController>();

  var demoItems = <FeatureDemoModel>[].obs;
  var isLoading = false.obs;
  var hasShownThisSession = false;

  @override
  void onInit() {
    super.onInit();
    fetchDemoNodes();
  }

  Future<void> fetchDemoNodes() async {
    try {
      isLoading.value = true;
      final res = await http.get(Uri.parse(AppConfig.demoNodes)).timeout(
            const Duration(seconds: 8),
          );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is List) {
          demoItems.value = decoded.map((e) => FeatureDemoModel.fromJson(e)).toList();
        }
      }
    } catch (_) {
      // Silently catch error, fallback features will be provided or demo skipped
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkAndShowDemo({bool force = false}) async {
    if (!force && hasShownThisSession) return;

    // Check SharedPreferences if shown recently
    final prefs = await SharedPreferences.getInstance();
    final String todayKey = "demo_shown_${DateTime.now().toIso8601String().substring(0, 10)}";
    final bool shownToday = prefs.getBool(todayKey) ?? false;

    if (!force && shownToday) {
      hasShownThisSession = true;
      return;
    }

    if (demoItems.isEmpty) {
      await fetchDemoNodes();
    }

    if (demoItems.isNotEmpty) {
      hasShownThisSession = true;
      await prefs.setBool(todayKey, true);

      // Delay slightly so the home page renders smoothly first
      await Future.delayed(const Duration(milliseconds: 1000));
      FeatureDemoDialog.show(demoItems);
    }
  }

  static void navigateFromDemo(FeatureDemoModel item) {
    Get.back(); // Dismiss demo dialog

    final nav = item.navigation.trim();
    final url = item.url.trim().toLowerCase();
    final title = item.name;
    final kw = item.keywords.isNotEmpty ? item.keywords.last : item.name;

    if (url.contains('keyword-search-summary') ||
        url.contains('keywordsummary') ||
        nav.toLowerCase().contains('keywordsummary')) {
      Get.toNamed('/keywordSummary', arguments: {'keyword': kw});
      return;
    }

    if (url.contains('keywordtimeline') || nav.toLowerCase().contains('timeline')) {
      Get.toNamed('/timeline', arguments: {'title': title, 'endpoint': item.url, 'keyword': kw});
      return;
    }

    if (nav.toLowerCase() == 'exambattle' || nav.toLowerCase() == '/exambattle') {
      Get.toNamed('/exambattle');
      return;
    }

    if (nav == 'searchParentNavigation' || nav.toLowerCase() == 'searchparentnavigation') {
      Get.toNamed('/searchParentNavigation', arguments: {'keyword': kw, 'title': title});
      return;
    }

    if (nav == 'parentNavigation' || nav.toLowerCase() == 'parentnavigation') {
      Get.toNamed('/parentNavigation', arguments: {'keyword': kw, 'title': title});
      return;
    }

    if (nav.toLowerCase() == 'examcreate' || nav.toLowerCase() == '/examcreate') {
      Get.toNamed('/examcreate', arguments: {'keyword': kw});
      return;
    }

    if (nav == 'navigationSlide' || nav == '/navigationSlide') {
      Get.toNamed('/navigationSlide', arguments: {'title': title, 'endpoint': item.url});
      return;
    }

    if (nav.isNotEmpty) {
      Get.toNamed('/$nav', arguments: {'keyword': kw, 'title': title, 'endpoint': item.url});
      return;
    }

    // Default fallback to keyword summary
    Get.toNamed('/keywordSummary', arguments: {'keyword': kw});
  }
}
