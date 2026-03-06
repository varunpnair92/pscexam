import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'study_controller.dart';

class StudyPage extends StatelessWidget {

  final StudyController controller = Get.put(StudyController());

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

        body: controller.showQuestions.value

            /// QUESTION VIEW
            ? DefaultTabController(
                length: 3,
                child: Column(
                  children: [

                    TabBar(
                      labelColor: Colors.blue,
                      tabs: [
                        Tab(text: "Description"),
                        Tab(text: "Questions"),
                        Tab(text: "Exam"),
                      ],
                    ),

                    Expanded(
                      child: TabBarView(
                        children: [

                          /// DESCRIPTION
                          Obx(
                            () => SingleChildScrollView(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                controller.description.value,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),

                          /// QUESTIONS
                          ListView.builder(
                            padding: EdgeInsets.all(12),
                            itemCount: controller.questions.length,
                            itemBuilder: (_, i) {

                              final q = controller.questions[i];

                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                elevation: 3,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        q["question"] ?? "",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      SizedBox(height: 10),

                                      Divider(),

                                      Text(
                                        q["answer"] ?? "",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          /// EXAM
                          Center(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.play_arrow),
                              label: Text("Start Practice Exam"),
                              onPressed: () {

                                Get.toNamed(
                                  "/studyExam",
                                  arguments: controller.questions.toList(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )

            /// HIERARCHY GRID
            : GridView.builder(
                padding: EdgeInsets.all(16),
                itemCount: controller.items.length,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, i) {

                  final item = controller.items[i];

                  final name = item["name"] ?? "";

                  return GestureDetector(

                    onTap: () => controller.onTileTap(item),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            name.isNotEmpty
                                ? name[0].toUpperCase()
                                : "",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
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