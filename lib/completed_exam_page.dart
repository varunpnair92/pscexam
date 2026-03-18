import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'result_controller.dart';
import 'test_controller.dart';

class ResultPage extends StatelessWidget {
  final ResultController ctrl = Get.put(ResultController());
  final TestController testCtrl = Get.find<TestController>();

  ResultPage({super.key});

  Color getScoreColor(int mark) {
    if (mark >= 80) return Colors.green;
    if (mark >= 50) return Colors.orange;
    return Colors.red;
  }

  String getGrade(int mark) {
    if (mark >= 80) return "Excellent";
    if (mark >= 60) return "Good";
    if (mark >= 40) return "Average";
    return "Needs Work";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Results"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ctrl.fetchLatestAttempts(),
          )
        ],
      ),

      body: Obx(() {
        /// 🔄 Loading
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        /// ❌ Error
        if (ctrl.errorMsg.isNotEmpty) {
          return Center(child: Text(ctrl.errorMsg.value));
        }

        /// 📭 Empty
        if (ctrl.exams.isEmpty) {
          return const Center(child: Text("No exams attempted"));
        }

        /// ✅ List
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: ctrl.exams.length,
          itemBuilder: (_, i) {
            final exam = ctrl.exams[i];
            final scoreColor = getScoreColor(exam.mark);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: scoreColor.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: scoreColor.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🟢 TOP ROW
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exam.examName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        /// SCORE BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: scoreColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${exam.mark}",
                            style: TextStyle(
                              color: scoreColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// CATEGORY
                    Text(
                      "${exam.category} • ${exam.type.toUpperCase()}",
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 10),

                    /// ATTEMPT + GRADE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Attempt ${exam.attempt}",
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          getGrade(exam.mark),
                          style: TextStyle(
                            color: scoreColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// BUTTONS
                    Row(
                      children: [

                        /// 🔍 REVIEW
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              testCtrl.examId = exam.examids;
                              testCtrl.attempt = exam.attempt;

                              await testCtrl.fetchResult();

                              testCtrl.current.value = 0;
                              Get.toNamed('/review');
                            },
                            icon: const Icon(Icons.menu_book, size: 16),
                            label: const Text("Review"),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// 🔁 RETAKE
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              testCtrl.resetController();
                              testCtrl.examId = exam.examids;

                              Get.toNamed('/exam',
                                  arguments: {'id': exam.examids});
                            },
                            icon: const Icon(Icons.replay, size: 16),
                            label: const Text("Retake"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}