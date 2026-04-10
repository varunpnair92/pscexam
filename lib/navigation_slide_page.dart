import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'navigation_slide_controller.dart';
import 'ui_utils.dart';

class NavigationSlidePage extends StatefulWidget {
  const NavigationSlidePage({super.key});

  @override
  State<NavigationSlidePage> createState() => _NavigationSlidePageState();
}

class _NavigationSlidePageState extends State<NavigationSlidePage> {
  late NavigationSlideController controller;
  late PageController pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    controller = Get.put(NavigationSlideController());
    pageController = PageController(viewportFraction: 0.8);
    pageController.addListener(() {
      setState(() {
        _currentPage = pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = Get.arguments?['title'] ?? "Browse";

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1B8A4E)));
        }

        if (controller.items.isEmpty) {
          return const Center(child: Text("No items found", style: TextStyle(color: Colors.white70)));
        }

        return Column(
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: controller.items.length,
                onPageChanged: (idx) => controller.currentPage.value = idx,
                itemBuilder: (context, index) {
                  double scale = (1.0 - (index - _currentPage).abs() * 0.2).clamp(0.8, 1.0);
                  double opacity = (1.0 - (index - _currentPage).abs() * 0.5).clamp(0.4, 1.0);

                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: _buildItemCard(controller.items[index]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            
            // 🏷️ Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 8,
                  width: controller.currentPage.value == index ? 24 : 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: controller.currentPage.value == index 
                        ? const Color(0xFF1B8A4E) 
                        : Colors.white24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        );
      }),
    );
  }

  Widget _buildItemCard(dynamic item) {
    String title = controller.getTitle(item);
    String subtitle = (item["description"] ?? "").toString();
    String imageUrl = controller.getImageUrl(item);

    return GestureDetector(
      onTap: () => controller.onNodeTap(item),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E293B), // Slate 800
              Color(0xFF0F172A), // Slate 900
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFF1B8A4E).withOpacity(0.1),
              blurRadius: 40,
              spreadRadius: -10,
            ),
          ],
          border: Border.all(color: Colors.white10, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image (if any)
            if (imageUrl.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image_not_supported_outlined, color: Colors.white10, size: 50),
                  ),
                ),
              ),
            
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                ),
              ),
            ),

            // Text Content
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B8A4E),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B8A4E).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Explore Now",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
