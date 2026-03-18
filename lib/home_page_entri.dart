import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/test_controller.dart';

class EntriHomePage extends StatelessWidget {
  final TestController testController = Get.put(TestController());

  EntriHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 check resume
    testController.checkResume();

    return Scaffold(
      appBar: AppBar(
        title: const Text("PSC Kerala"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 RESUME CARD
            Obx(() {
              if (!testController.hasResume.value) {
                return const SizedBox();
              }

              int answered = testController.resumeAnswered.value;
              int total = testController.resumeTotal.value;
              int seconds = testController.resumeTimeLeft.value;

              int min = seconds ~/ 60;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  int id = testController.resumeExamId.value;

                  await testController.loadProgress(id);

                  Get.toNamed('/exam', arguments: {"id": id});
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade200],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Row(
                    children: [
                      const Icon(Icons.play_circle,
                          size: 40, color: Colors.white),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Continue Exam",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "$answered/$total answered • $min min left",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),

                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              );
            }),

            /// 🔥 QUICK ACCESS
            const Text(
              "Quick Access",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _menu(Icons.quiz, "Mock", "/examMenu"),
                _menu(Icons.menu_book, "Study", "/study"),
                _menu(Icons.flash_on, "Daily", "/daily"),
                _menu(Icons.bar_chart, "Result", "/result"),
                _menu(Icons.show_chart, "Progress", "/progress"),
                _menu(Icons.star, "Special", "/special"),
              ],
            ),

            const SizedBox(height: 20),

            /// 📚 COURSES
            const Text(
              "Courses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _courseCard("LDC"),
                  _courseCard("Degree Level"),
                  _courseCard("10th Level"),
                  _courseCard("Plus Two"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📊 PERFORMANCE
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.analytics, color: Colors.green),
                title: const Text("Your Performance"),
                subtitle: const Text("Track your accuracy and progress"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.toNamed('/progress');
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 🔥 MENU BUTTON
  Widget _menu(IconData icon, String title, String route) {
    return InkWell(
      onTap: () => Get.toNamed(route),
      borderRadius: BorderRadius.circular(12),

      child: Container(
        margin: const EdgeInsets.all(6),

        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 COURSE CARD
  Widget _courseCard(String title) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade200],
        ),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}