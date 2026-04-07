import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exam_model.dart';
import 'test_controller.dart';
import 'auth_controller.dart';


class ExamSplashPage extends StatelessWidget {
  const ExamSplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final Exam exam = args['exam'];
    final bool isResume = args['isResume'] ?? false;
    final TestController testController = Get.find<TestController>();

    const Color primaryColor = Color(0xFF1B8A4E);
    const Color secondaryColor = Color(0xFF27AE60);

    final auth = AuthController.instance;


    final bool isLocked = exam.locked;
    final bool hasAccess = auth.canAccess(exam);


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0D3320)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ─── ICON / ILLUSTRATION ───
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_rounded,
                    size: 80,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // ─── TITLE & CATEGORY ───
                Text(
                  exam.specialization,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3320),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    exam.category,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (exam.description != null && exam.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    exam.description!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 48),

                // ─── EXAM DETAILS CARD ───
                Container(
                  padding: const EdgeInsets.all(24),
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
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.help_center_rounded, "Questions", "${exam.totalQuestions} items"),
                      const Divider(height: 32, thickness: 1),
                      _buildDetailRow(
                          Icons.timer_rounded, "Time Limit", _formatDuration(exam.totalQuestions * 45)), // 🔥 Dynamic Timer
                      const Divider(height: 32, thickness: 1),
                      _buildDetailRow(Icons.stars_rounded, "Points", "1.0 per correct"),
                    ],
                  ),
                ),

                const SizedBox(height: 40), // 🔥 Fixed spacer

                // ─── INSTRUCTIONS ───
                Text(
                  (exam.instructions != null && exam.instructions!.isNotEmpty) 
                      ? exam.instructions! 
                      : "Read each question carefully before choosing your answer. You can review your answers at the end of the session.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // ─── START BUTTON ───
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: isLocked
                        ? () {
                            Get.snackbar(
                              "Exam Locked",
                              "This exam is currently locked and not started.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                          }
                        : (!hasAccess
                            ? () {
                                auth.showPremiumAlert();
                              }
                            : () async {
                                if (isResume) {
                                  await testController.loadProgress(exam.id, title: exam.specialization);
                                } else {
                                  await testController.loadQuestions(exam.id, title: exam.specialization);
                                }
                                Get.offAndToNamed('/exam', arguments: {'id': exam.id, 'title': exam.specialization});
                              }),


                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLocked
                              ? "Exam Locked"
                              : (!hasAccess ? "Premium Required" : (isResume ? "Resume Exam" : "Start Exam Now")),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        Icon(isLocked || !hasAccess ? Icons.lock_outline_rounded : Icons.arrow_forward_rounded, size: 22),


                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),

    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 24),
        const SizedBox(width: 16),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0D3320),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return "No Limit";
    final Duration duration = Duration(seconds: seconds);
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes} mins";
    }
  }
}
