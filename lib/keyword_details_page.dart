import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'keyword_details_controller.dart';

class KeywordDetailsPage extends StatelessWidget {
  final KeywordDetailsController ctrl = Get.put(KeywordDetailsController());

  // ─── Green + White Palette ────────────────────────────────────
  static const _bg = Color(0xFFF4FBF4);
  static const _green1 = Color(0xFF1B8A4E);
  static const _textDark = Color(0xFF0D3320);
  static const _green2 = Color(0xFF27AE60);

  KeywordDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
          onPressed: ctrl.handleBack,
        ),
        title: Obx(() => Text(
          ctrl.currentKeyword.value.isNotEmpty ? ctrl.currentKeyword.value : "Search Details",
          style: const TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 18),
        )),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: _green1));
              }

              if (ctrl.keywordData.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text("No details found", style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
                    ],
                  ),
                );
              }

              final data = ctrl.keywordData;
              final String keyword = data["keyword"] ?? "";
              final String manglish = data["keywordmanglish"] ?? "";
              final List characteristics = data["characteristics"] ?? [];
              final List allQuestions = data["all_mapped_questions"] ?? [];

              return ListView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Keyword Heading
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_green1, _green2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _green1.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          keyword,
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        if (manglish.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            manglish,
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontStyle: FontStyle.italic),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    "Characteristics",
                    style: TextStyle(color: _textDark, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  if (characteristics.isEmpty)
                    Text("No characteristics available.", style: TextStyle(color: Colors.grey.shade500)),

                  ...characteristics.map((c) {
                    final String charName = c["characteristic_name"] ?? "";
                    
                    // 1. Try to find matching questions in all_mapped_questions based on the characteristic name
                    final List<String> answers = [];
                    if (charName.isNotEmpty) {
                      for (var q in allQuestions) {
                        final qText = (q["question"] ?? "").toString();
                        // Also remove any trailing question marks for better matching
                        final searchName = charName.replaceAll('?', '').trim();
                        if (searchName.isNotEmpty && qText.contains(searchName)) {
                          final ans = (q["answer"] ?? "").toString().trim();
                          if (ans.isNotEmpty && !answers.contains(ans)) {
                            answers.add(ans);
                          }
                        }
                      }
                    }

                    // 2. Fallback to the API's nested questions array if we didn't find any match
                    if (answers.isEmpty) {
                      final List nestedQuestions = c["questions"] ?? [];
                      for (var q in nestedQuestions) {
                        if (q["answer"] != null && q["answer"].toString().trim().isNotEmpty) {
                          final ans = q["answer"].toString().trim();
                          if (!answers.contains(ans)) {
                            answers.add(ans);
                          }
                        }
                      }
                    }
                    
                    if (answers.isEmpty) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(Icons.label_important_rounded, color: _green1, size: 22),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    charName,
                                    style: const TextStyle(
                                      color: _textDark, 
                                      fontSize: 17, 
                                      fontWeight: FontWeight.bold,
                                      height: 1.3
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1, thickness: 1, color: _bg),
                            ),
                            ...answers.map((ans) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _green2.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _green2.withOpacity(0.15)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2, right: 10),
                                      child: Icon(Icons.check_circle_rounded, color: _green2, size: 18),
                                    ),
                                    Expanded(
                                      child: Text(
                                        ans,
                                        style: const TextStyle(
                                          color: _green1,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )).toList(),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    final TextEditingController textCtrl = TextEditingController();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _green1.withOpacity(0.12), width: 1.5),
        ),
        child: TextField(
          controller: textCtrl,
          textInputAction: TextInputAction.search,
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              ctrl.onSearchSubmit(val.trim());
              textCtrl.clear();
            }
          },
          decoration: InputDecoration(
            hintText: "Search keywords...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: _green1, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
