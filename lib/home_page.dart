import 'dart:ui';
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
          extendBody: true, // Let the content scroll behind the floating glass bar
          body: IndexedStack(
            index: index.value,
            children: pages,
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20), // Floating margins
            height: 70, // Slightly taller for premium feel
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B8A4E).withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: BottomNavigationBar(
                  currentIndex: index.value,
                  onTap: (i) => index.value = i,
                  backgroundColor: Colors.transparent, // Let glass shine through
                  elevation: 0,
                  iconSize: 26,
                  selectedItemColor: const Color(0xFF1B8A4E),
                  unselectedItemColor: Colors.grey.shade400,
                  type: BottomNavigationBarType.fixed,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Icon(Icons.home_rounded, size: 26),
                      ),
                      activeIcon: Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Icon(Icons.home_rounded, size: 28),
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Icon(Icons.quiz_rounded, size: 26),
                      ),
                      activeIcon: Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Icon(Icons.quiz_rounded, size: 28),
                      ),
                      label: 'Exam',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Icon(Icons.school_rounded, size: 26),
                      ),
                      activeIcon: Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Icon(Icons.school_rounded, size: 28),
                      ),
                      label: 'Study',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}