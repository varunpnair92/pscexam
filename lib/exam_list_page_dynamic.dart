import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exam_controller.dart';
import 'test_controller.dart';
import 'auth_controller.dart';
import 'home_page.dart';
import 'psc_loading_logo.dart';
import 'app_theme.dart';
import 'ui_utils.dart';

class DynamicExamListPage extends StatelessWidget {
  final examController = Get.put(ExamController());
  final testController = Get.put(TestController());

  final index = 0.obs;
  final search = "".obs;

  DynamicExamListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final String endpoint = args["endpoint"] ?? "";

    if (endpoint.isNotEmpty) {
      examController.loadFromEndpoint(endpoint);
    }

    return Obx(() => Scaffold(
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

                  // ─── SEARCH BOX ───
                  AppTheme.buildPremiumSearchBar(
                    controller: TextEditingController(text: search.value)
                      ..selection = TextSelection.collapsed(offset: search.value.length),
                    onChanged: (v) => search.value = v.toLowerCase(),
                    hintText: "Search Exam...",
                    onClear: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      search.value = "";
                    },
                  ),

                  Expanded(
                    child: Obx(() {
                      if (examController.exams.isEmpty) {
                        return const Center(child: PSCLoadingLogo(size: 80));
                      }

                      /// 🔎 FILTER EXAMS
                      var exams = examController.exams.where((e) {
                        return e.specialization.toLowerCase().contains(search.value);
                      }).toList();

                      if (exams.isEmpty) {
                        return const Center(child: Text("No exams found", style: TextStyle(color: Colors.grey)));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: exams.length,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.15, // Shorter, more compact tiles
                        ),
                        itemBuilder: (_, i) {
                          final exam = exams[i];
                          final auth = AuthController.instance;
                          final bool hasAccess = auth.canAccess(exam);
                          final grad = AppTheme.premiumGradients[i % AppTheme.premiumGradients.length];
                          final name = exam.specialization;
                          final icon = UIUtils.getIconForName(name);

                          return AppTheme.buildStaggeredAnimation(
                            index: i,
                            child: FutureBuilder<Map<String, dynamic>>(
                              future: testController.getProgressSummary(exam.id),
                              builder: (context, snapshot) {
                                double progress = 0;
                                Color progressColor = Colors.white70;
                                int answered = 0;
                                int total = exam.totalQuestions;

                                if (snapshot.hasData) {
                                  Map<String, dynamic>? p = snapshot.data;
                                  if (p != null) {
                                    bool finished = p["finished"] ?? false;
                                    answered = p["answered"] ?? 0;
                                    progress = total == 0 ? 0 : (answered / total);
                                    if (finished) {
                                      progressColor = const Color(0xFF2ECC71); // Bright green
                                    } else if (answered > 0) {
                                      progressColor = Colors.amber;
                                    }
                                  }
                                }

                                return GestureDetector(
                                  onTap: () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    prefs.setString('last_exam_name', exam.specialization);
                                    prefs.setString('last_exam_id', exam.id.toString());

                                    bool resume = await testController.hasProgressForExam(exam.id);

                                    if (resume) {
                                      Get.defaultDialog(
                                        title: "Resume",
                                        middleText: "Restart or continue?",
                                        textCancel: "Restart",
                                        textConfirm: "Resume",
                                        confirmTextColor: Colors.white,
                                        onConfirm: () async {
                                          Get.back();
                                          Get.toNamed('/examSplash', arguments: {'exam': exam, 'isResume': true});
                                        },
                                        onCancel: () async {
                                          Get.back();
                                          await testController.clearProgress(exam.id);
                                          Get.toNamed('/examSplash', arguments: {'exam': exam, 'isResume': false});
                                        },
                                      );
                                    } else {
                                      Get.toNamed('/examSplash', arguments: {'exam': exam, 'isResume': false});
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
                                            child: Icon(icon, color: Colors.white.withOpacity(0.08), size: 70),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                                      child: Icon(icon, color: Colors.white, size: 14),
                                                    ),
                                                    const Spacer(),
                                                    if (exam.accessType != "free")
                                                      const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 16),
                                                  ],
                                                ),
                                                const Spacer(),
                                                Text(
                                                  name,
                                                  style: AppTheme.cardTitleStyle.copyWith(fontSize: 13),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                
                                                // Progress Section
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("$total Qs", style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                                    FutureBuilder<int>(
                                                      future: testController.getAttemptCount(exam.id),
                                                      builder: (context, snap) => Text("Att: ${snap.data ?? 0}", style: const TextStyle(color: Colors.white60, fontSize: 9)),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(4),
                                                  child: LinearProgressIndicator(
                                                    value: progress,
                                                    minHeight: 3,
                                                    backgroundColor: Colors.white.withOpacity(0.1),
                                                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
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
                                );
                              },
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

          /// BOTTOM NAVIGATION (Preserved but styled)
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: BottomNavigationBar(
              currentIndex: index.value,
              onTap: (i) {
                index.value = i;
                if (i == 0) {
                  Get.offAll(() => HomePage(), arguments: {"tab": 0});
                } else {
                  Get.offAll(() => HomePage(), arguments: {"tab": 1});
                }
              },
              backgroundColor: Colors.white,
              elevation: 0,
              selectedItemColor: AppTheme.primary,
              unselectedItemColor: Colors.grey.shade400,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.quiz_rounded, size: 24), label: "Exam"),
                BottomNavigationBarItem(icon: Icon(Icons.school_rounded, size: 24), label: "Study"),
              ],
            ),
          ),
        ));
  }
}
