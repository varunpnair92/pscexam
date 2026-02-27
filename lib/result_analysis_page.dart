import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'test_controller.dart';

class AnalysisPage extends StatelessWidget {
  final TestController controller = Get.find<TestController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Result Analysis")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Questions: ${controller.total}"),
              Text("Attempted: ${controller.attempted}"),
              Text("Not Attempted: ${controller.notAttempted}"),
              Text("Correct: ${controller.correct}"),
              Text("Wrong: ${controller.wrong}"),

              SizedBox(height: 20),

              Text(
                "Score: ${controller.percentage.toStringAsFixed(2)}%",
                style: TextStyle(fontSize: 22),
              ),

              Spacer(),

              ElevatedButton(
                onPressed: () async {
                  // 🔥 FETCH RESULT FROM SERVER
                  await controller.fetchResult();

                  // 🔥 GO REVIEW PAGE
                  Get.toNamed('/review');
                },
                child: Text("Review Exam"),
              ),
            ],
          );
        }),
      ),
    );
  }
}