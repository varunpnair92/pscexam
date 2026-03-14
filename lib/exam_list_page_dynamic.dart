import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exam_controller.dart';
import 'test_controller.dart';
import 'app_config.dart';

class DynamicExamListPage extends StatelessWidget {

  final examController = Get.put(ExamController());
  final testController = Get.put(TestController());

  @override
  Widget build(BuildContext context) {

    final args = Get.arguments;
    final String endpoint = args["endpoint"];

    /// Load exams
    examController.loadFromEndpoint(endpoint);

    return Column(
      children: [

        /// TOP BAR (acts like AppBar)
        Container(
          height: 60,
          width: double.infinity,
          color: Colors.blue,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Select Exam",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        /// EXAM LIST
        Expanded(
          child: Obx(() {

            if (examController.exams.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: examController.exams.length,
              itemBuilder: (_, i) {

                var exam = examController.exams[i];

                return ListTile(

                  title: Text(exam.specialization),

                  trailing: exam.locked
                      ? Icon(Icons.lock, color: Colors.red)
                      : Icon(Icons.lock_open, color: Colors.green),

                  tileColor:
                      exam.locked ? Colors.grey.shade300 : Colors.white,

                  onTap: exam.locked
                      ? () {
                          Get.snackbar(
                            "Exam Locked",
                            "This exam is currently locked",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      : () async {

                          bool resume =
                              await testController.hasProgressForExam(exam.id);

                          if (resume) {

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
        ),
      ],
    );
  }
}