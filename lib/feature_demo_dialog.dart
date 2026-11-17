import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'feature_demo_model.dart';
import 'feature_demo_controller.dart';

class FeatureDemoDialog extends StatefulWidget {
  final List<FeatureDemoModel> demoItems;

  const FeatureDemoDialog({super.key, required this.demoItems});

  static void show(List<FeatureDemoModel> items) {
    if (items.isEmpty) return;
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      FeatureDemoDialog(demoItems: items),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
    );
  }

  @override
  State<FeatureDemoDialog> createState() => _FeatureDemoDialogState();
}

class _FeatureDemoDialogState extends State<FeatureDemoDialog> {
  late PageController _pageCtrl;
  int _currentIndex = 0;

  static const _textDark = Color(0xFF0D3320);

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < widget.demoItems.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  void _onPrev() {
    if (_currentIndex > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  void _tryFeature(FeatureDemoModel item) {
    FeatureDemoController.navigateFromDemo(item);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == widget.demoItems.length - 1;
    final currentItem = widget.demoItems[_currentIndex];
    final gradient = currentItem.gradientColors;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          constraints: const BoxConstraints(maxWidth: 390, maxHeight: 540),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              children: [
                // ── Top Header Bar ──
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradient.first.withValues(alpha: 0.08),
                        Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: gradient.first.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 14, color: gradient.first),
                            const SizedBox(width: 5),
                            Text(
                              "ആപ്പ് ഫീച്ചർ ഡെമോ • Tour",
                              style: TextStyle(
                                color: gradient.first,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Step Indicator
                      Text(
                        "${_currentIndex + 1} / ${widget.demoItems.length}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                        splashRadius: 18,
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),

                // ── Progress Dots ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: List.generate(widget.demoItems.length, (i) {
                      final active = i == _currentIndex;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: BoxDecoration(
                            color: active ? gradient.first : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // ── Carousel Content ──
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.demoItems.length,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemBuilder: (context, index) {
                      final item = widget.demoItems[index];
                      final itemGradient = item.gradientColors;

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Feature Icon Container
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: itemGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: itemGradient.first.withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                item.iconData,
                                size: 38,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Feature Name
                            Text(
                              item.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _textDark,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Feature Description
                            Text(
                              item.fallbackDescription,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13.8,
                                height: 1.55,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            // Keywords / Sample Tags if available
                            if (item.keywords.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                alignment: WrapAlignment.center,
                                children: item.keywords.take(4).map((kw) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                    decoration: BoxDecoration(
                                      color: itemGradient.first.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: itemGradient.first.withValues(alpha: 0.18),
                                      ),
                                    ),
                                    child: Text(
                                      kw,
                                      style: TextStyle(
                                        color: itemGradient.first,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const Divider(height: 1, thickness: 0.8),

                // ── Bottom Action Buttons ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (_currentIndex > 0) ...[
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey),
                              tooltip: "Previous",
                              onPressed: _onPrev,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _tryFeature(currentItem),
                              icon: Icon(Icons.play_arrow_rounded, color: gradient.first, size: 18),
                              label: Text(
                                "ഇപ്പോൾ കാണുക (Try Now)",
                                style: TextStyle(
                                  color: gradient.first,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: gradient.first),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _onNext,
                              icon: Icon(
                                isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                              label: Text(
                                isLast ? "തുടങ്ങാം (Start)" : "അടുത്തത് (Next)",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gradient.first,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "ഡെമോ ഒഴിവാക്കുക (Skip Demo)",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
