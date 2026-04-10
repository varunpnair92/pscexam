import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exam_menu_controller.dart';
import 'auth_controller.dart';
import 'ui_utils.dart';
import 'navigation_slide_view.dart';
import 'app_theme.dart'; // 🔥 Unified Theme

class ExamMenuPage extends StatelessWidget {
  final ExamMenuController controller = Get.put(ExamMenuController());

  ExamMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;

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
                  title: controller.keys.isNotEmpty ? controller.keys.last : "Exams",
                  onBack: controller.keys.length > 1 ? controller.goBack : null,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppTheme.textDark),
                      onPressed: controller.fetchTree,
                    ),
                  ],
                ),

                // ─── SEARCH BAR ───
                AppTheme.buildPremiumSearchBar(
                  controller: TextEditingController(text: controller.searchQuery.value)
                    ..selection = TextSelection.collapsed(offset: controller.searchQuery.value.length),
                  onChanged: (val) => controller.searchQuery.value = val,
                  hintText: "Search categories...",
                  onClear: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    controller.clearSearch();
                  },
                ),

                // ─── BREADCRUMB ───
                if (controller.keys.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_shared_rounded, size: 14, color: AppTheme.textMid),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.keys.join(" / "),
                            style: AppTheme.breadcrumbStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ─── CONTENT ───
                Expanded(
                  child: controller.items.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                      : controller.displayedItems.isEmpty
                          ? const Center(child: Text("No matches found", style: TextStyle(color: Colors.grey)))
                          : controller.isSlideView.value
                              ? NavigationSlideView(
                                  items: controller.displayedItems,
                                  onNodeTap: (item) {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    controller.onTileTap(item);
                                  },
                                  getTitle: (item) => (item["name"] ?? "").toString(),
                                  getImageUrl: (item) => (item["image"] ?? item["image_url"] ?? "").toString(),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(16),
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
                                    final grad = AppTheme.premiumGradients[i % AppTheme.premiumGradients.length];
                                    final icon = UIUtils.getIconForName(name);
                                    final bool hasAccess = auth.canAccess(item);

                                    return AppTheme.buildStaggeredAnimation(
                                      index: i,
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
            ),
          ],
        ),
      ),
    );
  }
}