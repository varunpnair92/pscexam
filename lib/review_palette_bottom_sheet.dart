import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'test_controller.dart';

class ReviewPaletteBottomSheet extends StatelessWidget {
  final PageController pageController;
  final TestController controller = Get.find<TestController>();

  ReviewPaletteBottomSheet({required this.pageController, super.key});

  /// 🔹 FILTER LOGIC
  List<int> getAttended() {
    List<int> list = [];
    for (int i = 0; i < controller.snapshot.length; i++) {
      var q = controller.snapshot[i.toString()];
      String selected = (q?['selected'] ?? "").toString().trim();
      if (selected.isNotEmpty) list.add(i);
    }
    return list;
  }

  List<int> getUnattended() {
    List<int> list = [];
    for (int i = 0; i < controller.snapshot.length; i++) {
      var q = controller.snapshot[i.toString()];
      String selected = (q?['selected'] ?? "").toString().trim();
      if (selected.isEmpty) list.add(i);
    }
    return list;
  }

  List<int> getCorrect() {
    List<int> list = [];
    for (int i = 0; i < controller.snapshot.length; i++) {
      var q = controller.snapshot[i.toString()];
      String selected = (q?['selected'] ?? "").toString().trim();
      String correct = (q?['correct'] ?? "").toString().trim();
      if (selected.isNotEmpty && selected == correct) list.add(i);
    }
    return list;
  }

  List<int> getWrong() {
    List<int> list = [];
    for (int i = 0; i < controller.snapshot.length; i++) {
      var q = controller.snapshot[i.toString()];
      String selected = (q?['selected'] ?? "").toString().trim();
      String correct = (q?['correct'] ?? "").toString().trim();
      if (selected.isNotEmpty && selected != correct) list.add(i);
    }
    return list;
  }

  Color _getColorForIndex(int index) {
      var q = controller.snapshot[index.toString()];
      String selected = (q?['selected'] ?? "").toString().trim();
      String correct = (q?['correct'] ?? "").toString().trim();
      
      if (selected.isEmpty) return Colors.grey.shade400;
      if (selected == correct) return Colors.green.shade500;
      return Colors.red.shade500;
  }

  Widget buildGrid(List<int> list) {
    if (list.isEmpty) {
      return const Center(child: Text("No questions in this category.", style: TextStyle(color: Colors.grey)));
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        int qIndex = list[i];
        return GestureDetector(
          onTap: () {
            controller.current.value = qIndex;
            pageController.jumpToPage(qIndex);
            Get.back();
          },
          child: Container(
            decoration: BoxDecoration(
              color: _getColorForIndex(qIndex),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
              ]
            ),
            child: Center(
              child: Text(
                "${qIndex + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Container(
        height: 500,
        padding: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))
        ),
        child: Column(
          children: [
            // Grabber
            Center(
              child: Container(
                width: 45,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            const Text(
              "Question Palette",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),

            const SizedBox(height: 12),

            TabBar(
              labelColor: Colors.blue.shade700,
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: Colors.blue.shade600,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              tabs: const [
                Tab(text: "Attended"),
                Tab(text: "Unattended"),
                Tab(text: "Correct"),
                Tab(text: "Wrong"),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  buildGrid(getAttended()),
                  buildGrid(getUnattended()),
                  buildGrid(getCorrect()),
                  buildGrid(getWrong()),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
