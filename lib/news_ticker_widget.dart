import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'news_controller.dart';
import 'news_model.dart';

class NewsTickerWidget extends StatefulWidget {
  const NewsTickerWidget({super.key});

  @override
  State<NewsTickerWidget> createState() => _NewsTickerWidgetState();
}

class _NewsTickerWidgetState extends State<NewsTickerWidget> {
  final NewsController newsCtrl = Get.put(NewsController());
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (newsCtrl.newsList.isEmpty) return;
      
      if (_currentPage < newsCtrl.newsList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (newsCtrl.newsList.isEmpty) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.toNamed('/newsfeeder'),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4), // 🔥 Up to border (no horizontal margin)
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: const Color(0xFF1B8A4E).withOpacity(0.08)),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── FLASH NEWS Label ───
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1B8A4E), Color(0xFF27AE60)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(11),
                      bottomLeft: Radius.circular(11),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "FLASH",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // ─── Scrolling Content ───
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // 1. Invisible items to determine max height + buffer
                      Opacity(
                        opacity: 0,
                        child: IgnorePointer(
                          child: Stack(
                            children: newsCtrl.newsList.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12), // Buffer to avoid overflow
                              child: _buildNewsContent(item),
                            )).toList(),
                          ),
                        ),
                      ),
                      // 2. The actual PageView
                      Positioned.fill(
                        child: PageView.builder(
                          controller: _pageController,
                          scrollDirection: Axis.vertical,
                          itemCount: newsCtrl.newsList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Center(
                              child: _buildNewsContent(newsCtrl.newsList[index]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF1B8A4E), size: 18),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNewsContent(NewsItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Adjusted for column
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                item.title.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                "${item.date.day}/${item.date.month}",
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.4),
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            item.content,
            style: const TextStyle(
              color: Color(0xFF0D3320),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
