import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exam_create_controller.dart';
import 'app_theme.dart';

class ExamCreatePage extends StatelessWidget {
  const ExamCreatePage({super.key});

  static const Color _green1 = Color(0xFF1B8A4E);
  static const Color _green2 = Color(0xFF27AE60);
  static const Color _green3 = Color(0xFF52C97A);
  static const Color _textDark = Color(0xFF0D3320);

  @override
  Widget build(BuildContext context) {
    final ExamCreateController ctrl = Get.put(ExamCreateController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ─── IMMERSIVE BACKGROUND ───
          AppTheme.buildImmersiveBackground(context),

          SafeArea(
            child: Column(
              children: [
                // ─── CUSTOM APP BAR ───
                _buildAppBar(context, ctrl),

                // ─── MAIN CONTENT BODY ───
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. HERO BANNER
                        _buildHeroBanner(context),
                        const SizedBox(height: 24),

                        // 2. KEYWORD SEARCH SECTION
                        _buildKeywordSection(ctrl),
                        const SizedBox(height: 24),

                        // 3. QUESTION COUNT SECTION
                        _buildQuestionCountSection(ctrl),
                        const SizedBox(height: 32),

                        // 4. GENERATE EXAM BUTTON
                        _buildGenerateButton(ctrl),
                        const SizedBox(height: 24),

                        // 5. TIPS / HINTS CARD
                        _buildTipsCard(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ExamCreateController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Obx(
              () => Text(
                ctrl.pageTitle.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _green1, size: 22),
            tooltip: "Reset",
            onPressed: () {
              ctrl.keywordController.clear();
              ctrl.selectedCount.value = 10;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_green1, _green2, _green3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _green1.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 14),
                            SizedBox(width: 5),
                            Text(
                              "Instant Practice",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "AI Exam Generator",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Generate custom exams on any topic with your preferred question count.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.quiz_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordSection(ExamCreateController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.search_rounded, color: _green1, size: 20),
            SizedBox(width: 8),
            Text(
              "Topic or Keyword / വിഷയം",
              style: TextStyle(
                color: _textDark,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Text Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _green1.withOpacity(0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: ctrl.keywordController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => ctrl.generateExam(),
            style: const TextStyle(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: "Enter keyword (e.g. ഗാന്ധി, കേരളം, PSC)...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.edit_note_rounded, color: _green1, size: 24),
              suffixIcon: Obx(
                () => ctrl.currentKeyword.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Colors.grey, size: 20),
                        onPressed: () => ctrl.keywordController.clear(),
                      )
                    : const SizedBox.shrink(),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Suggested Keywords Header
        Row(
          children: [
            Icon(Icons.trending_up_rounded, color: Colors.grey.shade600, size: 16),
            const SizedBox(width: 6),
            Text(
              "Popular Topics:",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Suggested Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ctrl.suggestedKeywords.map((kw) {
            return Obx(() {
              final bool isSelected = ctrl.currentKeyword.value.trim() == kw;
              return InkWell(
                onTap: () => ctrl.selectKeyword(kw),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _green1 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _green1 : Colors.grey.shade300,
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _green1.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        kw,
                        style: TextStyle(
                          color: isSelected ? Colors.white : _textDark,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuestionCountSection(ExamCreateController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.format_list_numbered_rounded, color: _green1, size: 20),
            SizedBox(width: 8),
            Text(
              "Question Count / ചോദ്യങ്ങൾ",
              style: TextStyle(
                color: _textDark,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Quick Preset Chips
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ctrl.presetCounts.map((count) {
            return Obx(() {
              final bool isSelected = ctrl.selectedCount.value == count;
              return GestureDetector(
                onTap: () => ctrl.setCount(count),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? _green1 : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? _green1 : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _green1.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                            ),
                          ],
                  ),
                  child: Text(
                    "$count",
                    style: TextStyle(
                      color: isSelected ? Colors.white : _textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            });
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Interactive Stepper Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Stepper controls
              InkWell(
                onTap: ctrl.decrementCount,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(Icons.remove_rounded, color: _textDark, size: 22),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Obx(
                      () => Text(
                        "${ctrl.selectedCount.value}",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: _green1,
                        ),
                      ),
                    ),
                    Text(
                      "Questions",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: ctrl.incrementCount,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _green1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _green1.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.add_rounded, color: _green1, size: 22),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Estimated Duration Badge
        Obx(() {
          final int seconds = ctrl.selectedCount.value * 45;
          final int minutes = seconds ~/ 60;
          final int remSec = seconds % 60;
          String timeStr = "$minutes min";
          if (remSec > 0) timeStr += " $remSec sec";

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _green1.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: _green1, size: 16),
                const SizedBox(width: 6),
                Text(
                  "Estimated Time: $timeStr (45s / question)",
                  style: const TextStyle(
                    color: _green1,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGenerateButton(ExamCreateController ctrl) {
    return Obx(() {
      final bool loading = ctrl.isLoading.value;

      return SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: loading ? null : () => ctrl.generateExam(),
          style: ElevatedButton.styleFrom(
            backgroundColor: _green1,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: _green1.withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: loading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    ),
                    SizedBox(width: 14),
                    Text(
                      "Generating Exam...",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt_rounded, size: 22),
                    SizedBox(width: 10),
                    Text(
                      "Generate Exam / പരീക്ഷ തുടങ്ങുക",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
        ),
      );
    });
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb_outline_rounded, color: Colors.amber.shade900, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Exam Instructions",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "• Each question has 45 seconds.\n• You can review answers at the end of the test.\n• Negative marks apply per standard PSC criteria.",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
