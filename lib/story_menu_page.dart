import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'story_menu_controller.dart';
import 'auth_controller.dart';
import 'ui_utils.dart';
import 'navigation_slide_view.dart';
import 'app_theme.dart';

class StoryMenuPage extends StatelessWidget {
  final StoryMenuController ctrl = Get.put(StoryMenuController());

  StoryMenuPage({super.key});

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
                title: ctrl.keys.isNotEmpty ? ctrl.keys.last : "Stories",
                onBack: ctrl.keys.length > 1 ? ctrl.goBack : null,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppTheme.textDark),
                    onPressed: ctrl.fetchTree,
                  ),
                ],
              ),

              // ─── SEARCH BAR ───
              AppTheme.buildPremiumSearchBar(
                controller: TextEditingController(text: ctrl.searchQuery.value)
                  ..selection = TextSelection.collapsed(offset: ctrl.searchQuery.value.length),
                onChanged: (val) => ctrl.searchQuery.value = val,
                hintText: "Search stories...",
                onClear: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  ctrl.clearSearch();
                },
              ),

              // ─── BREADCRUMB ───
              Obx(() => ctrl.keys.length > 1 
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_shared_rounded, size: 14, color: AppTheme.textMid),
                        const SizedBox(width: 8),
                        Expanded(child: Text(
                          ctrl.keys.join(" > "),
                          style: AppTheme.breadcrumbStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),

              // ─── CONTENT ───
              Expanded(
                child: Obx(() {
                  if (ctrl.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }

                  if (ctrl.isSlideView.value) {
                    return NavigationSlideView(
                      items: ctrl.displayedItems,
                      onNodeTap: ctrl.onTileTap,
                      getTitle: (item) => (item["name"] ?? "").toString(),
                      getImageUrl: (item) => (item["image_url"] ?? item["image"] ?? "").toString(),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ctrl.displayedItems.length,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (_, i) {
                      final item = ctrl.displayedItems[i];
                      final name = (item["name"] ?? "").toString();
                      final grad = AppTheme.premiumGradients[i % AppTheme.premiumGradients.length];
                      final icon = UIUtils.getIconForName(name);
                      
                      final auth = AuthController.instance;
                      final bool hasAccess = auth.canAccess(item);

                      return AppTheme.buildStaggeredAnimation(
                        index: i,
                        child: GestureDetector(
                          onTap: () => ctrl.onTileTap(item),
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
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
