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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Top Row: Small Faded Title ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  "${item.date.day} ${_getMonth(item.date.month)} ${item.date.year}",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // ─── Main Content ───
            Text(
              item.content,
              style: const TextStyle(
                color: Color(0xFF0D3320),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
