import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/math_formula.dart';
import 'test_controller.dart';

class ReviewPage extends StatelessWidget {
  final TestController controller = Get.find<TestController>();

  ReviewPage({super.key});

  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Review Exam")),

      body: Obx(() {
        if (controller.snapshot.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return PageView.builder(
          controller: pageController,
          itemCount: controller.snapshot.length,

          onPageChanged: (index) {
            controller.current.value = index;
          },

          itemBuilder: (context, i) {
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

                  /// ❓ QUESTION TEXT
                  MathText(text: q['question'] ?? ""),

                  SizedBox(height: 20),

                  /// 🎨 OPTIONS
                  ...List.from(
                    q['options'] ?? [],
                  ).where((o) => o.toString().trim().isNotEmpty).map((option) {
                    String selected = (q['selected'] ?? "").toString().trim();

                    String correct = (q['correct'] ?? "").toString().trim();

                    String opt = option.toString().trim();

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
                          child: MathText(text: opt),
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: 20),

                  /// 🟢 SOLUTION
                  if (q['description'] != null &&
                      q['description'].toString().trim().isNotEmpty)
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.all(12),

                      /// First line as title
                      title: Text(
                        q['description'].toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),

                      children: [
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.35,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),

                          child: SingleChildScrollView(
                            child: MathText(text: q['description']),
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
                        onPressed: i > 0
                            ? () {
                                pageController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              }
                            : null,
                        child: Text("Previous"),
                      ),

                      ElevatedButton(
                        onPressed: i < controller.snapshot.length - 1
                            ? () {
                                pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              }
                            : null,
                        child: Text("Next"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
