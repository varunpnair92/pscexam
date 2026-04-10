import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'story_menu_controller.dart';
import 'auth_controller.dart';
import 'ui_utils.dart';
import 'navigation_slide_view.dart';

class StoryMenuPage extends StatelessWidget {
  final controller = Get.put(StoryMenuController());

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            controller.keys.isNotEmpty ? controller.keys.last : "Stories",
            style: const TextStyle(
              color: UIUtils.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: controller.stack.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: UIUtils.textDark, size: 20),
                  onPressed: controller.goBack,
                )
              : null,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded, color: UIUtils.textDark),
                onPressed: controller.fetchTree,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // ─── SEARCH BAR ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: "Search stories...",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: UIUtils.greenPrimary, size: 20),
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
            if (controller.stack.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.folder_shared_rounded, size: 14, color: UIUtils.textMid),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.keys.join(" / "),
                        style: const TextStyle(color: UIUtils.textMid, fontSize: 11, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // ─── GRID BODY ───
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator(color: UIUtils.greenPrimary))
                  : controller.displayedItems.isEmpty
                      ? const Center(child: Text("No stories found", style: TextStyle(color: Colors.grey)))
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
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.3,
                              ),
                              itemBuilder: (_, i) {
                                final item = controller.displayedItems[i];
                                final name = item["name"] ?? "";
                                final gradients = UIUtils.getPremiumGradients();
                                final grad = gradients[i % gradients.length];
                                final icon = UIUtils.getIconForName(name);

                                final bool hasAccess = auth.canAccess(item);

                                return GestureDetector(
                                  onTap: () {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    controller.onTileTap(item);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: grad,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: grad.first.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Stack(
                                      children: [
                                        Column(
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
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.bottomLeft,
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Opacity(
                                                    opacity: hasAccess ? 1.0 : 0.6,
                                                    child: Text(
                                                      name,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (!hasAccess)
                                          const Positioned.fill(
                                            child: Center(
                                              child: Icon(
                                                Icons.lock_rounded,
                                                color: Colors.white70,
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
