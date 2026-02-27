import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'test_controller.dart';

class ReviewPage extends StatelessWidget {
  final TestController controller = Get.find<TestController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Review Exam")),
      body: Obx(() {
        if (controller.questions.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        var i = controller.current.value;
        var q = controller.questions[i];
        var userAns = controller.answers[i];

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔢 Question Number
              Text(
                "Question ${i + 1} / ${controller.questions.length}",
                style: TextStyle(fontSize: 20),
              ),

              SizedBox(height: 10),

              // ❓ Question
              Text(q.question, style: TextStyle(fontSize: 18)),

              SizedBox(height: 20),

              // 🎨 OPTIONS
              ...q.options
                  .where((o) => o.toString().isNotEmpty)
                  .map((o) {
                Color color = Colors.grey.shade200;

                // 🟩 Correct answer
                if (o == q.answer) {
                  color = Colors.green;
                }

                // 🟥 Wrong selected answer
                if (o == userAns && userAns != q.answer) {
                  color = Colors.red;
                }

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: null, // disabled
                    child: Text(o.toString()),
                  ),
                );
              }),

              Spacer(),

              // ⬅️➡️ NAVIGATION BUTTONS
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: controller.current.value > 0
                        ? controller.previous
                        : null,
                    child: Text("Previous"),
                  ),

                  ElevatedButton(
                    onPressed: controller.current.value <
                            controller.questions.length - 1
                        ? controller.next
                        : null,
                    child: Text("Next"),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}