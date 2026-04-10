import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'study_controller.dart';
import 'modern_study_card.dart';
import 'auth_controller.dart';
import 'ui_utils.dart';
import 'app_theme.dart';

class StudyPage extends StatelessWidget {
  final StudyController controller = Get.put(StudyController());

  StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppTheme.background,
        body: Stack(
          children: [
            // ─── IMMERSIVE BACKGROUND ───
            AppTheme.buildImmersiveBackground(context),

            Column(
              children: [
                // ─── CUSTOM APP BAR ───
                AppTheme.buildPremiumAppBar(
                  title: controller.keys.isNotEmpty ? controller.keys.last : "Study",
                  onBack: controller.keys.length > 1 ? controller.goBack : null,
                ),

                Expanded(
                  child: controller.showQuestions.value
                      ? DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              // ─── Custom TabBar ───
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
                                    _buildDescriptionTab(controller, AppTheme.primary, AppTheme.background),
                                    _buildQuestionsTab(controller, AppTheme.primary),
                                    _buildExamTab(controller, AppTheme.primary, AppTheme.background),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : _buildHierarchyGrid(controller, AppTheme.primary, AppTheme.background),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionTab(StudyController controller, Color primary, Color lightBg) {
    return Obx(() {
      final pages = controller.descriptionPages;
      if (pages.isEmpty) {
        return const Center(child: Text("No Description Available", style: TextStyle(color: Colors.grey)));
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
                      color: Colors.white.withOpacity(0.8),
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

  Widget _buildQuestionsTab(StudyController controller, Color primary) {
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

  Widget _buildExamTab(StudyController controller, Color primary, Color lightBg) {
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
                  Get.toNamed("/studyExam", arguments: controller.questions.toList());
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

  Widget _buildHierarchyGrid(StudyController controller, Color primary, Color lightBg) {
    return Column(
      children: [
        // ─── SEARCH BAR ───
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: "Search topics...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: primary, size: 20),
                suffixIcon: controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          controller.clearSearch();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // ─── BREADCRUMB INDICATOR ───
        if (controller.keys.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.folder_shared_rounded, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.keys.join(" / "),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        // ─── GRID BODY ───
        Expanded(
          child: controller.items.isEmpty
              ? Center(child: CircularProgressIndicator(color: primary))
              : controller.displayedItems.isEmpty
                  ? const Center(child: Text("No topics found", style: TextStyle(color: Colors.grey)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: controller.displayedItems.length,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemBuilder: (_, i) {
                        final item = controller.displayedItems[i];
                        final name = (item["name"] ?? "").toString();
                        final gradients = UIUtils.getPremiumGradients();
                        final grad = gradients[i % gradients.length];
                        final icon = UIUtils.getIconForName(name);
                        final bool hasAccess = AuthController.instance.canAccess(item);

                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (i % 10) * 100),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, val, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - val)),
                              child: Opacity(opacity: val, child: child),
                            );
                          },
                          child: GestureDetector(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              controller.onTileTap(item);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: AppTheme.glassBox(gradient: grad),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      right: -10,
                                      top: -10,
                                      child: Icon(icon, color: Colors.white.withOpacity(0.12), size: 80),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(icon, color: Colors.white, size: 18),
                                          ),
                                          const Spacer(),
                                          Text(
                                            name,
                                            style: AppTheme.cardTitleStyle,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!hasAccess)
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.black.withOpacity(0.2),
                                          child: const Center(
                                            child: Icon(Icons.lock_rounded, color: Colors.white70, size: 28),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
