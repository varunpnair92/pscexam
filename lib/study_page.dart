import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'study_controller.dart';

class StudyPage extends StatelessWidget {
  final StudyController controller = Get.put(StudyController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      // 🔥 SHOW QUESTIONS IF END
      if (controller.showQuestions.value) {
        return ListView.builder(
          itemCount: controller.questions.length,
          itemBuilder: (_, i) {
            final q = controller.questions[i];
            return Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(q["question"]),
              ),
            );
          },
        );
      }

      // 🔥 SHOW HIERARCHY TILES
      return GridView.builder(
        padding: EdgeInsets.all(16),
        itemCount: controller.items.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () => controller.onTileTap(controller.items[i]),
            child: Card(
              child: Center(
                child: Text(
                  controller.items[i],
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}