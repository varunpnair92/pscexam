import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'auth_controller.dart';
import 'tree_service.dart'; // 🔥 Import TreeService

class StoryMenuController extends GetxController {
  var items = [].obs;
  var isLoading = true.obs;
  var searchQuery = "".obs;
  var isSlideView = false.obs; // 🔥 Track if current level is a slide view

  List<dynamic> get displayedItems {
    if (searchQuery.value.isEmpty) return items;
    return items
        .where((e) => (e["name"] ?? "")
            .toString()
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  /// BREADCRUMB / STACK for future potential nesting
  var keys = <String>["Stories"].obs;
  var stack = <List>[].obs;
  var slideStack = <bool>[].obs; // 🔥 Track slide state for back navigation

  @override
  void onInit() {
    super.onInit();

    // 🔄 RE-FETCH ON COURSE CHANGE
    ever(AuthController.instance.selectedCourseName, (_) {
      fetchTree();
      stack.clear();
      keys.clear();
    });

    fetchTree();
  }

  Future<void> fetchTree({bool force = false}) async {
    isLoading.value = true;
    try {
      await TreeService.instance.fetchTree(force: force);
      if (TreeService.instance.fullTree.isNotEmpty) {
        final List<dynamic> data = TreeService.instance.fullTree;

        // 🎯 1. FIND THE SELECTED COURSE NODE
        final auth = AuthController.instance;
        final String selectedCourse = auth.selectedCourseName.value;
        
        final courseNode = _findNodeByName(selectedCourse, data);

        if (courseNode != null && courseNode['children'] != null) {
          final List<dynamic> children = courseNode['children'];

          // 🎯 2. LOOK FOR "STORY" CHILD FIRST (Priority)
          var storyNode = children.firstWhereOrNull(
            (c) => (c["name"] ?? "").toString().toUpperCase().contains("STORY"),
          );

          // Fallback to "BOOSTER" only if "STORY" not found
          if (storyNode == null) {
            storyNode = children.firstWhereOrNull(
              (c) => (c["name"] ?? "").toString().toUpperCase().contains("BOOSTER"),
            );
          }

          if (storyNode != null) {
            items.value = storyNode['children'] ?? [];
            keys.value = [storyNode['name'] ?? "Stories"];

            final String nav = (storyNode['navigation'] ?? '').toString().trim();
            isSlideView.value = (nav == 'navigationSlide' || nav == '/navigationSlide');
          } else {
            // Fallback to course children themselves if no specific STORY node
            items.value = children;
            keys.value = [selectedCourse];
          }
        }
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void onTileTap(dynamic item) {
    final auth = AuthController.instance;
    if (!auth.canAccess(item)) {
      auth.showPremiumAlert();
      return;
    }

    final name = item["name"] ?? "Story";
    final children = item["children"];
    final String navStr = item["navigation"]?.toString().trim() ?? "";

    if (navStr == 'navigationSlide' || navStr == '/navigationSlide') {
      stack.add(List.from(items));
      slideStack.add(isSlideView.value); // Save current
      
      items.value = children;
      keys.add(name);
      isSlideView.value = true;
      searchQuery.value = "";
      return;
    }

    if (children != null && (children as List).isNotEmpty) {
      // Go deeper
      stack.add(List.from(items));
      slideStack.add(isSlideView.value); // Save current

      items.value = children;
      keys.add(name);
      searchQuery.value = "";
      isSlideView.value = false;
    } else {
      // Interactive story viewer
      List<String> keywords = [];
      if (item["keywords"] != null) {
        keywords = List<String>.from(item["keywords"]);
      } else if (item["keyword"] != null) {
        keywords = [item["keyword"].toString()];
      }
      if (keywords.isEmpty) keywords = [name];

      Get.toNamed('/story', arguments: {
        "title": name,
        "keywords": keywords,
        "endpoint": item["url"] ?? "",
        "access": item["access"], // Propagate for check in StoryController
      });
    }
  }

  void goBack() {
    if (stack.isNotEmpty) {
      items.value = stack.removeLast();
      keys.removeLast();
      if (slideStack.isNotEmpty) {
        isSlideView.value = slideStack.removeLast();
      }
      searchQuery.value = "";
    }
  }

  void clearSearch() {
    searchQuery.value = "";
  }

  Map<String, dynamic>? _findNodeByName(String name, List list) {
    for (var item in list) {
      String itemName = (item['name'] ?? "").toString().toUpperCase();
      if (itemName == name.toUpperCase()) return Map<String, dynamic>.from(item);
      if (item['children'] != null && item['children'] is List) {
        final found = _findNodeByName(name, item['children']);
        if (found != null) return found;
      }
    }
    return null;
  }
}
