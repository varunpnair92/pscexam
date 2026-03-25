import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'test_controller.dart';

class AnalysisPage extends StatelessWidget {
  final controller = Get.find<TestController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Analytics")),

      body: Obx(() {
        int total = controller.total;
        int correct = controller.correct;
        int wrong = controller.wrong;
        int unanswered = controller.notAttempted;

        int timeTaken = controller.totalSeconds - controller.remainingSeconds.value;
        if (timeTaken < 0) timeTaken = 0;
        int perQuestionSec = controller.attempted > 0 ? timeTaken ~/ controller.attempted : 0;

        String formatTime(int sec) {
          int m = sec ~/ 60;
          int s = sec % 60;
          if (m > 0) return "${m}m ${s}s";
          return "${s}s";
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // ================= OVERVIEW =================
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(width: 4, height: 20, color: Colors.orange),
                          SizedBox(width: 8),
                          Text("Overview", style: TextStyle(fontSize: 18)),
                        ],
                      ),

                      SizedBox(height: 20),

                      // ⭐ REAL DONUT CHART
                      SizedBox(
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                centerSpaceRadius: 50,
                                sectionsSpace: 2,
                                sections: [
                                  PieChartSectionData(
                                    value: correct.toDouble(),
                                    color: Colors.green,
                                    title: "",
                                  ),

                                  PieChartSectionData(
                                    value: wrong.toDouble(),
                                    color: Colors.red,
                                    title: "",
                                  ),

                                  PieChartSectionData(
                                    value: unanswered.toDouble(),
                                    color: Colors.grey,
                                    title: "",
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${((correct / total) * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Correct"),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // ================= LEGEND =================
                      statRow("Correct", correct, Colors.green),
                      statRow("Wrong", wrong, Colors.red),
                      statRow("Unanswered", unanswered, Colors.grey),

                      SizedBox(height: 10),

                      ElevatedButton.icon(
                        onPressed: () async {
                          await controller.fetchResult();

                          // 🔥 START REVIEW FROM FIRST QUESTION
                          controller.current.value = 0;
                          Get.toNamed('/review');
                        },
                        icon: Icon(Icons.menu_book),
                        label: Text("ANSWER KEY & SOLUTION"),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // ================= ANALYTICS =================
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(width: 4, height: 20, color: Colors.orange),
                          SizedBox(width: 8),
                          Text("Analytics", style: TextStyle(fontSize: 18)),
                        ],
                      ),

                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          analyticsItem(
                            Icons.my_location,
                            "${controller.correct - controller.wrong}",
                            "Score",
                          ),

                          analyticsItem(Icons.flash_on, formatTime(perQuestionSec), "Per Question"),

                          analyticsItem(Icons.timer, formatTime(timeTaken), "Total Time"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ================= SMALL WIDGETS =================

  Widget statRow(String label, int value, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Text(
              value.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget analyticsItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 40),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}
