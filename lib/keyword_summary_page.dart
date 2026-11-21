import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
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

  List<_PointItemData> _getPointsOnlyItems() {
    final List<_PointItemData> items = [];

    // 1. From parsed summaryCards (highest fidelity: structured label and value)
    if (ctrl.summaryCards.isNotEmpty) {
      for (final card in ctrl.summaryCards) {
        for (final item in card.items) {
          if (item.hasValue) {
            items.add(_PointItemData(
              keyword: item.label,
              point: item.value!,
              category: card.cleanTitle,
              rawText: item.rawText,
            ));
          } else if (item.rawText.isNotEmpty) {
            final delimiter = item.rawText.contains(' — ')
                ? ' — '
                : (item.rawText.contains(' - ') ? ' - ' : (item.rawText.contains(' : ') ? ' : ' : null));
            if (delimiter != null) {
              final parts = item.rawText.split(delimiter);
              final k = parts[0].trim().replaceFirst(RegExp(r'^[•\-\*\d\.\s]+'), '').trim();
              final p = parts.sublist(1).join(delimiter).trim();
              items.add(_PointItemData(
                keyword: k,
                point: p,
                category: card.cleanTitle,
                rawText: item.rawText,
              ));
            } else {
              items.add(_PointItemData(
                keyword: item.rawText,
                point: '',
                category: card.cleanTitle,
                rawText: item.rawText,
              ));
            }
          }
        }
      }
    }

    // 2. From pointByPointList
    if (items.isEmpty && ctrl.pointByPointList.isNotEmpty) {
      for (final p in ctrl.pointByPointList) {
        items.add(_PointItemData(
          keyword: p['keyword'] ?? '',
          point: p['point'] ?? '',
          category: '',
          rawText: p['formatted'] ?? '',
        ));
      }
    }

    // 3. Fallback from summaryLines
    if (items.isEmpty && ctrl.summaryLines.isNotEmpty) {
      for (final line in ctrl.summaryLines) {
        if (line.startsWith('#')) continue;
        final delimiter = line.contains(' — ')
            ? ' — '
            : (line.contains(' - ') ? ' - ' : (line.contains(' : ') ? ' : ' : null));
        if (delimiter != null) {
          final parts = line.split(delimiter);
          final k = parts[0].trim().replaceFirst(RegExp(r'^[•\-\*\d\.\s]+'), '').trim();
          final p = parts.sublist(1).join(delimiter).trim();
          items.add(_PointItemData(
            keyword: k,
            point: p,
            category: '',
            rawText: line,
          ));
        } else {
          items.add(_PointItemData(
            keyword: line,
            point: '',
            category: '',
            rawText: line,
          ));
        }
      }
    }

    // 4. Children with points
    if (ctrl.childrenData.isNotEmpty) {
      for (final child in ctrl.childrenData) {
        final pt = (child['point'] ?? '').toString().trim();
        final name = (child['name'] ?? child['keyword'] ?? '').toString().trim();
        if (pt.isNotEmpty && name.isNotEmpty) {
          if (!items.any((it) => it.keyword == name && it.point == pt)) {
            items.add(_PointItemData(
              keyword: name,
              point: pt,
              category: (child['category'] ?? '').toString().trim(),
              rawText: "$name - $pt",
            ));
          }
        }
      }
    }

    return items;
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
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (ctrl.currentKeyword.value.isNotEmpty) {
          _showNoteSheet(context, ctrl.currentKeyword.value);
        }
      },
      child: Container(
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
    final pointsItems = _getPointsOnlyItems();
    final int pointsCount = pointsItems.length;

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
            itemCount: ctrl.summaryCards.length + 2,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final isPointsOnly = index == 1;

              final bool isSelected;
              final String label;
              final Color activeColor;

              if (isAll) {
                isSelected = _selectedCategoryIndex == -1;
                label = "All (${ctrl.summaryCards.length})";
                activeColor = _green1;
              } else if (isPointsOnly) {
                isSelected = _selectedCategoryIndex == -2;
                label = pointsCount > 0 ? "Points Only ($pointsCount)" : "Points Only";
                activeColor = _green1;
              } else {
                final cardIndex = index - 2;
                isSelected = _selectedCategoryIndex == cardIndex;
                final card = ctrl.summaryCards[cardIndex];
                label = card.shortTitle;
                activeColor = card.accentColor;
              }

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    if (isAll) {
                      _selectedCategoryIndex = -1;
                    } else if (isPointsOnly) {
                      _selectedCategoryIndex = -2;
                    } else {
                      _selectedCategoryIndex = index - 2;
                    }
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
                    child: isPointsOnly
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.checklist_rounded,
                                size: 14,
                                color: isSelected ? Colors.white : _green1,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                label,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : _textDark,
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
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
    if (_selectedCategoryIndex == -2) {
      return _buildPointsOnlySection();
    }

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

  Widget _buildPointsOnlySection() {
    final items = _getPointsOnlyItems();

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Text(
            "No point-by-point facts available for this topic.",
            style: TextStyle(color: _textMid, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _green1.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _green1.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _green1.withValues(alpha: 0.08),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _green1.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.checklist_rounded, color: _green1, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "പോയിന്റുകൾ (Points Only)",
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${items.length} Key Facts / Points",
                        style: const TextStyle(
                          color: _green1,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  color: _green1,
                  tooltip: "Copy all points",
                  onPressed: () {
                    final textToCopy = items.map((it) {
                      if (it.hasPoint) {
                        return "${it.keyword} — ${it.point}";
                      }
                      return it.rawText;
                    }).join("\n");
                    _copyToClipboard(
                      customText: textToCopy,
                      customMessage: "All points copied to clipboard",
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: _green1.withValues(alpha: 0.15)),
          // Body with numbered list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final item = items[idx];
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  final targetKw = item.hasPoint ? item.point : item.keyword;
                  _showNoteSheet(
                    context,
                    targetKw,
                    categoryTitle: item.category.isNotEmpty ? item.category : "Points Only",
                    pointIndex: idx + 1,
                  );
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
                          color: _green1.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "${idx + 1}",
                          style: const TextStyle(
                            color: _green1,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: item.hasPoint
                            ? Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: item.keyword,
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
                                      text: item.point,
                                      style: const TextStyle(
                                        color: _green1,
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
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16, color: _textMid),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        tooltip: "Copy point",
                        onPressed: () {
                          final str = item.hasPoint ? "${item.keyword} — ${item.point}" : item.rawText;
                          _copyToClipboard(
                            customText: str,
                            customMessage: "Point copied to clipboard",
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
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
                    final targetKeyword = item.hasValue ? item.value! : item.label;
                    _showNoteSheet(
                      context,
                      targetKeyword,
                      fallbackItem: item,
                      categoryTitle: card.cleanTitle,
                      pointIndex: idx + 1,
                    );
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
                    child: _buildRichSummaryLine(line),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRichSummaryLine(String line) {
    final delimiter = line.contains(' — ')
        ? ' — '
        : (line.contains(' - ') ? ' - ' : (line.contains(' : ') ? ' : ' : null));

    if (delimiter != null) {
      final parts = line.split(delimiter);
      final k = parts[0].trim().replaceFirst(RegExp(r'^[•\-\*\d\.\s]+'), '').trim();
      final p = parts.sublist(1).join(delimiter).trim();
      if (k.isNotEmpty && p.isNotEmpty) {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: k,
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
                text: p,
                style: const TextStyle(
                  color: _green1,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  height: 1.45,
                ),
              ),
            ],
          ),
        );
      }
    }

    return SelectableText(
      line,
      style: const TextStyle(
        color: _textDark,
        fontSize: 14.5,
        height: 1.55,
        fontWeight: FontWeight.w500,
      ),
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
                _showNoteSheet(context, childName);
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
        final childData = index < ctrl.childrenData.length ? ctrl.childrenData[index] : null;
        final childPoint = (childData?['point'] ?? '').toString().trim();
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
                _showNoteSheet(context, childName);
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            childName,
                            style: const TextStyle(
                              color: _textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (childPoint.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              childPoint,
                              style: const TextStyle(
                                color: _green1,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
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

  void _showNoteSheet(
    BuildContext context,
    String keyword, {
    SummaryItem? fallbackItem,
    String? categoryTitle,
    int? pointIndex,
  }) {
    String cleanKeyword = keyword.trim();
    if (cleanKeyword.contains('(')) {
      cleanKeyword = cleanKeyword.substring(0, cleanKeyword.indexOf('(')).trim();
    }
    if (cleanKeyword.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _StudyNoteSheetWidget(
          keyword: cleanKeyword,
          fallbackItem: fallbackItem,
          categoryTitle: categoryTitle,
          pointIndex: pointIndex,
          onCopy: (text) => _copyToClipboard(
            customText: text,
            customMessage: "Note copied to clipboard",
          ),
          onOpenAsMain: (kw) {
            Navigator.pop(ctx);
            _textCtrl.text = kw;
            ctrl.onKeywordTap(kw);
          },
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

class _StudyNoteSheetWidget extends StatefulWidget {
  final String keyword;
  final SummaryItem? fallbackItem;
  final String? categoryTitle;
  final int? pointIndex;
  final void Function(String text) onCopy;
  final void Function(String keyword) onOpenAsMain;

  const _StudyNoteSheetWidget({
    required this.keyword,
    this.fallbackItem,
    this.categoryTitle,
    this.pointIndex,
    required this.onCopy,
    required this.onOpenAsMain,
  });

  @override
  State<_StudyNoteSheetWidget> createState() => _StudyNoteSheetWidgetState();
}

class _StudyNoteSheetWidgetState extends State<_StudyNoteSheetWidget> {
  final KeywordSummaryController ctrl = Get.find<KeywordSummaryController>();
  bool isLoading = true;
  String description = "";
  String summary = "";
  List<String> summaryLines = [];
  List<SummaryCardModel> summaryCards = [];
  int keywordId = 0;
  String? errorMessage;

  static const _bg = Color(0xFFF4FBF4);
  static const _green1 = Color(0xFF1B8A4E);
  static const _textDark = Color(0xFF0D3320);
  static const _textMid = Color(0xFF4D7A5E);

  @override
  void initState() {
    super.initState();
    _loadNoteData();
  }

  Future<void> _loadNoteData() async {
    if (ctrl.currentKeyword.value == widget.keyword) {
      setState(() {
        description = ctrl.description.value;
        summary = ctrl.summary.value;
        summaryLines = List<String>.from(ctrl.summaryLines);
        summaryCards = List<SummaryCardModel>.from(ctrl.summaryCards);
        keywordId = ctrl.keywordId.value;
        isLoading = false;
      });
      return;
    }

    try {
      final res = await http.get(
        Uri.parse("${AppConfig.keywordSearchSummary}?keyword=${Uri.encodeComponent(widget.keyword)}"),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          description = decoded['description'] ?? '';
          summary = decoded['summary'] ?? '';
          keywordId = decoded['id'] ?? 0;

          if (decoded['summary_lines'] is List) {
            summaryLines = List<dynamic>.from(decoded['summary_lines'])
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }

          if (summary.contains('#')) {
            summaryCards = SummaryCardModel.parse(summary);
          }
        }
      } else {
        errorMessage = "Note details not found";
      }
    } catch (e) {
      errorMessage = "Could not load note";
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _copyFullNote() {
    String noteText = "${widget.keyword} — PSC Study Note\n";
    if (widget.fallbackItem != null) {
      noteText += "\n[ക്വിക്ക് പോയിന്റ് (Key Fact)]\n";
      noteText += widget.fallbackItem!.hasValue
          ? "• ${widget.fallbackItem!.label} — ${widget.fallbackItem!.value}\n"
          : "• ${widget.fallbackItem!.rawText}\n";
    }
    if (description.isNotEmpty) {
      noteText += "\n[വിവരണം (Description)]\n$description\n";
    }
    if (summaryCards.isNotEmpty) {
      noteText += "\n[സംഗ്രഹം (Summary)]\n";
      for (final card in summaryCards) {
        noteText += "# ${card.cleanTitle}\n";
        for (final it in card.items) {
          noteText += it.hasValue ? "• ${it.label} — ${it.value}\n" : "• ${it.rawText}\n";
        }
      }
    } else if (summaryLines.isNotEmpty) {
      noteText += "\n[സംഗ്രഹം (Summary)]\n";
      for (final line in summaryLines) {
        noteText += "• $line\n";
      }
    } else if (summary.isNotEmpty) {
      noteText += "\n[സംഗ്രഹം (Summary)]\n$summary\n";
    }

    widget.onCopy(noteText.trim());
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag Handle ──
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // ── Note Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 12, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: _green1.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: _green1, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.keyword,
                            style: const TextStyle(
                              color: _textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _green1.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "കുറിപ്പ് • Study Note",
                                  style: TextStyle(
                                    color: _green1,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (keywordId > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "# ID: #$keywordId",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (widget.categoryTitle != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${widget.categoryTitle} • #${widget.pointIndex ?? 1}",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: _green1, size: 20),
                      tooltip: "Copy Note",
                      onPressed: _copyFullNote,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                      tooltip: "Close",
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 0.8),

              // ── Note Content (Both Description & Summary Together) ──
              Expanded(
                child: isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: _green1),
                            SizedBox(height: 14),
                            Text(
                              "കുറിപ്പ് ലോഡ് ചെയ്യുന്നു (Loading Note)...",
                              style: TextStyle(color: _textMid, fontSize: 13.5),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        controller: scrollCtrl,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                        children: [
                          // 1. Fallback / Current Fact (if opened from a list point)
                          if (widget.fallbackItem != null) ...[
                            _buildFactBadgeCard(),
                            const SizedBox(height: 14),
                          ],

                          // 2. വിവരണ കുറിപ്പ് (Description)
                          if (description.isNotEmpty) ...[
                            _buildNoteSectionHeader(
                              icon: Icons.auto_stories_rounded,
                              title: "വിവരണം (Description)",
                              color: _green1,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _bg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _green1.withValues(alpha: 0.18)),
                              ),
                              child: SelectableText(
                                description,
                                style: const TextStyle(
                                  color: _textDark,
                                  fontSize: 14.5,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 3. സംഗ്രഹ കുറിപ്പ് (Summary)
                          if (summaryCards.isNotEmpty || summaryLines.isNotEmpty || summary.isNotEmpty) ...[
                            _buildNoteSectionHeader(
                              icon: Icons.notes_rounded,
                              title: "സംഗ്രഹം (Summary / Key Points)",
                              color: _green1,
                              badgeText: summaryLines.isNotEmpty
                                  ? "${summaryLines.length} points"
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryContentInNote(),
                            const SizedBox(height: 20),
                          ],

                          // If neither description nor summary found
                          if (description.isEmpty &&
                              summaryLines.isEmpty &&
                              summary.isEmpty &&
                              summaryCards.isEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, color: Colors.amber.shade800, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "ഈ വിഷയത്തെക്കുറിച്ചുള്ള വിശദമായ കുറിപ്പ് ലഭ്യമല്ല. പ്രധാന പോയിന്റ് മുകളിൽ നൽകിയിട്ടുണ്ട്.",
                                      style: TextStyle(
                                        color: Colors.amber.shade900,
                                        fontSize: 13.5,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // ── Action Buttons ──
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Get.toNamed('/keywordDetails', arguments: {"keyword": widget.keyword});
                                  },
                                  icon: const Icon(Icons.account_tree_rounded, size: 17, color: _green1),
                                  label: const Text(
                                    "Show Details",
                                    style: TextStyle(color: _green1, fontWeight: FontWeight.bold),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: _green1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => widget.onOpenAsMain(widget.keyword),
                                  icon: const Icon(Icons.open_in_new_rounded, size: 17),
                                  label: const Text(
                                    "Open Full View",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _green1,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFactBadgeCard() {
    final it = widget.fallbackItem!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _green1.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _green1.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: _green1.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: _green1, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: it.hasValue
                ? Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${it.label}  —  ",
                          style: const TextStyle(
                            color: _textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: it.value,
                          style: const TextStyle(
                            color: _green1,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    it.rawText,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    String? badgeText,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _textDark,
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (badgeText != null) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryContentInNote() {
    if (summaryCards.isNotEmpty) {
      return Column(
        children: summaryCards.map((card) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: card.accentColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(card.icon, color: card.accentColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      card.cleanTitle,
                      style: TextStyle(
                        color: card.accentColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...card.items.map((it) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• ", style: TextStyle(color: card.accentColor, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: it.hasValue
                                ? Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "${it.label} — ",
                                          style: const TextStyle(color: _textDark, fontSize: 13.5),
                                        ),
                                        TextSpan(
                                          text: it.value,
                                          style: TextStyle(
                                            color: card.accentColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Text(it.rawText, style: const TextStyle(color: _textDark, fontSize: 13.5)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          );
        }).toList(),
      );
    }

    if (summaryLines.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _green1.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: summaryLines.map((line) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.circle, size: 6, color: _green1),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      line,
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _green1.withValues(alpha: 0.18)),
      ),
      child: SelectableText(
        summary,
        style: const TextStyle(color: _textDark, fontSize: 14.5, height: 1.55),
      ),
    );
  }
}

class _PointItemData {
  final String keyword;
  final String point;
  final String category;
  final String rawText;

  _PointItemData({
    required this.keyword,
    required this.point,
    this.category = '',
    required this.rawText,
  });

  bool get hasPoint => point.trim().isNotEmpty;
}
