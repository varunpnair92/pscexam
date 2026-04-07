import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exam_controller.dart';
import 'test_controller.dart';
import 'auth_controller.dart';
import 'home_page.dart';
import 'psc_loading_logo.dart';

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
          appBar: AppBar(title: const Text("Select Exam")),
          body: Column(
            children: [
              /// 🔍 SEARCH BOX
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search Exam",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (v) {
                    search.value = v.toLowerCase();
                  },
                ),
              ),

              Expanded(
                child: Obx(() {
                  if (examController.exams.isEmpty) {
                    return const Center(
                      child: PSCLoadingLogo(size: 80),
                    );
                  }

                  /// 🔎 FILTER EXAMS
                  var exams = examController.exams.where((e) {
                    return e.specialization.toLowerCase().contains(search.value);
                  }).toList();

                  return ListView.builder(
                    itemCount: exams.length,
                    itemBuilder: (_, i) {
                      var exam = exams[i];

                      final auth = AuthController.instance;
                      final bool hasAccess = auth.canAccess(exam);



                      return FutureBuilder<Map<String, dynamic>>(
                        future: testController.getProgressSummary(exam.id),
                        builder: (context, snapshot) {
                          String progressText = "Not Started";
                          Color progressColor = Colors.grey;

                          int answered = 0;
                          int total = 0;

                          if (snapshot.hasData) {
                            Map<String, dynamic>? p = snapshot.data;
                            if (p != null) {
                              bool finished = p["finished"] ?? false;
                              answered = p["answered"] ?? 0;
                              total = exam.totalQuestions;

                              if (finished) {
                                progressText = "Finished";
                                progressColor = Colors.green;
                              } else if (answered > 0) {
                                progressText = "Progress $answered/$total";
                                progressColor = Colors.orange;
                              }
                            }
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
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
                                    onConfirm: () async {
                                      Get.back();
                                      Get.toNamed(
                                        '/examSplash',
                                        arguments: {
                                          'exam': exam,
                                          'isResume': true,
                                        },
                                      );
                                    },
                                    onCancel: () async {
                                      Get.back();
                                      await testController.clearProgress(exam.id);
                                      Get.toNamed(
                                        '/examSplash',
                                        arguments: {
                                          'exam': exam,
                                          'isResume': false,
                                        },
                                      );
                                    },
                                  );
                                } else {
                                  Get.toNamed(
                                    '/examSplash',
                                    arguments: {
                                      'exam': exam,
                                      'isResume': false,
                                    },
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Stack(
                                  children: [
                                    Opacity(
                                      opacity: hasAccess ? 1.0 : 0.5,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          /// TITLE + LOCK ICON
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  exam.specialization,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  if (exam.accessType != "free")
                                                    const Padding(
                                                      padding: EdgeInsets.only(right: 8.0),
                                                      child: Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 20),
                                                    ),
                                                  Icon(
                                                    exam.locked ? Icons.lock : Icons.lock_open,
                                                    color: exam.locked ? Colors.red : Colors.green,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "$total Qs",
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                progressText,
                                                style: TextStyle(
                                                  color: progressColor,
                                                  fontWeight: true ? FontWeight.bold : FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              FutureBuilder<int>(
                                                future: testController.getAttemptCount(exam.id),
                                                builder: (context, snap) {
                                                  int attempts = snap.data ?? 0;
                                                  return Text(
                                                    "Att: $attempts",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),

                                          /// PROGRESS BAR
                                          LinearProgressIndicator(
                                            value: total == 0 ? 0 : answered / total,
                                            backgroundColor: Colors.grey.shade300,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              progressColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!hasAccess)
                                      const Positioned.fill(
                                        child: Center(
                                          child: Icon(
                                            Icons.lock_outline_rounded,
                                            color: Colors.black12,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),

          /// BOTTOM NAVIGATION
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
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
              selectedItemColor: const Color(0xFF1B8A4E),
              unselectedItemColor: Colors.grey.shade400,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.quiz_rounded, size: 26),
                  ),
                  label: "Exam",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.school_rounded, size: 26),
                  ),
                  label: "Study",
                ),
              ],
            ),
          ),
        ));
  }
}
