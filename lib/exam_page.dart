import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/test_controller.dart';

class ExamPage extends StatelessWidget {
  final TestController controller = Get.put(TestController());

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map?;
    final int? examId = args?['id'];

    // 🔥 HANDLE NULL SAFELY
    if (examId == null) {
      return Scaffold(
        body: Center(child: Text("Invalid Exam ID")),
      );
    }

    controller.loadQuestions(examId);

    return Scaffold(
      appBar: AppBar(title: Text("Exam")),
      body: Obx(() {
        if (controller.questions.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        var q = controller.questions[controller.current.value];

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                q.question,
                style: TextStyle(fontSize: 18),
              ),

              SizedBox(height: 20),

              // 🔥 FILTER EMPTY OPTIONS
              ...q.options
                  .where((o) => o.toString().isNotEmpty)
                  .map((o) => ElevatedButton(
                        onPressed: () =>
                            controller.selectAnswer(o.toString()),
                        child: Text(o.toString()),
                      )),

              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: controller.previous,
                    child: Text("Previous"),
                  ),
                  ElevatedButton(
                    onPressed: controller.next,
                    child: Text("Next"),
                  ),
                ],
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () => Get.toNamed('/result'),
                child: Text("Submit"),
              ),
            ],
          ),
        );
      }),
    );
  }
}