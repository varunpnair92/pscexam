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
        onTap: () => ctrl.navigateAttemptCategory(ctrl.liveExamsNode),
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

  Widget _buildFixedGrid(List items, BuildContext context) {
    final totalCount = items.length + (ctrl.liveExamsNode.isNotEmpty ? 1 : 0);
    final cardGradients = UIUtils.getPremiumGradients();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: totalCount,
      itemBuilder: (_, i) {
        if (ctrl.liveExamsNode.isNotEmpty && i == 0) {
          return GestureDetector(
            onTap: () => ctrl.navigateAttemptCategory(ctrl.liveExamsNode),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE1306C), Color(0xFFF77737)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(14),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.stream_rounded, color: Colors.white, size: 24),
                  Spacer(),
                  Text("Live Exams", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          );
        }
        final actualIndex = ctrl.liveExamsNode.isNotEmpty ? i - 1 : i;
        final item = items[actualIndex];
        final name = item['name'] ?? '';
        final grad = cardGradients[i % cardGradients.length];
        final icon = UIUtils.getIconForName(name);

        return GestureDetector(
          onTap: () => ctrl.navigateAttemptCategory(item),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: grad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const Spacer(),
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = ctrl.boosterTopics;
      if (items.isEmpty && ctrl.liveExamsNode.isEmpty) return const SizedBox.shrink();

      final String orient = ctrl.boosterOrientation.value.toLowerCase().trim();
      final bool isFixed = orient == 'fixed';
      final bool isCollapse = orient == 'collapse';

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.only(top: 14, bottom: isCollapse ? 2 : 12),
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
              if (ctrl.boosterSectionName.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ctrl.boosterSectionName.value.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B8A4E),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              if (isFixed)
                _buildFixedGrid(items, context)
              else if (isCollapse) ...[
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
              ] else ...[
                // 'horizontal' orientation: Horizontal scrolling list ONLY, no toggle arrow
                _buildHorizontalList(items, context),
              ],
            ],
          ),
        ),
      );
    });
  }
}
