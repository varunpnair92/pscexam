import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'knowledge_capsule_controller.dart';

class KnowledgeCapsuleOverlay extends StatelessWidget {
  final KnowledgeCapsuleController controller = Get.put(KnowledgeCapsuleController());

  // ─── Palette ───
  static const _green1 = Color(0xFF1B8A4E);
  static const _green2 = Color(0xFF27AE60);
  static const _gold = Color(0xFFFFD700);
  static const _textDark = Color(0xFF0D3320);

  KnowledgeCapsuleOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 1200),
        curve: Curves.elasticOut,
        top: controller.isVisible.value ? 60 : -400, // Drop from top
        left: 20,
        right: 20,
        child: IgnorePointer(
          ignoring: !controller.isVisible.value,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: controller.isVisible.value ? 1 : 0,
            child: _buildCapsule(),
          ),
        ),
      );
    });
  }

  Widget _buildCapsule() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
              gradient: LinearGradient(
                colors: [
                  _green1.withOpacity(0.08),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─── Icon & Header ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _green1.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: _green1,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "PSC Capsule",
                      style: TextStyle(
                        color: _green1,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // ─── The Fact ───
                Text(
                  controller.currentFact.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Buttons ───
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => controller.dismiss(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Dismiss",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.dismiss(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green1,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Got it!",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
