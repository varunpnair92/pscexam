import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/home_page.dart';
import 'package:psc_exam/math_formula.dart';
import 'test_controller.dart';

class ReviewPage extends StatefulWidget {
  ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TestController controller = Get.find<TestController>();
  
  late PageController pageController;
  final ScrollController circleController = ScrollController();
  late Worker _worker;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: controller.current.value);
    
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Exam Review", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(
              () => Center(
                child: Text(
                  "${controller.current.value + 1}/${controller.snapshot.length}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
                ),
              ),
            ),
          )
        ],
      ),
      body: Obx(() {
        if (controller.snapshot.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        /// 🔹 AUTO SCROLL NAVIGATOR INIT
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (circleController.hasClients && circleController.position.pixels == 0) {
            circleController.jumpTo(
              ((controller.current.value * 46.0) - (Get.width / 2) + 23.0).clamp(0.0, circleController.position.maxScrollExtent),
            );
          }
        });

        return Column(
          children: [
            /// 🔵 TOP QUESTION NAVIGATOR (CIRCLES)
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
                itemCount: controller.snapshot.length,
                itemBuilder: (context, index) {
                  return Obx(() {
                    bool isCurrent = index == controller.current.value;
                    var item = controller.snapshot[index.toString()];

                    String selected = (item?['selected'] ?? "").toString().trim();
                    String correct = (item?['correct'] ?? "").toString().trim();

                    Color color;
                    if (selected.isEmpty) {
                      color = Colors.grey.shade300;
                    } else if (selected == correct) {
                      color = Colors.green.shade500;
                    } else {
                      color = Colors.red.shade500;
                    }

                    return GestureDetector(
                      onTap: () {
                        controller.current.value = index;
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
                              color: selected.isEmpty && !isCurrent ? Colors.black54 : Colors.white,
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

            // 🧾 HEADER SECTION
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Answer Review", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w600, fontSize: 13)),
                  Obx(() {
                     var item = controller.snapshot[controller.current.value.toString()];
                     String selected = (item?['selected'] ?? "").toString().trim();
                     String correct = (item?['correct'] ?? "").toString().trim();
                     if (selected.isEmpty) {
                       return const Text("Skipped", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13));
                     } else if (selected == correct) {
                       return const Text("Correct +1.0", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13));
                     } else {
                       return const Text("Incorrect -0.33", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13));
                     }
                  }),
                ],
              ),
            ),

            // 📄 QUESTION + OPTIONS SWIPE VIEW
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: controller.snapshot.length,
                onPageChanged: (index) {
                  if (controller.current.value != index) {
                    controller.current.value = index;
                  }
                },
                itemBuilder: (context, i) {
                  var q = controller.snapshot[i.toString()];
                  return _buildReviewCard(q, i);
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
                    bool isLast = controller.current.value == controller.snapshot.length - 1;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        if (!isLast) {
                          controller.next();
                        }
                      },
                      child: Row(
                        children: [
                          const Text("Next", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
      
      // 🧭 BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade500,
        onTap: (i) {
          if (i == 0) {
            Get.offAll(() => HomePage(), arguments: {"tab": 0});
          } else {
            Get.offAll(() => HomePage(), arguments: {"tab": 1});
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: "Study",
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic>? q, int qIndex) {
    if (q == null) return const SizedBox.shrink();

    String selected = (q['selected'] ?? "").toString().trim();
    String correct = (q['correct'] ?? "").toString().trim();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16, 
            right: 16, 
            top: 16, 
            // Add massive bottom padding if solution panel exists so it doesn't cover options
            bottom: (q['description'] != null && q['description'].toString().trim().isNotEmpty) ? 140 : 16
          ),
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
                child: MathText(text: "Q${qIndex + 1}.  ${q['question']}"),
              ),
              
              const SizedBox(height: 24),
              
              // Options List
              ...List.from(q['options'] ?? []).where((o) => o.toString().trim().isNotEmpty).map((option) {
                String opt = option.toString().trim();
                
                bool isCorrectAnswer = (opt == correct);
                bool isUserWrongSelected = (opt == selected && selected != correct);

                Color bgColor = Colors.white;
                Color borderColor = Colors.grey.shade300;
                IconData leadingIcon = Icons.radio_button_off_rounded;
                Color iconColor = Colors.grey.shade400;

                if (isCorrectAnswer) {
                  bgColor = Colors.green.shade50;
                  borderColor = Colors.green.shade400;
                  leadingIcon = Icons.check_circle_rounded;
                  iconColor = Colors.green.shade600;
                } else if (isUserWrongSelected) {
                  bgColor = Colors.red.shade50;
                  borderColor = Colors.red.shade400;
                  leadingIcon = Icons.cancel_rounded;
                  iconColor = Colors.red.shade600;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: (isCorrectAnswer || isUserWrongSelected) ? 2 : 1),
                    boxShadow: [
                      if (isCorrectAnswer)
                        BoxShadow(color: Colors.green.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4)),
                      if (isUserWrongSelected)
                         BoxShadow(color: Colors.red.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Row(
                    children: [
                      Icon(leadingIcon, color: iconColor, size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MathText(text: opt),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // 🟢 DRAGGABLE SOLUTION PANEL (IF EXISTS)
        if (q['description'] != null && q['description'].toString().trim().isNotEmpty)
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.12,
              minChildSize: 0.12,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: Colors.green.shade200, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4)),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // Grabber Handle
                      Center(
                        child: Container(
                          width: 45,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Title row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           const Icon(Icons.lightbulb_circle, color: Colors.green, size: 22),
                           const SizedBox(width: 8),
                           const Text(
                             "Swipe Up for Solution",
                             style: TextStyle(
                               fontSize: 15,
                               fontWeight: FontWeight.bold,
                               color: Colors.green,
                             ),
                           ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Description Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade100),
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
    );
  }
}
