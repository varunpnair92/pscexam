import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exam_controller.dart';
import 'test_controller.dart';
import 'app_config.dart';
import 'home_page.dart';

class DynamicExamListPage extends StatelessWidget {
  final examController = Get.put(ExamController());
  final testController = Get.put(TestController());

  final index = 0.obs;

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String endpoint = args["endpoint"];

    // Load exams
    examController.loadFromEndpoint(endpoint);

    return Obx(() => Scaffold(
          appBar: AppBar(title: const Text("Select Exam")),

          body: Obx(() {
            if (examController.exams.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: examController.exams.length,
              itemBuilder: (_, i) {
                var exam = examController.exams[i];

                return ListTile(
                  title: Text(exam.specialization),

                  trailing: exam.locked
                      ? const Icon(Icons.lock, color: Colors.red)
                      : const Icon(Icons.lock_open, color: Colors.green),

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
                          bool resume = await testController
                              .hasProgressForExam(exam.id);

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

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index.value,
            onTap: (i) {
              index.value = i;

              if (i == 0) {
                Get.offAll(() => HomePage(), arguments: {"tab": 0});
              } else {
                Get.offAll(() => HomePage(), arguments: {"tab": 1});
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz),
                label: "Exam",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: "Study",
              ),
            ],
          ),
        ));
  }
}