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

  var description = "".obs;

  var examIndex = 0.obs;
var examAnswers = <int, String>{}.obs;
var navigationType = "".obs;

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


  //===============fetch description ================
  Future<void> fetchKeywordDescription(String keyword) async {
  try {
    final res = await http.get(
      Uri.parse("${AppConfig.keywordDesc}$keyword/"),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      description.value = data["description"] ?? "";
    } else {
      description.value = "No description available";
    }
  } catch (e) {
    description.value = "Failed to load description";
  }
}

  // ================= TILE CLICK =================

 void onTileTap(dynamic item) {
  final type = item["type"];
  final name = item["name"];
  final navigation = item["navigation"];

  if (type == "node") {
    keys.add(name);
    fetchHierarchy();
  }

  if (type == "leaf") {

    if (navigation == "studyQuestion") {
      fetchQuestionsByKeyword(name);
      fetchKeywordDescription(name);
      Get.toNamed("/studyQuestion");
      return;
    }

    // studyFull behaviour (original)
    keys.add(name);
    fetchQuestionsByKeyword(name);
    fetchKeywordDescription(name);
    showQuestions.value = true;
  }
}
  // ================= FETCH QUESTIONS =================

  Future<void> fetchQuestionsByKeyword(String keyword) async {
   //R showQuestions.value = true;

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

  void selectExamAnswer(String ans) {
  examAnswers[examIndex.value] = ans;
}

void nextExam() {
  if (examIndex.value < questions.length - 1) {
    examIndex.value++;
  }
}

void previousExam() {
  if (examIndex.value > 0) {
    examIndex.value--;
  }
}
}
