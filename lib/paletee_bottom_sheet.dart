import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'test_controller.dart';

class PaletteBottomSheet extends StatelessWidget {
  final TestController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text("Exam Overview",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),

          SizedBox(height: 20),

          Expanded(
            child: Obx(() => GridView.builder(
                  itemCount: controller.questions.length,
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                  ),
                  itemBuilder: (_, i) {
                    return GestureDetector(
                      onTap: () {
                        controller.jumpTo(i);
                        Get.back();
                      },
                      child: Container(
                        margin: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: controller.getColor(i),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text("${i + 1}",
                              style:
                                  TextStyle(color: Colors.white)),
                        ),
                      ),
                    );
                  },
                )),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: () {
              Get.defaultDialog(
                title: "Submit Exam",
                middleText: "Are you sure you want to finish?",
                textCancel: "No",
                textConfirm: "Yes",
                onConfirm: () async {
                  Get.back();

                  // 🔥 SAFE TIMER CANCEL
                  controller.timer?.cancel();

                  await controller.submitResult();

                  // 🔥 FIX — pass examId
                  await controller.clearProgress(controller.examId);

                  Get.offAllNamed('/analysis');
                },
              );
            },
            child: Text("FINISH EXAM"),
          ),
        ],
      ),
    );
  }
}