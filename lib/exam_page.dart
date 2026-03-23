import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/math_formula.dart';
import 'package:psc_exam/paletee_bottom_sheet.dart';
import 'package:psc_exam/test_controller.dart';

class ExamPage extends StatelessWidget {
  // 🔥 USE EXISTING CONTROLLER
  final TestController controller = Get.find();

  /// 🔹 SCROLL CONTROLLER FOR QUESTION NAVIGATOR
  final ScrollController circleController = ScrollController();

  ExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    bool isLocalExam = args is List;

    // 🔹 STUDY EXAM MODE (questions passed directly)
    if (args is List) {
      isLocalExam = true;
      controller.loadLocalQuestions(args);
    }
    // 🔹 REAL EXAM MODE (exam id)
    else if (args is Map && args.containsKey('id')) {
      final int examId = args['id'];
      controller.examId = examId;
      if (controller.questions.isEmpty) {
        controller.loadQuestions(examId);
      }
    }
    // 🔹 INVALID DATA
    else if (controller.questions.isEmpty) {
      return Scaffold(body: Center(child: Text("Invalid Exam Data")));
    }

    return Scaffold(
      // 🧠 TOP BAR
      appBar: AppBar(
         automaticallyImplyLeading: false,
        
        title: Obx(
          () => Text(
            "${controller.current.value + 1}/${controller.questions.length}",
          ),
        ),
        actions: [
          Icon(Icons.timer),

          Padding(
            padding: EdgeInsets.all(12),
            child: Obx(() {
              int sec = controller.remainingSeconds.value;
              int min = sec ~/ 60;
              int s = sec % 60;

              return Text(
                "$min:${s.toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 16),
              );
            }),
          ),
        ],
      ),

      body: Obx(() {
        if (controller.questions.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        var q = controller.questions[controller.current.value];

        /// 🔹 AUTO SCROLL NAVIGATOR WHEN QUESTION CHANGES
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (circleController.hasClients) {
            circleController.animateTo(
              (controller.current.value * 46).toDouble(),
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          }
        });

        return Column(
          children: [
            /// 🔵 QUESTION NAVIGATOR (CIRCLES)
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                controller: circleController,
                scrollDirection: Axis.horizontal,
                itemCount: controller.questions.length,
                itemBuilder: (context, index) {
                  return Obx(() {
                    bool isCurrent = index == controller.current.value;

                    bool isMarked = controller.marked.contains(index);

                    String? ans = controller.answers[index];

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
                        controller.current.value = index;
                        controller.saveProgress();
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: isCurrent
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            // 🧾 MCQ HEADER
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.grey.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("MCQ"), Text("Marks: +1  -0.33")],
              ),
            ),

            // 📄 QUESTION + OPTIONS
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ListView(
                  children: [
                    MathText(text: q.question),

                    SizedBox(height: 20),

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
                          onPressed: () {
                            controller.selectAnswer(o.toString());
                            controller.saveProgress();
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: MathText(text: o.toString()),
                          ),
                        ),
                      );
                    }),

                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            controller.previous();
                            controller.saveProgress();
                          },
                          child: Text("Previous"),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            controller.next();
                            controller.saveProgress();
                          },
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

      // 🧭 BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.bookmark, color: Colors.white),

            Obx(() {
              bool isMarked = controller.marked.contains(
                controller.current.value,
              );

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMarked ? Colors.orange : Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  controller.toggleMarkReview();
                  controller.saveProgress();
                },
                child: Text(isMarked ? "Remove Mark" : "Mark for Review"),
              );
            }),

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

            // 🔥 FINISH BUTTON
          ],
        ),
      ),
    );
  }
}
