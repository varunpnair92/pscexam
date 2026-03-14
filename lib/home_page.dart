import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/exam_menu_page.dart';
import 'package:psc_exam/study_page.dart';

class HomePage extends StatelessWidget {
  final index = 0.obs;

  final pages = [
    ExamMenuPage(),
    StudyPage(),
  ];

  HomePage({super.key}) {
    final args = Get.arguments;
    if (args != null && args["tab"] != null) {
      index.value = args["tab"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: IndexedStack(
            index: index.value,
            children: pages,
          ),

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index.value,
            onTap: (i) => index.value = i,
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