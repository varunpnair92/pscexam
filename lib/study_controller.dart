import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class StudyController extends GetxController {
  var keys = <String>[].obs;
  var items = [].obs;
  var questions = [].obs;
  var showQuestions = false.obs;

  @override
  void onInit() {
    fetchHierarchy();
    super.onInit();
  }

  // 🔥 FETCH HIERARCHY
  Future<void> fetchHierarchy() async {
    final res = await http.post(
      Uri.parse(AppConfig.hierarchy),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"keys": keys}),
    );

    final data = jsonDecode(res.body);

    if (data["result"] == "empty") {
      fetchQuestions();
    } else {
      items.value = data["result"];
    }
  }

  // 🔥 TILE TAP
  void onTileTap(String value) {
    keys.add(value);
    fetchHierarchy();
  }

  // 🔥 FETCH QUESTIONS
  Future<void> fetchQuestions() async {
    final res = await http.post(
      Uri.parse(AppConfig.keywordQuestions),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"keywords": keys}),
    );

    questions.value = jsonDecode(res.body);
    showQuestions.value = true;
  }

  // 🔥 BACK ONE LEVEL
  void goBack() {
    if (keys.isNotEmpty) {
      keys.removeLast();
      showQuestions.value = false;
      fetchHierarchy();
    }
  }
}