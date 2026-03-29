import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'news_controller.dart';
import 'news_model.dart';

class NewsFeederPage extends StatelessWidget {
  final NewsController newsCtrl = Get.find<NewsController>();

  static const _bg = Color(0xFFF4FBF4);
  static const _green1 = Color(0xFF1B8A4E);
  static const _textDark = Color(0xFF0D3320);

  NewsFeederPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Flash News",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _green1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: _bg),
        child: Obx(() {
          if (newsCtrl.newsList.isEmpty) {
            return const Center(
              child: Text("No current updates available"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: newsCtrl.newsList.length,
            itemBuilder: (context, index) {
              final item = newsCtrl.newsList[index];
              return _NewsCard(item: item);
            },
          );
        }),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem item;
  const _NewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B8A4E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Color(0xFF1B8A4E),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "${item.date.day}/${item.date.month}/${item.date.year} ${item.date.hour}:${item.date.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.content,
              style: const TextStyle(
                color: Color(0xFF0D3320),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
