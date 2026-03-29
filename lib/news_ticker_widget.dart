import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'news_controller.dart';

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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFF1B8A4E).withOpacity(0.1)),
          ),
          child: Row(
            children: [
              // ─── FLASH NEWS Label ───
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: double.infinity,
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
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // ─── Scrolling Content ───
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical, // Scroll up/down for "Flash" feel
                  itemCount: newsCtrl.newsList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = newsCtrl.newsList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            "${item.title}: ",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.content,
                              style: const TextStyle(
                                color: Color(0xFF0D3320),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF1B8A4E), size: 20),
              const SizedBox(width: 8),
            ],
          ),
        ),
      );
    });
  }
}
