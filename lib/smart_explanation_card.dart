import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'math_formula.dart';
import 'summary_card_model.dart';

/// FastFact represents a structured key-value fact item (e.g. "രചയിതാവ് : അതുലൻ")
class FastFact {
  final String label;
  final String value;
  final String rawText;

  const FastFact({
    required this.label,
    required this.value,
    required this.rawText,
  });
}

/// StudyPoint represents a standalone narrative revision point / exam takeaway
class StudyPoint {
  final String text;

  const StudyPoint({required this.text});
}

/// ClassifiedNotes holds structured, categorized revision data for students
class ClassifiedNotes {
  final String? coreFact;
  final List<FastFact> fastFacts;
  final List<StudyPoint> studyPoints;
  final String topicTitle;

  const ClassifiedNotes({
    this.coreFact,
    required this.fastFacts,
    required this.studyPoints,
    required this.topicTitle,
  });

  int get totalPointsCount =>
      (coreFact != null ? 1 : 0) + fastFacts.length + studyPoints.length;

  bool get isEmpty =>
      coreFact == null && fastFacts.isEmpty && studyPoints.isEmpty;
}

/// SmartExplanationCard
/// An attractive, immersive, point-by-point Study Notes widget for students.
/// Classifies question descriptions into:
///  1. 🎯 Core Fact / പ്രധാന വസ്തുത (Highlight Spotlight)
///  2. ⚡ Fast Facts / ഫാക്ട് ഫയൽ (Key-Value Facts)
///  3. 💡 Study Points / ഓർക്കേണ്ട കാര്യങ്ങൾ (Numbered Exam Points)
/// Supports full LaTeX math formulas, topic theme matching, and one-tap copy.
class SmartExplanationCard extends StatefulWidget {
  final String description;
  final String? category;
  final String? keyword;
  final bool initiallyExpanded;
  final String? title;

  const SmartExplanationCard({
    super.key,
    required this.description,
    this.category,
    this.keyword,
    this.initiallyExpanded = true,
    this.title,
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

  static const Color _textDark = Color(0xFF0F2419);
  static const Color _textMid = Color(0xFF335C45);

  @override
  Widget build(BuildContext context) {
    final cleanDesc = widget.description.trim();
    if (cleanDesc.isEmpty || cleanDesc.toLowerCase() == "null") {
      return const SizedBox.shrink();
    }

    // Determine topic title and theme
    final String topic = (widget.category != null && widget.category!.trim().isNotEmpty)
        ? widget.category!.trim()
        : (widget.keyword != null && widget.keyword!.trim().isNotEmpty
            ? widget.keyword!.trim()
            : "ജനറൽ നോളജ്");

    final Color accentColor = _getTopicColor(widget.category, widget.keyword);
    final IconData topicIcon = _getTopicIcon(widget.category, widget.keyword);

    // If explicit # Header # blocks exist, render multi-card header mode
    if (cleanDesc.contains('#')) {
      final cards = SummaryCardModel.parse(cleanDesc);
      if (cards.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cards.map((c) => _buildLegacyCardWidget(c)).toList(),
        );
      }
    }

    final ClassifiedNotes notes = _classifyDescription(cleanDesc, topicTitle: topic);
    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }

    final int pointsCount = notes.totalPointsCount;
    final bool isSingleFact = notes.coreFact != null && notes.fastFacts.isEmpty && notes.studyPoints.isEmpty;

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Bar (Tap to expand / collapse) ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: _isExpanded
                  ? const BorderRadius.vertical(top: Radius.circular(16))
                  : BorderRadius.circular(16),
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.09),
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
                    // Book / Topic Icon Badge
                    Container(
                      padding: const EdgeInsets.all(7.5),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(topicIcon, color: accentColor, size: 17),
                    ),
                    const SizedBox(width: 10),

