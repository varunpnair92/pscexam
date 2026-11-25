import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'master_keyword_model.dart';
import 'study_controller.dart';

class MasterKeywordNavigationController extends GetxController {
  var nodes = <MasterKeywordNode>[].obs;
  var breadcrumbs = <Map<String, dynamic>>[].obs; // [{'id': 317, 'keyword': 'കേരളം'}]
  var isLoading = false.obs;
  var parentTitle = "Master Keywords".obs;
  var currentKeyword = "".obs;
  var currentKeywordId = Rx<int?>(null);
  var currentChildrenCount = 0.obs;
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

      int? targetId;
      if (args['id'] != null) {
        targetId = int.tryParse(args['id'].toString());
      }

      if (targetId != null) {
        drillDownById(targetId, targetKw.isNotEmpty ? targetKw : "Keyword");
      } else if (targetKw.isNotEmpty) {
        currentKeyword.value = targetKw;
        parentTitle.value = targetKw;
        // When keyword is present, direct show that in study!
        openStudy(targetKw, id: targetId);
        search(targetKw);
      } else {
        fetchRoots();
      }
    } else {
      fetchRoots();
    }
  }

  @override
  void onClose() {
    searchInputController.dispose();
    super.onClose();
  }

  // Fetch roots / top master keywords that have sub-keywords
  Future<void> fetchRoots() async {
    isLoading.value = true;
    try {
      final res = await http.get(Uri.parse(AppConfig.masterKeyword));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['roots'] != null) {
          final List rootsList = data['roots'];
          nodes.assignAll(
            rootsList.map((e) => MasterKeywordNode.fromJson(e)).toList(),
          );
        } else {
          nodes.clear();
        }
      } else {
        nodes.clear();
      }
      breadcrumbs.clear();
      currentKeyword.value = "";
      currentKeywordId.value = null;
      currentChildrenCount.value = nodes.length;
      parentTitle.value = "Master Keywords";
    } catch (e) {
      print("Error fetching master keyword roots: $e");
      nodes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Search keyword or drill down by search query
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    isLoading.value = true;
    try {
      if (!searchHistory.contains(trimmed)) {
        searchHistory.insert(0, trimmed);
        if (searchHistory.length > 10) {
          searchHistory.removeLast();
        }
      }

      final encoded = Uri.encodeComponent(trimmed);
      final res = await http.get(Uri.parse("${AppConfig.masterKeyword}?search=$encoded"));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));

        // Case A: Specific keyword located / exact match
        if (data['id'] != null && data['keyword'] != null) {
          final int kwId = data['id'];
          final String kwName = data['keyword'].toString();

          currentKeyword.value = kwName;
          currentKeywordId.value = kwId;
          parentTitle.value = kwName;

          // Rebuild breadcrumb from parent_chain
          List<Map<String, dynamic>> newBreadcrumb = [];
          if (data['parent_chain'] != null && (data['parent_chain'] as List).isNotEmpty) {
            newBreadcrumb = (data['parent_chain'] as List)
                .map((e) => {'id': e['id'], 'keyword': e['keyword'].toString()})
                .toList();
          }
          if (!newBreadcrumb.any((b) => b['id'] == kwId)) {
            newBreadcrumb.add({'id': kwId, 'keyword': kwName});
          }
          breadcrumbs.assignAll(newBreadcrumb);

          // Sub-children
          if (data['children'] != null && (data['children'] as List).isNotEmpty) {
            final List ch = data['children'];
            nodes.assignAll(ch.map((e) => MasterKeywordNode.fromJson(e)).toList());
            currentChildrenCount.value = nodes.length;
          } else {
            // Leaf node: no children
            nodes.clear();
            currentChildrenCount.value = 0;

            // Automatically open study view for leaf node as requested!
            openStudy(kwName, id: kwId);
          }
        }
        // Case B: Multiple fuzzy matches
        else if (data['matches'] != null && (data['matches'] as List).isNotEmpty) {
          final List matches = data['matches'];
          final first = matches.first;
          final String firstKw = (first['keyword'] ?? '').toString().trim();
          final String normTrimmed = trimmed.replaceAll('കേരളം ', 'കേരള ').replaceAll('keralam ', 'kerala ').trim();
          final String normFirst = firstKw.replaceAll('കേരളം ', 'കേരള ').replaceAll('keralam ', 'kerala ').trim();

          // Auto drill-down if the primary match closely corresponds to the search (e.g. കേരളം ചരിത്രം -> കേരള ചരിത്രം)
          if (normTrimmed.toLowerCase() == normFirst.toLowerCase() ||
              trimmed.toLowerCase() == firstKw.toLowerCase() ||
              matches.length == 1) {
            final int matchId = first['id'] is int ? first['id'] : int.tryParse(first['id']?.toString() ?? '0') ?? 0;
            if (matchId > 0) {
              drillDownById(matchId, firstKw);
              return;
            }
          }

          nodes.assignAll(matches.map((e) => MasterKeywordNode.fromJson(e)).toList());
          currentChildrenCount.value = nodes.length;
          breadcrumbs.clear();
          currentKeyword.value = trimmed;
          currentKeywordId.value = null;
          parentTitle.value = "Search: $trimmed";
        } else {
          nodes.clear();
          currentChildrenCount.value = 0;
          breadcrumbs.clear();
          currentKeyword.value = trimmed;
          parentTitle.value = "No results for '$trimmed'";
        }
      } else {
        nodes.clear();
        currentChildrenCount.value = 0;
      }
    } catch (e) {
      print("Error searching master keyword: $e");
      nodes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Drill down or study a node
  void onNodeTap(MasterKeywordNode node) {
    if (node.keyword.trim().isNotEmpty) {
      // Keyword present in node -> directly show that in study!
      openStudy(node.keyword, id: node.id);
    } else if (node.hasChildren || node.childrenCount > 0) {
      drillDownById(node.id, node.keyword);
    }
  }

  // Drill down explicitly into a node's sub-categories
  void drillDownNode(MasterKeywordNode node) {
    drillDownById(node.id, node.keyword);
  }

  // Fetch children of a keyword by its ID
  Future<void> drillDownById(int id, String keyword) async {
    isLoading.value = true;
    try {
      final res = await http.get(Uri.parse("${AppConfig.masterKeyword}?id=$id"));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));

        currentKeyword.value = keyword;
        currentKeywordId.value = id;
        parentTitle.value = keyword;

        // Rebuild breadcrumb path
        List<Map<String, dynamic>> newBreadcrumb = [];
        if (data['parent_chain'] != null && (data['parent_chain'] as List).isNotEmpty) {
          newBreadcrumb = (data['parent_chain'] as List)
              .map((e) => {'id': e['id'], 'keyword': e['keyword'].toString()})
              .toList();
        }
        if (!newBreadcrumb.any((b) => b['id'] == id)) {
          newBreadcrumb.add({'id': id, 'keyword': keyword});
        }
        breadcrumbs.assignAll(newBreadcrumb);

        if (data['children'] != null && (data['children'] as List).isNotEmpty) {
          final List ch = data['children'];
          nodes.assignAll(ch.map((e) => MasterKeywordNode.fromJson(e)).toList());
          currentChildrenCount.value = nodes.length;
        } else {
          nodes.clear();
          currentChildrenCount.value = 0;
          openStudy(keyword, id: id);
        }
      }
    } catch (e) {
      print("Error drilling down into master keyword: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Open Study Page (/studyFull) with Questions & Description
  void openStudy(String keyword, {int? id}) {
    final cleanKw = keyword.trim();
    if (cleanKw.isEmpty) return;

    Map<String, dynamic> routeArgs = {
      "title": cleanKw,
      "keywords": [cleanKw],
      "id": id,
      "initialTab": 0, // Direct show Note tab for student
    };

    if (Get.isRegistered<StudyController>()) {
      Get.delete<StudyController>();
    }
    Get.toNamed("/studyFull", arguments: routeArgs);
  }

  // Navigate to breadcrumb level
  void navigateToBreadcrumb(int index) {
    if (index < 0) {
      resetToRoots();
      return;
    }
    if (index >= breadcrumbs.length) return;

    final item = breadcrumbs[index];
    breadcrumbs.removeRange(index + 1, breadcrumbs.length);
    drillDownById(item['id'], item['keyword'].toString());
  }

  // Reset to root view
  void resetToRoots() {
    searchInputController.clear();
    breadcrumbs.clear();
    fetchRoots();
  }

  // Clear current search
  void clearSearch() {
    searchInputController.clear();
    if (breadcrumbs.isNotEmpty) {
      final last = breadcrumbs.last;
      drillDownById(last['id'], last['keyword']);
    } else {
      fetchRoots();
    }
  }

  // Handle back button
  void goBack() {
    if (breadcrumbs.length > 1) {
      navigateToBreadcrumb(breadcrumbs.length - 2);
    } else if (breadcrumbs.length == 1) {
      resetToRoots();
    } else {
      Get.back();
    }
  }
}
