import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'timeline_model.dart';

class TimelineController extends GetxController {
  var timelineYears = <TimelineYear>[].obs;
  var isLoading = false.obs;
  var currentKeyword = "".obs;
  var pageTitle = "Timeline".obs;
  var errorMessage = "".obs;
  var hasInitialKeyword = false.obs;

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    
    if (args['title'] != null && args['title'].toString().trim().isNotEmpty) {
      pageTitle.value = args['title'].toString().trim();
    }

    String initialKeyword = "";
    if (args['keyword'] != null && args['keyword'].toString().trim().isNotEmpty) {
      initialKeyword = args['keyword'].toString().trim();
    } else if (args['keywords'] != null && args['keywords'] is List && (args['keywords'] as List).isNotEmpty) {
      initialKeyword = (args['keywords'] as List).last.toString().trim();
    }

    final lower = initialKeyword.toLowerCase();
    if (initialKeyword.isNotEmpty &&
        lower != 'timeline' &&
        lower != '/timeline' &&
        lower != 'timelinenavigation' &&
        lower != 'timeline navigation') {
      hasInitialKeyword.value = true;
      searchCtrl.text = initialKeyword;
      currentKeyword.value = initialKeyword;
      fetchTimeline(initialKeyword);
    } else {
      hasInitialKeyword.value = false;
      searchCtrl.clear();
      currentKeyword.value = "";
      timelineYears.clear();
      errorMessage.value = "";
    }
  }

  Future<void> fetchTimeline(String keyword) async {
    final cleanKeyword = keyword.trim();
    if (cleanKeyword.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = "";
    timelineYears.clear();

    try {
      final encodedKeyword = Uri.encodeComponent(cleanKeyword);
      final url = "${AppConfig.keywordTimeline}$encodedKeyword/";
      
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<TimelineYear> parsed = [];

        if (data is List) {
          parsed = data
              .map((e) => TimelineYear.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else if (data is Map) {
          if (data['timeline'] != null && data['timeline'] is List) {
            parsed = (data['timeline'] as List)
                .map((e) => TimelineYear.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          } else if (data['data'] != null && data['data'] is List) {
            parsed = (data['data'] as List)
                .map((e) => TimelineYear.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
        }

        timelineYears.assignAll(parsed);
        currentKeyword.value = cleanKeyword;

        if (parsed.isEmpty) {
          errorMessage.value = "No timeline events found for '$cleanKeyword'.";
        }
      } else {
        errorMessage.value = "Failed to load timeline (Status: ${res.statusCode}).";
      }
    } catch (e) {
      errorMessage.value = "Network error loading timeline.";
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchSubmit(String query) {
    if (query.trim().isNotEmpty) {
      fetchTimeline(query);
    }
  }

  void clearSearch() {
    searchCtrl.clear();
    currentKeyword.value = "";
    timelineYears.clear();
    errorMessage.value = "";
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
}
