import 'package:flutter/material.dart';
import 'auth_controller.dart';

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
                  padding: const EdgeInsets.symmetric(vertical: 24),
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
