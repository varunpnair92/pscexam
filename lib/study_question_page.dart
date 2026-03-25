import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'study_controller.dart';
import 'modern_study_card.dart';

class StudyQuestionPage extends StatelessWidget {
  final StudyController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(controller.keys.join(" > ")),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.questions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Sticky Progress Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book_rounded, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "${controller.questions.length} Questions Available",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),

            // Question List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.questions.length,
                itemBuilder: (_, i) {
                  final q = controller.questions[i];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (i * 100).clamp(0, 500)), // Staggered delay
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: ModernStudyCard(q: q, index: i),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
