import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'parent_navigation_model.dart';
import 'study_controller.dart';

class SearchParentNavigationController extends GetxController {
  var nodes = <ParentNavigationNode>[].obs;
  var isLoading = false.obs;
  var parentTitle = "Search Parent Navigation".obs;
  var currentKeyword = "".obs;
  var searchHistory = <String>[].obs;

  final TextEditingController searchInputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      if (args['title'] != null && args['title'].toString().isNotEmpty) {
        parentTitle.value = args['title'].toString();
      }
      String targetKw = "";
      if (args['keyword'] != null && args['keyword'].toString().isNotEmpty) {
        targetKw = args['keyword'].toString();
      } else if (args['keywords'] != null) {
        if (args['keywords'] is List && (args['keywords'] as List).isNotEmpty) {
          targetKw = (args['keywords'] as List).last.toString();
        } else if (args['keywords'] is String) {
          targetKw = args['keywords'].toString();
        }
      }
      if (targetKw.isEmpty && args['title'] != null && args['title'].toString().isNotEmpty) {
        targetKw = args['title'].toString();
      }

      if (targetKw.isNotEmpty) {
        searchInputController.text = targetKw;
        currentKeyword.value = targetKw;
        fetchChildren(targetKw);
      }
    }
  }

  @override
  void onClose() {
    searchInputController.dispose();
    super.onClose();
  }

  void search(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    currentKeyword.value = trimmed;
    fetchChildren(trimmed);
  }

  void clearSearch() {
    searchInputController.clear();
    currentKeyword.value = "";
    nodes.clear();
    parentTitle.value = "Search Parent Navigation";
  }

  Future<void> fetchChildren(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      nodes.clear();
      return;
    }

    isLoading.value = true;
    try {
      if (!searchHistory.contains(trimmed)) {
        searchHistory.insert(0, trimmed);
        if (searchHistory.length > 10) {
          searchHistory.removeLast();
        }
      }

      final encodedKeyword = Uri.encodeComponent(trimmed);
      final url = "${AppConfig.baseUrl}parent-keyword-with-child-description/?keyword=$encodedKeyword";
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        dynamic data;
        try {
          data = jsonDecode(utf8.decode(res.bodyBytes));
        } catch (_) {
          data = jsonDecode(res.body);
        }

        List childrenList = [];
        if (data is Map) {
          if (data["children"] != null && data["children"] is List) {
            childrenList = data["children"];
          } else if (data["data"] != null && data["data"] is List) {
            childrenList = data["data"];
          } else if (data["results"] != null && data["results"] is List) {
            childrenList = data["results"];
          } else if (data["nodes"] != null && data["nodes"] is List) {
            childrenList = data["nodes"];
          }

          if (data["parent"] != null && data["parent"].toString().isNotEmpty) {
            parentTitle.value = data["parent"].toString();
          } else {
            parentTitle.value = trimmed;
          }
        } else if (data is List) {
          childrenList = data;
          parentTitle.value = trimmed;
        }

        List<ParentNavigationNode> newNodes = [];
        if (childrenList.isNotEmpty) {
          if (childrenList[0] is String) {
            newNodes = childrenList.map((e) => ParentNavigationNode.fromString(e.toString())).toList();
          } else {
            newNodes = childrenList.map((e) => ParentNavigationNode.fromJson(e)).toList();
          }
        }
        nodes.assignAll(newNodes);
      } else {
        nodes.clear();
      }
    } catch (e) {
      print("Error fetching search parent navigation children: $e");
      nodes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void onNodeTap(ParentNavigationNode node) {
    final nav = (node.navigation ?? "").toLowerCase().trim();

    if (nav.contains('timeline')) {
      Map<String, dynamic> args = {'title': node.name};
      if (node.keywords != null && node.keywords!.isNotEmpty) {
        String kw = node.keywords!.last.trim();
        if (kw.toLowerCase() != 'timeline' && kw.toLowerCase() != '/timeline') {
          args['keyword'] = kw;
        }
      }
      Get.toNamed('/timeline', arguments: args);
      return;
    }

    if (nav == 'searchparentnavigation' || nav == '/searchparentnavigation') {
      Get.toNamed('/searchParentNavigation', arguments: {
        "keyword": (node.keywords != null && node.keywords!.isNotEmpty) ? node.keywords!.last : node.name,
        "title": node.name,
      }, preventDuplicates: false);
      return;
    }

    if (nav == 'parentnavigation' || nav == '/parentnavigation') {
      Get.toNamed('/parentNavigation', arguments: {
        "keyword": (node.keywords != null && node.keywords!.isNotEmpty) ? node.keywords!.last : node.name,
        "title": node.name,
      });
      return;
    }

    Map<String, dynamic> routeArgs = {
      "title": node.name,
      "keywords": node.keywords ?? [node.name],
      "id": node.id,
    };

    if (Get.isRegistered<StudyController>()) {
      Get.delete<StudyController>();
    }
    Get.toNamed("/studyFull", arguments: routeArgs);
  }
}
