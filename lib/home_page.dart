import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/exam_list_page.dart';
import 'package:psc_exam/study_page.dart';

class HomePage extends StatelessWidget {
  final index = 0.obs;

  final pages = [
    ExamListPage(),
    StudyPage(), // 🔥 new study tab
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: pages[index.value],

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