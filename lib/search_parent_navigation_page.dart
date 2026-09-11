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
                                                  color: Colors.white.withOpacity(0.12),
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
                                                            .withOpacity(0.2),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: TextField(
          controller: ctrl.searchInputController,
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          onSubmitted: (val) => ctrl.search(val),
          decoration: InputDecoration(
            hintText: "Search keyword (e.g. rain, മലയാളം)...",
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon:
                const Icon(Icons.search_rounded, color: Colors.white, size: 22),
            suffixIcon: ctrl.currentKeyword.value.isNotEmpty ||
                    ctrl.searchInputController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => ctrl.clearSearch(),
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () =>
                        ctrl.search(ctrl.searchInputController.text),
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
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
          final isSelected = ctrl.currentKeyword.value.toLowerCase() == item.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              visualDensity: VisualDensity.compact,
              label: Text(
                item,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              backgroundColor: isSelected
                  ? AppTheme.primary.withOpacity(0.8)
                  : Colors.white.withOpacity(0.15),
              side: BorderSide(
                color: isSelected ? AppTheme.accent : Colors.white.withOpacity(0.2),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              color: Colors.white.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearched
                  ? "No navigation nodes found for \"${ctrl.currentKeyword.value}\""
                  : "Search Parent Navigation",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
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
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
