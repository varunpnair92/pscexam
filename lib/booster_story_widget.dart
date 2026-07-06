import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'ui_utils.dart';
import 'dart:math' as math;

class BoosterStoryWidget extends StatefulWidget {
  const BoosterStoryWidget({super.key});

  @override
  State<BoosterStoryWidget> createState() => _BoosterStoryWidgetState();
}

class _BoosterStoryWidgetState extends State<BoosterStoryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final HomeController ctrl = Get.find<HomeController>();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildStoryItem(List items, int index, BuildContext context) {
    if (ctrl.liveExamsNode.isNotEmpty && index == 0) {
      return GestureDetector(
        onTap: () => ctrl.navigateAttemptCategory(ctrl.liveExamsNode.value),
        child: SizedBox(
          width: 76,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animationController.value * 2 * math.pi,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Color(0xFFE1306C),
                                Color(0xFFF77737),
                                Color(0xFFFCAF45),
                                Color(0xFFE1306C),
                              ],
                              stops: [0.0, 0.33, 0.66, 1.0],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.stream_rounded,
                      size: 24,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 66,
                child: Text(
                  "Live Exams",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final actualIndex = ctrl.liveExamsNode.isNotEmpty ? index - 1 : index;
    final item = items[actualIndex];
    final name = item['name'] ?? '';
    final icon = UIUtils.getIconForName(name);

    return GestureDetector(
      onTap: () => ctrl.navigateAttemptCategory(item),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animationController.value * 2 * math.pi,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Color(0xFFE1306C),
                              Color(0xFFF77737),
                              Color(0xFFFCAF45),
                              Color(0xFFE1306C),
                            ],
                            stops: [0.0, 0.33, 0.66, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: const Color(0xFF1B8A4E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 66,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D3320),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List items, BuildContext context) {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length + (ctrl.liveExamsNode.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          return _buildStoryItem(items, index, context);
        },
      ),
    );
  }

  Widget _buildExpandedGrid(List items, BuildContext context) {
    final totalCount = items.length + (ctrl.liveExamsNode.isNotEmpty ? 1 : 0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        spacing: 0,
        runSpacing: 16,
        alignment: WrapAlignment.start,
        children: List.generate(totalCount, (index) {
          return _buildStoryItem(items, index, context);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = ctrl.boosterTopics;
      if (items.isEmpty && ctrl.liveExamsNode.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.only(top: 14, bottom: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF1B8A4E).withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B8A4E).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isExpanded
                  ? _buildExpandedGrid(items, context)
                  : _buildHorizontalList(items, context),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
