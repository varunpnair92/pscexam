import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'parent_navigation_controller.dart';
import 'app_theme.dart';
import 'ui_utils.dart';
import 'auth_controller.dart';

class ParentNavigationPage extends StatelessWidget {
  const ParentNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ParentNavigationController controller = Get.put(ParentNavigationController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          AppTheme.buildImmersiveBackground(context),
          Obx(() => Column(
            children: [
              AppTheme.buildPremiumAppBar(
                title: controller.parentTitle.value,
                onBack: () => Get.back(),
              ),
              Expanded(
                child: controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: controller.nodes.length,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemBuilder: (_, i) {
                          final node = controller.nodes[i];
                          final grad = AppTheme.premiumGradients[i % AppTheme.premiumGradients.length];
                          final icon = UIUtils.getIconForName(node.name);

                          return AppTheme.buildStaggeredAnimation(
                            index: i,
                            child: GestureDetector(
                              onTap: () => controller.onNodeTap(node),
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
                                              node.name,
                                              style: AppTheme.cardTitleStyle,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
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
          )),
        ],
      ),
    );
  }
}
