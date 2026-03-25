import 'package:flutter/material.dart';

class ModernStudyCard extends StatefulWidget {
  final Map<String, dynamic> q;
  final int index;

  const ModernStudyCard({super.key, required this.q, required this.index});

  @override
  State<ModernStudyCard> createState() => _ModernStudyCardState();
}

class _ModernStudyCardState extends State<ModernStudyCard> {
  bool isRevealed = false;

  List<String> _getOptions() {
    final q = widget.q;
    if (q["options"] != null && q["options"] is List && q["options"].isNotEmpty) {
      return List<String>.from(q["options"]);
    }
    List<String> opts = [];
    for (int i = 1; i <= 4; i++) {
      if (q["option$i"] != null && q["option$i"].toString().trim().isNotEmpty) {
        opts.add(q["option$i"].toString().trim());
      }
    }
    return opts;
  }

  @override
  Widget build(BuildContext context) {
    final opts = _getOptions();
    final answer = (widget.q["answer"] ?? "").toString().trim();
    final description = (widget.q["description"] ?? "").toString().trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Q${widget.index + 1}",
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.q["question"] ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tap to Reveal OR Revealed Content
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: isRevealed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: GestureDetector(
                onTap: () => setState(() => isRevealed = true),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.visibility_rounded, color: Colors.grey.shade500, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        "Tap to Reveal Answer",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show Options if present
                  if (opts.isNotEmpty) ...opts.map((opt) {
                    bool isCorrect = opt.trim().toLowerCase() == answer.toLowerCase();
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green.shade50 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCorrect ? Colors.green.shade400 : Colors.grey.shade200,
                          width: isCorrect ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              opt,
                              style: TextStyle(
                                color: isCorrect ? Colors.green.shade900 : Colors.black87,
                                fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (isCorrect)
                            const Icon(Icons.check_circle_rounded, color: Colors.green),
                        ],
                      ),
                    );
                  }) else 
                  // Just show the answer if no options
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.shade400, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            answer,
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Option Explanation (if exists)
                  if (description.isNotEmpty && description.toLowerCase() != "null") ...[
                    const SizedBox(height: 12),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                        childrenPadding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                        iconColor: Colors.blue.shade600,
                        collapsedIconColor: Colors.grey.shade600,
                        title: Row(
                          children: [
                            Icon(Icons.lightbulb_outline_rounded, color: Colors.blue.shade500, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Explanation",
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Text(
                              description,
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                height: 1.5,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
