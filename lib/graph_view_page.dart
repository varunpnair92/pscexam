import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'keyword_details_controller.dart';

class GraphViewPage extends StatelessWidget {
  final KeywordDetailsController ctrl = Get.isRegistered<KeywordDetailsController>()
      ? Get.find<KeywordDetailsController>()
      : Get.put(KeywordDetailsController());

  // Modern Dark Mind-Map Palette (as seen in OSINT / Visual network maps)
  static const Color _bgDark = Color(0xFF0F0E17);
  static const Color _cardBg = Color(0xFF1B1A24);
  static const Color _primaryAccent = Color(0xFF7F56D9);
  static const Color _secondaryAccent = Color(0xFF9E77ED);
  static const Color _nodeCircle = Color(0xFF6941C6);
  static const Color _leafBg = Color(0xFF242232);
  static const Color _lineColor = Color(0xFF4A4458);

  GraphViewPage({super.key}) {
    // If opened directly with arguments or when keywordData is empty but currentKeyword exists
    final args = Get.arguments;
    if (args != null && args["keyword"] != null && args["keyword"].toString().isNotEmpty) {
      String kw = args["keyword"].toString();
      if (!ctrl.searchHistory.contains(kw)) {
        ctrl.searchHistory.add(kw);
      }
      ctrl.fetchKeywordDetails(kw);
    } else if (ctrl.currentKeyword.value.isNotEmpty && ctrl.keywordData.isEmpty) {
      ctrl.fetchKeywordDetails(ctrl.currentKeyword.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _cardBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: ctrl.handleBack,
        ),
        title: Obx(() => Text(
              ctrl.currentKeyword.value.isNotEmpty
                  ? "Graph View: ${ctrl.currentKeyword.value}"
                  : "Graph View Visualizer",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            )),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _secondaryAccent),
            tooltip: "Reset Graph",
            onPressed: () {
              if (ctrl.currentKeyword.value.isNotEmpty) {
                ctrl.fetchKeywordDetails(ctrl.currentKeyword.value);
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          _searchHeader(),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: _secondaryAccent),
                );
              }

              if (ctrl.keywordData.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hub_outlined, size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      Text("No graph network data available",
                          style: TextStyle(color: Colors.white38, fontSize: 16)),
                    ],
                  ),
                );
              }

              final data = ctrl.keywordData;
              final String rootKeyword = data["keyword"] ?? "";
              final List characteristics = data["characteristics"] ?? [];
              final List allQuestions = data["all_mapped_questions"] ?? [];

              return InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(500),
                minScale: 0.3,
                maxScale: 3.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 60),
                  child: CustomPaint(
                    painter: MindMapGraphPainter(
                      data: data,
                      lineColor: _lineColor,
                      accentColor: _secondaryAccent,
                    ),
                    child: _buildGraphNodesTree(rootKeyword, characteristics, allQuestions),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _searchHeader() {
    final TextEditingController textCtrl = TextEditingController();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: _cardBg,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _bgDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _primaryAccent.withOpacity(0.3), width: 1.2),
        ),
        child: TextField(
          controller: textCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          textInputAction: TextInputAction.search,
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              ctrl.onSearchSubmit(val.trim());
              textCtrl.clear();
            }
          },
          decoration: InputDecoration(
            hintText: "Explore keyword in graph...",
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: _secondaryAccent, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildGraphNodesTree(String rootKeyword, List characteristics, List allQuestions) {
    return Row(
      key: const ValueKey('graph_root_row'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // LEVEL 0: ROOT NODE (Central Keyword)
        _buildRootNode(rootKeyword),
        const SizedBox(width: 140),

        // LEVEL 1, 2 & 3: CHARACTERISTIC -> QUESTION -> ANSWER
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: characteristics.map<Widget>((c) {
            final String charName = c["characteristic_name"] ?? "";
            
            // Extract question-answer pairs
            final List<Map<String, String>> qaPairs = [];
            final List nestedQuestions = c["questions"] ?? [];

            for (var q in nestedQuestions) {
              final String qText = (q["question"] ?? "").toString().trim();
              final String ansText = (q["answer"] ?? "").toString().trim();
              if (qText.isNotEmpty && ansText.isNotEmpty) {
                if (!qaPairs.any((pair) => pair["question"] == qText && pair["answer"] == ansText)) {
                  qaPairs.add({"question": qText, "answer": ansText});
                }
              }
            }

            if (qaPairs.isEmpty && charName.isNotEmpty && rootKeyword.isNotEmpty) {
              for (var q in allQuestions) {
                final qText = (q["question"] ?? "").toString().trim();
                final searchName = charName.replaceAll('?', '').trim();
                
                if (searchName.isNotEmpty && 
                    qText.contains(searchName) && 
                    qText.contains(rootKeyword)) {
                  final ansText = (q["answer"] ?? "").toString().trim();
                  if (ansText.isNotEmpty) {
                    if (!qaPairs.any((pair) => pair["question"] == qText && pair["answer"] == ansText)) {
                      qaPairs.add({"question": qText, "answer": ansText});
                    }
                  }
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  // LEVEL 1: CHARACTERISTIC BRANCH NODE
                  _buildBranchNode(charName, qaPairs.length, c),
                  const SizedBox(width: 140),

                  // LEVEL 2 & 3: QUESTION NODES & ANSWER NODES
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: qaPairs.map<Widget>((pair) {
                      final String qText = pair["question"]!;
                      final String ansText = pair["answer"]!;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            // LEVEL 2: QUESTION NODE
                            _buildQuestionNode(qText, charName),
                            const SizedBox(width: 140),

                            // LEVEL 3: ANSWER NODE
                            _buildLeafNode(ansText, charName),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRootNode(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _primaryAccent,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _primaryAccent.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchNode(String title, int count, Map charData) {
    return GestureDetector(
      onTap: () {
        if (title.isNotEmpty) {
          Get.toNamed('/characteristic', arguments: {
            "title": ctrl.currentKeyword.value,
            "category": title,
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _secondaryAccent.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: _secondaryAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _secondaryAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$count",
                  style: const TextStyle(color: _secondaryAccent, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              )
            ],
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded, color: _secondaryAccent, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionNode(String questionText, String parentBranch) {
    return GestureDetector(
      onTap: () {
        if (ctrl.currentKeyword.value.isNotEmpty) {
          Get.toNamed('/characteristic', arguments: {
            "title": ctrl.currentKeyword.value,
            "category": parentBranch,
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1C2B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _secondaryAccent.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFF5A623),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                questionText,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.90),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeafNode(String title, String parentBranch) {
    return GestureDetector(
      onTap: () {
        if (ctrl.currentKeyword.value.isNotEmpty) {
          Get.toNamed('/characteristic', arguments: {
            "title": ctrl.currentKeyword.value,
            "category": parentBranch,
          });
        } else {
          ctrl.onSearchSubmit(title);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _leafBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF34D399),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter to draw curved bezier connection lines like D3.js mind maps
class MindMapGraphPainter extends CustomPainter {
  final Map data;
  final Color lineColor;
  final Color accentColor;

  MindMapGraphPainter({
    required this.data,
    required this.lineColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Basic canvas background grid / connecting lines render support if required
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
