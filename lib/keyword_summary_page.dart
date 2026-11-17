import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'keyword_summary_controller.dart';
import 'summary_card_model.dart';

class KeywordSummaryPage extends StatefulWidget {
  const KeywordSummaryPage({super.key});

  @override
  State<KeywordSummaryPage> createState() => _KeywordSummaryPageState();
}

class _KeywordSummaryPageState extends State<KeywordSummaryPage> {
  final KeywordSummaryController ctrl = Get.put(KeywordSummaryController());
  final TextEditingController _textCtrl = TextEditingController();

  int _selectedCategoryIndex = -1; // -1 = All
  final Set<int> _collapsedCardIndices = {};

  // ─── Theme Palette ──────────────────────────────────────────
  static const _bg = Color(0xFFF4FBF4);            // off-white background
  static const _green1 = Color(0xFF1B8A4E);        // deep green
  static const _textDark = Color(0xFF0D3320);      // dark green text
  static const _textMid = Color(0xFF4D7A5E);

  @override
  void initState() {
    super.initState();
    if (ctrl.currentKeyword.value.isNotEmpty) {
      _textCtrl.text = ctrl.currentKeyword.value;
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _copyToClipboard({String? customText, String? customMessage}) {
    String fullText = customText ?? "";
    if (customText == null) {
      fullText = ctrl.currentKeyword.value;
      if (ctrl.description.value.isNotEmpty) {
        fullText += "\n\n${ctrl.description.value}";
      }
      if (ctrl.summaryCards.isNotEmpty) {
        for (final card in ctrl.summaryCards) {
          fullText += "\n\n# ${card.cleanTitle}\n";
          for (final item in card.items) {
            if (item.hasValue) {
              fullText += "• ${item.label} - ${item.value}\n";
            } else {
              fullText += "• ${item.rawText}\n";
            }
          }
        }
      } else if (ctrl.summaryLines.isNotEmpty) {
        fullText += "\n\n${ctrl.summaryLines.map((e) => "• $e").join("\n")}";
      } else if (ctrl.summary.value.isNotEmpty) {
        fullText += "\n\n${ctrl.summary.value}";
      }
    }

    Clipboard.setData(ClipboardData(text: fullText.trim()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(customMessage ?? "Summary copied to clipboard"),
          ],
        ),
        backgroundColor: _textDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ctrl.handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
            onPressed: ctrl.handleBack,
          ),
          title: Obx(() => Text(
            ctrl.currentKeyword.value.isEmpty ? "Summary" : ctrl.currentKeyword.value,
            style: const TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 18),
            overflow: TextOverflow.ellipsis,
          )),
          centerTitle: true,
          actions: [
            Obx(() {
              final hasContent = ctrl.description.value.isNotEmpty ||
                  ctrl.summaryLines.isNotEmpty ||
                  ctrl.summary.value.isNotEmpty;
              if (!hasContent) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.copy_rounded, color: _green1, size: 20),
                tooltip: "Copy Summary",
                onPressed: _copyToClipboard,
              );
            }),
          ],
        ),
        body: Column(
          children: [
            // ── Search bar ──
            _searchBar(),

            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: _green1),
                        SizedBox(height: 16),
                        Text(
                          "Loading summary...",
                          style: TextStyle(color: _textMid, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                if (ctrl.responseType.value == 'error') {
                  return _buildErrorState();
                }

                if (ctrl.responseType.value == 'parent') {
                  if (ctrl.childrenList.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.account_tree_outlined,
                      message: "No sub-topics found for this keyword.",
                    );
                  }
                  return _buildParentView();
                }

                // If description or summary is available
                final hasDirectData = ctrl.description.value.isNotEmpty ||
                    ctrl.summaryLines.isNotEmpty ||
                    ctrl.summary.value.isNotEmpty;

                if (hasDirectData || ctrl.responseType.value == 'success') {
                  if (!hasDirectData) {
                    return _buildEmptyState(
                      icon: Icons.article_outlined,
                      message: "No summary or description available for this keyword.",
                    );
                  }
                  return _buildSummaryContentView(context);
                }

                if (ctrl.responseType.value == 'empty') {
                  return _buildEmptyState(
                    icon: Icons.article_outlined,
                    message: "No summary data found for '${ctrl.currentKeyword.value}'.",
                  );
                }

                // Unknown / Initial
                return _buildEmptyState(
                  icon: Icons.search_rounded,
                  message: "Search for a keyword to view its description & summary.",
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _green1.withValues(alpha: 0.15), width: 1.5),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.search_rounded, color: _green1, size: 20),
            ),
            Expanded(
              child: TextField(
                controller: _textCtrl,
                textInputAction: TextInputAction.search,
                onSubmitted: (val) {
                  final trimmed = val.trim();
                  if (trimmed.isNotEmpty) {
                    ctrl.onSearchSubmit(trimmed);
                  }
                },
                decoration: InputDecoration(
                  hintText: "Search keyword (e.g. രാജീവ് ഗാന്ധി)...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _textCtrl,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                  onPressed: () {
                    _textCtrl.clear();
                  },
                );
              },
            ),
            Container(
              margin: const EdgeInsets.only(right: 6),
              child: Material(
                color: _green1,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    final trimmed = _textCtrl.text.trim();
                    if (trimmed.isNotEmpty) {
                      ctrl.onSearchSubmit(trimmed);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryContentView(BuildContext context) {
    return RefreshIndicator(
      color: _green1,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await ctrl.fetchSummary(
          ctrl.currentKeyword.value,
          kid: ctrl.keywordId.value > 0 ? ctrl.keywordId.value : null,
        );
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          // ── Topic Header Card ──
          _buildTopicHeaderCard(),

          const SizedBox(height: 14),

          // ── Description Card (Keywordsdescription) ──
          if (ctrl.description.value.isNotEmpty) ...[
            _buildDescriptionCard(),
            const SizedBox(height: 16),
          ],

          // ── Summary Cards (Enclosed in # to #) or Legacy Points ──
          if (ctrl.summaryCards.isNotEmpty) ...[
            _buildCategoryFilterBar(),
            const SizedBox(height: 14),
            _buildSummaryCardsSection(),
          ] else if (ctrl.summaryLines.isNotEmpty) ...[
            _buildSummaryPointsSection(),
          ] else if (ctrl.summary.value.isNotEmpty) ...[
            _buildRawSummaryCard(),
          ],

          // ── Legacy Children fallback (if ever returned) ──
          if (ctrl.childrenList.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildLegacyChildrenSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildTopicHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green1.withValues(alpha: 0.12), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _green1.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bookmark_rounded, color: _green1, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ctrl.currentKeyword.value,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (ctrl.keywordId.value > 0)
                _chipWidget(
                  label: "ID: #${ctrl.keywordId.value}",
                  icon: Icons.tag_rounded,
                  bg: Colors.white,
                ),
              if (ctrl.summaryCards.isNotEmpty)
                _chipWidget(
                  label: "${ctrl.summaryCards.length} Categories",
                  icon: Icons.dashboard_outlined,
                  bg: _green1.withValues(alpha: 0.1),
                  textColor: _green1,
                ),
              if (ctrl.summaryLines.isNotEmpty)
                _chipWidget(
                  label: "${ctrl.summaryLines.length} Total Points",
                  icon: Icons.checklist_rounded,
                  bg: _green1.withValues(alpha: 0.1),
                  textColor: _green1,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipWidget({
    required String label,
    required IconData icon,
    required Color bg,
    Color textColor = _textMid,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _green1.withValues(alpha: 0.15), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE8F5E9).withValues(alpha: 0.8),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green1.withValues(alpha: 0.2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  color: _green1,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                "വിവരണം (Description)",
                style: TextStyle(
                  color: _textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            ctrl.description.value,
            style: const TextStyle(
              color: _textDark,
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.category_rounded, color: _green1, size: 18),
                const SizedBox(width: 6),
                Text(
                  "വിഭാഗങ്ങൾ (${ctrl.summaryCards.length})",
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  if (_collapsedCardIndices.length == ctrl.summaryCards.length) {
                    _collapsedCardIndices.clear();
                  } else {
                    _collapsedCardIndices.addAll(
                      List.generate(ctrl.summaryCards.length, (i) => i),
                    );
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      _collapsedCardIndices.length == ctrl.summaryCards.length
                          ? Icons.unfold_more_rounded
                          : Icons.unfold_less_rounded,
                      size: 16,
                      color: _green1,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _collapsedCardIndices.length == ctrl.summaryCards.length
                          ? "Expand All"
                          : "Collapse All",
                      style: const TextStyle(
                        color: _green1,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: ctrl.summaryCards.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final isSelected = isAll
                  ? _selectedCategoryIndex == -1
                  : _selectedCategoryIndex == (index - 1);
              final label = isAll
                  ? "All (${ctrl.summaryCards.length})"
                  : ctrl.summaryCards[index - 1].shortTitle;
              final Color activeColor = isAll
                  ? _green1
                  : ctrl.summaryCards[index - 1].accentColor;

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = isAll ? -1 : (index - 1);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? activeColor : Colors.grey.shade300,
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : _textDark,
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCardsSection() {
    final List<int> cardIndicesToShow;
    if (_selectedCategoryIndex >= 0 &&
        _selectedCategoryIndex < ctrl.summaryCards.length) {
      cardIndicesToShow = [_selectedCategoryIndex];
    } else {
      cardIndicesToShow = List.generate(ctrl.summaryCards.length, (i) => i);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cardIndicesToShow.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final cardIndex = cardIndicesToShow[i];
        final card = ctrl.summaryCards[cardIndex];
        return _buildSummaryCard(card, cardIndex);
      },
    );
  }

  Widget _buildSummaryCard(SummaryCardModel card, int cardIndex) {
    final isCollapsed = _collapsedCardIndices.contains(cardIndex);
    final accentColor = card.accentColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header (Tap to toggle collapse) ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: isCollapsed
                  ? BorderRadius.circular(16)
                  : const BorderRadius.vertical(top: Radius.circular(16)),
              onTap: () {
                setState(() {
                  if (isCollapsed) {
                    _collapsedCardIndices.remove(cardIndex);
                  } else {
                    _collapsedCardIndices.add(cardIndex);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.08),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: isCollapsed
                      ? BorderRadius.circular(16)
                      : const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(card.icon, color: accentColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.cleanTitle,
                            style: const TextStyle(
                              color: _textDark,
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${card.count} Facts / Key Points",
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      color: accentColor,
                      tooltip: "Copy this section",
                      onPressed: () {
                        _copyToClipboard(
                          customText: card.toShareText(),
                          customMessage: "${card.shortTitle} copied to clipboard",
                        );
                      },
                    ),
                    Icon(
                      isCollapsed
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_up_rounded,
                      color: Colors.grey.shade600,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Card Body (Expanded Items) ──
          if (!isCollapsed) ...[
            Divider(height: 1, color: accentColor.withValues(alpha: 0.15)),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: card.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final item = card.items[idx];

                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    _showItemDetailSheet(context, card, item, idx + 1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${idx + 1}",
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: item.hasValue
                              ? Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: item.label,
                                        style: const TextStyle(
                                          color: _textDark,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          height: 1.45,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: " — ",
                                        style: TextStyle(
                                          color: _textMid,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: item.value,
                                        style: TextStyle(
                                          color: accentColor,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(
                                  item.rawText,
                                  style: const TextStyle(
                                    color: _textDark,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.45,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.format_list_bulleted_rounded, color: _green1, size: 20),
            const SizedBox(width: 8),
            const Text(
              "പ്രധാന വിവരങ്ങൾ (Summary)",
              style: TextStyle(
                color: _textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _green1.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${ctrl.summaryLines.length} points",
                style: const TextStyle(
                  color: _green1,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ctrl.summaryLines.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final line = ctrl.summaryLines[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _green1.withValues(alpha: 0.12), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.015),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: _green1.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: _green1,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SelectableText(
                      line,
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 14.5,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRawSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green1.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes_rounded, color: _green1, size: 20),
              SizedBox(width: 8),
              Text(
                "സംഗ്രഹം (Summary)",
                style: TextStyle(
                  color: _textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            ctrl.summary.value,
            style: const TextStyle(
              color: _textDark,
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyChildrenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_tree_rounded, color: _green1, size: 18),
            const SizedBox(width: 8),
            Text(
              "Related Topics (${ctrl.childrenList.length})",
              style: const TextStyle(
                color: _textDark,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ctrl.childrenList.map((childName) {
            return ActionChip(
              backgroundColor: _bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: _green1.withValues(alpha: 0.2)),
              ),
              avatar: const Icon(Icons.arrow_forward_rounded, size: 14, color: _green1),
              label: Text(
                childName,
                style: const TextStyle(color: _textDark, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                _showTopicActionSheet(context, childName);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildParentView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ctrl.childrenList.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final childName = ctrl.childrenList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _green1.withValues(alpha: 0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                _textCtrl.text = childName;
                ctrl.onKeywordTap(childName);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: _bg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_tree_rounded, color: _green1, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        childName,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: _green1,
                      ),
                      icon: const Icon(Icons.menu_book_rounded, size: 15),
                      label: const Text("Details", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Get.toNamed('/keywordDetails', arguments: {"keyword": childName});
                      },
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showItemDetailSheet(
    BuildContext context,
    SummaryCardModel card,
    SummaryItem item,
    int index,
  ) {
    String targetKeyword = item.hasValue ? item.value! : item.label;
    if (targetKeyword.contains('(')) {
      targetKeyword = targetKeyword.substring(0, targetKeyword.indexOf('(')).trim();
    }

    final bool canNavigate = targetKeyword.isNotEmpty &&
        targetKeyword != ctrl.currentKeyword.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: card.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${card.cleanTitle} • Point #$index",
                        style: TextStyle(
                          color: card.accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      color: _green1,
                      onPressed: () {
                        _copyToClipboard(
                          customText: item.hasValue ? "${item.label} — ${item.value}" : item.rawText,
                          customMessage: "Point copied to clipboard",
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  item.label,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                if (item.hasValue) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: card.accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: card.accentColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      item.value!,
                      style: TextStyle(
                        color: card.accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                if (canNavigate) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _textCtrl.text = targetKeyword;
                        ctrl.onKeywordTap(targetKeyword);
                      },
                      icon: const Icon(Icons.auto_stories_rounded, size: 18),
                      label: Text("Show Summary & Description: $targetKeyword"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green1,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        Get.toNamed('/keywordDetails', arguments: {"keyword": targetKeyword});
                      },
                      icon: const Icon(Icons.account_tree_rounded, size: 18, color: _green1),
                      label: Text(
                        "Show Details: $targetKeyword",
                        style: const TextStyle(color: _green1, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _green1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTopicActionSheet(BuildContext context, String topic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _green1.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_tree_rounded, color: _green1, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        topic,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.auto_stories_rounded, color: _green1),
                  title: const Text("Show Summary & Description", style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text("Bullet points, quick facts & overview"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  onTap: () {
                    Get.back();
                    _textCtrl.text = topic;
                    ctrl.onKeywordTap(topic);
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.menu_book_rounded, color: _green1),
                  title: const Text("Show Details", style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text("Characteristics, full theory & graph view"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/keywordDetails', arguments: {"keyword": topic});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    final msg = ctrl.errorMessage.value.isNotEmpty
        ? ctrl.errorMessage.value
        : "An error occurred while fetching data.";
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (ctrl.currentKeyword.value.isNotEmpty) {
                  ctrl.fetchSummary(ctrl.currentKeyword.value);
                }
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green1,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
