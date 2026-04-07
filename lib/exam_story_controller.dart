import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:psc_exam/app_config.dart';
import 'package:psc_exam/exam_model.dart';
import 'package:psc_exam/auth_controller.dart';
import 'package:psc_exam/test_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExamStoryController extends GetxController {
  var exams = <Exam>[].obs;
  var isLoading = false.obs;
  var currentIndex = 0.obs;
  
  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    final String endpoint = args["endpoint"] ?? "";
    if (endpoint.isNotEmpty) {
      loadFromEndpoint(endpoint);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> loadFromEndpoint(String endpoint) async {
    isLoading.value = true;
    exams.clear();

    try {
      final res = await http.get(
        Uri.parse(AppConfig.baseUrl + endpoint),
      );

      if (res.statusCode == 200) {
        List data = jsonDecode(res.body);
        exams.value = data.map((e) => Exam.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load exam stories");
    } finally {
      isLoading.value = false;
    }
  }

  void nextStory() {
    if (currentIndex.value < exams.length - 1) {
      currentIndex.value++;
      pageController.animateToPage(
        currentIndex.value, 
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
    } else {
      Get.back(); // Exits the story UI on the last item tap
    }
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void previousStory() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      pageController.animateToPage(
        currentIndex.value, 
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
    }
  }

  Future<void> startExam(Exam exam) async {
    final auth = AuthController.instance;
    final bool hasAccess = auth.canAccess(exam);

    if (!hasAccess) {
      auth.showPremiumAlert();
      return;
    }
    if (exam.locked) {
      Get.snackbar(
        "Exam Locked",
        "This exam is currently locked.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final testController = Get.find<TestController>();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('last_exam_name', exam.specialization);
    prefs.setString('last_exam_id', exam.id.toString());
    
    bool resume = await testController.hasProgressForExam(exam.id);

    if (resume) {
      Get.defaultDialog(
        title: "Resume Exam",
        middleText: "You have unfinished progress",
        textCancel: "Restart",
        textConfirm: "Resume",
        onConfirm: () async {
          Get.back();
          Get.toNamed('/examSplash', arguments: {'exam': exam, 'isResume': true});
        },
        onCancel: () async {
          Get.back();
          await testController.clearProgress(exam.id);
          Get.toNamed('/examSplash', arguments: {'exam': exam, 'isResume': false});
        },
      );
    } else {
      Get.toNamed('/examSplash', arguments: {'exam': exam, 'isResume': false});
    }
  }
}
