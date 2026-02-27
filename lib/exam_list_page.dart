import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

              onTap: () async {

                bool resume =
                    await testController.hasProgressForExam(exam.id);

                if (resume) {

                  await testController.loadProgress();

                  // 🔥 PASS EXAM ID HERE ALSO
                  Get.toNamed('/exam', arguments: {'id': exam.id});

                } else {

                  await testController.loadQuestions(exam.id);

                  // 🔥 PASS EXAM ID HERE ALSO
                  Get.toNamed('/exam', arguments: {'id': exam.id});
                }
              },
            );
          },
        );
      }),
    );
  }
}