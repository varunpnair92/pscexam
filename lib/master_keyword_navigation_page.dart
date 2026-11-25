import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'master_keyword_navigation_controller.dart';
import 'app_theme.dart';
import 'ui_utils.dart';

class MasterKeywordNavigationPage extends StatelessWidget {
  const MasterKeywordNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MasterKeywordNavigationController controller =
        Get.put(MasterKeywordNavigationController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          AppTheme.buildImmersiveBackground(context),
          Obx(
            () => Column(
              children: [
                // Custom App Bar
                AppTheme.buildPremiumAppBar(
                  title: controller.parentTitle.value,
                  onBack: () => controller.goBack(),
                  actions: [
                    if (controller.breadcrumbs.isNotEmpty ||
                        controller.currentKeyword.value.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.home_rounded, color: AppTheme.primary),
                        tooltip: "Reset to Roots",
                        onPressed: () => controller.resetToRoots(),
                      ),
                  ],
                ),

                // Search Bar & Recent Search Chips (Shown ONLY when NO keyword is configured on the node)
                if (!controller.hasNodeKeyword.value) ...[
                  _buildSearchBar(controller, context),
                  _buildRecentSearchChips(controller),
                ],

                // Breadcrumb Navigation
                if (controller.breadcrumbs.isNotEmpty)
                  _buildBreadcrumbs(controller),

                // Focused Node Study Action Banner
                if (controller.currentKeyword.value.isNotEmpty)
                  _buildFocusedNodeBanner(controller),

                // Main Content: Grid of subcategories or empty state
                Expanded(
                  child: controller.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(color: AppTheme.primary),
                        )
                      : controller.nodes.isEmpty
                          ? _buildEmptyState(controller)
                          : _buildNodesGrid(controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar(
      MasterKeywordNavigationController ctrl, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search_rounded,
                  color: AppTheme.primary, size: 22),
              onPressed: () {
                if (ctrl.searchInputController.text.trim().isNotEmpty) {
                  ctrl.search(ctrl.searchInputController.text);
                }
              },
            ),
            Expanded(
              child: TextField(
                controller: ctrl.searchInputController,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                onSubmitted: (val) => ctrl.search(val),
                decoration: InputDecoration(
                  hintText: "Search master keywords (e.g. കേരളം, പ്രാചീന കേരളം)...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (ctrl.currentKeyword.value.isNotEmpty ||
                ctrl.searchInputController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.close_rounded,
                    color: Colors.grey.shade600, size: 20),
                onPressed: () => ctrl.clearSearch(),
              ),
            InkWell(
              onTap: () {
                if (ctrl.searchInputController.text.trim().isNotEmpty) {
                  ctrl.search(ctrl.searchInputController.text);
                }
              },
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recent Search Chips
  Widget _buildRecentSearchChips(MasterKeywordNavigationController ctrl) {
    if (ctrl.searchHistory.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 34,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ctrl.searchHistory.length,
        itemBuilder: (context, index) {
          final item = ctrl.searchHistory[index];
          final isSelected =
              ctrl.currentKeyword.value.toLowerCase() == item.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ActionChip(
              visualDensity: VisualDensity.compact,
              label: Text(
                item,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              backgroundColor: isSelected
                  ? AppTheme.primary
                  : Colors.white.withValues(alpha: 0.85),
              side: BorderSide(
                color: isSelected ? AppTheme.primary : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onPressed: () {
                ctrl.searchInputController.text = item;
                ctrl.search(item);
              },
            ),
          );
        },
      ),
    );
  }

  // Breadcrumbs Trail
  Widget _buildBreadcrumbs(MasterKeywordNavigationController ctrl) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            ActionChip(
              visualDensity: VisualDensity.compact,
              avatar: const Icon(Icons.home_rounded, size: 14, color: AppTheme.primary),
              label: const Text("Root", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onPressed: () => ctrl.navigateToBreadcrumb(-1),
            ),
            for (int i = 0; i < ctrl.breadcrumbs.length; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.shade500),
              ),
              ActionChip(
                visualDensity: VisualDensity.compact,
                label: Text(
                  ctrl.breadcrumbs[i]['keyword'].toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: (i == ctrl.breadcrumbs.length - 1)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: (i == ctrl.breadcrumbs.length - 1)
                        ? Colors.white
                        : const Color(0xFF1E293B),
                  ),
                ),
                backgroundColor: (i == ctrl.breadcrumbs.length - 1)
                    ? AppTheme.primary
                    : Colors.white,
                side: BorderSide(
                  color: (i == ctrl.breadcrumbs.length - 1)
                      ? AppTheme.primary
                      : Colors.grey.shade300,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onPressed: () => ctrl.navigateToBreadcrumb(i),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Focused Node Study Action Banner (Allows studying the current topic directly)
  Widget _buildFocusedNodeBanner(MasterKeywordNavigationController ctrl) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_tree_rounded, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ctrl.currentKeyword.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  ctrl.currentChildrenCount.value > 0
                      ? "${ctrl.currentChildrenCount.value} Sub-topic(s)"
                      : "Leaf topic (No sub-categories)",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.menu_book_rounded, size: 14),
            label: const Text("Study", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () => ctrl.openStudy(
              ctrl.currentKeyword.value,
              id: ctrl.currentKeywordId.value,
            ),
          ),
        ],
      ),
    );
  }

  // Nodes Grid (Displays children or search results)
  Widget _buildNodesGrid(MasterKeywordNavigationController ctrl) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: ctrl.nodes.length,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (_, i) {
        final node = ctrl.nodes[i];
        final grad = AppTheme.premiumGradients[i % AppTheme.premiumGradients.length];
        final icon = UIUtils.getIconForName(node.keyword);

        return AppTheme.buildStaggeredAnimation(
          index: i,
          child: GestureDetector(
            onTap: () => ctrl.onNodeTap(node),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: AppTheme.glassBox(gradient: grad),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Icon(
                        icon,
                        color: Colors.white.withValues(alpha: 0.12),
                        size: 76,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  node.hasChildren
                                      ? Icons.folder_rounded
                                      : icon,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  node.hasChildren
                                      ? "${node.childrenCount}"
                                      : "Study",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            node.keyword,
                            style: AppTheme.cardTitleStyle.copyWith(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            node.hasChildren
                                ? "Sub-categories"
                                : "Questions & Notes",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                            ),
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
    );
  }

  // Empty State
  Widget _buildEmptyState(MasterKeywordNavigationController ctrl) {
    final bool hasKeyword = ctrl.currentKeyword.value.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasKeyword ? Icons.menu_book_rounded : Icons.search_rounded,
              size: 64,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              hasKeyword
                  ? ctrl.currentKeyword.value
                  : "Search Master Keywords",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasKeyword
                  ? "This topic has no further sub-categories. You can study all its questions and descriptions directly."
                  : "Search for topics like 'കേരളം', 'പ്രാചീന കേരളം' to explore master hierarchy",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
              ),
            ),
            if (hasKeyword) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: const Text("Open Study Mode", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => ctrl.openStudy(
                  ctrl.currentKeyword.value,
                  id: ctrl.currentKeywordId.value,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
