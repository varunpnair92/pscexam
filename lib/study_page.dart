import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'study_controller.dart';

class StudyPage extends StatelessWidget {
  final StudyController controller = Get.put(StudyController());

  StudyPage({super.key});

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

            /// ================= QUESTION VIEW =================
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

                          /// ================= DESCRIPTION (SWIPE) =================
                          Obx(() {
                            final pages = controller.descriptionPages;

                            if (pages.isEmpty) {
                              return Center(child: Text("No Description"));
                            }

                            return Column(
                              children: [
                                Expanded(
                                  child: PageView.builder(
                                    itemCount: pages.length,
                                    onPageChanged: (i) =>
                                        controller.currentPage.value = i,
                                    itemBuilder: (_, i) {
                                      return Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Card(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(16),
                                              child: Text(
                                                pages[i],
                                                style:
                                                    TextStyle(fontSize: 16),
                                                textAlign:
                                                    TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                /// PAGE INFO
                                Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Obx(() {
                                    final isLast =
                                        controller.currentPage.value ==
                                            pages.length - 1;

                                    return isLast
                                        ? Column(
                                            children: [
                                              Text(
                                                "Finished ✅",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                  "You reached the end 🎉"),
                                            ],
                                          )
                                        : Text(
                                            "Page ${controller.currentPage.value + 1} / ${pages.length}",
                                          );
                                  }),
                                ),
                              ],
                            );
                          }),

                          /// ================= QUESTIONS =================
                          ListView.builder(
                            padding: EdgeInsets.all(12),
                            itemCount: controller.questions.length,
                            itemBuilder: (_, i) {
                              final q = controller.questions[i];

                              return Card(
                                margin:
                                    EdgeInsets.symmetric(vertical: 8),
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
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          /// ================= EXAM =================
                          Center(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.play_arrow),
                              label:
                                  Text("Start Practice Exam"),
                              onPressed: () {
                                Get.toNamed(
                                  "/studyExam",
                                  arguments:
                                      controller.questions.toList(),
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

            /// ================= HIERARCHY GRID =================
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
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1B8A4E),
                                Color(0xFF27AE60)
                              ],
                            ),
                          ),
                          child: Icon(Icons.book_rounded,
                              color: Colors.white),
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