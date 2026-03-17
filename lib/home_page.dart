import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/app_home_page.dart';
import 'package:psc_exam/exam_menu_page.dart';
import 'package:psc_exam/study_page.dart';

class HomePage extends StatelessWidget {
  final index = 0.obs;

  final pages = [
    AppHomePage(),
    ExamMenuPage(),
    StudyPage(),
  ];

  HomePage({super.key}) {
    final args = Get.arguments;
    if (args != null && args['tab'] != null) {
      index.value = args['tab'] as int;
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
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF1B8A4E),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_rounded),
                label: 'Exam',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school_rounded),
                label: 'Study',
              ),
            ],
          ),
        ));
  }
}