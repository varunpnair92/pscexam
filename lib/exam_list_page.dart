import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psc_exam/exam_controller.dart';
import 'package:psc_exam/test_controller.dart';

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

        return ListView.builder(
          itemCount: examController.exams.length,
          itemBuilder: (_, i) {
            var exam = examController.exams[i];

            return ListTile(
              title: Text(exam.specialization),

              // 🔒 SHOW LOCK ICON
              trailing: exam.locked
                  ? Icon(Icons.lock, color: Colors.red)
                  : Icon(Icons.lock_open, color: Colors.green),

              // 🔒 GREY OUT LOCKED EXAM
              tileColor:
                  exam.locked ? Colors.grey.shade300 : Colors.white,

              onTap: exam.locked
                  ? () {
                      // 🔒 LOCKED MESSAGE
                      Get.snackbar(
                        "Exam Locked",
                        "This exam is currently locked",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  : () async {
                      // 🔓 UNLOCKED → NORMAL FLOW

                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('last_exam_name', exam.specialization);
                      prefs.setString('last_exam_id', exam.id.toString());

                      bool resume =
                          await testController.hasProgressForExam(exam.id);

                      if (resume) {
                        // 🔥 ASK USER RESUME OR RESTART
                        Get.defaultDialog(
                          title: "Resume Exam",
                          middleText: "You have unfinished progress",
                          textCancel: "Restart",
                          textConfirm: "Resume",

                          onConfirm: () async {
                            Get.back();

                            await testController.loadProgress(exam.id);

                            Get.toNamed('/exam',
                                arguments: {'id': exam.id});
                          },

                          onCancel: () async {
                            Get.back();

                            await testController.clearProgress(exam.id);
                            await testController.loadQuestions(exam.id);

                            Get.toNamed('/exam',
                                arguments: {'id': exam.id});
                          },
                        );
                      } else {
                        await testController.loadQuestions(exam.id);

                        Get.toNamed('/exam',
                            arguments: {'id': exam.id});
                      }
                    },
            );
          },
        );
      }),
      
      
    );
  }
}