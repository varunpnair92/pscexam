import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
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
    // 🌐 Fetch latest knowledge scroll from API on startup
    await fetchCapsuleFromApi();
  }

  Future<void> fetchCapsuleFromApi() async {
    try {
      isLoading.value = true;
      final res = await http.get(Uri.parse(AppConfig.activeKnowledgeScroll));
      
      if (res.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data.isNotEmpty) {
          // 🎲 Filter all active facts
          final activeList = data.where((e) => e['active'] == true).toList();
          final listToUse = activeList.isNotEmpty ? activeList : data;

          // 🎲 Pick a random fact each time the app opens
          final randomFact = listToUse[Random().nextInt(listToUse.length)];
          final String content = randomFact['content'] ?? "";
          
          if (content.isNotEmpty) {
            currentFact.value = content;
            _showWithDelay();
          }
        }
      }
    } catch (_) {
      // Silently fail if offline
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
