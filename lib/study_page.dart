import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'study_controller.dart';
import 'modern_study_card.dart';

class StudyPage extends StatelessWidget {
  final StudyController controller = Get.put(StudyController());

  StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color greenPrimary = Color(0xFF1B8A4E);
    const Color greenLight = Color(0xFFF4FBF4);

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            controller.keys.isNotEmpty ? controller.keys.last : "Study",
            style: const TextStyle(
              color: Color(0xFF0D3320),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0D3320), size: 20),
            onPressed: controller.goBack,
          ),
        ),
        body: controller.showQuestions.value
            ? DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    // ─── Custom TabBar ───
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6), // 🔥 Reduced vertical margin
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        labelColor: greenPrimary,
                        unselectedLabelColor: Colors.grey.shade500,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        tabs: const [
                          Tab(text: "Description"),
                          Tab(text: "Questions"),
                          Tab(text: "Exam"),
                        ],
                      ),
                    ),

                    Expanded(
                      child: TabBarView(
                        children: [
                          // ─── DESCRIPTION TAB ───
                          _buildDescriptionTab(controller, greenPrimary, greenLight),

                          // ─── QUESTIONS TAB ───
                          _buildQuestionsTab(controller, greenPrimary),

                          // ─── EXAM TAB ───
                          _buildExamTab(controller, greenPrimary, greenLight),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            // ─── HIERARCHY GRID ───
            : _buildHierarchyGrid(controller, greenPrimary, greenLight),
      ),
    );
  }

  Widget _buildDescriptionTab(StudyController controller, Color primary, Color lightBg) {
    return Obx(() {
      final pages = controller.descriptionPages;
      if (pages.isEmpty) {
        return const Center(child: Text("No Description Available", style: TextStyle(color: Colors.grey)));
      }

      return Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: pages.length,
              onPageChanged: (i) => controller.currentPage.value = i,
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.menu_book_rounded, color: primary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Insight Page",
                              style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              pages[i],
                              style: const TextStyle(
                                fontSize: 17,
                                color: Color(0xFF0D3320),
                                height: 1.7,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Page Indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: controller.currentPage.value == index ? 24 : 6,
                      decoration: BoxDecoration(
                        color: controller.currentPage.value == index ? primary : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ));
              }),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildQuestionsTab(StudyController controller, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            children: [
              Text(
                "Question Feed",
                style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Text(
                "${controller.questions.length} Items",
                style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.questions.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, i) {
              final q = controller.questions[i];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (i * 50).clamp(0, 400)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: ModernStudyCard(q: q, index: i),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExamTab(StudyController controller, Color primary, Color lightBg) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: lightBg,
              shape: BoxShape.circle,
              border: Border.all(color: primary.withOpacity(0.1), width: 2),
            ),
            child: Icon(Icons.rocket_launch_rounded, size: 64, color: primary),
          ),
          const SizedBox(height: 32),
          const Text(
            "Ready for a Challenge?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D3320)),
          ),
          const SizedBox(height: 12),
          Text(
            "Test your knowledge with a practice session based on these ${controller.questions.length} questions.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed("/studyExam", arguments: controller.questions.toList());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Start Practice Mode", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Practice makes perfect! 🎯",
            style: TextStyle(color: primary.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyGrid(StudyController controller, Color primary, Color lightBg) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.items.length,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.7, // 🔥 Increased vertical space
      ),
      itemBuilder: (_, i) {
        final item = controller.items[i];
        final name = item["name"] ?? "";

        return GestureDetector(
          onTap: () => controller.onTileTap(item),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: primary.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Center(
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primary, primary.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.folder_open_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D3320),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
