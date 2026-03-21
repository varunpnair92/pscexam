import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'study_controller.dart';

class DynamicMenuController extends GetxController {
  var items = [].obs;
  var stack = <dynamic>[].obs;
  var keys = <String>[].obs;

  String currentUrl = "";

  @override
  void onInit() {
    final args = Get.arguments ?? {};

    currentUrl = args['endpoint'] ?? "";
    String title = args['title'] ?? "Menu";
    final initialItems = args['items'];

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
  void onTileTap(dynamic item) {
    final title = getTitle(item);

    /// 1️⃣ CHILDREN → SUBMENU
    if (item["children"] != null && item["children"].isNotEmpty) {
      stack.add(items.toList());
      items.value = item["children"];
      keys.add(title);
      return;
    }

    /// 2️⃣ URL → CALL API
    if (item["url"] != null && item["url"] != "") {
      stack.add(items.toList());
      keys.add(title);
      fetchData(item["url"]);
      return;
    }

    /// 3️⃣ NAVIGATION → OPEN PAGE
    if (item["navigation"] != null && item["navigation"] != "") {
      Get.toNamed(item["navigation"], arguments: {
        "keywords": item["keywords"] ?? [],
        "title": title,
        "endpoint": item["url"] ?? "",
      });
      return;
    }

    /// 4️⃣ KEYWORD → OPEN STUDY PAGE
    if (item["keyword"] != null ||
        (item["keywords"] != null && item["keywords"].isNotEmpty)) {
      List<String> keywords = [];

      if (item["keywords"] != null) {
        keywords = List<String>.from(item["keywords"]);
      } else if (item["keyword"] != null) {
        keywords = [item["keyword"]];
      }

      Get.delete<StudyController>();
      Get.toNamed('/studyFull', arguments: {
        "keywords": keywords,
        "title": title,
      });

      return;
    }

    /// 5️⃣ FALLBACK TO STUDY PAGE IF NO URL/NAVIGATION
    Get.delete<StudyController>();
    Get.toNamed('/studyFull', arguments: {
      "title": title,
    });
  }

  /// BACK
  void goBack() {
    if (stack.isNotEmpty) {
      items.value = stack.removeLast();
      keys.removeLast();
    } else {
      Get.back();
    }
  }
}