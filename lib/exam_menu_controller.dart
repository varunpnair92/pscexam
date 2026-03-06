import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class ExamMenuController extends GetxController {

  var fullTree = [].obs;
  var items = [].obs;

  /// BACK STACK
  var stack = <dynamic>[].obs;

  /// BREADCRUMB
  var keys = <String>[].obs;

  @override
  void onInit() {
    fetchTree();
    super.onInit();
  }

  /// LOAD TREE
  Future<void> fetchTree() async {

    final res = await http.get(Uri.parse(AppConfig.nodeall));

    final data = jsonDecode(res.body);

    fullTree.value = data;

    /// FIND EXAM NODE
    final examNode = data.firstWhere(
      (e) => e["name"] == "EXAM",
      orElse: () => null,
    );

    if (examNode != null) {
      items.value = examNode["children"] ?? [];
    }

    keys.clear();
    keys.add("EXAM");
  }

  /// TILE CLICK
  void onTileTap(dynamic item) {

    final name = item["name"];

    /// ACTION → OPEN EXAM LIST
    if (item["url"] != null && item["url"] != "") {

      Get.toNamed(
        "/dynamicExamList",
        arguments: {"endpoint": item["url"]},
      );

      return;
    }

    /// NODE → GO DEEPER
    if (item["children"] != null && item["children"].length > 0) {

      stack.add(items);

      items.value = item["children"];

      keys.add(name);

      return;
    }

    /// LEAF
    print("Leaf clicked: $name");
  }

  /// BACK
  void goBack() {

    if (stack.isNotEmpty) {

      items.value = stack.removeLast();

      keys.removeLast();
    }
  }
}