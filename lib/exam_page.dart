import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/math_formula.dart';
import 'package:psc_exam/paletee_bottom_sheet.dart';
import 'package:psc_exam/test_controller.dart';
import 'package:psc_exam/question_model.dart';

class ExamPage extends StatefulWidget {
  ExamPage({super.key});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  // 🔥 USE EXISTING CONTROLLER
  final TestController controller = Get.find();

  /// 🔹 SCROLL CONTROLLER FOR QUESTION NAVIGATOR
  final ScrollController circleController = ScrollController();
  
  /// 🔹 PAGE CONTROLLER FOR SWIPE
  late PageController pageController;
  late Worker _worker;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: controller.current.value);
    
    // Auto-scroll PageView when controller.current changes from outside (e.g., clicking top navigation, auto-advance)
    _worker = ever(controller.current, (index) {
      if (pageController.hasClients && pageController.page?.round() != index) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }

      // Auto-scroll the top horizontal Question Navigator
      if (circleController.hasClients) {
        // Calculate offset to somewhat center the selected circle
        double screenWidth = Get.width;
        double itemWidth = 46.0;
        double targetScroll = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
        
        circleController.animateTo(
          targetScroll.clamp(0.0, circleController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _worker.dispose();
    pageController.dispose();
    circleController.dispose();
    super.dispose();
  }

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
      
      // 🔥 ALWAYS RELOAD IF ID MISMATCH OR EMPTY
      if (controller.examId != examId || controller.questions.isEmpty) {
        controller.loadQuestions(examId);
      }
    }
    // 🔹 INVALID DATA
    else if (controller.questions.isEmpty) {
      return const Scaffold(body: Center(child: Text("Loading Exam...")));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // 🧠 TOP BAR
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Obx(
          () => Text(
            "${controller.current.value + 1}/${controller.questions.length}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        actions: [
          const Icon(Icons.timer_outlined, color: Colors.blueGrey),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Obx(() {
              int sec = controller.remainingSeconds.value;
              int min = sec ~/ 60;
              int s = sec % 60;

              return Center(
                child: Text(
                  "$min:${s.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
              );
            }),
          ),
        ],
      ),

      body: Obx(() {
        if (controller.questions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            /// 🔵 QUESTION NAVIGATOR (CIRCLES)
            Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
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
                      color = Colors.grey.shade300;
                    } else {
                      color = Colors.green.shade500;
                    }

                    return GestureDetector(
                      onTap: () {
                        controller.current.value = index;
                        controller.saveProgress();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: isCurrent
                              ? Border.all(color: Colors.blue.shade600, width: 2.5)
                              : null,
                          boxShadow: isCurrent 
                              ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 6)] 
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: (ans == null || ans.isEmpty) && !isMarked && !isCurrent ? Colors.black54 : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.grey.shade100,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Multiple Choice", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w600, fontSize: 13)),
                  Text("Marks: +1  -0.33", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),

            // 📄 QUESTION + SWIPEABLE OPTIONS
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: controller.questions.length,
                onPageChanged: (index) {
                  if (controller.current.value != index) {
                    controller.current.value = index;
                    controller.saveProgress();
                  }
                },
                itemBuilder: (context, index) {
                  return _buildQuestionCard(controller.questions[index], index);
                },
              ),
            ),

            // 🧭 FIXED NAVIGATION (Next/Previous)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    bool hasPrev = controller.current.value > 0;
                    return TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: hasPrev ? Colors.blue.shade50 : Colors.grey.shade100,
                        foregroundColor: hasPrev ? Colors.blue.shade700 : Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text("Previous", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      onPressed: hasPrev ? () {
                        controller.previous();
                      } : null,
                    );
                  }),
                  Obx(() {
                    bool isLast = controller.current.value == controller.questions.length - 1;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLast ? Colors.green.shade600 : Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        if (!isLast) {
                          controller.next();
                        } else {
                           Get.bottomSheet(
                              PaletteBottomSheet(),
                              backgroundColor: Colors.white,
                              isScrollControlled: true,
                           );
                        }
                      },
                      child: Row(
                        children: [
                          Text(isLast ? "Review / Finish" : "Next", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          if (!isLast) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ]
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      }),

      // 🧭 BOTTOM BAR (Marking & Palette)
      bottomNavigationBar: Container(
        color: const Color(0xFF1E293B), // Slate Dark
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(() {
                bool isMarked = controller.marked.contains(controller.current.value);
                return ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMarked ? Colors.orange.shade500 : Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(isMarked ? Icons.bookmark_added_rounded : Icons.bookmark_border_rounded, size: 18),
                  label: Text(isMarked ? "Remove Mark" : "Mark Review", style: const TextStyle(fontWeight: FontWeight.w600)),
                  onPressed: () {
                    controller.toggleMarkReview();
                    controller.saveProgress();
                  },
                );
              }),

              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
                onPressed: () {
                  Get.bottomSheet(
                    PaletteBottomSheet(),
                    backgroundColor: Colors.white,
                    isScrollControlled: true,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Question q, int qIndex) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Question Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: MathText(text: "Q${qIndex + 1}.  ${q.question}"),
          ),
          
          const SizedBox(height: 24),
          
          // Options List
          ...q.options.where((o) => o.toString().trim().isNotEmpty).map((o) {
            String optText = o.toString();
            return Obx(() {
              final selectedAns = controller.answers[qIndex];
              final bool isSelected = selectedAns == optText;
              
              return GestureDetector(
                onTap: () {
                  controller.selectAnswer(optText);
                  controller.saveProgress();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.blue.shade400 : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(color: Colors.blue.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          key: ValueKey<bool>(isSelected),
                          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MathText(text: optText),
                      ),
                    ],
                  ),
                ),
              );
            });
          }),
        ],
      ),
    );
  }
}

