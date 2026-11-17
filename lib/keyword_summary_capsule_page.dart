import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'app_config.dart';
import 'summary_card_model.dart';

class KeywordSummaryCapsule {
  final int kid;
  final String keyword;
  final String? summary;

  KeywordSummaryCapsule({
    required this.kid,
    required this.keyword,
    this.summary,
  });

  factory KeywordSummaryCapsule.fromJson(Map<String, dynamic> json) {
    return KeywordSummaryCapsule(
      kid: json['kid'] ?? 0,
      keyword: json['keyword'] ?? '',
      summary: json['summary'],
    );
  }
}

class KeywordSummaryCapsuleController extends GetxController {
  var capsules = <KeywordSummaryCapsule>[].obs;
  var isLoading = true.obs;
  var errorMsg = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchCapsules();
  }

  Future<void> fetchCapsules() async {
    try {
      isLoading(true);
      errorMsg("");
      final res = await http.get(Uri.parse(AppConfig.keywordSummaryKnowledgeCapsule));
      if (res.statusCode == 200) {
        final List data = json.decode(utf8.decode(res.bodyBytes));
        capsules.value = data.map((e) => KeywordSummaryCapsule.fromJson(e)).toList();
      } else {
        errorMsg("Failed to load: ${res.statusCode}");
      }
    } catch (e) {
      errorMsg("Error: $e");
    } finally {
      isLoading(false);
    }
  }
}

class KeywordSummaryKnowledgeCapsulePage extends StatelessWidget {
  KeywordSummaryKnowledgeCapsulePage({super.key});

  final KeywordSummaryCapsuleController controller = Get.put(KeywordSummaryCapsuleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Light background for cards
      appBar: AppBar(
        title: const Text("Knowledge Capsule"),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMsg.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMsg.value,
              style: const TextStyle(color: Colors.black54),
            ),
          );
        }
        if (controller.capsules.isEmpty) {
          return const Center(
            child: Text(
              "No capsules available.",
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        return PageView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.capsules.length,
          itemBuilder: (context, index) {
            final capsule = controller.capsules[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.purple.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  Text(
                    capsule.keyword,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                  const Divider(height: 30, thickness: 1.5),
                  // Summary
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Builder(
                        builder: (context) {
                          final summaryText = capsule.summary ?? "";
                          if (summaryText.isEmpty) {
                            return const Text(
                              "No summary available.",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                height: 1.7,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }
                          final cards = SummaryCardModel.parse(summaryText);
                          if (cards.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: cards.map((card) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: card.accentColor.withValues(alpha: 0.25),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: card.accentColor.withValues(alpha: 0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: card.accentColor.withValues(alpha: 0.12),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(card.icon, color: card.accentColor, size: 16),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              card.cleanTitle,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.indigo.shade900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ...card.items.map((item) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: item.hasValue
                                              ? RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "${item.label}  —  ",
                                                        style: const TextStyle(
                                                          fontSize: 14.5,
                                                          color: Colors.black87,
                                                          fontWeight: FontWeight.w600,
                                                          height: 1.5,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: item.value,
                                                        style: TextStyle(
                                                          fontSize: 14.5,
                                                          color: card.accentColor,
                                                          fontWeight: FontWeight.bold,
                                                          height: 1.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Text(
                                                  item.rawText,
                                                  style: const TextStyle(
                                                    fontSize: 14.5,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.5,
                                                  ),
                                                ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          }
                          return Text(
                            summaryText,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              height: 1.7,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Footer indicator
                  Center(
                    child: Text(
                      "${index + 1} of ${controller.capsules.length}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
