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
      appBar: AppBar(title: const Text("Review Exam")),
      backgroundColor: Colors.grey.shade100,

      body: Obx(() {
        if (controller.snapshot.isEmpty) {
          return const Center(child: CircularProgressIndicator());
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
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// QUESTION NUMBER
                  Text(
                    "Question ${i + 1} / ${controller.snapshot.length}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  /// QUESTION + OPTIONS (DYNAMIC HEIGHT)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),

                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// QUESTION
                        MathText(text: q['question'] ?? ""),

                        const SizedBox(height: 15),

                        /// OPTIONS
                        ...List.from(q['options'] ?? [])
                            .where((o) => o.toString().trim().isNotEmpty)
                            .map((option) {

                          String selected =
                              (q['selected'] ?? "").toString().trim();

                          String correct =
                              (q['correct'] ?? "").toString().trim();

                          String opt = option.toString().trim();

                          Color color = opt == correct
                              ? Colors.green
                              : (opt == selected && selected != correct)
                                  ? Colors.red
                                  : Colors.grey.shade200;

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 6),

                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.all(14),
                              ),

                              onPressed: () {},

                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: MathText(text: opt),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  /// SOLUTION (USES REMAINING SPACE)
                  if (q['description'] != null &&
                      q['description'].toString().trim().isNotEmpty)

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),

                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),

                        child: ListView(
                          children: [

                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,

                              title: const Text(
                                "View Solution",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),

                              children: [

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),

                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green),
                                  ),

                                  child: MathText(
                                    text: q['description'],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  /// NAVIGATION BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [

                      ElevatedButton(
                        onPressed: i > 0
                            ? () {
                                pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              }
                            : null,

                        child: const Text("Previous"),
                      ),

                      ElevatedButton(
                        onPressed: i < controller.snapshot.length - 1
                            ? () {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              }
                            : null,

                        child: const Text("Next"),
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