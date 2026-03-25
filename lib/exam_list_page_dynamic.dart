import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exam_controller.dart';
import 'test_controller.dart';
import 'home_page.dart';

class DynamicExamListPage extends StatelessWidget {
final examController = Get.put(ExamController());
final testController = Get.put(TestController());

final index = 0.obs;
final search = "".obs;

DynamicExamListPage({super.key});

@override
Widget build(BuildContext context) {
final args = Get.arguments;
final String endpoint = args["endpoint"];


examController.loadFromEndpoint(endpoint);

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
                    child: CircularProgressIndicator());
              }

              /// 🔎 FILTER EXAMS
              var exams = examController.exams.where((e) {

                return e.specialization
                    .toLowerCase()
                    .contains(search.value);

              }).toList();

              return ListView.builder(
                itemCount: exams.length,
                itemBuilder: (_, i) {

                  var exam = exams[i];

                  return FutureBuilder<Map<String, dynamic>>(
                      future: testController
                          .getProgressSummary(exam.id),
                      builder: (context, snapshot) {

                        String progressText = "Not Started";
                        Color progressColor = Colors.grey;

                        int answered = 0;
                        int total = 0;

                        if (snapshot.hasData) {

                          Map<String, dynamic>? p =
                              snapshot.data;

                          if (p != null) {

                            bool finished =
                                p["finished"] ?? false;

                            answered =
                                p["answered"] ?? 0;

                            total =
                                p["total"] ?? 0;

                            if (finished) {
                              progressText = "Finished";
                              progressColor = Colors.green;
                            } 
                            else if (answered > 0) {
                              progressText =
                                  "Progress $answered/$total";
                              progressColor = Colors.orange;
                            }
                          }
                        }

                        return Card(
                          margin:
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(12),

                            onTap: exam.locked
                                ? () {
                                    Get.snackbar(
                                      "Exam Locked",
                                      "This exam is currently locked",
                                      snackPosition:
                                          SnackPosition.BOTTOM,
                                    );
                                  }
                                : () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    prefs.setString('last_exam_name', exam.specialization);
                                    prefs.setString('last_exam_id', exam.id.toString());

                                    bool resume =
                                        await testController
                                            .hasProgressForExam(
                                                exam.id);

                                    if (resume) {

                                      Get.defaultDialog(
                                        title: "Resume Exam",
                                        middleText:
                                            "You have unfinished progress",
                                        textCancel: "Restart",
                                        textConfirm:
                                            "Resume",
                                        onConfirm:
                                            () async {

                                          Get.back();

                                          await testController
                                              .loadProgress(
                                                  exam.id);

                                          Get.toNamed(
                                            '/exam',
                                            arguments: {
                                              'id':
                                                  exam.id
                                            },
                                          );
                                        },
                                        onCancel:
                                            () async {

                                          Get.back();

                                          await testController
                                              .clearProgress(
                                                  exam.id);

                                          await testController
                                              .loadQuestions(
                                                  exam.id);

                                          Get.toNamed(
                                            '/exam',
                                            arguments: {
                                              'id':
                                                  exam.id
                                            },
                                          );
                                        },
                                      );
                                    } else {

                                      await testController
                                          .loadQuestions(
                                              exam.id);

                                      Get.toNamed(
                                        '/exam',
                                        arguments: {
                                          'id': exam.id
                                        },
                                      );
                                    }
                                  },

                            child: Padding(
                              padding:
                                  const EdgeInsets.all(14),

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [

                                  /// TITLE + LOCK ICON
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [

                                      Expanded(
                                        child: Text(
                                          exam.specialization,
                                          style:
                                              const TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                      ),

                                      Icon(
                                        exam.locked
                                            ? Icons.lock
                                            : Icons
                                                .lock_open,
                                        color: exam.locked
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                      height: 6),

                                  /// QUESTION COUNT
                                  Text(
                                    "$total Questions",
                                    style:
                                        const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 6),

                                  /// PROGRESS TEXT
                                  Text(
                                    progressText,
                                    style: TextStyle(
                                      color:
                                          progressColor,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 6),

                                  /// ⭐ ATTEMPT COUNT
                                  FutureBuilder<int>(
                                    future: testController
                                        .getAttemptCount(
                                            exam.id),
                                    builder:
                                        (context, snap) {

                                      int attempts =
                                          snap.data ??
                                              0;

                                      return Text(
                                        "Attempts: $attempts",
                                        style:
                                            const TextStyle(
                                          fontSize: 12,
                                          color: Colors
                                              .grey,
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(
                                      height: 8),

                                  /// PROGRESS BAR
                                  LinearProgressIndicator(
                                    value: total == 0
                                        ? 0
                                        : answered /
                                            total,
                                    backgroundColor:
                                        Colors.grey
                                            .shade300,
                                    valueColor:
                                        AlwaysStoppedAnimation<
                                            Color>(
                                      progressColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                },
              );
            }),
          ),
        ],
      ),

      /// BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index.value,
        onTap: (i) {

          index.value = i;

          if (i == 0) {

            Get.offAll(
              () => HomePage(),
              arguments: {"tab": 0},
            );

          } else {

            Get.offAll(
              () => HomePage(),
              arguments: {"tab": 1},
            );
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
    ));

}
}
