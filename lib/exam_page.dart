import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/paletee_bottom_sheet.dart';
import 'package:psc_exam/test_controller.dart';

class ExamPage extends StatelessWidget {
  final TestController controller = Get.put(TestController());

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map?;
    final int? examId = args?['id'];

    if (examId == null) {
      return Scaffold(body: Center(child: Text("Invalid Exam ID")));
    }

    // 🔥 Load only once
    if (controller.questions.isEmpty) {
      controller.loadQuestions(examId);
    }

    return Scaffold(
      // 🧠 TOP BAR (like real exam)
      appBar: AppBar(
        title: Obx(
          () => Text(
            "${controller.current.value + 1}/${controller.questions.length}",
          ),
        ),
        actions: [
          Icon(Icons.timer),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text("89:16"), // 🔥 later add real timer
          ),
        ],
      ),

      body: Obx(() {
        if (controller.questions.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        var q = controller.questions[controller.current.value];

        return Column(
          children: [
            // 🧾 MCQ Header
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.grey.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("MCQ"), Text("Marks: +1  -0.33")],
              ),
            ),

            // 📄 Question + Options
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ListView(
                  children: [
                    Text(q.question, style: TextStyle(fontSize: 18)),

                    SizedBox(height: 20),

                    // 🎨 OPTIONS WITH SELECTED COLOR
                    ...q.options.where((o) => o.toString().isNotEmpty).map((o) {
                      final selected =
                          controller.answers[controller.current.value] == o;

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selected
                                ? Colors.blue
                                : Colors.grey.shade200,
                            foregroundColor: selected
                                ? Colors.white
                                : Colors.black,
                          ),
                          onPressed: () =>
                              controller.selectAnswer(o.toString()),
                          child: Text(o.toString()),
                        ),
                      );
                    }),
                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: controller.previous,
                          child: Text("Previous"),
                        ),

                        ElevatedButton(
                          onPressed: controller.next,
                          child: Text("Next"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),

      // 🧭 BOTTOM NAV (Bookmark + Review + Palette)
      // 🧭 BOTTOM NAV (Bookmark + Review + Palette + Finish)
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.bookmark, color: Colors.white),

            ElevatedButton(
              onPressed: controller.markReview,
              child: Text("Mark for Review"),
            ),

            IconButton(
              icon: Icon(Icons.grid_view, color: Colors.white),
              onPressed: () {
                Get.bottomSheet(
                  PaletteBottomSheet(),
                  backgroundColor: Colors.white,
                  isScrollControlled: true,
                );
              },
            ),

            // 🔥 NEW FINISH BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Get.defaultDialog(
                  title: "Submit Exam",
                  middleText: "Are you sure you want to finish?",
                  textCancel: "No",
                  textConfirm: "Yes",
                  onConfirm: () async {
                    Get.back();

                    await controller.submitResult(); // 🔥 submit

                    Get.offAllNamed('/analysis'); // 🔥 go analysis
                  },
                );
              },
              child: Text("Finish"),
            ),
          ],
        ),
      ),
    );
  }
}
