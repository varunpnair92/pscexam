import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'study_search_controller.dart';
import 'modern_study_card.dart';
import 'app_theme.dart';

class StudySearchPage extends StatelessWidget {
  final StudySearchController ctrl = Get.put(StudySearchController());
  final TextEditingController textCtrl = TextEditingController();

  StudySearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ─── IMMERSIVE BACKGROUND ───
          AppTheme.buildImmersiveBackground(context),

          Column(
            children: [
              // ─── CUSTOM APP BAR ───
              AppTheme.buildPremiumAppBar(
                title: "Study Search",
                onBack: ctrl.handleBack,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.hub_rounded, color: AppTheme.primary),
                    tooltip: "Open Graph View",
                    onPressed: () {
                      final kw = ctrl.currentKeyword.value;
                      Get.toNamed('/graphView', arguments: kw.isNotEmpty ? {"keyword": kw} : null);
                    },
                  )
                ],
              ),

              // ─── SEARCH INPUT BAR (MALAYALAM & ENGLISH) ───
              _buildSearchBar(context),

              // ─── RECENT SEARCH CHIPS ───
              _buildRecentSearchChips(),

              // ─── MAIN CONTENT BODY ───
              Expanded(
                child: Obx(() {
                  if (ctrl.isLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppTheme.primary),
                          const SizedBox(height: 16),
                          Text(
                            "Searching study materials for \"${ctrl.currentKeyword.value}\"...",
                            style: const TextStyle(color: AppTheme.textMid, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!ctrl.isSearched.value) {
                    return _buildInitialSearchState();
                  }

                  if (ctrl.questions.isEmpty && ctrl.descriptionPages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            "No study materials found for \"${ctrl.currentKeyword.value}\"",
                            style: const TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Try searching with another keyword in English or മലയാളം",
                            style: TextStyle(color: AppTheme.textMid, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }

                  // ─── 3-TAB STUDY VIEW (SAME AS STUDYFULL PAGE) ───
                  return DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        // Custom TabBar
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: TabBar(
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppTheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: AppTheme.textMid,
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            tabs: const [
                              Tab(text: "Description"),
                              Tab(text: "Questions"),
                              Tab(text: "Exam"),
                            ],
                          ),
                        ),

                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildDescriptionTab(ctrl, AppTheme.primary),
                              _buildQuestionsTab(ctrl, AppTheme.primary),
                              _buildExamTab(ctrl, AppTheme.primary, AppTheme.background),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Search bar supporting Malayalam and English keyboard entry
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: textCtrl,
          textInputAction: TextInputAction.search,
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              FocusManager.instance.primaryFocus?.unfocus();
              ctrl.performSearch(val);
            }
          },
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Search topic in English or മലയാളം...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: textCtrl,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                      onPressed: () {
                        textCtrl.clear();
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: AppTheme.primary, size: 20),
                  onPressed: () {
                    if (textCtrl.text.trim().isNotEmpty) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      ctrl.performSearch(textCtrl.text);
                    }
                  },
                ),
              ],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  /// Recent search chips
  Widget _buildRecentSearchChips() {
    return Obx(() {
      if (ctrl.searchHistory.isEmpty) return const SizedBox.shrink();

      return Container(
        height: 36,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: ctrl.searchHistory.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final item = ctrl.searchHistory[index];
            final bool isSelected = ctrl.currentKeyword.value == item;

            return GestureDetector(
              onTap: () {
                textCtrl.text = item;
                FocusManager.instance.primaryFocus?.unfocus();
                ctrl.performSearch(item);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 13,
                      color: isSelected ? Colors.white : AppTheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textDark,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  /// Initial state when no query has been searched yet
  Widget _buildInitialSearchState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.manage_search_rounded, size: 64, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              "Search Any Study Topic",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Type a keyword in English or മലയാളം (e.g., Kerala, PSC, തിരുവിതാംകൂർ) to load complete study materials, descriptions, questions, and practice exams.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Description Tab (Identical to studyFull Page)
  Widget _buildDescriptionTab(StudySearchController controller, Color primary) {
    return Obx(() {
      final pages = controller.descriptionPages;
      if (pages.isEmpty) {
        return const Center(
          child: Text("No Description Available", style: TextStyle(color: Colors.grey)),
        );
      }

      return Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: pages.length,
              onPageChanged: (i) => controller.currentPage.value = i,
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        pages[i],
                        style: const TextStyle(
                          fontSize: 17,
                          color: AppTheme.textDark,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Page Indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: controller.currentPage.value == index ? 24 : 6,
                      decoration: BoxDecoration(
                        color: controller.currentPage.value == index ? primary : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ));
              }),
            ),
          ),
        ],
      );
    });
  }

  /// Questions Tab (Identical to studyFull Page)
  Widget _buildQuestionsTab(StudySearchController controller, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            children: [
              const Text(
                "Question Feed",
                style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Text(
                "${controller.questions.length} Items",
                style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.questions.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, i) {
              final q = controller.questions[i];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (i * 50).clamp(0, 400)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: ModernStudyCard(q: q, index: i),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Exam Tab (Identical to studyFull Page)
  Widget _buildExamTab(StudySearchController controller, Color primary, Color lightBg) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: lightBg,
              shape: BoxShape.circle,
              border: Border.all(color: primary.withOpacity(0.1), width: 2),
            ),
            child: Icon(Icons.rocket_launch_rounded, size: 64, color: primary),
          ),
          const SizedBox(height: 32),
          const Text(
            "Ready for a Challenge?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D3320)),
          ),
          const SizedBox(height: 12),
          Text(
            "Test your knowledge with a practice session based on these ${controller.questions.length} questions.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.questions.isNotEmpty) {
                    Get.toNamed("/studyExam", arguments: controller.questions.toList());
                  } else {
                    Get.snackbar("Notice", "No questions available for practice exam");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Start Practice Mode", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.rocket_launch_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Practice makes perfect! 🎯",
            style: TextStyle(color: primary.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
