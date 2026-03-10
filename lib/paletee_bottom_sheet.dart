import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'test_controller.dart';

class PaletteBottomSheet extends StatelessWidget {
  final TestController controller = Get.find();

  PaletteBottomSheet({super.key});

  List<int> getAll() {
    return List.generate(controller.questions.length, (i) => i);
  }

  List<int> getAnswered() {
    return controller.answers.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => e.key)
        .toList();
  }

  List<int> getNotAnswered() {
    return List.generate(controller.questions.length, (i) => i)
        .where((i) =>
            !controller.answers.containsKey(i) ||
            controller.answers[i] == null ||
            controller.answers[i]!.isEmpty)
        .toList();
  }

  List<int> getMarked() {
    return controller.marked.toList();
  }

  Widget buildGrid(List<int> list) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, i) {
        int qIndex = list[i];

        bool isMarked = controller.marked.contains(qIndex);
        String? ans = controller.answers[qIndex];

        Color color;

        if (isMarked) {
          color = Colors.orange;
        } else if (ans == null || ans.isEmpty) {
          color = Colors.grey;
        } else {
          color = Colors.green;
        }

        return GestureDetector(
          onTap: () {
            controller.current.value = qIndex;
            Get.back();
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${qIndex + 1}",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Container(
        height: Get.height * 0.6,
        child: Column(
          children: [
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
          ],
        ),
      ),
    );
  }
}