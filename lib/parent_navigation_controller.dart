import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'parent_navigation_model.dart';
import 'study_controller.dart';
import 'auth_controller.dart';

class ParentNavigationController extends GetxController {
  var nodes = <ParentNavigationNode>[].obs;
  var isLoading = false.obs;
  var parentTitle = "".obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['keyword'] != null) {
      parentTitle.value = args['title'] ?? "Topics";
      fetchChildren(args['keyword']);
    }
  }

  Future<void> fetchChildren(String keyword) async {
    isLoading.value = true;
    try {
      // Use Uri.encodeComponent for safety with special characters/spaces
      final encodedKeyword = Uri.encodeComponent(keyword.trim());
      final url = "${AppConfig.baseUrl}parent-keyword-with-child-description/?keyword=$encodedKeyword";
      final res = await http.get(Uri.parse(url));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data["children"] != null) {
          final List childrenList = data["children"];
          List<ParentNavigationNode> newNodes = [];
          
          if (childrenList.isNotEmpty) {
            if (childrenList[0] is String) {
              newNodes = childrenList.map((e) => ParentNavigationNode.fromString(e.toString())).toList();
            } else {
              newNodes = childrenList.map((e) => ParentNavigationNode.fromJson(e)).toList();
            }
          }
          nodes.assignAll(newNodes);
          
          if (data["parent"] != null) {
            parentTitle.value = data["parent"].toString();
          }
        }
      }
    } catch (e) {
      print("Error fetching parent navigation children: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onNodeTap(ParentNavigationNode node) {
    Map<String, dynamic> routeArgs = {
      "title": node.name,
      "keywords": node.keywords ?? [node.name],
      "id": node.id,
    };

    // Use a fresh StudyController for the leaf node
    if (Get.isRegistered<StudyController>()) {
      Get.delete<StudyController>();
    }
    Get.toNamed("/studyFull", arguments: routeArgs);
  }
}
