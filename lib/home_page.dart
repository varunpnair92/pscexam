import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/app_home_page.dart';
import 'package:psc_exam/exam_menu_page.dart';
import 'package:psc_exam/study_page.dart';
import 'package:psc_exam/profile_page.dart';

class HomePage extends StatelessWidget {
  final index = 0.obs;

  final List<Widget> pages = [
    AppHomePage(),
    ExamMenuPage(),
    StudyPage(),
    ProfilePage(),
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
          extendBody: true, 
          body: IndexedStack(
            index: index.value,
            children: pages,
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.only(left: 12, right: 12, bottom: 15), 
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BottomNavigationBar(
                currentIndex: index.value,
                onTap: (i) => index.value = i,
                backgroundColor: Colors.white,
                elevation: 0,
                iconSize: 22,
                selectedItemColor: const Color(0xFF1B8A4E),
                unselectedItemColor: Colors.grey.shade400,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, height: 1.5),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10, height: 1.5),
                items: [
                  _buildNavItem(Icons.home_rounded, 'Home', 0),
                  _buildNavItem(Icons.quiz_rounded, 'Exam', 1),
                  _buildNavItem(Icons.school_rounded, 'Study', 2),
                  _buildNavItem(Icons.person_rounded, 'Profile', 3),
                ],
              ),
            ),
          ),
        ));
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int i) {
    const primaryGreen = Color(0xFF1B8A4E);
    bool isActive = index.value == i;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? primaryGreen.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}