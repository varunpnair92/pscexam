import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'math_formula.dart';
import 'summary_card_model.dart';

/// SmartExplanationCard
/// An intelligent, modern widget that parses question descriptions into structured,
/// beautifully styled summary cards (like KeywordSummaryPage) with topic icons,
/// key-value facts, numbered takeaway badges, and LaTeX math support.
class SmartExplanationCard extends StatefulWidget {
  final String description;
  final String? category;
  final String? keyword;
  final bool initiallyExpanded;

  const SmartExplanationCard({
    super.key,
    required this.description,
    this.category,
    this.keyword,
    this.initiallyExpanded = true,
  });

  @override
  State<SmartExplanationCard> createState() => _SmartExplanationCardState();
}

class _SmartExplanationCardState extends State<SmartExplanationCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  static const Color _textDark = Color(0xFF0D3320);
  static const Color _textMid = Color(0xFF4D7A5E);

  @override
  Widget build(BuildContext context) {
    final cleanDesc = widget.description.trim();
    if (cleanDesc.isEmpty || cleanDesc.toLowerCase() == "null") {
      return const SizedBox.shrink();
    }

    final String topicTitle = (widget.category != null && widget.category!.trim().isNotEmpty)
        ? widget.category!.trim()
        : (widget.keyword != null && widget.keyword!.trim().isNotEmpty
            ? widget.keyword!.trim()
            : "വിശദീകരണം (Explanation)");

    final List<SummaryCardModel> cards = _parseSmartDescription(cleanDesc, defaultTitle: topicTitle);

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards.map((card) => _buildCardWidget(card)).toList(),
    );
  }

  Widget _buildCardWidget(SummaryCardModel card) {
    final accentColor = card.accentColor;
    final int itemCount = card.items.length;
    final isSingleFact = itemCount <= 1;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
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
          // ── Header (Tap to toggle collapse) ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: _isExpanded
                  ? const BorderRadius.vertical(top: Radius.circular(16))
                  : BorderRadius.circular(16),
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.08),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: _isExpanded
                      ? const BorderRadius.vertical(top: Radius.circular(16))
                      : BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(card.icon, color: accentColor, size: 16),
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
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isSingleFact ? "Key Fact" : "$itemCount Points",
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Smart Summary",
                                style: const TextStyle(
                                  color: _textMid,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      color: accentColor,
                      tooltip: "Copy explanation",
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: card.toShareText()));
                        Get.snackbar(
                          "Copied",
                          "Explanation copied to clipboard",
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                          backgroundColor: _textDark,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ──
          if (_isExpanded) ...[
            Divider(height: 1, color: accentColor.withValues(alpha: 0.15)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: isSingleFact
                  ? _buildSingleFactView(card.items.first, accentColor)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < card.items.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10),
                          _buildItemRow(card.items[i], i, accentColor),
                        ],
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleFactView(SummaryItem item, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 10),
            child: Icon(Icons.lightbulb_rounded, color: accentColor, size: 18),
          ),
          Expanded(
            child: item.hasValue
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MathText(
                        text: item.label,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      MathText(
                        text: item.value!,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                    ],
                  )
                : MathText(
                    text: item.rawText,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(SummaryItem item, int index, Color accentColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number / Bullet Badge
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
            "${index + 1}",
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
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MathText(
                      text: item.label,
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 2),
                    MathText(
                      text: item.value!,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ],
                )
              : MathText(
                  text: item.rawText,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
        ),
      ],
    );
  }

  /// Intelligently parses any description string into structured SummaryCardModels
  static List<SummaryCardModel> _parseSmartDescription(String text, {required String defaultTitle}) {
    // 1. If explicit # header blocks exist, use SummaryCardModel.parse
    if (text.contains('#')) {
      final cards = SummaryCardModel.parse(text);
      if (cards.isNotEmpty) return cards;
    }

    // 2. Split lines by newlines, bullets, or semicolons
    final rawLines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final List<SummaryItem> kvItems = [];
    bool hasAnyKeyValue = false;

    for (var line in rawLines) {
      String cleanLine = line;
      // Strip common bullet prefixes
      if (cleanLine.startsWith('•') || cleanLine.startsWith('-') || cleanLine.startsWith('*')) {
        cleanLine = cleanLine.substring(1).trim();
      } else if (RegExp(r'^\d+[\.\)]\s*').hasMatch(cleanLine)) {
        cleanLine = cleanLine.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '').trim();
      }

      if (cleanLine.contains(' - ')) {
        final idx = cleanLine.indexOf(' - ');
        kvItems.add(SummaryItem(
          label: cleanLine.substring(0, idx).trim(),
          value: cleanLine.substring(idx + 3).trim(),
          rawText: cleanLine,
        ));
        hasAnyKeyValue = true;
      } else if (cleanLine.contains(' : ')) {
        final idx = cleanLine.indexOf(' : ');
        kvItems.add(SummaryItem(
          label: cleanLine.substring(0, idx).trim(),
          value: cleanLine.substring(idx + 3).trim(),
          rawText: cleanLine,
        ));
        hasAnyKeyValue = true;
      } else if (cleanLine.contains(' — ')) {
        final idx = cleanLine.indexOf(' — ');
        kvItems.add(SummaryItem(
          label: cleanLine.substring(0, idx).trim(),
          value: cleanLine.substring(idx + 3).trim(),
          rawText: cleanLine,
        ));
        hasAnyKeyValue = true;
      } else if (cleanLine.isNotEmpty) {
        kvItems.add(SummaryItem(
          label: cleanLine,
          value: null,
          rawText: cleanLine,
        ));
      }
    }

    // If multi-line or has key-value items
    if (rawLines.length > 1 || hasAnyKeyValue) {
      return [
        SummaryCardModel(
          title: defaultTitle,
          items: kvItems,
          rawBlock: text,
        ),
      ];
    }

    // 3. For narrative paragraphs, split on sentence endings
    final sentences = _splitSentences(text);
    if (sentences.length > 1) {
      final items = sentences
          .map((s) => SummaryItem(label: s, value: null, rawText: s))
          .toList();
      return [
        SummaryCardModel(
          title: defaultTitle,
          items: items,
          rawBlock: text,
        ),
      ];
    }

    // 4. Single sentence or short statement: single highlight item
    return [
      SummaryCardModel(
        title: defaultTitle,
        items: [
          SummaryItem(label: text.trim(), value: null, rawText: text.trim()),
        ],
        rawBlock: text,
      ),
    ];
  }

  /// Splits sentences cleanly while respecting Malayalam text and punctuation
  static List<String> _splitSentences(String text) {
    final List<String> result = [];
    final rawParts = text.split(RegExp(r'\n+'));

    for (final part in rawParts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;

      // Split on sentence boundaries: dot followed by space/end, or exclamation/question mark
      final pieces = trimmed.split(RegExp(r'(?<=[^\d\w][\.\?!])\s+|(?<=[a-zA-Z\u0D00-\u0D7F]{2,}[\.\?!])\s+'));
      for (var s in pieces) {
        s = s.trim();
        if (s.isNotEmpty) {
          result.add(s);
        }
      }
    }
    return result.isNotEmpty ? result : [text.trim()];
  }
}
