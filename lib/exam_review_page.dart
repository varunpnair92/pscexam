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
        // 🔄 Wait for snapshot
        if (controller.snapshot.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        int i = controller.current.value;
        var q = controller.snapshot[i.toString()];

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔢 Question number
              Text(
                "Question ${i + 1} / ${controller.snapshot.length}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 15),

              // ❓ Question text
              Text(
                q['question'],
                style: TextStyle(fontSize: 18),
              ),

              SizedBox(height: 20),

              // 🎨 OPTIONS (COLORED)
              ...List.from(q['options'])
                  // 🔥 remove empty options
                  .where((o) => o.toString().trim().isNotEmpty)
                  .map((option) {

                String selected =
                    (q['selected'] ?? "").toString().trim();

                String correct =
                    (q['correct'] ?? "").toString().trim();

                String opt = option.toString().trim();

                // ⭐ FINAL COLOR LOGIC
                Color color =
                    opt == correct
                        ? Colors.green              // 🟩 Correct
                        : (opt == selected &&
                           selected != correct)
                            ? Colors.red           // 🟥 Wrong
                            : Colors.grey.shade200;

                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.all(14),
                    ),

                    // 🔥 IMPORTANT FIX — NOT NULL
                    onPressed: () {},

                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(option.toString()),
                    ),
                  ),
                );
              }),

              Spacer(),

              // ⬅️➡️ Navigation
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
                            controller.snapshot.length - 1
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