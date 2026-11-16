import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'auth_controller.dart';
import 'exam_battle_model.dart';
import 'test_controller.dart';

class ExamBattleController extends GetxController {
  var selectedTab = 0.obs; // 0: Battles, 1: Results
  var battles = <BattleExamItem>[].obs;
  var results = <BattleExamItem>[].obs;
  var isLoading = false.obs;
  var errorMessage = "".obs;

  var currentTime = DateTime.now().obs;
  Timer? _ticker;

  @override
  void onInit() {
    super.onInit();
    _startClock();
    fetchBattleExams();
  }

  void _startClock() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      currentTime.value = DateTime.now();
    });
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  Future<void> fetchBattleExams() async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final auth = AuthController.instance;
      final userId = auth.userId;
      final uri = Uri.parse("${AppConfig.battleExams}?userid=$userId");

      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data is Map && data['status'] == 'success') {
          final bList = (data['battles'] as List? ?? [])
              .map((e) => BattleExamItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          final rList = (data['results'] as List? ?? [])
              .map((e) => BattleExamItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          battles.assignAll(bList);
          results.assignAll(rList);
        }
      } else {
        errorMessage.value = "Failed to load battle exams (${res.statusCode})";
      }
    } catch (e) {
      errorMessage.value = "Network error loading battle exams";
    } finally {
      isLoading.value = false;
    }
  }

  bool canAttend(BattleExamItem item) {
    if (item.startTime == null) return true;
    return currentTime.value.isAfter(item.startTime!) ||
        currentTime.value.isAtSameMomentAs(item.startTime!);
  }

  Duration getRemainingDuration(DateTime? startTime) {
    if (startTime == null) return Duration.zero;
    final diff = startTime.difference(currentTime.value);
    return diff.isNegative ? Duration.zero : diff;
  }

  String formatCountdown(DateTime? startTime) {
    if (startTime == null) return "Live Now";
    final rem = getRemainingDuration(startTime);
    if (rem == Duration.zero) return "Live Now";

    final hours = rem.inHours;
    final minutes = rem.inMinutes.remainder(60);
    final seconds = rem.inSeconds.remainder(60);

    if (hours > 0) {
      return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    }
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Future<void> attendExam(BattleExamItem item) async {
    final auth = AuthController.instance;
    if (item.isLocked) {
      auth.showPremiumAlert();
      return;
    }

    if (!canAttend(item)) {
      Get.snackbar(
        "Exam Not Started",
        "Please wait until the countdown finishes to join the battle.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    // Prepare TestController
    TestController testController;
    if (Get.isRegistered<TestController>()) {
      testController = Get.find<TestController>();
    } else {
      testController = Get.put(TestController());
    }

    // Set Battle Flag: No Resume, only Submit and Exit
    testController.isBattle.value = true;
    await testController.clearProgress(item.id);

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: Color(0xFF1B8A4E)),
      ),
      barrierDismissible: false,
    );

    try {
      await testController.loadQuestions(item.id, title: item.specialization);
      Get.back(); // Dismiss loading

      Get.toNamed('/exam', arguments: {
        'id': item.id,
        'title': item.specialization,
        'isBattle': true,
      });
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        "Could not load battle questions. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }
}
