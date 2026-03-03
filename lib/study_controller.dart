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
    final type = item["type"];
    final name = item["name"];

    if (type == "node") {
      keys.add(name);
      fetchHierarchy();
    }

    if (type == "leaf") {
      keys.add(name); // 👈 ADD THIS LINE
      fetchQuestionsByKeyword(name); // 👈 KEEP THIS
    }
  }

  // ================= FETCH QUESTIONS =================

  Future<void> fetchQuestionsByKeyword(String keyword) async {
    showQuestions.value = true;

    final res = await http.post(
      Uri.parse(AppConfig.keywordQuestions),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "keywords": [keyword], // 🔥 ONLY LAST VALUE
      }),
    );

    if (res.statusCode == 200) {
      questions.value = jsonDecode(res.body);
    }
  }

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
    if (showQuestions.value) {
      // If currently showing questions
      showQuestions.value = false;
      questions.clear();

      keys.removeLast(); // 👈 remove only leaf
      return;
    }

    if (keys.length > 1) {
      keys.removeLast();
      fetchHierarchy();
    }
  }
}
