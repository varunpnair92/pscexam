import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psc_exam/exam_controller.dart';
import 'package:psc_exam/test_controller.dart';
import 'package:psc_exam/auth_controller.dart';

class ExamListPage extends StatelessWidget {
  final examController = Get.put(ExamController());
  final testController = Get.put(TestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Exam")),

      body: Obx(() {
        if (examController.exams.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        final auth = AuthController.instance;
        final userType = auth.userType.value.toLowerCase().trim();
        final bool isPremium = userType == "trial" || userType == "paid";

        return ListView.builder(
          itemCount: examController.exams.length,
          itemBuilder: (_, i) {
            var exam = examController.exams[i];
            final bool hasAccess = auth.canAccess(exam);

            return ListTile(
              title: Opacity(
                opacity: hasAccess ? 1.0 : 0.6,
                child: Text(exam.specialization),
              ),
              subtitle: exam.accessType != "free"
                  ? const Text("⭐ Premium Content", style: TextStyle(color: Colors.amber, fontSize: 10))
                  : null,

              // 🔒 SHOW LOCK ICON
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (exam.accessType != "free")
                    const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Icon(
                    exam.locked ? Icons.lock : Icons.lock_open,
                    color: exam.locked ? Colors.red : Colors.green,
                  ),
                ],
              ),

              // 🔒 GREY OUT LOCKED EXAM
              tileColor: hasAccess
                  ? (exam.locked ? Colors.grey.shade300 : Colors.white)
                  : Colors.grey.shade100,

              onTap: () async {
                if (!auth.canAccess(exam)) {
                  auth.showPremiumAlert();
                  return;
                }

                if (exam.locked && !isPremium) {
                  Get.snackbar(
                    "Exam Locked",
                    "This exam is currently locked",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                // 🔓 UNLOCKED / PREMIUM → NORMAL FLOW
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
                      Get.toNamed('/examSplash', arguments: {
                        'exam': exam,
                        'isResume': true,
                      });
                    },
                    onCancel: () async {
                      Get.back();
                      await testController.clearProgress(exam.id);
                      Get.toNamed('/examSplash', arguments: {
                        'exam': exam,
                        'isResume': false,
                      });
                    },
                  );
                } else {
                  Get.toNamed('/examSplash', arguments: {
                    'exam': exam,
                    'isResume': false,
                  });
                }
              },
            );
          },
        );
      }),
    );
  }
}