                    // Title & Badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.title ?? "Study Notes",
                                style: const TextStyle(
                                  color: _textDark,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Topic Pill
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    topic,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  isSingleFact ? "🎯 Core Fact" : "⚡ $pointsCount Points",
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                "പഠന കുറിപ്പുകൾ",
                                style: TextStyle(
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

                    // Copy Notes Button
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      color: accentColor,
                      tooltip: "Copy study notes",
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: _toShareText(notes, topic),
                        ));
                        Get.snackbar(
                          "Notes Copied",
                          "Study notes copied to clipboard",
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                          backgroundColor: _textDark,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                          icon: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                        );
                      },
                    ),

                    // Expand / Collapse Icon
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

          // ── Classified Notes Body ──
          if (_isExpanded) ...[
            Divider(height: 1, color: accentColor.withValues(alpha: 0.14)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Core Fact Spotlight (if present)
                  if (notes.coreFact != null) ...[
                    _buildCoreFactCard(notes.coreFact!, accentColor, isSingleOnly: isSingleFact),
                  ],

                  // 2. Fast Facts File (Key-Value items)
                  if (notes.fastFacts.isNotEmpty) ...[
                    if (notes.coreFact != null) const SizedBox(height: 12),
                    _buildFastFactsSection(notes.fastFacts, accentColor),
                  ],

                  // 3. Point-by-Point Revision Notes
                  if (notes.studyPoints.isNotEmpty) ...[
                    if (notes.coreFact != null || notes.fastFacts.isNotEmpty)
                      const SizedBox(height: 12),
                    _buildStudyPointsSection(notes.studyPoints, accentColor),
                  ],

                  // Micro encouragement footer
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.school_outlined, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Text(
                        "ക്വിക്ക് റിവിഷൻ • Quick Exam Revision",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 🎯 Core Fact Spotlight Card
  Widget _buildCoreFactCard(String text, Color accentColor, {required bool isSingleOnly}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.20),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars_rounded, color: accentColor, size: 15),
              const SizedBox(width: 6),
              Text(
                "പ്രധാന വസ്തുത (Key Fact)",
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          MathText(
            text: text,
            style: const TextStyle(
              color: _textDark,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// ⚡ Fast Facts Section (Key-Value Facts Grid / Strip)
  Widget _buildFastFactsSection(List<FastFact> facts, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bolt_rounded, color: accentColor, size: 15),
            const SizedBox(width: 6),
            const Text(
              "ഫാക്ട് ഫയൽ (Key Facts)",
              style: TextStyle(
                color: _textMid,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        for (int i = 0; i < facts.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor.withValues(alpha: 0.20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facts[i].label,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "•",
                  style: TextStyle(
                    color: accentColor.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MathText(
                    text: facts[i].value,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 💡 Study Points Section (Numbered Point-by-Point Revision Cards)
  Widget _buildStudyPointsSection(List<StudyPoint> points, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: accentColor, size: 15),
            const SizedBox(width: 6),
            const Text(
              "പഠന പോയിന്റുകൾ (Study Points)",
              style: TextStyle(
                color: _textMid,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        for (int i = 0; i < points.length; i++) ...[
          if (i > 0) const SizedBox(height: 7),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFDFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number Capsule Badge
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 1, right: 10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${i + 1}",
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Text
                Expanded(
                  child: MathText(
                    text: points[i].text,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Builds a legacy card when `# Header #` syntax is explicitly detected
  Widget _buildLegacyCardWidget(SummaryCardModel card) {
    final accentColor = card.accentColor;
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(card.icon, color: accentColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.cleanTitle,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < card.items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 2, right: 8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "${i + 1}",
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: MathText(
                          text: card.items[i].hasValue
                              ? "${card.items[i].label}: ${card.items[i].value}"
                              : card.items[i].rawText,
                          style: const TextStyle(
                            color: _textDark,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Classifies description text into Core Fact, Fast Facts, and Study Points
  static ClassifiedNotes _classifyDescription(String rawText, {required String topicTitle}) {
    final text = rawText.trim();
    final List<FastFact> fastFacts = [];
    final List<StudyPoint> studyPoints = [];
    String? coreFact;

    // Split into non-empty lines
    final rawLines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final List<String> narrativeLines = [];

    for (var line in rawLines) {
      String clean = line;
      // Strip bullet symbols
      if (clean.startsWith('•') || clean.startsWith('-') || clean.startsWith('*')) {
        clean = clean.substring(1).trim();
      } else if (RegExp(r'^\d+[\.\)]\s*').hasMatch(clean)) {
        clean = clean.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '').trim();
      }

      // Check key-value delimiter
      String? delim;
      if (clean.contains(' - ')) {
        delim = ' - ';
      } else if (clean.contains(' : ')) {
        delim = ' : ';
      } else if (clean.contains(' — ')) {
        delim = ' — ';
      } else if (clean.contains(': ') && !clean.startsWith('http')) {
        delim = ': ';
      }

      if (delim != null) {
        final idx = clean.indexOf(delim);
        final key = clean.substring(0, idx).trim();
        final val = clean.substring(idx + delim.length).trim();
        if (key.isNotEmpty && val.isNotEmpty && key.length < 50) {
          fastFacts.add(FastFact(label: key, value: val, rawText: clean));
          continue;
        }
      }

      narrativeLines.add(clean);
    }

    // Process narrative lines into sentences
    final List<String> allSentences = [];
    for (var line in narrativeLines) {
      final sentences = _splitSentences(line);
      allSentences.addAll(sentences);
    }

    if (allSentences.length == 1 && fastFacts.isEmpty) {
      coreFact = allSentences.first;
    } else if (allSentences.isNotEmpty) {
      coreFact = allSentences.first;
      for (int i = 1; i < allSentences.length; i++) {
        studyPoints.add(StudyPoint(text: allSentences[i]));
      }
    }

    return ClassifiedNotes(
      coreFact: coreFact,
      fastFacts: fastFacts,
      studyPoints: studyPoints,
      topicTitle: topicTitle,
    );
  }

  /// Splits sentences cleanly without breaking on Malayalam & English honorifics
  static List<String> _splitSentences(String text) {
    final List<String> result = [];
    // Protect common Malayalam & English honorifics with placeholders
    String protected = text
        .replaceAll('ഡോ.', 'ഡോ__DOT__')
        .replaceAll('ശ്രീ.', 'ശ്രീ__DOT__')
        .replaceAll('പ്രൊഫ.', 'പ്രൊഫ__DOT__')
        .replaceAll('മി.', 'മി__DOT__')
        .replaceAll('മിസ്.', 'മിസ്__DOT__')
        .replaceAll('Dr.', 'Dr__DOT__')
        .replaceAll('Mr.', 'Mr__DOT__')
        .replaceAll('Mrs.', 'Mrs__DOT__')
        .replaceAll('Prof.', 'Prof__DOT__')
        .replaceAll('e.g.', 'e__DOT__g__DOT__')
        .replaceAll('i.e.', 'i__DOT__e__DOT__');

    final pieces = protected.split(RegExp(r'(?<=[\.\?!])\s+'));
    for (var s in pieces) {
      var restored = s
          .replaceAll('ഡോ__DOT__', 'ഡോ.')
          .replaceAll('ശ്രീ__DOT__', 'ശ്രീ.')
          .replaceAll('പ്രൊഫ__DOT__', 'പ്രൊഫ.')
          .replaceAll('മി__DOT__', 'മി.')
          .replaceAll('മിസ്__DOT__', 'മിസ്.')
          .replaceAll('Dr__DOT__', 'Dr.')
          .replaceAll('Mr__DOT__', 'Mr.')
          .replaceAll('Mrs__DOT__', 'Mrs.')
          .replaceAll('Prof__DOT__', 'Prof.')
          .replaceAll('e__DOT__g__DOT__', 'e.g.')
          .replaceAll('i__DOT__e__DOT__', 'i.e.')
          .trim();
      if (restored.isNotEmpty) {
        result.add(restored);
      }
    }
    return result.isNotEmpty ? result : [text.trim()];
  }

  /// Formats all notes for clean clipboard sharing
  static String _toShareText(ClassifiedNotes notes, String topic) {
    final buffer = StringBuffer();
    buffer.writeln("📝 $topic • Study Notes");
    buffer.writeln("─────────────────────────");
    if (notes.coreFact != null) {
      buffer.writeln("🎯 പ്രധാന വസ്തുത:");
      buffer.writeln("• ${notes.coreFact}");
      buffer.writeln();
    }
    if (notes.fastFacts.isNotEmpty) {
      buffer.writeln("📌 ഫാക്ട് ഫയൽ (Key Facts):");
      for (final f in notes.fastFacts) {
        buffer.writeln("• ${f.label}: ${f.value}");
      }
      buffer.writeln();
    }
    if (notes.studyPoints.isNotEmpty) {
      buffer.writeln("💡 പഠന പോയിന്റുകൾ (Study Points):");
      for (int i = 0; i < notes.studyPoints.length; i++) {
        buffer.writeln("${i + 1}. ${notes.studyPoints[i].text}");
      }
    }
    return buffer.toString().trim();
  }

  static Color _getTopicColor(String? category, String? keyword) {
    final text = "${category ?? ''} ${keyword ?? ''}".toLowerCase();
    if (text.contains('ചരിത്രം') || text.contains('history')) {
      return const Color(0xFFB45309); // Amber / Bronze
    } else if (text.contains('ഭൂമിശാസ്ത്രം') || text.contains('geography') || text.contains('നദി') || text.contains('ജില്ല')) {
      return const Color(0xFF0284C7); // Sky / Blue
    } else if (text.contains('ഭരണഘടന') || text.contains('രാഷ്ട്രീയം') || text.contains('politics') || text.contains('constitution')) {
      return const Color(0xFF4F46E5); // Indigo
    } else if (text.contains('ശാസ്ത്രം') || text.contains('science') || text.contains('ജീവശാസ്ത്രം') || text.contains('ഫിസിക്സ്') || text.contains('കെമിസ്ട്രി')) {
      return const Color(0xFF059669); // Emerald
    } else if (text.contains('സാഹിത്യം') || text.contains('literature') || text.contains('മലയാളം') || text.contains('കൃതി')) {
      return const Color(0xFF7C3AED); // Purple
    } else if (text.contains('കറന്റ്') || text.contains('current') || text.contains('സമകാലികം')) {
      return const Color(0xFFE11D48); // Rose / Red
    } else if (text.contains('കായിക') || text.contains('sports')) {
      return const Color(0xFFEA580C); // Orange
    } else if (text.contains('ഗണിതം') || text.contains('maths') || text.contains('റീസണിംഗ്')) {
      return const Color(0xFFD97706); // Warm Amber
    } else if (text.contains('സിനിമ') || text.contains('കല') || text.contains('cinema')) {
      return const Color(0xFFDB2777); // Pink
    }
    return const Color(0xFF0F766E); // Deep Teal / Marine
  }

  static IconData _getTopicIcon(String? category, String? keyword) {
    final text = "${category ?? ''} ${keyword ?? ''}".toLowerCase();
    if (text.contains('ചരിത്രം') || text.contains('history')) {
      return Icons.history_edu_rounded;
    } else if (text.contains('ഭൂമിശാസ്ത്രം') || text.contains('geography') || text.contains('നദി') || text.contains('ജില്ല')) {
      return Icons.public_rounded;
    } else if (text.contains('ഭരണഘടന') || text.contains('രാഷ്ട്രീയം') || text.contains('politics') || text.contains('constitution')) {
      return Icons.account_balance_rounded;
    } else if (text.contains('ശാസ്ത്രം') || text.contains('science') || text.contains('ജീവശാസ്ത്രം') || text.contains('ഫിസിക്സ്') || text.contains('കെമിസ്ട്രി')) {
      return Icons.biotech_rounded;
    } else if (text.contains('സാഹിത്യം') || text.contains('literature') || text.contains('മലയാളം') || text.contains('കൃതി')) {
      return Icons.menu_book_rounded;
    } else if (text.contains('കറന്റ്') || text.contains('current') || text.contains('സമകാലികം')) {
      return Icons.newspaper_rounded;
    } else if (text.contains('കായിക') || text.contains('sports')) {
      return Icons.sports_soccer_rounded;
    } else if (text.contains('ഗണിതം') || text.contains('maths') || text.contains('റീസണിംഗ്')) {
      return Icons.calculate_rounded;
    } else if (text.contains('സിനിമ') || text.contains('കല') || text.contains('cinema')) {
      return Icons.movie_creation_outlined;
    }
    return Icons.auto_stories_rounded;
  }
}
