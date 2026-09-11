import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'search_parent_navigation_controller.dart';
import 'app_theme.dart';
import 'ui_utils.dart';

class SearchParentNavigationPage extends StatelessWidget {
  const SearchParentNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchParentNavigationController controller =
        Get.put(SearchParentNavigationController());

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
                  _buildSearchBar(controller, context),
                  _buildRecentSearchChips(controller),
                  Expanded(
                    child: controller.isLoading.value
                        ? const Center(
                            child: CircularProgressIndicator(color: AppTheme.primary))
                        : controller.nodes.isEmpty
                            ? _buildEmptyState(controller)
                            : GridView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: controller.nodes.length,
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.2,
                                ),
                                itemBuilder: (_, i) {
                                  final node = controller.nodes[i];
                                  final grad = AppTheme.premiumGradients[
                                      i % AppTheme.premiumGradients.length];
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
                                                child: Icon(
                                                  icon,
                                                  color: Colors.white.withValues(alpha: 0.12),
                                                  size: 80,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withValues(alpha: 0.2),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        icon,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
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

  Widget _buildSearchBar(
      SearchParentNavigationController ctrl, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                onSubmitted: (val) => ctrl.search(val),
                decoration: InputDecoration(
                  hintText: "Search keyword (e.g. rain, മലയാളം)...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
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
                height: 52,
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

  Widget _buildRecentSearchChips(SearchParentNavigationController ctrl) {
    if (ctrl.searchHistory.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ctrl.searchHistory.length,
        itemBuilder: (context, index) {
          final item = ctrl.searchHistory[index];
          final isSelected =
              ctrl.currentKeyword.value.toLowerCase() == item.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              visualDensity: VisualDensity.compact,
              label: Text(
                item,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              backgroundColor: isSelected
                  ? AppTheme.primary
                  : Colors.white.withValues(alpha: 0.85),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.primary
                    : Colors.grey.shade300,
              ),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Widget _buildEmptyState(SearchParentNavigationController ctrl) {
    final bool hasSearched = ctrl.currentKeyword.value.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearched ? Icons.search_off_rounded : Icons.search_rounded,
              size: 72,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearched
                  ? "No navigation nodes found for \"${ctrl.currentKeyword.value}\""
                  : "Search Parent Navigation",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearched
                  ? "Try searching with a different keyword in English or മലയാളം"
                  : "Type a keyword in the search bar above to fetch topic nodes",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
