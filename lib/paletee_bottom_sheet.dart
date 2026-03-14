import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'test_controller.dart';

class PaletteBottomSheet extends StatelessWidget {
  final TestController controller = Get.find();

  PaletteBottomSheet({super.key});

  /// ALL QUESTIONS
  List<int> getAll() {
    return List.generate(controller.questions.length, (i) => i);
  }

  /// ANSWERED QUESTIONS
  List<int> getAnswered() {
    return controller.answers.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => e.key)
        .toList();
  }

  /// NOT ANSWERED
  List<int> getNotAnswered() {
    return List.generate(controller.questions.length, (i) => i)
        .where(
          (i) =>
              !controller.answers.containsKey(i) ||
              controller.answers[i] == null ||
              controller.answers[i]!.isEmpty,
        )
        .toList();
  }

  /// MARKED QUESTIONS
  List<int> getMarked() {
    return controller.marked.toList();
  }

  /// GRID BUILDER
  Widget buildGrid(List<int> list) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (_, i) {
        int qIndex = list[i];

        return Obx(() {
          return GestureDetector(
            onTap: () {
              controller.jumpTo(qIndex);
              Get.back();
            },
            child: Container(
              decoration: BoxDecoration(
                color: controller.getColor(qIndex),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "${qIndex + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  /// CIRCLE WIDGET FOR SUBMIT DIALOG
  Widget buildCircle(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Center(
            child: Text(
              "$count",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Text(title, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Container(
        height: 450,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// TITLE
            const Text(
              "Exam Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// TABS
            const TabBar(
              labelColor: Colors.black,
              tabs: [
                Tab(text: "*"),
                Tab(text: "Answered"),
                Tab(text: "Not Answered"),
                Tab(text: "Review"),
              ],
            ),

            const SizedBox(height: 10),

            /// TAB CONTENT
            Expanded(
              child: TabBarView(
                children: [
                  buildGrid(getAll()),
                  buildGrid(getAnswered()),
                  buildGrid(getNotAnswered()),
                  buildGrid(getMarked()),
                ],
              ),
            ),

            /// SUMMARY COUNTS
            Obx(() {
              int total = controller.questions.length;
              int answered = controller.answers.length;
              int marked = controller.marked.length;
              int notAnswered = total - answered;

              return Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Total: $total"),
                    Text("Answered: $answered"),
                    Text("Not Answered: $notAnswered"),
                    Text("Review: $marked"),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            /// BUTTON ROW
            Row(
              children: [
                /// EXIT & SAVE
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Get.defaultDialog(
                        title: "Exit Exam",
                        middleText:
                            "Progress will be saved. You can resume later.",
                        textCancel: "Cancel",
                        textConfirm: "Exit",
                        onConfirm: () async {
                          Get.back();

                          await controller.saveProgress();

                          controller.timer?.cancel();

                          Get.offAllNamed(
                            '/dynamicExamList',
                            arguments: {"endpoint": "/examlist"},
                          );
                        },
                      );
                    },
                    child: const Text("EXIT & SAVE"),
                  ),
                ),

                const SizedBox(width: 10),

                /// FINISH & SUBMIT
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      int total = controller.questions.length;
                      int answered = controller.answers.length;
                      int review = controller.marked.length;
                      int notAnswered = total - answered;

                      Get.dialog(
                        AlertDialog(
                          title: const Text("Submit Exam"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildCircle("Answered", answered, Colors.green),
                              const SizedBox(height: 10),
                              buildCircle(
                                "Not Answered",
                                notAnswered,
                                Colors.grey,
                              ),
                              const SizedBox(height: 10),
                              buildCircle("Review", review, Colors.orange),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Get.back();

                                controller.timer?.cancel();

                                await controller.submitResult();

                                await controller.clearProgress(
                                  controller.examId,
                                );

                                Get.offAllNamed('/analysis');
                              },
                              child: const Text("Final Submit"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("FINISH"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
