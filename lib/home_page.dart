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
          bottomNavigationBar: _buildTelegramNavBar(),
        ));
  }

  Widget _buildTelegramNavBar() {
    const primaryGreen = Color(0xFF1B8A4E);
    const bgGreen = Color(0xFFE8F5E9); // Very light green for the pill
    final List<Map<String, dynamic>> navItems = [
      {'label': 'Home', 'icon': Icons.home_outlined, 'activeIcon': Icons.home_rounded},
      {'label': 'Exam', 'icon': Icons.quiz_outlined, 'activeIcon': Icons.quiz_rounded},
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