import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/home_page.dart';
import 'package:psc_exam/math_formula.dart';
import 'test_controller.dart';

class ReviewPage extends StatelessWidget {
  final TestController controller = Get.find<TestController>();

  ReviewPage({super.key});

  final PageController pageController = PageController();
  final index = 0.obs;

  /// 🔥 SCROLL CONTROLLER FOR PALETTE
  final ScrollController circleController = ScrollController();

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

            /// 🔥 AUTO MOVE PALETTE
            if (circleController.hasClients) {
              circleController.animateTo(
                (index * 46).toDouble(),
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            }
          },

          itemBuilder: (context, i) {
            var q = controller.snapshot[i.toString()];

            return Padding(
              padding: const EdgeInsets.all(16),

              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔵 QUESTION PALETTE + COUNT
                      Row(
                        children: [
                          /// QUESTION CIRCLES
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: ListView.builder(
                                controller: circleController,
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.snapshot.length,

                                itemBuilder: (context, index) {
                                  var item =
                                      controller.snapshot[index.toString()];

                                  String selected = (item['selected'] ?? "")
                                      .toString()
                                      .trim();

                                  String correct = (item['correct'] ?? "")
                                      .toString()
                                      .trim();

                                  Color color;

                                  if (selected.isEmpty) {
                                    color = Colors.grey;
                                  } else if (selected == correct) {
                                    color = Colors.green;
                                  } else {
                                    color = Colors.red;
                                  }

                                  return Obx(() {
                                    bool isCurrent =
                                        index == controller.current.value;

                                    return GestureDetector(
                                      onTap: () {
                                        pageController.jumpToPage(index);

                                        controller.current.value = index;

                                        /// 🔥 AUTO SCROLL WHEN CLICK
                                        if (circleController.hasClients) {
                                          circleController.animateTo(
                                            (index * 46).toDouble(),
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.ease,
                                          );
                                        }
                                      },

                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),

                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color,
                                          border: isCurrent
                                              ? Border.all(
                                                  color: Colors.black,
                                                  width: 3,
                                                )
                                              : null,
                                        ),

                                        child: Center(
                                          child: Text(
                                            "${index + 1}",
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
                              ),
                            ),
                          ),

                          /// QUESTION COUNT
                          Obx(
                            () => Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                "${controller.current.value + 1}/${controller.snapshot.length}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      /// QUESTION + OPTIONS
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
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// QUESTION
                            MathText(text: q['question'] ?? ""),

                            const SizedBox(height: 15),

                            /// OPTIONS
                            ...List.from(
                              q['options'] ?? [],
                            ).where((o) => o.toString().trim().isNotEmpty).map((
                              option,
                            ) {
                              String selected = (q['selected'] ?? "")
                                  .toString()
                                  .trim();

                              String correct = (q['correct'] ?? "")
                                  .toString()
                                  .trim();

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

                      const Spacer(),

                      /// NAVIGATION BUTTONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          ElevatedButton(
                            onPressed: i > 0
                                ? () {
                                    pageController.previousPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
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
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
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

                  /// DRAGGABLE SOLUTION PANEL
                  if (q['description'] != null &&
                      q['description'].toString().trim().isNotEmpty)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: DraggableScrollableSheet(
                        initialChildSize: 0.15,
                        minChildSize: 0.1,
                        maxChildSize: 0.9,

                        builder: (context, scrollController) {
                          return Container(
                            padding: const EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              border: Border.all(color: Colors.grey.shade300),

                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 8),
                              ],
                            ),

                            child: ListView(
                              controller: scrollController,
                              children: [
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),

                                const Text(
                                  "View Solution",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),

                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green),
                                  ),

                                  child: MathText(text: q['description']),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
            currentIndex: index.value,
            onTap: (i) {
              index.value = i;

              if (i == 0) {
                Get.offAll(() => HomePage(), arguments: {"tab": 0});
              } else {
                Get.offAll(() => HomePage(), arguments: {"tab": 1});
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz),
                label: "Exam",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: "Study",
              ),
            ],
          ),
      
    );
  }
}
