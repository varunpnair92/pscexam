import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/math_formula.dart'; // ⭐ math support
import 'test_controller.dart';

class ReviewPage extends StatelessWidget {
  final TestController controller = Get.find<TestController>();

  ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Review Exam")),

      body: Obx(() {
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
              /// 🔢 QUESTION NUMBER
              Text(
                "Question ${i + 1} / ${controller.snapshot.length}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 15),

              /// ❓ QUESTION TEXT (Math Support)
              MathText(text: q['question'] ?? ""),

              SizedBox(height: 20),

              /// 🎨 OPTIONS
              ...List.from(
                q['options'] ?? [],
              ).where((o) => o.toString().trim().isNotEmpty).map((option) {
                String selected = (q['selected'] ?? "").toString().trim();

                String correct = (q['correct'] ?? "").toString().trim();

                String opt = option.toString().trim();

                /// ⭐ COLOR LOGIC
                Color color = opt == correct
                    ? Colors.green
                    : (opt == selected && selected != correct)
                    ? Colors.red
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
                    onPressed: () {},

                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: MathText(
                        text: opt, // ⭐ option math support
                      ),
                    ),
                  ),
                );
              }),

              SizedBox(height: 20),

              /// 🟢 SOLUTION / DESCRIPTION
              if (q['description'] != null &&
                  q['description'].toString().trim().isNotEmpty)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.all(12),

                  title: Text(
                    "Show Solution",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),

                      child: MathText(
                        text: q['description'], // ⭐ supports math also
                      ),
                    ),
                  ],
                ),

              Spacer(),

              /// ⬅️➡️ NAVIGATION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: controller.current.value > 0
                        ? controller.previous
                        : null,
                    child: Text("Previous"),
                  ),

                  ElevatedButton(
                    onPressed:
                        controller.current.value <
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
