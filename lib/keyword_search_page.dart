import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'keyword_search_controller.dart';

class KeywordSearchPage extends StatelessWidget {
  final KeywordSearchController ctrl = Get.put(KeywordSearchController());

  // ─── Green + White Palette ────────────────────────────────────
  static const _bg = Color(0xFFF4FBF4);            // off-white background
  static const _green1 = Color(0xFF1B8A4E);        // deep green
  static const _textDark = Color(0xFF0D3320);      // dark green text

  KeywordSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
          onPressed: ctrl.handleBack,
        ),
        title: Obx(() {
          if (ctrl.keywordsList.isEmpty) {
            return const Text("Keyword Search", style: TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 16));
          }
          if (ctrl.selectedKeyword.value.isNotEmpty) {
            return Text(ctrl.selectedKeyword.value, style: const TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 16));
          }
          return Text(
            ctrl.keywordsList.join(", "),
            style: const TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          );
        }),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.hub_rounded, color: _green1),
            tooltip: "Open Graph View",
            onPressed: () {
              final kw = ctrl.selectedKeyword.value.isNotEmpty
                  ? ctrl.selectedKeyword.value
                  : (ctrl.keywordsList.isNotEmpty ? ctrl.keywordsList.first : "");
              Get.toNamed('/graphView', arguments: {"keyword": kw});
            },
          )
        ],
      ),
      body: Column(
        children: [
          // ── Search bar to initiate new searches ──
          _searchBar(),

          // ── Keyword Tiles for Multiple Keywords ──
          _keywordTiles(),
          
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: _green1));
              }

              if (ctrl.questions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text("No results found", style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ctrl.questions.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (_, i) {
                  final q = ctrl.questions[i];
                  return SearchResultCard(
                    q: q, 
                    index: i, 
                    onHashtagTap: (kw) => ctrl.onHashtagTap(kw)
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    final TextEditingController textCtrl = TextEditingController();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _green1.withOpacity(0.12), width: 1.5),
        ),
        child: TextField(
          controller: textCtrl,
          textInputAction: TextInputAction.search,
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              ctrl.processSearchQuery(val.trim());
              textCtrl.clear();
            }
          },
          decoration: InputDecoration(
            hintText: "Search topics (e.g. Kerala, PSC)...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: _green1, size: 20),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward_rounded, color: _green1, size: 20),
              onPressed: () {
                if (textCtrl.text.trim().isNotEmpty) {
                  ctrl.processSearchQuery(textCtrl.text.trim());
                  textCtrl.clear();
                }
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _keywordTiles() {
    return Obx(() {
      if (ctrl.keywordsList.isEmpty) {
        return const SizedBox.shrink();
      }

      final showAllChip = ctrl.keywordsList.length > 1;
      final isAllSelected = ctrl.selectedKeyword.value.isEmpty;
      final totalItems = ctrl.keywordsList.length + (showAllChip ? 1 : 0);

      return Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: totalItems,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (showAllChip && index == 0) {
              return GestureDetector(
                onTap: () => ctrl.selectKeywordTile(""),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isAllSelected ? _green1 : _bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isAllSelected ? _green1 : _green1.withOpacity(0.3),
                      width: isAllSelected ? 1.5 : 1,
                    ),
                    boxShadow: isAllSelected
                        ? [
                            BoxShadow(
                              color: _green1.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.done_all_rounded,
                        size: 15,
                        color: isAllSelected ? Colors.white : _green1,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "All Topics",
                        style: TextStyle(
                          color: isAllSelected ? Colors.white : _textDark,
                          fontWeight: isAllSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final kwIndex = showAllChip ? index - 1 : index;
            final kw = ctrl.keywordsList[kwIndex];
            final isSelected = kw.toLowerCase() == ctrl.selectedKeyword.value.toLowerCase();

            return Container(
              decoration: BoxDecoration(
                color: isSelected ? _green1 : _green1.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? _green1 : _green1.withOpacity(0.3),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _green1.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => ctrl.selectKeywordTile(kw),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.label_rounded,
                            size: 14,
                            color: isSelected ? Colors.white : _green1,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            kw,
                            style: TextStyle(
                              color: isSelected ? Colors.white : _textDark,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ctrl.removeKeywordTile(kw),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6, left: 2),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.25) : Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 12,
                        color: isSelected ? Colors.white : Colors.red.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

class SearchResultCard extends StatefulWidget {
  final Map<String, dynamic> q;
  final int index;
  final Function(String) onHashtagTap;

  const SearchResultCard({
    super.key,
    required this.q,
    required this.index,
    required this.onHashtagTap,
  });

  @override
  State<SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends State<SearchResultCard> {
  bool isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.q;
    final index = widget.index;
    final List<String> keywords = q["keywords"] != null ? List<String>.from(q["keywords"]) : [];
    final String description = (q["description"] ?? "").toString().trim();
    final String answer = (q["answer"] ?? "").toString().trim();

    const Color _green1 = Color(0xFF1B8A4E);
    const Color _green2 = Color(0xFF27AE60);
    const Color _textDark = Color(0xFF0D3320);
    const Color _textMid = Color(0xFF4D7A5E);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Question ID & Number ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Question ${index + 1}", style: TextStyle(color: _green1, fontSize: 12, fontWeight: FontWeight.bold)),
                Text("#${q['id']}", style: TextStyle(color: Colors.grey.shade300, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            // ── Question ──
            Text(
              q["question"] ?? "No question text",
              style: const TextStyle(color: _textDark, fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
            ),
            const SizedBox(height: 20),

            // ── Answer Reveal ──
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: isRevealed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: GestureDetector(
                onTap: () => setState(() => isRevealed = true),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.visibility_rounded, color: Colors.grey.shade400, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        "Tap to Reveal Answer",
                        style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _green2.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _green2.withOpacity(0.2), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: _green2, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            answer,
                            style: const TextStyle(color: _green1, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Explanation Option ──
                  if (description.isNotEmpty && description.toLowerCase() != "null") ...[
                    const SizedBox(height: 8),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(bottom: 8),
                        iconColor: Colors.blue.shade600,
                        collapsedIconColor: Colors.grey.shade600,
                        title: Row(
                          children: [
                            Icon(Icons.lightbulb_outline_rounded, color: Colors.blue.shade500, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Explanation",
                              style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade100.withOpacity(0.5)),
                            ),
                            child: Text(
                              description,
                              style: TextStyle(color: Colors.blue.shade900, height: 1.5, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // ── Keywords/Hashtags ──
            if (keywords.isNotEmpty) ...[
              const Text("Related Topics", style: TextStyle(color: _textMid, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: keywords.map((kw) => _hashtag(kw)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _hashtag(String kw) {
    return InkWell(
      onTap: () {
        widget.onHashtagTap(kw);
        Get.toNamed('/keywordDetails', arguments: {"keyword": kw});
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.12), width: 1),
        ),
        child: Text(
          "#$kw",
          style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
