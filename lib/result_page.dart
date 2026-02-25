import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/test_controller.dart';

class ResultPage extends StatelessWidget {
  final controller = Get.find<TestController>();

  @override
  Widget build(BuildContext context) {
    int total = controller.questions.length;
    int attended = controller.answers.length;
    int notAttended = total - attended;
    double percent = (attended / total) * 100;

    return Scaffold(
      appBar: AppBar(title: Text("Summary")),
      body: Column(
        children: [
          Text("Total: $total"),
          Text("Attended: $attended"),
          Text("Not Attended: $notAttended"),
          Text("Percentage: ${percent.toStringAsFixed(2)}%"),
        ],
      ),
    );
  }
}