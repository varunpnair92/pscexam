import 'package:flutter/material.dart';
import 'auth_controller.dart';
import 'math_formula.dart';
import 'smart_explanation_card.dart';

class ModernStudyCard extends StatefulWidget {
  final Map<String, dynamic> q;
  final int index;

  const ModernStudyCard({super.key, required this.q, required this.index});

  @override
  State<ModernStudyCard> createState() => _ModernStudyCardState();
}

class _ModernStudyCardState extends State<ModernStudyCard> {
  bool isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final answer = (widget.q["answer"] ?? "").toString().trim();
    final note = (widget.q["note"] ?? widget.q["notes"] ?? widget.q["description"] ?? "").toString().trim();

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
                  child: MathText(
                    text: widget.q["question"] ?? "",
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
                onTap: () {
                  final auth = AuthController.instance;
                  if (!auth.canAccess(widget.q)) {
                    auth.showPremiumAlert();
                    return;
                  }
                  setState(() => isRevealed = true);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        AuthController.instance.canAccess(widget.q) 
                          ? Icons.visibility_rounded 
                          : Icons.lock_rounded, 
                        color: Colors.grey.shade500, 
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AuthController.instance.canAccess(widget.q)
                          ? "Tap to Reveal Answer"
                          : "Premium Required",
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ശരിയായ ഉത്തരം (Correct Answer)",
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              MathText(
                                text: answer,
                                style: const TextStyle(
                                  color: Color(0xFF14532D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Note (Classified Point-by-Point Learning Mode) ──
                  if (note.isNotEmpty && note.toLowerCase() != "null") ...[
                    const SizedBox(height: 10),
                    SmartExplanationCard(
                      description: note,
                      category: widget.q["category"]?.toString(),
                      keyword: widget.q["keyword"]?.toString() ?? widget.q["master_keyword"]?.toString(),
                      title: "Note",
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
