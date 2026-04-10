import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psc_exam/exam_controller.dart';
import 'package:psc_exam/test_controller.dart';
import 'package:psc_exam/auth_controller.dart';
import 'package:psc_exam/app_theme.dart';
import 'package:psc_exam/ui_utils.dart';

class ExamListPage extends StatelessWidget {
  final examController = Get.put(ExamController());
  final testController = Get.put(TestController());

  ExamListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ─── IMMERSIVE BACKGROUND ───
          AppTheme.buildImmersiveBackground(context),

          Column(
            children: [
              // ─── CUSTOM APP BAR ───
              AppTheme.buildPremiumAppBar(
                title: "Select Exam",
                onBack: () => Get.back(),
              ),

              Expanded(
                child: Obx(() {
                  if (examController.exams.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }

                  final auth = AuthController.instance;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: examController.exams.length,
                    physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.15,
                      ),
                    itemBuilder: (_, i) {
                      final exam = examController.exams[i];
                      final bool hasAccess = auth.canAccess(exam);
                      final grad = AppTheme.premiumGradients[i % AppTheme.premiumGradients.length];
                      final name = exam.specialization;
                      final icon = UIUtils.getIconForName(name);

                      return AppTheme.buildStaggeredAnimation(
                        index: i,
                        child: GestureDetector(
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString('last_exam_name', exam.specialization);
                            prefs.setString('last_exam_id', exam.id.toString());

                            bool resume = await testController.hasProgressForExam(exam.id);

                            if (resume) {
                              Get.defaultDialog(
                                title: "Resume Exam",
                                middleText: "You have unfinished progress",
                                textCancel: "Restart",
                                textConfirm: "Resume",
                                confirmTextColor: Colors.white,
                                onConfirm: () async {
                                  Get.back();
                                  Get.toNamed('/examSplash', arguments: {
                                    'exam': exam,
                                    'isResume': true,
                                  });
                                },
                                onCancel: () async {
                                  Get.back();
                                  await testController.clearProgress(exam.id);
                                  Get.toNamed('/examSplash', arguments: {
                                    'exam': exam,
                                    'isResume': false,
                                  });
                                },
                              );
                            } else {
                              Get.toNamed('/examSplash', arguments: {
                                'exam': exam,
                                'isResume': false,
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: AppTheme.glassBox(gradient: grad),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -10,
                                    top: -10,
                                    child: Icon(icon, color: Colors.white.withOpacity(0.12), size: 80),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(icon, color: Colors.white, size: 18),
                                        ),
                                        const Spacer(),
                                        Text(
                                          name,
                                          style: AppTheme.cardTitleStyle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (exam.accessType != "free")
                                          const Padding(
                                            padding: EdgeInsets.only(top: 4),
                                            child: Row(
                                              children: [
                                                Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 14),
                                                SizedBox(width: 4),
                                                Text("Premium", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (!hasAccess || exam.locked)
                                    Positioned.fill(child: AppTheme.buildLockedOverlay()),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}