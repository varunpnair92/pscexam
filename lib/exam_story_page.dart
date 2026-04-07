import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/auth_controller.dart';
import 'package:psc_exam/exam_model.dart';
import 'package:psc_exam/psc_loading_logo.dart';
import 'package:psc_exam/exam_story_controller.dart';

class ExamStoryPage extends StatelessWidget {
  const ExamStoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inject the dedicated controller
    final ExamStoryController controller = Get.put(ExamStoryController());

    return Scaffold(
      backgroundColor: Colors.black, // Typical for stories
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: PSCLoadingLogo(size: 60));
        }

        final items = controller.exams;
        if (items.isEmpty) {
          return const Center(
            child: Text("No stories available", style: TextStyle(color: Colors.white)),
          );
        }

        return SafeArea(
          child: Stack(
            children: [
              // Content Area
              Positioned.fill(
                child: PageView.builder(
                  controller: controller.pageController,
                  physics: const BouncingScrollPhysics(), // Handle navigation with swiping
                  onPageChanged: controller.onPageChanged,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildContent(items[index], controller);
                  },
                ),
              ),

              // Title Header
              Positioned(
                top: 40,
                left: 6,
                right: 16,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        "Exam Stories",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Top Progress Bars
              Positioned(
                top: 20,
                left: 10,
                right: 10,
                child: Row(
                  children: List.generate(items.length, (index) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= controller.currentIndex.value
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Swipe handles page scrolling inherently now
            ],
          ),
        );
      }),
    );
  }

  Widget _buildContent(Exam exam, ExamStoryController controller) {
    final auth = AuthController.instance;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1B8A4E), // Deep green gradient
        gradient: LinearGradient(
          colors: [Color(0xFF0D3320), Color(0xFF1B8A4E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                exam.category,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            exam.specialization,
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (exam.description != null && exam.description!.isNotEmpty)
            Text(
              exam.description!,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            )
          else
            Text(
              "Challenge yourself with this exam and check your standing.",
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 40),
          
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B8A4E),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            icon: const Icon(Icons.play_arrow, size: 28),
            label: const Text("Start Exam", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onPressed: () => controller.startExam(exam),
          ),
          
          if (exam.accessType != "free" || exam.locked) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (exam.accessType != "free")
                  const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 20),
                if (exam.accessType != "free") const SizedBox(width: 4),
                if (exam.locked)
                  const Icon(Icons.lock, color: Colors.redAccent, size: 20),
              ],
            )
          ]
        ],
      ),
    );
  }
}
