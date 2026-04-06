import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/app_home_page.dart';
import 'package:psc_exam/exam_menu_page.dart';
import 'package:psc_exam/study_page.dart';
import 'package:psc_exam/profile_page.dart';
import 'package:psc_exam/story_menu_page.dart';
import 'package:psc_exam/auth_controller.dart';
import 'package:psc_exam/home_controller.dart';
import 'package:psc_exam/exam_menu_controller.dart';
import 'package:psc_exam/story_menu_controller.dart';
import 'package:psc_exam/study_controller.dart';

class HomePage extends StatelessWidget {
  final index = 0.obs;
  // 🎯 Track last loaded course for each tab to prevent redundant reloads
  final Map<int, int> _lastLoadedCourseForTab = {};

  final List<Widget> pages = [
    AppHomePage(),
    ExamMenuPage(),
    StoryMenuPage(),
    StudyPage(),
    ProfilePage(),
  ];

  HomePage({super.key}) {
    final args = Get.arguments;
    if (args != null && args['tab'] != null) {
      index.value = args['tab'] as int;
    }

    // 🔄 REFRESH CONTENT ON TAB SWITCH (Makes it feel "Live")
    ever(index, (_) {
      _refreshActiveTab();
    });

    // 🔄 RE-FETCH ON USER PRIVILEGE CHANGE
    ever(AuthController.instance.userType, (_) {
      _lastLoadedCourseForTab.clear();
      _refreshActiveTab(force: true);
    });

    // 🎯 RE-FETCH ON COURSE CHANGE
    ever(AuthController.instance.selectedCourseId, (_) {
      _lastLoadedCourseForTab.clear();
      _refreshActiveTab(force: true);
    });
  }

  void _refreshActiveTab({bool force = false}) {
    final int currentCourseId = AuthController.instance.selectedCourseId.value;

    // 🛑 If not forced, skip refresh if we already loaded this course for this tab
    if (!force && _lastLoadedCourseForTab[index.value] == currentCourseId) {
      return;
    }

    // 🔄 Mark as loaded for this course
    _lastLoadedCourseForTab[index.value] = currentCourseId;

    switch (index.value) {
      case 0:
        if (Get.isRegistered<HomeController>()) Get.find<HomeController>().fetchHomeData();
        break;
      case 1:
        if (Get.isRegistered<ExamMenuController>()) Get.find<ExamMenuController>().fetchTree();
        break;
      case 2:
        if (Get.isRegistered<StoryMenuController>()) Get.find<StoryMenuController>().fetchTree();
        break;
      case 3:
        if (Get.isRegistered<StudyController>()) Get.find<StudyController>().fetchTree();
        break;
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
          bottomNavigationBar: _buildTelegramNavBar(),
        ));
  }

  Widget _buildTelegramNavBar() {
    const primaryGreen = Color(0xFF1B8A4E);
    const bgGreen = Color(0xFFE8F5E9); // Very light green for the pill
    final List<Map<String, dynamic>> navItems = [
      {'label': 'Home', 'icon': Icons.home_outlined, 'activeIcon': Icons.home_rounded},
      {'label': 'Exam', 'icon': Icons.quiz_outlined, 'activeIcon': Icons.quiz_rounded},
      {'label': 'Story', 'icon': Icons.auto_stories_outlined, 'activeIcon': Icons.auto_stories_rounded},
      {'label': 'Study', 'icon': Icons.school_outlined, 'activeIcon': Icons.school_rounded},
      {'label': 'Profile', 'icon': Icons.person_outline_rounded, 'activeIcon': Icons.person_rounded},
    ];

    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 15),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35), // Pure pill/oval shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double itemWidth = constraints.maxWidth / navItems.length;
          
          return Stack(
            children: [
              // 🧪 The Sliding Pill Background
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                left: (index.value * itemWidth) + (itemWidth * 0.15),
                top: 8,
                child: Container(
                  width: itemWidth * 0.7,
                  height: 38, // Pill height
                  decoration: BoxDecoration(
                    color: bgGreen,
                    borderRadius: BorderRadius.circular(19),
                  ),
                ),
              ),
              
              // 🏷️ The Icons and Labels
              Row(
                children: List.generate(navItems.length, (i) {
                  bool isActive = index.value == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => index.value = i,
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            scale: isActive ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isActive ? navItems[i]['activeIcon'] : navItems[i]['icon'],
                              color: isActive ? primaryGreen : Colors.grey.shade500,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            navItems[i]['label'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                              color: isActive ? primaryGreen : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}