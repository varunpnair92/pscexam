import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationSlideView extends StatefulWidget {
  final List<dynamic> items;
  final Function(dynamic) onNodeTap;
  final String Function(dynamic) getTitle;
  final String Function(dynamic) getImageUrl;

  const NavigationSlideView({
    super.key,
    required this.items,
    required this.onNodeTap,
    required this.getTitle,
    required this.getImageUrl,
  });

  @override
  State<NavigationSlideView> createState() => _NavigationSlideViewState();
}

class _NavigationSlideViewState extends State<NavigationSlideView> {
  late PageController pageController;
  double _currentPage = 0.0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 0.8);
    pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = pageController.page!;
        });
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(child: Text("No items found", style: TextStyle(color: Colors.grey)));
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: PageView.builder(
            controller: pageController,
            itemCount: widget.items.length,
            onPageChanged: (idx) {
              if (mounted) {
                setState(() => _currentIndex = idx);
              }
            },
            itemBuilder: (context, index) {
              double scale = (1.0 - (index - _currentPage).abs() * 0.2).clamp(0.8, 1.0);
              double opacity = (1.0 - (index - _currentPage).abs() * 0.5).clamp(0.4, 1.0);

              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: _buildItemCard(widget.items[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 30),
        
        // 🏷️ Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 8,
              width: _currentIndex == index ? 24 : 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentIndex == index 
                    ? const Color(0xFF1B8A4E) 
                    : Colors.black12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildItemCard(dynamic item) {
    String title = widget.getTitle(item);
    String subtitle = (item["description"] ?? "").toString();
    String imageUrl = widget.getImageUrl(item);

    return GestureDetector(
      onTap: () => widget.onNodeTap(item),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF000000),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.white10, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (imageUrl.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B8A4E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Explore",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
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
