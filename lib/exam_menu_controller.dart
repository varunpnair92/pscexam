import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class ExamMenuController extends GetxController {
  var keys = <String>["EXAM"].obs;
  var items = [].obs;
  var currentType = "".obs;

  @override
  void onInit() {
    fetchHierarchy();
    super.onInit();
  }

  Future<void> fetchHierarchy() async {
    final res = await http.post(
      Uri.parse(AppConfig.hierarchy),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"keys": keys}),
    );

    final data = jsonDecode(res.body);

    currentType.value = data["type"];
    items.value = data["result"];
  }

  void onTileTap(dynamic item) {
    final type = item["type"];

    // 🔥 ACTION → Navigate to dynamic exam list
    if (type == "action") {
      Get.toNamed(
        "/dynamicExamList",
        arguments: {"endpoint": item["url"]},
      );
      return;
    }

    // 🔥 NODE → Drill down
    if (type == "node") {
      keys.add(item["name"]);
      fetchHierarchy();
      return;
    }

    // 🔥 LEAF → (if needed for questions)
    if (type == "leaf") {
      // You can handle leaf logic here if required
      print("Leaf clicked: ${item["name"]}");
    }
  }
}