import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dynamic_menu_controller.dart';
import 'ui_utils.dart';
import 'auth_controller.dart';
import 'app_theme.dart'; // 🔥 Unified Theme
import 'navigation_slide_view.dart';

class DynamicMenuPage extends StatelessWidget {
  final DynamicMenuController ctrl = Get.put(DynamicMenuController());

  DynamicMenuPage({super.key});

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
                title: ctrl.keys.isNotEmpty ? ctrl.keys.last : "Browse",
                onBack: ctrl.goBack,
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
                  if (ctrl.isSlideView.value) {
                    return NavigationSlideView(
                      items: ctrl.items,
                      onNodeTap: ctrl.onTileTap,
                      getTitle: (item) => ctrl.getTitle(item),
                      getImageUrl: (item) => (item["image_url"] ?? item["image"] ?? "").toString(),
                    );
                  }

                  if (ctrl.items.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ctrl.items.length,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (_, i) {
                      final item = ctrl.items[i];
                      final title = ctrl.getTitle(item);
                      final grad = AppTheme.premiumGradients[i % AppTheme.premiumGradients.length];
                      final icon = UIUtils.getIconForName(title);
                      
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
                                          title,
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