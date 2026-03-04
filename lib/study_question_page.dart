import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'study_controller.dart';

class StudyQuestionPage extends StatelessWidget {
  final StudyController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.keys.join(" > ")),
      ),
      body: Obx(() => ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: controller.questions.length,
            itemBuilder: (_, i) {
              final q = controller.questions[i];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q["question"] ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Divider(),
                      Text(
                        q["answer"] ?? "",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }
}