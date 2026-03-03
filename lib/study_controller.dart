import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class StudyController extends GetxController {
  // 🔥 START ROOT
  var keys = <String>["LDC"].obs;

  var items = [].obs;
  var questions = [].obs;

  var isLeaf = false.obs;
  var showQuestions = false.obs;

  @override
  void onInit() {
    fetchHierarchy();
    super.onInit();
  }

  // ================= FETCH HIERARCHY =================

  Future<void> fetchHierarchy() async {
    final res = await http.post(
      Uri.parse(AppConfig.hierarchy),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"keys": keys}),
    );

    final data = jsonDecode(res.body);

    items.value = data["result"];
    isLeaf.value = data["type"] == "leaf";
    showQuestions.value = false;
  }

  // ================= TILE CLICK =================

  void onTileTap(dynamic item) {
    final String name = item["name"];
    final String type = item["type"];

    if (type == "node") {
      keys.add(name); // ✅ add String only
      fetchHierarchy();
    }

    if (type == "leaf") {
      keys.add(name); // ✅ add String only
      fetchQuestions();
    }
  }

  // ================= FETCH QUESTIONS =================

  Future<void> fetchQuestions() async {
    final res = await http.post(
      Uri.parse(AppConfig.keywordQuestions),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"keywords": keys}),
    );

    questions.value = jsonDecode(res.body);
    showQuestions.value = true;
  }

  // ================= GO BACK =================

  void goBack() {
    if (keys.length > 1) {
      keys.removeLast();
      fetchHierarchy();
    }
  }
}
