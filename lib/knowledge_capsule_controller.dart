import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class KnowledgeCapsuleController extends GetxController {
  var isVisible = false.obs;
  var currentFact = "".obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 🛡️ Global Toggle Check
    if (AppConfig.knowledgeCardActive) {
      _initCapsule();
    }
  }

  Future<void> _initCapsule() async {
    final prefs = await SharedPreferences.getInstance();
    final String lastDate = prefs.getString('last_capsule_date') ?? "";
    final String today = DateTime.now().toIso8601String().substring(0, 10);

    // 🕒 Step 1: Check if we have a fresh fact for today
    if (lastDate == today) {
      final String cachedFact = prefs.getString('last_capsule_content') ?? "";
      if (cachedFact.isNotEmpty) {
        currentFact.value = cachedFact;
        _showWithDelay();
        return;
      }
    }

    // 🌐 Step 2: Fetch from API if cache is old or empty
    await fetchCapsuleFromApi(prefs, today);
  }

  Future<void> fetchCapsuleFromApi(SharedPreferences prefs, String today) async {
    try {
      isLoading.value = true;
      final res = await http.get(Uri.parse(AppConfig.activeKnowledgeScroll));
      
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        if (data.isNotEmpty) {
          // Take the first active fact
          final fact = data.firstWhere((e) => e['active'] == true, orElse: () => data.first);
          final String content = fact['content'] ?? "";
          
          if (content.isNotEmpty) {
            currentFact.value = content;
            // 💾 Cache it for 24 hours
            await prefs.setString('last_capsule_date', today);
            await prefs.setString('last_capsule_content', content);
            _showWithDelay();
          }
        }
      }
    } catch (_) {
      // Silently fail, fall back to last known or do nothing
    } finally {
      isLoading.value = false;
    }
  }

  void _showWithDelay() {
    // Show after a small delay to let the home screen settle
    Future.delayed(const Duration(milliseconds: 800), () {
      isVisible.value = true;
    });
  }

  void dismiss() {
    isVisible.value = false;
  }
}
