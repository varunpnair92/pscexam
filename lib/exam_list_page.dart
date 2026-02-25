import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/exam_controller.dart';

class ExamListPage extends StatelessWidget {
  final controller = Get.put(ExamController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Exam")),
      body: Obx(() {
        if (controller.exams.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: controller.exams.length,
          itemBuilder: (_, i) {
            var exam = controller.exams[i];

            return ListTile(
              title: Text(exam.specialization),

              // 🔥 PASS ARGUMENT SAFELY
              onTap: () {
                Get.toNamed('/exam', arguments: {'id': exam.id});
              },
            );
          },
        );
      }),
    );
  }
}