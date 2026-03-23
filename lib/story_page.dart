import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'story_controller.dart';

class StoryPage extends StatelessWidget {
  final StoryController controller = Get.put(StoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Typical for stories
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final items = controller.items;
        if (items.isEmpty) {
          return Center(child: Text("No story available", style: TextStyle(color: Colors.white)));
        }

        final currentItem = items[controller.currentIndex.value];

        return SafeArea(
          child: Stack(
            children: [
              // Content Area
              Positioned.fill(
                child: _buildContent(currentItem),
              ),

              // Top Progress Bars
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: List.generate(items.length, (index) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= controller.currentIndex.value
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Title Header
              Positioned(
                top: 30,
                left: 6,
                right: 16,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        controller.title.value,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Click Areas
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTapDown: (_) => controller.previousStory(),
                        behavior: HitTestBehavior.translucent,
                        child: Container(),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTapDown: (_) => controller.nextStory(),
                        behavior: HitTestBehavior.translucent,
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildContent(StoryItemData item) {
    if (item.type == 'description') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Center(
          child: SingleChildScrollView(
            child: Text(
              item.data.toString(),
              style: TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else if (item.type == 'question') {
      final qMap = item.data;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                qMap["question"] ?? "No question text",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF27AE60),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                qMap["answer"] ?? "No answer text",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    } else if (item.type == 'exam') {
      return Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF27AE60),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          icon: Icon(Icons.play_arrow, size: 28, color: Colors.white),
          label: Text(
            "Start Practice Exam", 
            style: TextStyle(fontSize: 18, color: Colors.white)
          ),
          onPressed: () => controller.startExam(),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
