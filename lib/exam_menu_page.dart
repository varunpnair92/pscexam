import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exam_menu_controller.dart';

class ExamMenuPage extends StatelessWidget {

  final controller = Get.put(ExamMenuController());

  @override
  Widget build(BuildContext context) {

    return Obx(
      () => Scaffold(

        appBar: AppBar(
          title: Text(controller.keys.join(" > ")),

          leading: controller.keys.length > 1
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: controller.goBack,
                )
              : null,
        ),

        body: controller.items.isEmpty
            ? Center(child: CircularProgressIndicator())

            : GridView.builder(
                padding: EdgeInsets.all(16),

                itemCount: controller.items.length,

                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),

                itemBuilder: (_, i) {

                  final item = controller.items[i];

                  final name = item["name"] ?? "";

                  return GestureDetector(

                    onTap: () => controller.onTileTap(item),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [const Color(0xFF1B8A4E), const Color(0xFF27AE60)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.quiz_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}